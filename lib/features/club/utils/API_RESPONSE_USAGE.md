# ApiResponse 使用指南

## 概述

`ApiResponse` 类是一个通用的 API 响应包装器,用于统一处理所有 API 响应。它包含了状态码、错误信息、数据等字段,便于扩展和错误处理。

## 核心类

### 1. ApiResponse<T>

位置: `lib/features/club/models/api_response.dart`

**字段:**
- `code`: HTTP 状态码
- `errorCode`: 业务错误码
- `message`: 响应消息
- `detail`: 详细错误信息
- `data`: 响应数据(泛型)
- `requestId`: 请求ID(用于追踪)
- `timestamp`: 时间戳

**方法:**
- `isSuccess`: 判断请求是否成功
- `hasError`: 判断是否有错误
- `errorMessage`: 获取错误信息

### 2. ApiResponseHelper

位置: `lib/features/club/utils/api_response_helper.dart`

提供便捷的静态方法来解析不同类型的响应。

## 使用方法

### 方法 1: 使用 ApiResponseHelper (推荐)

这是最简洁的方式,适合大多数场景。

#### 解析单个对象

```dart
import 'package:ios_club_app/features/club/utils/api_response_helper.dart';

static Future<ArticleModel?> getArticle(String id) async {
  try {
    final response = await ApiClient.get('/Article/$id');
    return await ApiResponseHelper.parseSingleObject(
      response,
      ArticleModel.fromJson,
      errorMessage: 'Error fetching article',
    );
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
```

#### 解析对象列表

```dart
static Future<List<ArticleModel>?> getAllArticles() async {
  try {
    final response = await ApiClient.get('/Article');
    return await ApiResponseHelper.parseList(
      response,
      ArticleModel.fromJson,
      errorMessage: 'Error fetching articles',
    );
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
```

#### 解析字符串

```dart
static Future<String?> createArticle(ArticleCreateDto data) async {
  try {
    final response = await ApiClient.post('/Article', body: data.toJson());
    return await ApiResponseHelper.parseString(
      response,
      errorMessage: 'Error creating article',
    );
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
```

#### 解析布尔值

```dart
static Future<bool> deleteArticle(String id) async {
  try {
    final response = await ApiClient.delete('/Article/$id');
    return await ApiResponseHelper.parseBool(
      response,
      errorMessage: 'Error deleting article',
    );
  } catch (e) {
    print('Error: $e');
    return false;
  }
}
```

### 方法 2: 直接使用 ApiResponse

当你需要访问完整的响应信息(如错误码、消息等)时使用。

```dart
import 'dart:convert';
import 'package:ios_club_app/features/club/models/api_response.dart';

static Future<ArticleModel?> getArticle(String id) async {
  try {
    final response = await ApiClient.get('/Article/$id');

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        jsonDecode(response.body),
      );

      // 检查是否成功
      if (apiResponse.isSuccess && apiResponse.data != null) {
        return ArticleModel.fromJson(apiResponse.data!);
      } else {
        // 处理业务错误
        print('Error: ${apiResponse.errorMessage}');
        print('Error code: ${apiResponse.errorCode}');
        return null;
      }
    }
  } catch (e) {
    print('Error: $e');
  }
  return null;
}
```

### 方法 3: 获取完整的 ApiResponse 对象

当你需要在 UI 层显示错误信息时使用。

```dart
static Future<ApiResponse<ArticleModel>?> getArticleWithResponse(String id) async {
  try {
    final response = await ApiClient.get('/Article/$id');
    return ApiResponseHelper.getApiResponse<ArticleModel>(
      response,
      fromJsonT: (data) => ArticleModel.fromJson(data as Map<String, dynamic>),
    );
  } catch (e) {
    print('Error: $e');
    return null;
  }
}

// 在 UI 层使用
final apiResponse = await ArticleService.getArticleWithResponse('123');
if (apiResponse != null) {
  if (apiResponse.isSuccess) {
    // 显示数据
    print('Article: ${apiResponse.data}');
  } else {
    // 显示错误消息
    showErrorDialog(apiResponse.errorMessage);
  }
}
```

## 迁移指南

### 旧代码

```dart
static Future<List<ArticleModel>?> getAllArticles() async {
  try {
    final response = await ApiClient.get('/Article');
    if (response.statusCode == 200) {
      final Map<String, dynamic> apiResponse = jsonDecode(response.body);
      final List<dynamic>? data = apiResponse['data'];
      if (data != null) {
        return data.map((e) => ArticleModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
  } catch (e) {
    print('Error: $e');
  }
  return null;
}
```

### 新代码

```dart
static Future<List<ArticleModel>?> getAllArticles() async {
  try {
    final response = await ApiClient.get('/Article');
    return await ApiResponseHelper.parseList(
      response,
      ArticleModel.fromJson,
      errorMessage: 'Error fetching articles',
    );
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
```

## 优势

1. **代码更简洁**: 减少了重复的解析代码
2. **统一错误处理**: 所有 API 响应都经过统一的错误处理
3. **类型安全**: 使用泛型确保类型安全
4. **易于扩展**: 可以轻松添加新的解析方法
5. **便于调试**: 统一的错误日志输出
6. **支持错误信息**: 可以获取详细的错误码和消息

## 注意事项

1. `ApiResponseHelper` 的所有方法都会自动处理 `statusCode == 200` 的检查
2. 错误信息会自动打印到控制台(仅在 debug 模式)
3. 如果需要自定义错误处理,可以直接使用 `ApiResponse` 类
4. 所有方法都是异步的,记得使用 `await`
