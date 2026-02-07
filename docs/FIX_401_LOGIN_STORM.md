# 401错误导致登录接口崩溃问题修复

## 问题描述

在后端接口返回401（未授权）错误后，应用会多次访问登录接口，导致登录接口崩溃。这是一个典型的"重试风暴"问题。

## 问题根因分析

### 原有实现的问题

在 `lib/features/education/services/edu_http_client.dart` 中：

1. **实例级别的锁**：使用 `_isRelogging` 作为实例级别的标志
2. **竞态条件**：多个请求几乎同时检查 `_isRelogging`（都是false）
3. **并发登录**：多个请求同时触发登录逻辑
4. **重试放大**：配合重试机制（2次重试），问题被进一步放大

### 问题场景示例

```
时间线：
T0: 5个服务同时发起请求
T1: 所有请求都返回401
T2: 5个请求几乎同时检查 _isRelogging（都是false）
T3: 5个请求都将 _isRelogging 设为true
T4: 5个请求同时开始登录
T5: 每个登录可能重试2次
结果: 可能产生 5-15 次登录请求 → 登录接口崩溃
```

## 解决方案

### 核心改进

实现了**全局登录锁机制**，使用 `Completer` 实现请求排队：

```dart
/// 全局登录锁，确保同一时间只有一个登录请求
static Completer<bool>? _loginCompleter;

/// 最后一次登录失败的时间戳，用于防止频繁重试
static int? _lastLoginFailTime;

/// 登录失败后的冷却时间（毫秒）
static const int _loginCooldownMs = 5000;
```

### 关键特性

1. **全局锁机制**
   - 使用 `static Completer<bool>` 确保跨实例的全局锁
   - 第一个请求创建 Completer 并执行登录
   - 后续请求等待 Completer 完成并复用结果

2. **登录冷却期**
   - 登录失败后进入5秒冷却期
   - 冷却期内不会再次尝试登录
   - 防止频繁重试导致的服务器压力

3. **请求排队**
   - 多个401请求会排队等待
   - 只有第一个请求执行实际登录
   - 其他请求复用登录结果

### 工作流程

```
场景：5个服务同时遇到401

请求1: 检查 _loginCompleter (null) → 创建 Completer → 开始登录
请求2: 检查 _loginCompleter (存在且未完成) → 等待
请求3: 检查 _loginCompleter (存在且未完成) → 等待
请求4: 检查 _loginCompleter (存在且未完成) → 等待
请求5: 检查 _loginCompleter (存在且未完成) → 等待

请求1: 登录完成 → complete(true) → 通知所有等待的请求
请求2-5: 收到登录成功通知 → 使用新cookie重试原请求

结果: 只有1次登录请求 ✓
```

## 代码变更

### 修改文件
- `lib/features/education/services/edu_http_client.dart`

### 主要变更

1. **添加全局状态管理**
```dart
static Completer<bool>? _loginCompleter;
static int? _lastLoginFailTime;
static const int _loginCooldownMs = 5000;
```

2. **实现带锁的重登录方法**
```dart
Future<bool> _reLoginWithLock() async {
  // 检查冷却期
  if (_lastLoginFailTime != null) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastLoginFailTime! < _loginCooldownMs) {
      return false;
    }
  }

  // 等待已有的登录请求
  if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
    return await _loginCompleter!.future;
  }

  // 创建新的登录请求
  _loginCompleter = Completer<bool>();
  // ... 执行登录逻辑
}
```

3. **更新错误拦截器**
```dart
onError: (DioException e, handler) async {
  if (statusCode == 401 || statusCode == 403) {
    if (await _reLoginWithLock()) {
      // 重登录成功，重试请求
    }
  }
}
```

## 测试

创建了单元测试文件：`test/unit/edu_http_client_test.dart`

测试覆盖：
- 多个并发401请求只触发一次登录
- 登录失败后进入冷却期
- 登录成功后清除冷却状态
- 模拟5个服务同时遇到401的场景

## 效果对比

### 修复前
```
5个服务同时401 → 5-15次登录请求 → 登录接口崩溃
```

### 修复后
```
5个服务同时401 → 1次登录请求 → 所有请求复用结果 ✓
```

## 性能影响

- **减少网络请求**：从多次登录请求减少到1次
- **降低服务器压力**：避免登录接口被大量请求淹没
- **改善用户体验**：更快的错误恢复，避免重复登录
- **增加可靠性**：冷却机制防止频繁重试

## 注意事项

1. **全局状态**：`_loginCompleter` 和 `_lastLoginFailTime` 是静态变量，跨所有 `EduHttpClient` 实例共享
2. **冷却时间**：默认5秒，可根据实际情况调整 `_loginCooldownMs`
3. **日志记录**：添加了详细的日志，便于调试和监控
4. **向后兼容**：不影响现有的API调用方式

## 相关文件

- 修改：`lib/features/education/services/edu_http_client.dart`
- 测试：`test/unit/edu_http_client_test.dart`
- 依赖：`lib/core/services/retry_policy.dart`

## 建议

1. **监控登录频率**：在生产环境中监控登录请求的频率
2. **调整冷却时间**：根据实际情况调整冷却时间（当前5秒）
3. **添加指标**：考虑添加登录重试次数的统计指标
4. **用户提示**：如果频繁遇到401，考虑提示用户重新登录

## 版本信息

- 修复日期：2026-02-07
- 影响版本：所有使用 `EduHttpClient` 的版本
- 修复类型：Bug Fix - Critical
