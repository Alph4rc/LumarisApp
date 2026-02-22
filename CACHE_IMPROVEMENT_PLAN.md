# iOS Club App 缓存方案改进计划

## 1. 现状分析
当前项目采用 **"轻量级 + 集中式"** 的缓存策略，几乎完全依赖 `shared_preferences`。

*   **存储引擎**: `SharedPreferences` (Key-Value)。
*   **网络缓存**: 自定义 `RequestCache` + Dio 拦截器，基于 URL 正则控制过期时间。
*   **业务数据**: 用户凭证、课表、成绩、待办事项等均序列化为 JSON 字符串存储。

## 2. 存在问题
| 问题维度 | 具体表现 | 风险等级 |
| :--- | :--- | :--- |
| **性能** | `SharedPreferences` 启动时全量加载，大量 JSON 数据会导致内存占用飙升和启动卡顿。 | 🔴 高 |
| **安全** | 用户密码以明文形式存储在 XML/Plist 文件中，存在泄漏风险。 | 🔴 高 |
| **查询** | 无法进行复杂查询（如"查找未完成Todo"），必须全量反序列化后在内存中过滤。 | 🟡 中 |
| **类型** | 仅支持基础类型，复杂对象需要频繁序列化/反序列化，消耗 CPU。 | 🟡 中 |

## 3. 改进目标
1.  **提升安全性**: 敏感数据（密码、Token）加密存储。
2.  **优化性能**: 引入高性能数据库，实现按需加载，降低内存占用。
3.  **增强能力**: 支持复杂查询和结构化数据存储。

## 4. 详细改进方案

### 4.1 安全性升级 (P0 - 必须)
引入 `flutter_secure_storage` 库，专门用于存储敏感信息。

*   **迁移对象**: `username`, `password` (对应 `PrefsKeys.USERNAME`, `PrefsKeys.PASSWORD`)。
*   **实现方式**: 创建 `SecureStorageService` 单例，替换现有直接操作 `SharedPreferences` 的代码。

### 4.2 结构化数据迁移 (P1 - 推荐)
引入 `Hive` 或 `Isar` (推荐 Hive，因其轻量且也是 Key-Value 风格，迁移成本低) 替代 `shared_preferences` 存储大量业务数据。

*   **迁移对象**:
    *   `request_cache_*` (API 响应缓存)
    *   `course_data` (课程数据)
    *   `all_score_data` (成绩数据)
    *   `todo_data` (待办事项)
*   **优势**: 二进制序列化速度快，支持 Box 分离（按需打开），不阻塞主线程。

### 4.3 架构分层优化 (P2 - 长期)
将缓存逻辑从业务 Service 中剥离，建立统一的 `Repository` 层。

*   **Current**: `EduService` 直接操作 `PrefsService`。
*   **New**: `EduService` -> `EduRepository` -> (`RemoteDataSource` + `LocalDataSource`)。

## 5. 实施路线图

### 第一阶段：安全加固 (预计 1 天)
1.  添加 `flutter_secure_storage` 依赖。
2.  创建 `SecureStorageService`。
3.  修改 `EduService` 和 `LoginService`，将密码读写逻辑切换到新服务。
4.  添加数据迁移逻辑（检测到旧密码时自动迁移到安全存储并删除旧 Key）。

### 第二阶段：网络缓存优化 (预计 2-3 天)
1.  评估引入 `hive_flutter`。
2.  重构 `RequestCache`，将底层存储从 `SharedPreferences` 切换到 `Hive Box`。
3.  验证不同过期策略（短效/长效）在 Hive 中的实现。

### 第三阶段：业务数据迁移 (预计 3-5 天)
1.  为 `CourseModel`, `ScoreModel`, `TodoItem` 生成 Hive Adapter。
2.  创建独立的 Hive Boxes (`courses`, `scores`, `todos`)。
3.  重构 `CourseStore`, `ScoreStore`, `TodoService` 以使用 Hive。
4.  实现旧数据到新数据库的迁移逻辑。

## 6. 技术选型对比

| 特性 | SharedPreferences (现状) | Hive (推荐) | Isar/Sqflite |
| :--- | :--- | :--- | :--- |
| **存取速度** | 慢 (XML/JSON) | 🚀 极快 (二进制) | 快 |
| **内存占用** | 高 (全量加载) | 低 (按需) | 低 |
| **查询能力** | 无 | 基础 (Key/Index) | 强 (SQL/Filter) |
| **使用难度** | 简单 | 简单 | 中等 |
| **适用场景** | 简单配置 | 缓存、大量对象 | 复杂关系数据 |

## 7. 结论
建议优先完成 **第一阶段（安全加固）**，消除明文存储密码的安全隐患。随后根据 App 性能监测情况，逐步推进第二、三阶段的存储引擎替换。
