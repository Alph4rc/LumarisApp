# 光序 (Lumaris) 后端 API 开发指南

本文档面向第三方开发者，说明如何实现与光序 App 兼容的后端 API 服务。

## 目录

- [1. 概述](#1-概述)
- [2. 快速开始](#2-快速开始)
- [3. 认证机制](#3-认证机制)
- [4. 通用约定](#4-通用约定)
- [5. API 接口规范](#5-api-接口规范)
  - [5.1 登录 /login](#51-登录-login)
  - [5.2 课程 /course](#52-课程-course)
  - [5.3 成绩 /score](#53-成绩-score)
  - [5.4 考试 /exam](#54-考试-exam)
  - [5.5 校车 /bus](#55-校车-bus)
  - [5.6 电费 /electricity](#56-电费-electricity)
  - [5.7 校园卡 /payment](#57-校园卡-payment)
  - [5.8 培养方案 /program](#58-培养方案-program)
  - [5.9 信息 /info](#59-信息-info)
  - [5.10 导航 /schoolnav](#510-导航-schoolnav)
  - [5.11 地图 /map](#511-地图-map)
- [6. 数据格式速查表](#6-数据格式速查表)
- [7. 错误处理](#7-错误处理)
- [8. 接入检查清单](#8-接入检查清单)
- [附录：接口速查索引](#附录接口速查索引)

---

## 1. 概述

光序 App 通过 HTTP REST API 与各学校后端通信。每个学校运行独立的服务实例，App 通过 `ApiConfig` 中的 `eduApiBaseUrl` 配置项连接到对应学校。

**通信协议**: HTTP/HTTPS JSON REST API  
**数据格式**: `application/json`  
**认证方式**: Cookie-based（通过 `Cookie` 或 `xauat` 请求头传递）

---

## 2. 快速开始

### 2.1 最小可行后端

要支持光序 App 基本功能，你至少需要实现以下接口：

| 优先级 | 接口 | 用途 |
|--------|------|------|
| **必须** | `POST /Login` | 用户登录，获取认证 Cookie |
| **必须** | `GET /Course?studentId=` | 获取课程表 |
| **必须** | `GET /Score?studentId=&semester=` | 获取成绩 |
| **必须** | `GET /Score/Semester?studentId=` | 获取学期列表 |
| **必须** | `GET /Info/Time` | 获取当前学期时间范围 |
| **推荐** | `GET /Exam?studentId=` | 获取考试安排 |
| **推荐** | `GET /Bus/{date}` | 获取校车时刻表 |
| **推荐** | `GET /SchoolNav` | 获取校园导航链接 |
| **可选** | `/Electricity/*` | 电费查询与订阅 |
| **可选** | `/Payment/*` | 校园卡流水 |
| **可选** | `/Program/*` | 培养方案查询 |
| **可选** | `/Map/*` | 校园地图 POI |

### 2.2 配置 App 连接你的后端

App 使用 `lib/core/config/api_config.dart` 中的 `SchoolConfig` 配置后端地址：

```dart
SchoolConfig(
  id: 'your-school-id',
  name: '你的学校名称',
  eduApiBaseUrl: 'https://your-server.com',
)
```

---

## 3. 认证机制

### 3.1 登录流程

```
App                          Server
 |                              |
 |-- POST /Login ---------->|
 |   {username, password}       |
 |                              |
 |<--- 200 OK ------------------|
 |   {code:0, message:"ok",     |
 |    data: {success,           |
 |           studentId,         |
 |           cookie}}           |
 |                              |
 |-- 后续请求 ------------------>|
 |   Header: Cookie: <cookie>   |
 |   Header: xauat: <cookie>    |
```

1. App 发送 `POST /Login`，请求体为 `{"username": "...", "password": "..."}`
2. 后端验证凭证后返回 `cookie` 字段
3. App 将 cookie 持久化存储
4. 后续所有请求携带 `Cookie` 和 `xauat` 两个请求头，值均为该 cookie

### 3.2 登录接口

**请求:**

```json
POST /Login
Content-Type: application/json

{
  "username": "学号",
  "password": "密码"
}
```

**成功响应 (200):**

```json
{
  "code": 0,
  "message": "ok",
  "data": {
    "success": true,
    "studentId": "20210001",
    "cookie": "session_token_or_cookie_value"
  }
}
```

**失败响应 (401):**

```json
{
  "code": 401,
  "message": "用户名或密码错误",
  "data": null
}
```

> **注意**: 响应中的 `cookie` 字段可以是任何字符串（Session ID、JWT Token、实际 Cookie 字符串均可）。App 仅将其作为不透明令牌透传，不会解析其内容。App 也会尝试解析 `token`、`userId`、`name`、`department`、`className` 等额外字段，但这些不在规范内。

### 3.3 401 自动重登录

App 在收到 401/403 响应时会自动触发重登录流程：
- 使用本地安全存储的用户名/密码重新调用 `/Login`
- 重登成功则自动重试原请求
- 重登有 5 秒冷却期，避免频繁重试

因此你的后端只需在认证失败时返回 HTTP 401，App 会自动处理后续。

---

## 4. 通用约定

### 4.1 请求头

App 发送的每个请求包含以下头：

```
Accept: application/json
Content-Type: application/json
Cookie: <登录返回的cookie>
xauat: <登录返回的cookie>
x-language: zh-CN
```

### 4.2 统一响应格式

所有接口使用 `ApiResponse` 包装器返回数据：

| 字段 | 类型 | 说明 |
|------|------|------|
| `code` | `int \| string \| null` | 状态码。0 表示成功，其他值表示错误 |
| `message` | `string` | 提示信息 |
| `data` | any / null | 实际返回数据，类型因接口而异 |
| `total` | int / null | 列表接口的记录总数（可选） |

**成功判定**：`code` 为 `null`、`0`、`"0"`、`200` 或 `"200"` 均视为成功。

**列表响应示例:**

```json
{
  "code": 0,
  "message": "ok",
  "data": [...],
  "total": 10
}
```

**单对象响应示例:**

```json
{
  "code": 0,
  "message": "ok",
  "data": {...}
}
```

### 4.3 数值类型灵活性

**重要**: App 的 JSON 解析器对数值字段具有类型灵活性。你的 API 返回数值时可以使用：

- `"3"` (字符串) 或 `3` (数字) —— 均可正常解析
- `3.5` (浮点数) 或 `"3.5"` (字符串) —— 均可正常解析
- `null` / `0` / `"0"` —— 均视为 0
- `true` 或 `"true"` —— 均视为 true

这适用于所有标记为 `int32`/`int64`/`double`/`bool` 的字段。你无需担心返回类型的精确匹配。

### 4.4 空值处理

所有可为空的字段，App 均能正确处理 `null` 值。对于字符串字段，`null` 和 `""` 等价。

### 4.5 多语言支持

请求头 `x-language` 控制响应语言。支持：`de` / `ru` / `fr` / `ja` / `ko` / `en` / `zh-CN` / `zh-TW`。默认 `zh-CN`。

---

## 5. API 接口规范

### 5.1 登录 /login

#### `POST /Login`

认证用户身份并返回会话令牌。

**请求体：**

| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| `username` | string | 是 | 学号或用户名 |
| `password` | string | 是 | 密码（明文） |

**响应体 `data` 字段 (LoginResponse)：**

| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| `success` | boolean | 是 | 登录是否成功 |
| `studentId` | string | 否 | 学号 |
| `cookie` | string | 是 | 会话令牌，用于后续请求认证 |

**响应示例：**

```json
{
  "code": 0,
  "message": "ok",
  "data": {
    "success": true,
    "studentId": "20210001",
    "cookie": "session_token_or_cookie_value"
  }
}
```

---

### 5.2 课程 /course

#### `GET /Course?studentId={studentId}`

获取指定学生的课程表。

**请求参数：**

| 参数 | 类型 | 必须 | 说明 |
|------|------|------|------|
| `studentId` | string | 否 | 学号。未传时返回当前登录用户的课程 |

**响应体 `data` 字段：** `CourseActivity` 数组。

```json
{
  "code": 0,
  "message": "ok",
  "data": [
    {
      "courseName": "高等数学",
      "courseCode": "MATH1001",
      "lessonId": "2024-MATH1001-01",
      "teachers": ["张三"],
      "room": "教一楼301",
      "campus": "雁塔校区",
      "weekday": 0,
      "startUnit": 1,
      "endUnit": 2,
      "weekIndexes": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
      "credits": "4.0"
    }
  ],
  "total": 1
}
```

**CourseActivity 字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `courseName` | string | 课程名称 |
| `courseCode` | string | 课程代码 |
| `lessonId` | string | 教学班 ID（用于课程去重和识别） |
| `teachers` | string[] | 授课教师列表 |
| `room` | string | 上课教室 |
| `campus` | string | 校区名称 |
| `weekday` | int | **星期几。API 文档约定 0=周一, 1=周二, …, 6=周日。但注意：App 内部业务逻辑（课程匹配、通知提醒等）实际以 Dart 的 `DateTime.weekday`（1=周一~7=周日）与 `weekday` 直接比较，未做偏移转换。目前线上后端均返回 1=周一的格式，请保持返回 1=周一 即可。** |
| `startUnit` | int | 开始节次（如 1 表示第1节） |
| `endUnit` | int | 结束节次（如 2 表示第2节） |
| `weekIndexes` | int[] | 上课周次列表（如 `[1,2,3,...,16]`） |
| `credits` | string | 学分 |

> **lessonId 是关键字段**：App 使用它来匹配用户自定义课程。如果可能，请保持 lessonId 在不同查询之间的稳定性。

---

### 5.3 成绩 /score

#### `GET /Score/Semester?studentId={studentId}`

获取所有可用学期列表。

**响应体 `data` 字段 (SemesterItem 数组)：**

```json
{
  "code": 0,
  "message": "ok",
  "data": [
    { "value": "2024-1", "text": "2024-2025学年第一学期" },
    { "value": "2025-2", "text": "2025-2026学年第二学期" }
  ]
}
```

**SemesterItem 字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `value` | string | 学期标识符，格式 `YYYY-N`（如 `2025-2` 表示 2025-2026 学年第 2 学期） |
| `text` | string | 学期显示名称，格式 `YYYY-YYYY学年第N学期` |

#### `GET /Score?studentId={studentId}&semester={semester}`

获取指定学期的成绩详情。

**请求参数：**

| 参数 | 类型 | 必须 | 说明 |
|------|------|------|------|
| `studentId` | string | 是 | 学号 |
| `semester` | string | 是 | 学期标识符（即 `value` 字段的值，如 `2025-2`） |

**响应体 `data` 字段：** `ScoreItem` 数组。

```json
{
  "code": 0,
  "message": "ok",
  "data": [
    {
      "name": "2024-2025学年第一学期",
      "lessonCode": "MATH1001",
      "lessonName": "高等数学",
      "grade": "85",
      "gpa": "3.5",
      "gradeDetail": "平时:85 期末:85",
      "credit": "4.0",
      "isMinor": false
    }
  ],
  "total": 1
}
```

**ScoreItem 字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | string | 学期名称 |
| `lessonCode` | string | 课程代码（用于重修去重） |
| `lessonName` | string | 课程名称 |
| `grade` | string | 成绩（可以是分数如 "85" 或等级如 "良好"） |
| `gpa` | string | 绩点（如 "3.5"；无绩点体系时返回 "0"） |
| `gradeDetail` | string | 成绩明细（如平时分/期末分，可选） |
| `credit` | string | 学分 |
| `isMinor` | boolean | 是否为辅修课程 |

> **GPA 计算说明**：App 取 `parseDouble(gpa) * parseDouble(credit)` 加权计算总 GPA。重修课程以 `lessonCode` 去重，取 GPA 更高的记录。

#### `GET /Score/ThisSemester`

获取当前学期标识（不要求登录）。用于 App 首页显示当前学期名称。

**响应体 `data` 字段 (SemesterItem)：**

```json
{
  "code": 0,
  "message": "ok",
  "data": {
    "value": "2025-2",
    "text": "2025-2026学年第二学期"
  }
}
```

---

### 5.4 考试 /exam

#### `GET /Exam?studentId={studentId}`

获取考试安排。这是数据格式要求**最严格**的接口之一。

**请求参数：**

| 参数 | 类型 | 必须 | 说明 |
|------|------|------|------|
| `studentId` | string | 否 | 学号 |

**响应体 `data` 字段：** `ExamInfo` 数组。

```json
{
  "code": 0,
  "message": "ok",
  "data": [
    {
      "name": "高等数学",
      "time": "2026-07-13 15:00~16:00",
      "location": "主楼301",
      "seat": "A-12"
    }
  ]
}
```

**ExamInfo 字段说明：**

| 字段 | JSON Key | 类型 | 必须 | 说明 |
|------|----------|------|------|------|
| 考试名称 | `name` | string | 是 | 课程名称 |
| 考试时间 | `time` | string | 是 | 见下方格式说明 |
| 考试地点 | `location` | string | 是 | 教室 |
| 座位号 | `seat` | string | 是 | 座位编号 |

#### 5.4.1 `time` 字段格式（必须严格遵守）

```
YYYY-MM-DD HH:MM~HH:MM  或  YYYY-MM-DD HH:MM-HH:MM
```

| 示例 | 含义 |
|------|------|
| `2026-07-13 15:00~16:00` | 2026年7月13日 15:00 到 16:00（波浪号分隔） |
| `2026-01-10 08:00-10:00` | 2026年1月10日 08:00 到 10:00（横线分隔） |

**App 解析规则**（正则）：

- 模式1（横线分隔）：`(\d{4})-(\d{2})-(\d{2}).*?(\d{2}):(\d{2})-(\d{2}):(\d{2})`
- 模式2（波浪号分隔）：`(\d{4})-(\d{2})-(\d{2}).*?(\d{2}):(\d{2})~(\d{2}):(\d{2})`

日期和起始时间之间可以有任意字符（如空格或 T）。App 取结束时间来判断考试是否过期（只展示尚未结束的考试）。

**正确示例：**

| ✅ 正确 | ❌ 错误 | 原因 |
|---------|---------|------|
| `2026-07-13 15:00~16:00` | `2026-07-13T15:00:00` | 缺少结束时间 |
| `2026-01-10 08:00-10:00` | `2026-01-10` | 缺少时间范围 |
| `2026-06-20T09:00~11:00` | `09:00~11:00` | 缺少日期 |

---

### 5.5 校车 /bus

#### `GET /Bus/{date}`

获取指定日期的校车时刻表。

**路径参数：**

| 参数 | 类型 | 必须 | 说明 |
|------|------|------|------|
| `date` | string | 是 | 查询日期，格式 `YYYY-MM-DD`（如 `2026-04-27`） |

**响应体 `data` 字段：** `BusItem` 数组。

```json
{
  "code": 0,
  "message": "ok",
  "data": [
    {
      "lineName": "雁塔→草堂",
      "description": "工作日班车",
      "departureStation": "雁塔校区南门",
      "arrivalStation": "草堂校区东门",
      "runTime": "01:20:00",
      "arrivalStationTime": "x01:50"
    }
  ],
  "total": 7
}
```

**BusItem 字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `lineName` | string | 线路名称 |
| `description` | string | 描述/班次编号（如"A1"、"周末班车"） |
| `departureStation` | string | 出发站 |
| `arrivalStation` | string | 到达站 |
| `runTime` | string | **行车时长，格式 `HH:MM:SS`**（如 `01:20:00` = 1小时20分） |
| `arrivalStationTime` | string | **到达终点时间，格式 `xHH:MM`**（带 `x` 前缀，如 `x01:50`） |

**时间字段详解：**

- `runTime`：完整格式 `HH:MM:SS`。App 展示时截取到最后一个 `:` 之前，显示为 `HH:MM`。
- `arrivalStationTime`：格式 `xHH:MM`。App 去掉前缀 `x` 后与 `runTime` 计算发车时间。
- **当日过滤**：查询今天的数据时，App 会过滤掉发车时间早于当前时刻的班次。

#### `GET /Bus/NewData/{date}?loc={loc}`

获取新校区班车数据。额外参数 `loc`（默认 `ALL`），可按校区筛选（如 `雁塔`）。响应格式同上。

#### `GET /Bus/OldData/{date}?isShow={true|false}`

获取老校区班车数据。额外参数 `isShow`（默认 `false`），控制是否显示旧数据。响应格式同上。

> 如果你的学校只有一个校区，只需实现 `/Bus/{date}` 即可。App 内部会同时调用所有三个接口并合并结果。

---

### 5.6 电费 /electricity

#### `GET /Electricity?url={roomUrl}`

查询指定房间的当前电费余额。

**响应体 `data` 字段：** 数字（double），表示剩余金额（元）。

```json
{
  "code": 0,
  "message": "ok",
  "data": 42.50
}
```

#### `GET /Electricity/WeeklyData?url={roomUrl}`

查询指定房间的周用电数据。

**响应体 `data` 字段：** `ElectricData` 数组。

```json
{
  "code": 0,
  "message": "ok",
  "data": [
    { "timestamp": "2025-01-13T00:00:00Z", "value": 3.5 },
    { "timestamp": "2025-01-14T00:00:00Z", "value": 2.8 }
  ]
}
```

**ElectricData 字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `timestamp` | string (ISO 8601) | 数据时间点，兼容 `Timestamp` |
| `value` | double | 当日用电量（度），兼容 `Value` |

#### `GET /Electricity/RechargeUrl?url={roomUrl}`

获取电费充值页面 URL。

**响应体 `data` 字段：** 字符串 URL。

```json
{
  "code": 0,
  "message": "ok",
  "data": "https://pay.example.com/electricity/recharge?room=123"
}
```

#### `POST /Electricity/Subscriptions`

创建电费余额预警订阅。

**请求体：**

```json
{
  "url": "房间查询URL",
  "email": "user@example.com",
  "threshold": 10.0
}
```

| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| `url` | string (≤1024) | 是 | 房间查询 URL |
| `email` | string (≤256) | 是 | 通知邮箱 |
| `threshold` | double (≥0.01) | 否 | 余额预警阈值（元） |

**响应体 `data` 字段 (ElectricitySubscriptionResponse)：**

```json
{
  "code": 0,
  "message": "ok",
  "data": {
    "id": "sub_123",
    "url": "...",
    "email": "user@example.com",
    "threshold": 10.0,
    "isActive": true,
    "createdAt": "2025-01-15T10:30:00Z",
    "updatedAt": "2025-01-15T10:30:00Z",
    "nextCheckAt": "2025-01-16T10:30:00Z",
    "lastCheckedAt": null,
    "lastKnownBalance": null,
    "lastAlertedAt": null,
    "lastAlertedBalance": null,
    "lastErrorMessage": ""
  }
}
```

#### `GET /Electricity/Subscriptions?email={email}`

查询某个邮箱的订阅状态。

**响应体 `data` 字段 (ElectricitySubscriptionQueryResponse)：**

```json
{
  "code": 0,
  "message": "ok",
  "data": {
    "email": "user@example.com",
    "threshold": 10.0,
    "hasSubscription": true,
    "subscriptionId": "sub_123"
  }
}
```

#### `DELETE /Electricity/Subscriptions/{id}`

取消订阅。成功返回 HTTP 204 No Content。

---

### 5.7 校园卡 /payment

#### `GET /Payment/{id}`

获取电子校园卡绑定 URL 或状态。`id` 为学号。

**响应体 `data` 字段：** 字符串（HTML 页面或 URL）。

```json
{
  "code": 0,
  "message": "ok",
  "data": "<html>...</html>"
}
```

#### `GET /Payment/{id}/turnover`

获取校园卡消费流水。

**响应体 `data` 字段 (PaymentTurnoverResult)：**

```json
{
  "code": 0,
  "message": "ok",
  "data": {
    "records": [
      {
        "turnoverType": "消费",
        "datetimeStr": "2025-01-15 12:30:00",
        "resume": "食堂二楼",
        "tranamt": "1550"
      }
    ],
    "balance": "25080"
  }
}
```

**PaymentModel 字段：**

| 字段 | JSON Key | 类型 | 说明 |
|------|----------|------|------|
| 交易类型 | `turnoverType` | string | 交易类型（如"消费"、"充值"、"补助"） |
| 交易时间 | `datetimeStr` | string | **格式 `YYYY-MM-DD HH:mm:ss`** |
| 交易摘要 | `resume` | string | 交易描述/商户名称 |
| 交易金额 | `tranamt` | number\|string | **单位为分** |

**PaymentTurnoverResult 顶层字段：**

| 字段 | JSON Key | 类型 | 说明 |
|------|----------|------|------|
| 流水记录 | `records` | PaymentModel[] | 流水记录列表 |
| 当前余额 | `balance` | number\|string | **单位为分** |

> **金额单位说明（重要）**：`tranamt` 和 `balance` 的单位均为**分**，不是元。示例：
> - `tranamt: "1550"` → App 展示为 `15.50 元`
> - `balance: "25080"` → App 展示为 `250.80 元`
> - 负值表示支出：`tranamt: "-1000"` → `-10.00 元`

---

### 5.8 培养方案 /program

#### `GET /Program?id={majorId}&name={studentName}`

查询某个专业的培养方案课程列表。

**请求参数：**

| 参数 | 类型 | 必须 | 说明 |
|------|------|------|------|
| `id` | string | 否 | 专业 ID |
| `name` | string | 否 | 学生姓名（用于个性化查询） |

**响应体 `data` 字段：** `PlanCourse` 数组。

```json
{
  "code": 0,
  "message": "ok",
  "data": [
    {
      "name": "高等数学",
      "lessonType": "必修",
      "examMode": "考试",
      "courseTypeName": "公共基础课",
      "credits": 4.0,
      "termStr": "2024-2025-1"
    }
  ]
}
```

**PlanCourse 字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | string | 课程名称（兼容 PascalCase `Name`） |
| `lessonType` | string | 课程类型（必修/选修）（兼容 `LessonType`） |
| `examMode` | string | 考核方式（考试/考查）（兼容 `ExamMode`） |
| `courseTypeName` | string | 课程类别（公共基础课/专业基础课等）（兼容 `CourseTypeName`） |
| `credits` | double | 学分（兼容 `Credits`） |
| `termStr` | string | 开课学期（兼容 `TermStr`） |

> 字段名同时兼容 camelCase 和 PascalCase，如 `name` 和 `Name` 均可。

#### `GET /Program/GetDic?id={majorId}`

获取按学期分组的培养方案字典。

**响应体 `data` 字段：** 字典对象，key 为学期字符串，value 为该学期的 `PlanCourse` 数组。

```json
{
  "code": 0,
  "message": "ok",
  "data": {
    "2024-2025-1": [
      { "name": "高等数学", "lessonType": "必修", "examMode": "考试", "courseTypeName": "公共基础课", "credits": 4.0, "termStr": "2024-2025-1" }
    ],
    "2024-2025-2": [
      { "name": "线性代数", "lessonType": "必修", "examMode": "考试", "courseTypeName": "公共基础课", "credits": 3.0, "termStr": "2024-2025-2" }
    ]
  }
}
```

---

### 5.9 信息 /info

#### `GET /Info/Time`

获取当前学期信息。App 启动时首先调用此接口，用于学期判断和周次计算。

**响应体 `data` 字段 (TimeModel)：**

```json
{
  "code": 0,
  "message": "ok",
  "data": {
    "startTime": "2025-02-24",
    "endTime": "2025-07-05"
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `startTime` | string | 本学期开始日期（ISO 8601，如 `2025-02-24`） |
| `endTime` | string | 本学期结束日期（ISO 8601，如 `2025-07-05`） |

> App 会根据 `startTime` 和当前日期自动计算当前是第几教学周。响应中可包含额外字段（如 `semester`），App 会以字典方式存储。

#### `GET /Info/Completion`

获取学业完成情况（学分修读进度）。

**响应体 `data` 字段：** `StudyModule` 数组。

```json
{
  "code": 0,
  "message": "ok",
  "data": [
    {
      "type": "必修课",
      "total": { "name": "必修课", "actual": 45.0, "full": 50.0 },
      "other": [
        { "name": "数学类", "actual": 12.0, "full": 12.0 },
        { "name": "外语类", "actual": 8.0, "full": 10.0 }
      ]
    }
  ]
}
```

**StudyModule 字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `type` | string | 课程类别（如"必修课"、"选修课"） |
| `total` | CreditInfo | 总学分信息 |
| `other` | CreditInfo[] | 子类别详情 |

**CreditInfo 字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | string | 类别名称 |
| `actual` | double | 已获学分 |
| `full` | double | 应修学分 |

---

### 5.10 导航 /schoolnav

#### `GET /SchoolNav`

获取校园导航链接分类列表。用于 App 的"校园导航"功能页面。

**响应体 `data` 字段：** `CategoryModel` 数组。

```json
{
  "code": 0,
  "message": "ok",
  "data": [
    {
      "key": "academic",
      "name": "学术教务",
      "description": "教务系统、选课等",
      "icon": "school",
      "index": 0,
      "links": [
        {
          "key": "edu_system",
          "name": "教务系统",
          "url": "https://jwc.example.edu.cn",
          "icon": "book",
          "description": "选课、查成绩",
          "index": 0
        }
      ]
    }
  ]
}
```

**CategoryModel 字段：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `key` | string | 分类唯一标识 |
| `name` | string | 分类名称 |
| `description` | string\|null | 分类描述 |
| `icon` | string | 图标标识（App 内置图标映射） |
| `index` | int | 排序权重（越小越靠前） |
| `links` | LinkModel[] | 该分类下的链接列表 |

**LinkModel 字段：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `key` | string | 链接唯一标识 |
| `name` | string | 链接名称 |
| `url` | string | 目标 URL |
| `icon` | string\|null | 图标标识 |
| `description` | string\|null | 链接描述 |
| `index` | int | 排序权重 |

---

### 5.11 地图 /map

地图接口用于管理校园 POI（兴趣点），支持按分类、校区筛选和关键词搜索。

#### `GET /Map`

获取全部 POI。

**响应体 `data` 字段：** `MapPoiModel` 数组。

```json
{
  "code": 0,
  "message": "ok",
  "data": [
    {
      "id": 1,
      "name": "图书馆",
      "category": "建筑",
      "latitude": 34.1234,
      "longitude": 108.5678,
      "description": "草堂校区图书馆",
      "address": "草堂校区中心",
      "campus": "草堂",
      "icon": "library",
      "is_active": true,
      "sort_order": 0,
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-01-01T00:00:00Z"
    }
  ]
}
```

**MapPoiModel 字段说明：**

| 字段 | JSON Key | 类型 | 必须 | 说明 |
|------|----------|------|------|------|
| ID | `id` | int | 否 | POI ID（服务端自动生成） |
| 名称 | `name` | string (≤100) | 是 | POI 名称 |
| 分类 | `category` | string (≤50) | 是 | 分类名称 |
| 纬度 | `latitude` | double | 是 | 纬度 |
| 经度 | `longitude` | double | 是 | 经度 |
| 描述 | `description` | string? (≤500) | 否 | 描述 |
| 地址 | `address` | string? (≤200) | 否 | 地址 |
| 校区 | `campus` | string? (≤50) | 否 | 所属校区 |
| 图标 | `icon` | string? (≤200) | 否 | 图标标识 |
| 启用 | `is_active` | boolean | 否 | 是否启用 |
| 排序 | `sort_order` | int | 否 | 排序权重 |
| 创建时间 | `createdAt` | datetime | 否 | 创建时间（ISO 8601） |
| 更新时间 | `updatedAt` | datetime | 否 | 更新时间（ISO 8601） |

#### 其他 Map 端点

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/Map/{id}` | 获取指定 POI 详情 |
| GET | `/Map/category/{category}` | 按分类筛选 |
| GET | `/Map/campus/{campus}` | 按校区筛选 |
| GET | `/Map/search?keyword=` | 关键词搜索 |
| GET | `/Map/categories` | 获取所有分类（`string[]`） |
| GET | `/Map/campuses` | 获取所有校区（`string[]`） |

---

## 6. 数据格式速查表

### 6.1 时间 / 日期格式一览

| 场景 | 字段 | 格式 | 示例 |
|------|------|------|------|
| 考试时间 | `time` | `YYYY-MM-DD HH:MM~HH:MM` 或 `HH:MM-HH:MM` | `2026-07-13 15:00~16:00` |
| 学期起止 | `startTime` / `endTime` | ISO 8601 日期 | `2025-02-24` |
| 校车行驶时长 | `runTime` | `HH:MM:SS` | `01:20:00` |
| 校车到达时间 | `arrivalStationTime` | `xHH:MM`（带 x 前缀） | `x01:50` |
| 消费记录时间 | `datetimeStr` | `YYYY-MM-DD HH:mm:ss` | `2025-03-23 12:00:00` |
| 电费时间戳 | `timestamp` | ISO 8601 datetime | `2025-01-13T00:00:00Z` |
| 订阅时间戳 | `createdAt` 等 | ISO 8601 datetime | `2025-09-01T08:00:00Z` |
| 学期标识 | `value` | `YYYY-N` | `2025-2` |
| 学期名称 | `text` | `YYYY-YYYY学年第N学期` | `2025-2026学年第二学期` |
| 校车查询日期 | `date` 路径参数 | `YYYY-MM-DD` | `2026-04-27` |

### 6.2 特殊数值格式一览

| 场景 | 字段 | 单位 | 类型 | 示例 |
|------|------|------|------|------|
| 消费金额 | `tranamt` | **分** | number\|string | `1550` = 15.50元 |
| 校园卡余额 | `balance` | **分** | number\|string | `25080` = 250.80元 |
| 电费余额 | `data` | 元 | double | `42.50` = 42.50元 |
| 电费用量 | `value` | 度 | double | `3.5` = 3.5度 |
| 学分 | `credit` / `credits` | — | string | `"4.0"` |
| 绩点 | `gpa` | — | string | `"3.5"` |
| 学业学分 | `actual` / `full` | — | double | `45.0` / `60.0` |

### 6.3 枚举 / 特殊值一览

| 场景 | 字段 | 取值说明 |
|------|------|----------|
| 星期 | `weekday` | **API 约定值：`0`=周一, `1`=周二, …, `6`=周日。但实际运行时 App 按 1-7 处理（与 Dart `DateTime.weekday` 一致），请返回 1=周一 的值。** |
| 节次 | `startUnit` / `endUnit` | 通常 1~8，1=第一节课 |
| 成功状态码 | `code` | `null` / `0` / `"0"` / `200` / `"200"` |
| 多语言 | `x-language` header | `zh-CN`, `en`, `de`, `ru`, `fr`, `ja`, `ko`, `zh-TW` |
| 交易类型 | `turnoverType` | "消费" / "充值" / "补助" |
| 考核方式 | `examMode` | "考试" / "考查" |
| 课程类型 | `lessonType` | "必修" / "选修" |

---

## 7. 错误处理

### 7.1 HTTP 状态码约定

| 状态码 | 含义 | App 行为 |
|--------|------|----------|
| 200 | 成功 | 正常解析 |
| 204 | 成功（无内容） | 正常处理（如删除订阅） |
| 400 | 请求参数错误 | 显示 `message` 中的错误信息 |
| 401 | 未认证 | 触发自动重登录 |
| 403 | 无权限 | 触发自动重登录 |
| 404 | 资源不存在 | 显示 `message` 中的错误信息 |
| 500 | 服务器内部错误 | 显示 `message` 中的错误信息 |
| 502 | 网关错误 | 显示错误信息（上游教务系统不可用） |
| 503 | 服务不可用 | 显示错误信息（支付系统不可用） |

### 7.2 错误响应格式

错误响应同样使用 `ApiResponse` 包装器：

```json
{
  "code": 401,
  "message": "用户名或密码错误",
  "data": null
}
```

App 也兼容以下简化的错误格式：

**格式二（通用错误）：**
```json
{ "error": "服务器内部错误" }
```

**格式三（带消息的错误）：**
```json
{ "message": "上游服务暂不可用", "error": "503 Service Unavailable" }
```

### 7.3 网络超时

App 的请求超时设置为：
- 连接超时: 10秒
- 读取超时: 10秒
- 失败后自动重试 2 次（指数退避：500ms, 1000ms）

请确保你的接口在 10 秒内返回响应。

---

## 8. 接入检查清单

完成以下检查，确认你的后端与 App 完全兼容：

- [ ] 部署 HTTPS 服务（生产环境必须）
- [ ] 实现 `POST /Login`，返回 `ApiResponse` 包装的 `{success, studentId, cookie}`
- [ ] 实现 `GET /Info/Time`，返回 `{startTime, endTime}`（无需认证）
- [ ] 实现 `GET /Course`，返回课程列表（需要认证）
- [ ] 实现 `GET /Score/Semester` 和 `GET /Score`，返回成绩（需要认证）
- [ ] 实现 `GET /Exam`，**`time` 字段格式为 `YYYY-MM-DD HH:MM~HH:MM`**
- [ ] **`weekday` 请返回 1=周一（匹配 Dart `DateTime.weekday`），详情见 [5.2 课程字段说明](#52-课程-course)**
- [ ] **`tranamt` 和 `balance` 单位为分**（不是元）
- [ ] `semester.value` 格式为 `YYYY-N`（如 `2025-2`）
- [ ] 所有需要认证的接口在缺少/无效 Cookie 时返回 401
- [ ] Cookie 过期后返回 401（App 会自动重登）
- [ ] 使用 `ApiResponse` 统一包装响应（`code`、`message`、`data`、`total`）
- [ ] 接口响应时间 < 10 秒
- [ ] 数值字段可使用字符串或数字类型（App 均能解析）
- [ ] 接口支持 CORS（如需 Web 端访问）
- [ ] (可选) 实现校车、电费、校园卡、培养方案、地图等接口

---

## 附录：接口速查索引

| 方法 | 路径 | 认证 | 说明 |
|------|------|------|------|
| POST | `/Login` | 否 | 登录认证 |
| GET | `/Course` | 是 | 课程表 |
| GET | `/Exam` | 是 | 考试安排 |
| GET | `/Score/Semester` | 是 | 学期列表 |
| GET | `/Score` | 是 | 成绩详情 |
| GET | `/Score/ThisSemester` | 是 | 当前学期 |
| GET | `/Info/Completion` | 是 | 学业完成情况 |
| GET | `/Info/Time` | 是 | 学期时间信息 |
| GET | `/Bus/{date}` | 是 | 校车时刻表 |
| GET | `/Bus/NewData/{date}` | 是 | 校车新校区数据 |
| GET | `/Bus/OldData/{date}` | 是 | 校车旧校区数据 |
| GET | `/Payment/{id}` | 是 | 校园卡绑卡信息 |
| GET | `/Payment/{id}/turnover` | 是 | 校园卡消费流水 |
| GET | `/Electricity` | 是 | 电费余额查询 |
| GET | `/Electricity/WeeklyData` | 是 | 用电周报 |
| GET | `/Electricity/RechargeUrl` | 是 | 电费充值链接 |
| POST | `/Electricity/Subscriptions` | 是 | 创建余额告警订阅 |
| GET | `/Electricity/Subscriptions` | 是 | 查询订阅状态 |
| DELETE | `/Electricity/Subscriptions/{id}` | 是 | 取消订阅 |
| GET | `/Program` | 是 | 培养方案 |
| GET | `/Program/GetDic` | 是 | 培养方案（按学期分组） |
| GET | `/SchoolNav` | 否 | 校园导航链接 |
| GET | `/Map` | 否 | 校园地图 POI |
| GET | `/App/GetTag` | 否 | 应用版本更新 |
