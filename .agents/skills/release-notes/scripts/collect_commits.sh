#!/usr/bin/env bash
# 收集某一版本区间的提交，供 release-notes skill 整理更新日志。
# 这里只做确定性的取数工作：区间解析、提交列表、以及标题看不出类型的提交各自改了哪些文件。
#
# 用法：
#   collect_commits.sh                    # 最近 tag .. HEAD
#   collect_commits.sh 1.2.1              # 1.2.1 .. HEAD
#   collect_commits.sh 1.2.1 3f2d1d2      # 显式指定区间

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

current_version() {
  sed -n 's/^version:[[:space:]]*\([^+[:space:]]*\).*/\1/p' pubspec.yaml | head -1
}

from="${1:-}"
to="${2:-HEAD}"

if [[ -z "$from" ]]; then
  from="$(git describe --tags --abbrev=0 "$to" 2>/dev/null || true)"
fi

echo "# 仓库              $(basename "$ROOT")"
echo "# pubspec 版本      $(current_version)"
echo "# 最近 5 个 tag     $(git tag --sort=-creatordate | head -5 | tr '\n' ' ')"

if [[ -z "$from" ]]; then
  echo "# 提交范围          全历史（没有可用 tag）"
  range_args=("$to")
else
  echo "# 提交范围          ${from}..${to}"
  range_args=("${from}..${to}")
fi

if [[ -n "$(git tag --points-at "$to" | head -1)" ]]; then
  echo "# 注意              ${to} 已经打过 tag，区间大概率为空"
fi

echo "# 提交条数          $(git rev-list --count --no-merges "${range_args[@]}")"
echo

git log --no-merges --date=short --pretty=format:'%h%x09%ad%x09%s' "${range_args[@]}"
echo
echo

# "123"、"update" 这类没有 Conventional Commits 前缀的提交，光看标题判断不了该不该收进
# 更新日志，得看它动了哪些文件。这里把它们单独列出来并附上改动统计。
echo "## 标题看不出类型的提交（附改动文件）"
git log --no-merges --pretty=format:'%h%x09%s' "${range_args[@]}" \
  | while IFS=$'\t' read -r sha subject; do
      case "$subject" in
        feat*|fix*|perf*|refactor*|chore*|ci*|test*|style*|docs*|build*|revert*) continue ;;
      esac
      echo
      echo "### ${sha}  ${subject}"
      git show --stat --format='' "$sha" | head -12
    done
echo
