#!/usr/bin/env bash

# 在 macOS 上本地构建并发布 Apple 产物：
#   - 签名使用本机钥匙串里的证书 + Xcode 里登录的开发者账号（不依赖 CI 的 ASC API Key 权限）
#   - 构建完成后可选上传 App Store Connect（TestFlight），这一步仍需要 ASC API Key
#   - 不经过 Downloader 平台：App Store 签名的 ipa/pkg 无法被用户直接下载安装
#
# 用法：
#   scripts/release-apple.sh [ios|macos|all] [--upload] [--output-dir DIR]
#                            [--channel appstore] [--skip-clean] [--dry-run]
#
# --upload 需要：
#   ASC_API_KEY_ID    App Store Connect API Key ID
#   ASC_ISSUER_ID     Issuer ID
#   ASC_API_KEY_PATH  .p8 路径；不填时依次查找
#                     ~/.appstoreconnect/private_keys/AuthKey_<ID>.p8、~/keys/AuthKey_<ID>.p8

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# 与 release.sh 保持一致：调用者的 cwd 可能是 scripts/ 之类的子目录。
cd "${PROJECT_ROOT}"

TARGETS=()
UPLOAD="false"
OUTPUT_DIR="dist"
CHANNEL="appstore"
SKIP_CLEAN="false"
DRY_RUN="false"

log() { printf '[apple] %s\n' "$*"; }
die() { printf '[apple] ERROR: %s\n' "$*" >&2; exit 1; }

usage() {
  sed -n '3,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while (($#)); do
  case "$1" in
    ios|macos) TARGETS+=("$1"); shift ;;
    all) TARGETS+=(ios macos); shift ;;
    --upload) UPLOAD="true"; shift ;;
    --output-dir) (($# >= 2)) || die "--output-dir requires a value"; OUTPUT_DIR="$2"; shift 2 ;;
    --channel) (($# >= 2)) || die "--channel requires a value"; CHANNEL="$2"; shift 2 ;;
    --skip-clean) SKIP_CLEAN="true"; shift ;;
    --dry-run) DRY_RUN="true"; shift ;;
    --help|-h) usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

((${#TARGETS[@]} > 0)) || TARGETS=(all)
# all 展开成两个目标，这里再展一次，避免下面重复写分支。
expanded=()
for target in "${TARGETS[@]}"; do
  if [[ "${target}" == "all" ]]; then expanded+=(ios macos); else expanded+=("${target}"); fi
done
TARGETS=("${expanded[@]}")

[[ "$(uname -s)" == "Darwin" ]] || die "Apple builds require macOS"
command -v flutter >/dev/null 2>&1 || die "flutter not found in PATH"
command -v xcodebuild >/dev/null 2>&1 || die "xcodebuild not found; install Xcode"

if ! output_abs="$(cd "${PROJECT_ROOT}" && mkdir -p "${OUTPUT_DIR}" && cd "${OUTPUT_DIR}" && pwd)"; then
  die "Could not create output dir: ${OUTPUT_DIR}"
fi
OUTPUT_DIR="${output_abs}"

# 本流程用钥匙串签名，先确认机器上确实有可分发的证书，否则 archive 成功但 export 会失败。
identities="$(security find-identity -v -p codesigning 2>/dev/null || true)"
if ! grep -q 'Apple Distribution' <<<"${identities}"; then
  die "钥匙串里没有 Apple Distribution 证书：Xcode → Settings → Accounts 登录开发者账号并下载证书后再试"
fi
log "签名证书：$(grep 'Apple Distribution' <<<"${identities}" | head -1 | sed 's/^ *[0-9]*) //')"
log "Xcode：$(xcodebuild -version | head -1)"

main_bundle_id() {
  sed -n 's/.*PRODUCT_BUNDLE_IDENTIFIER = \(com\.example\.[A-Za-z0-9.]*\);.*/\1/p' \
    "${PROJECT_ROOT}/$1/Runner.xcodeproj/project.pbxproj" |
    grep -vE '\.(RunnerTests|TodayCoursesWidget)$' | head -1
}

# 这个工程沿用了 Flutter 默认 Bundle ID，只有先在 ASC 注册 App ID 和 app 记录，
# 自动签名才能生成描述文件。这里只提示，不阻断构建。
verify_bundles=()
for target in "${TARGETS[@]}"; do
  bundle_id="$(main_bundle_id "${target}")"
  if [[ -n "${bundle_id}" ]]; then
    log "提示：${target} 的 Bundle ID 是占位值 ${bundle_id}，需确保 App ID 与 app 记录已在 ASC 注册"
    verify_bundles+=("${bundle_id}")
  fi
done

for target in "${TARGETS[@]}"; do
  log "构建 ${target}（本地签名）"
  args=(build "${target}" --local-signing --channel "${CHANNEL}" --output-dir "${OUTPUT_DIR}")
  [[ "${SKIP_CLEAN}" == "true" ]] && args+=(--skip-clean)
  [[ "${DRY_RUN}" == "true" ]] && args+=(--dry-run)
  bash "${SCRIPT_DIR}/release.sh" "${args[@]}"
done

if [[ "${UPLOAD}" != "true" ]]; then
  log "产物位于 ${OUTPUT_DIR}"
  log "上传 App Store Connect：scripts/release-apple.sh ${TARGETS[*]} --upload"
  exit 0
fi

[[ -n "${ASC_API_KEY_ID:-}" ]] || die "--upload requires ASC_API_KEY_ID"
[[ -n "${ASC_ISSUER_ID:-}" ]] || die "--upload requires ASC_ISSUER_ID"
if [[ -z "${ASC_API_KEY_PATH:-}" ]]; then
  for candidate in \
    "${HOME}/.appstoreconnect/private_keys/AuthKey_${ASC_API_KEY_ID}.p8" \
    "${HOME}/keys/AuthKey_${ASC_API_KEY_ID}.p8"; do
    if [[ -f "${candidate}" ]]; then ASC_API_KEY_PATH="${candidate}"; break; fi
  done
fi
[[ -n "${ASC_API_KEY_PATH:-}" && -f "${ASC_API_KEY_PATH}" ]] ||
  die "--upload requires ASC_API_KEY_PATH (or put the .p8 in ~/.appstoreconnect/private_keys)"

[[ "${DRY_RUN}" == "true" ]] || command -v xcrun >/dev/null 2>&1 || die "xcrun not found"

# 上传前先用同一把 Key 检查认证、签名资源权限和 app 记录：CI 上这次失败就是
# 因为 app 记录缺失直到 exportArchive 才暴露，本地提前几秒就能看到。
if [[ "${DRY_RUN}" != "true" && ${#verify_bundles[@]} -gt 0 ]]; then
  bash "${SCRIPT_DIR}/verify_asc_key.sh" "${verify_bundles[@]}"
fi

for target in "${TARGETS[@]}"; do
  args=(upload-asc "${target}" --output-dir "${OUTPUT_DIR}")
  [[ "${DRY_RUN}" == "true" ]] && args+=(--dry-run)
  bash "${SCRIPT_DIR}/release.sh" "${args[@]}"
done
log "完成：构建已上传 App Store Connect（还需在 ASC 侧提交审核）"
