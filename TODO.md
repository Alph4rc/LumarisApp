# 项目待办事项 (Project Todo)

本文档旨在跟踪项目的技术债务、重构计划和待办功能，特别是关于存储层迁移的工作。

## 🚀 存储层迁移与兼容性 (Storage Layer Migration & Compatibility)

项目正在从 `SharedPreferences` 迁移到 `Hive` + `SecureStorage` 的混合架构。为确保**所有版本**（包括 `TodoService`, `CourseRepository`, `ScoreRepository` 等任何涉及本地存储的服务）都能平滑升级，必须严格遵守以下原则：

- [x] **长期维护迁移逻辑 (Maintain Migration Logic)**
  - [x] **全局原则**：所有服务（Service/Repository）必须保留 `_migrateFromPrefs` 逻辑，**严禁删除**，以支持用户从任意旧版本升级到最新版。
  - [x] **增强健壮性 (Robustness)**：
    - [x] 检查所有 Model 的 `fromJson` 方法（如 `TodoItem`, `ScoreList`, `SemesterModel`），确保在字段缺失或类型不匹配时使用默认值（`??`）或 `try-catch` 处理，**严禁抛出异常导致应用崩溃**。
    - [x] 在所有 `_migrateFromPrefs` 方法中添加详细的逐条 `try-catch` 块，确保单条脏数据不会阻塞整个迁移流程，并记录错误日志。
  - [x] **清理废弃 Keys**：在 `PrefsKeys` 中为已迁移的 Key（`COURSE_DATA`, `ALL_SCORE_DATA`, `TODO_DATA`）添加 `@Deprecated` 注解，防止新代码误写入。

- [x] **验证业务数据迁移**
  - [x] 确认 `CourseRepository` 的 `_migrateFromPrefs` 逻辑在所有场景下均能正确执行。
  - [x] 确认 `TodoService` 的 `_migrateFromPrefs` 逻辑能正确迁移旧版待办事项。
  - [x] 确认 `ScoreRepository` 的数据迁移逻辑。

- [x] **待办事项服务 (TodoService) 重构**
  - [x] 修复 `TodoService` 中的 `fromJsonClub` 方法，确保字段映射与 API 响应完全一致（`id`, `endTime`, `status` 兼容 bool/int）。

## 🛠 代码优化 (Code Refactoring)

- [x] **网络请求缓存 (RequestCache)**
  - [ ] 为 JSON 解析失败的情况添加更详细的错误日志或埋点。
  - [x] 添加 `clearExpired()` 方法，定期清理过期的 Hive 缓存条目以释放空间。

- [ ] **课程数据结构优化**
  - [ ] 目前 `CourseRepository` 将所有课程作为一个 List 存入 Hive。建议重构为将每门课程作为独立的 Hive Object 存储，以便支持更细粒度的更新和查询。

- [x] **依赖注入**
  - [x] `TodoService` 已改为使用 `BaseHttpClient` 替代直接实例化 `Dio`，统一配置（超时、重试拦截器）。

## 📝 其他待办 (General Todos)

- [ ] **设置存储 (SettingsStore)**
  - [ ] 评估是否需要将 `SettingsStore` 中的用户偏好设置也迁移到 Hive，或者继续保留在 SharedPreferences 中（目前作为轻量级配置存储是可接受的）。

- [ ] **测试 (Testing)**
  - [ ] 为 `RequestCache` 的缓存策略和降级逻辑编写单元测试。
  - [ ] 为 `HiveManager` 的初始化和单例模式编写测试。

## 🔍 已知问题 (Known Issues)

- [x] `TodoService.nowToUpdate` 同步逻辑已修复：成功后调用 `clearLocalData()` 清除 Hive 数据，而非错误地删除 SharedPreferences 旧 Key。
