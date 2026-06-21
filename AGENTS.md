# 光序 - 代码规范指南

## 常用命令

### 构建和测试
- `flutter test` - 运行所有测试
- `flutter test test/unit/course_model_test.dart` - 运行单个测试文件
- `flutter test --coverage` - 生成覆盖率报告
- `scripts/check_coverage.sh` - 检查覆盖率阈值（80%）
- `flutter analyze` - 运行静态分析
- `dart format .` - 格式化代码

## 代码规范

### 导入和格式化
- 使用 flutter_lints 包进行静态分析
- 使用 `dart format .` 格式化代码
- 按顺序组织导入：dart -> flutter -> 第三方 -> 本地
- 本地文件使用相对导入

### 命名和类型
- 类名使用 PascalCase（CourseModel、UserService）
- 变量和方法名使用 camelCase（courseName、getUserData）
- 使用强类型 - 明确声明变量类型
- 优先使用 final 声明不可变变量

### 错误处理
- 异步操作使用 try-catch 块
- 使用空感知操作符（?.、??）处理空值
- 记录错误时提供适当上下文
- 尽可能返回空默认值而不是 null

### 测试规范
- 在 test/unit/ 中为模型和业务逻辑编写单元测试
- 在 test/widget/ 中为UI组件编写组件测试
- 使用描述性测试名称，遵循"should_ when_"模式
- 目标测试覆盖率80%+

### 多语言支持
使用 l10n 包进行多语言支持
- 创建一个本地化资源文件，例如 strings.arb
- 使用 `flutter gen-l10n` 命令生成本地化代码