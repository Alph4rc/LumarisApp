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
- [6. 错误处理](#6-错误处理)
- [7. 接入检查清单](#7-接入检查清单)

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
| **必须** | `POST /login` | 用户登录，获取认证 Cookie |
| **必须** | `GET /course?studentId=` | 获取课程表 |
| **必须** | `GET /score?studentId=&semester=` | 获取成绩 |
| **必须** | `GET /score/Semester?studentId=` | 获取学期列表 |
| **必须** | `GET /info/Time` | 获取当前学期时间范围 |
| **推荐** | `GET /exam?studentId=` | 获取考试安排 |
| **推荐** | `GET /bus/{time}` | 获取校车时刻表 |
| **推荐** | `GET /schoolnav` | 获取校园导航链接 |
| **可选** | `/electricity/*` | 电费查询与订阅 |
| **可选** | `/payment/*` | 校园卡流水 |
| **可选** | `/program/*` | 培养方案查询 |
| **可选** | `/map/*` | 校园地图 POI |

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
 |-- POST /login ----------->|
 |   {username, password}       |
 |                              |
 |<--- 200 OK ------------------|
 |   {code, message, data:      |
 |    {success, studentId,      |
 |     cookie}}                 |
 |                              |
 |-- 后续请求 ------------------>|
 |   Header: Cookie: <cookie>   |
 |   Header: xauat: <cookie>    |
```

1. App 发送 `POST /login`，请求体为 `{"username": "...", "password": "..."}`
2. 后端验证凭证后返回 `cookie` 字段
3. App 将 cookie 持久化存储
4. 后续所有请求携带 `Cookie` 和 `xauat` 两个请求头，值均为该 cookie

### 3.2 登录接口

**请求:**

```json
POST /login
Content-Type: application/json

{
  "username": "学号",
  "password": "密码"
}
```

**成功响应 (200):**

```json
{
  "code": 200,
  "message": "OK",
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
- 使用本地安全存储的用户名/密码重新调用 `/login`
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
```

### 4.2 统一响应格式

所有接口使用 `ApiResponse` 包装器返回数据：

| 字段 | 类型 | 说明 |
|------|------|------|
| code | int/string | 状态码。200 表示成功，其他值表示错误 |
| message | string | 提示信息 |
| data | any/null | 实际返回数据，类型因接口而异 |
| total | int/null | 列表接口的记录总数（可选） |

**列表响应示例:**

```json
{
  "code": 200,
  "message": "OK",
  "data": [...],
  "total": 10
}
```

**单对象响应示例:**

```json
{
  "code": 200,
  "message": "OK",
  "data": {...}
}
```

### 4.3 数值类型灵活性

**重要**: App 的 JSON 解析器对数值字段具有类型灵活性。你的 API 返回数值时可以使用：

- `"3"` (字符串) 或 `3` (数字) —— 均可正常解析
- `3.5` (浮点数) 或 `"3.5"` (字符串) —— 均可正常解析
- `null` / `0` / `"0"` —— 均视为 0

这适用于所有标记为 `int32`/`int64`/`double` 的字段。你无需担心返回类型的精确匹配。

### 4.4 空值处理

所有可为空的字段，App 均能正确处理 `null` 值。对于字符串字段，`null` 和 `""` 等价。

### 4.5 日期时间格式

使用 ISO 8601 格式：`2024-09-01T08:00:00` 或 `2024-09-01T08:00:00Z`

---

## 5. API 接口规范

### 5.1 登录 /login

#### `POST /login`

认证用户身份并返回会话令牌。

**请求体：**

| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| username | string | 是 | 学号或用户名 |
| password | string | 是 | 密码（明文） |

**响应体 `data` 字段 (LoginResponse)：**

| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| success | boolean | 是 | 登录是否成功 |
| studentId | string | 否 | 学号 |
| cookie | string | 是 | 会话令牌，用于后续请求认证 |

**响应示例：**

```json
{
  "code": 200,
  "message": "OK",
  "data": {
    "success": true,
    "studentId": "20210001",
    "cookie": "session_token_or_cookie_value"
  }
}
```

---

### 5.2 课程 /course

#### `GET /course?studentId={studentId}`

获取指定学生的课程表。

**请求参数：**

| 参数 | 类型 | 必须 | 说明 |
|------|------|------|------|
| studentId | string | 否 | 学号。未传时返回当前登录用户的课程 |

**响应体 `data` 字段：** `CourseActivity` 数组。

```json
{
  "code": 200,
  "message": "OK",
  "data": [
    {
      "courseName": "高等数学",
      "courseCode": "MATH1001",
      "lessonId": "2024-MATH1001-01",
      "teachers": ["张三"],
      "room": "教一楼301",
      "campus": "雁塔校区",
      "weekday": 1,
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
| courseName | string | 课程名称 |
| courseCode | string | 课程代码 |
| lessonId | string | 教学班 ID（用于课程去重和识别） |
| teachers | string[] | 授课教师列表 |
| room | string | 上课教室 |
| campus | string | 校区名称 |
| weekday | int | 星期几（1=周一, 7=周日） |
| startUnit | int | 开始节次（如第1节） |
| endUnit | int | 结束节次（如第2节） |
| weekIndexes | int[] | 上课周次列表（如 [1,2,3,...,16]） |
| credits | string | 学分 |

> **lessonId 是关键字段**：App 使用它来匹配用户自定义课程。如果可能，请保持 lessonId 在不同查询之间的稳定性。

---

### 5.3 成绩 /score

#### `GET /score/Semester?studentId={studentId}`

获取所有可用学期列表。

**响应体 `data` 字段 (SemesterResult)：**

```json
{
  "code": 200,
  "message": "OK",
  "data": {
    "data": [
      { "value": "2024-2025-1", "text": "2024-2025学年第一学期" },
      { "value": "2023-2024-2", "text": "2023-2024学年第二学期" }
    ]
  }
}
```

**SemesterItem 字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| value | string | 学期标识符（用于请求成绩详情） |
| text | string | 学期显示名称 |

#### `GET /score?studentId={studentId}&semester={semester}`

获取指定学期的成绩详情。

**响应体 `data` 字段：** `ScoreResponse` 数组。

```json
{
  "code": 200,
  "message": "OK",
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

**ScoreResponse 字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| name | string | 学期名称 |
| lessonCode | string | 课程代码 |
| lessonName | string | 课程名称 |
| grade | string | 成绩（可以是分数或等级，如 "85" / "良好"） |
| gpa | string | 绩点（如 "3.5"，无绩点体系可留空） |
| gradeDetail | string | 成绩明细（如平时分/期末分，可选） |
| credit | string | 学分 |
| isMinor | boolean | 是否为辅修课程 |

#### `GET /score/ThisSemester`

获取当前学期标识（不要求登录）。用于App首页显示当前学期名称。

**响应体 `data` 字段 (SemesterItem)：**

```json
{
  "code": 200,
  "message": "OK",
  "data": {
    "value": "2024-2025-2",
    "text": "2024-2025学年第二学期"
  }
}
```

---

### 5.4 考试 /exam

#### `GET /exam?studentId={studentId}`

获取考试安排。

**请求参数：**

| 参数 | 类型 | 必须 | 说明 |
|------|------|------|------|
| studentId | string | 否 | 学号 |

**响应体 `data` 字段 (ExamResponse)：**

```json
{
  "code": 200,
  "message": "OK",
  "data": {
    "exams": [
      {
        "name": "高等数学",
        "time": "2025-01-15 09:00:00",
        "location": "教一楼301",
        "seat": "15"
      }
    ],
    "canClick": false,
    "error": null
  }
}
```

**ExamInfo 字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| name | string | 课程名称 |
| time | string | 考试时间 |
| location | string | 考试地点 |
| seat | string | 座位号 |

**ExamResponse 顶层字段：**

| 字段 | 类型 | 说明 |
|------|------|------|
| exams | ExamInfo[] | 考试安排列表 |
| canClick | boolean | 考试详情是否可点击查看（通常为 false） |
| error | string\|null | 错误信息，正常时为 null |

---

### 5.5 校车 /bus

#### `GET /bus/{time}`

获取指定日期的校车时刻表。`time` 参数格式为 `yyyy-MM-dd`。

**响应体 `data` 字段 (BusModel)：**

```json
{
  "code": 200,
  "message": "OK",
  "data": {
    "records": [
      {
        "lineName": "雁塔→草堂",
        "description": "工作日班车",
        "departureStation": "雁塔校区南门",
        "arrivalStation": "草堂校区东门",
        "runTime": "07:30",
        "arrivalStationTime": "08:30"
      }
    ],
    "total": 1
  }
}
```

**BusItem 字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| lineName | string | 线路名称 |
| description | string | 描述（如"周末班车"） |
| departureStation | string | 出发站 |
| arrivalStation | string | 到达站 |
| runTime | string | 发车时间（HH:mm） |
| arrivalStationTime | string | 到达时间（HH:mm） |

#### `GET /bus/NewData/{time}?loc={loc}`

获取新校区班车数据（草堂校区）。参数：
- `time`: 日期 `yyyy-MM-dd`
- `loc`: 可选，默认为 `ALL`

响应格式与 `/bus/{time}` 相同。

#### `GET /bus/OldData/{time}?isShow={true|false}`

获取老校区班车数据（雁塔校区）。参数：
- `time`: 日期 `yyyy-MM-dd`
- `isShow`: 可选，默认为 `false`

响应格式与 `/bus/{time}` 相同。

> 如果你的学校只有一个校区，只需实现 `/bus/{time}` 即可。App 内部会同时调用所有三个接口并合并结果。

---

### 5.6 电费 /electricity

#### `GET /electricity?url={roomUrl}`

查询指定房间的当前电费余额。

**响应体 `data` 字段：** 数字（double），表示剩余金额（元）。

```json
{
  "code": 200,
  "message": "OK",
  "data": 42.50
}
```

#### `GET /electricity/WeeklyData?url={roomUrl}`

查询指定房间的周用电数据。

**响应体 `data` 字段：** `ElectricData` 数组。

```json
{
  "code": 200,
  "message": "OK",
  "data": [
    { "timestamp": "2025-01-13T00:00:00", "value": 3.5 },
    { "timestamp": "2025-01-14T00:00:00", "value": 2.8 }
  ]
}
```

**ElectricData 字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| timestamp | datetime | 数据时间点 |
| value | double | 当日用电量（度） |

#### `GET /electricity/RechargeUrl?url={roomUrl}`

获取电费充值页面 URL。

**响应体 `data` 字段：** 字符串 URL。

```json
{
  "code": 200,
  "message": "OK",
  "data": "https://pay.example.com/electricity/recharge?room=123"
}
```

#### `POST /electricity/Subscriptions`

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
| url | string(≤1024) | 是 | 房间查询 URL |
| email | string(≤256) | 是 | 通知邮箱 |
| threshold | double(≥0.01) | 否 | 余额预警阈值（元） |

**响应体 `data` 字段 (ElectricitySubscriptionResponse)：**

```json
{
  "code": 200,
  "message": "OK",
  "data": {
    "id": "sub_123",
    "url": "...",
    "email": "user@example.com",
    "threshold": 10.0,
    "isActive": true,
    "createdAt": "2025-01-15T10:30:00",
    "updatedAt": "2025-01-15T10:30:00",
    "nextCheckAt": "2025-01-16T10:30:00",
    "lastCheckedAt": null,
    "lastKnownBalance": null,
    "lastAlertedAt": null,
    "lastAlertedBalance": null,
    "lastErrorMessage": ""
  }
}
```

#### `GET /electricity/Subscriptions?email={email}`

查询某个邮箱的订阅状态。

**响应体 `data` 字段 (ElectricitySubscriptionQueryResponse)：**

```json
{
  "code": 200,
  "message": "OK",
  "data": {
    "email": "user@example.com",
    "threshold": 10.0,
    "hasSubscription": true,
    "subscriptionId": "sub_123"
  }
}
```

#### `DELETE /electricity/Subscriptions/{id}`

取消订阅。成功返回 HTTP 204 No Content。

---

### 5.7 校园卡 /payment

#### `GET /payment/{id}`

获取电子校园卡绑定 URL 或状态。`id` 为学号。

**响应体 `data` 字段：** 字符串（HTML 页面或 URL）。

```json
{
  "code": 200,
  "message": "OK",
  "data": "<html>...</html>"
}
```

#### `GET /payment/{id}/turnover`

获取校园卡消费流水。

**响应体 `data` 字段 (PaymentData)：**

```json
{
  "code": 200,
  "message": "OK",
  "data": {
    "records": [
      {
        "turnoverType": "消费",
        "datetimeStr": "2025-01-15 12:30:00",
        "resume": "食堂二楼",
        "tranamt": 15.50
      }
    ],
    "total": 1250.80
  }
}
```

**PaymentModel 字段：**

| 字段 | 类型 | 说明 |
|------|------|------|
| turnoverType | string | 交易类型（消费/充值/补助） |
| datetimeStr | string | 交易时间 |
| resume | string | 交易摘要/商户名称 |
| tranamt | double | 交易金额（元，正数为收入，负数为支出） |

**PaymentData 顶层字段：**

| 字段 | 类型 | 说明 |
|------|------|------|
| records | PaymentModel[] | 流水记录列表 |
| total | double | 统计总额 |

---

### 5.8 培养方案 /program

#### `GET /program?id={majorId}&name={studentName}`

查询某个专业的培养方案课程列表。

**请求参数：**

| 参数 | 类型 | 必须 | 说明 |
|------|------|------|------|
| id | string | 否 | 专业 ID |
| name | string | 否 | 学生姓名（用于个性化查询） |

**响应体 `data` 字段：** `PlanCourse` 数组。

```json
{
  "code": 200,
  "message": "OK",
  "data": [
    {
      "name": "高等数学",
      "lessonType": "必修",
      "examMode": "考试",
      "courseTypeName": "公共基础课",
      "credits": 4.0,
      "termStr": "2024-2025-1"
    }
  ],
  "total": 1
}
```

**PlanCourse 字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| name | string | 课程名称 |
| lessonType | string | 课程类型（必修/选修） |
| examMode | string | 考核方式（考试/考查） |
| courseTypeName | string | 课程类别（公共基础课/专业基础课等） |
| credits | double | 学分 |
| termStr | string | 开课学期 |

#### `GET /program/GetDic?id={majorId}`

获取按学期分组的培养方案字典。

**响应体 `data` 字段：** 字典对象，key 为学期字符串，value 为该学期的 `PlanCourse` 数组。

```json
{
  "code": 200,
  "message": "OK",
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

#### `GET /info/Time`

获取当前学期信息。App 启动时首先调用此接口，用于学期判断和周次计算。

**响应体 `data` 字段 (TimeModel)：**

```json
{
  "code": 200,
  "message": "OK",
  "data": {
    "startTime": "2025-02-24",
    "endTime": "2025-07-05"
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| startTime | string | 本学期开始日期（yyyy-MM-dd） |
| endTime | string | 本学期结束日期（yyyy-MM-dd） |

> App 会根据 startTime 和当前日期自动计算当前是第几教学周。

#### `GET /info/Completion`

获取学业完成情况（学分修读进度）。

**响应体 `data` 字段：** `StudyModule` 数组。

```json
{
  "code": 200,
  "message": "OK",
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
| type | string | 课程类别 |
| total | CreditInfo | 总学分信息 |
| other | CreditInfo[] | 子类别详情 |

**CreditInfo 字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| name | string | 类别名称 |
| actual | double | 已获学分 |
| full | double | 应修学分 |

---

### 5.10 导航 /schoolnav

#### `GET /schoolnav`

获取校园导航链接分类列表。用于 App 的"校园导航"功能页面。

**响应体 `data` 字段：** `CategoryModel` 数组。

```json
{
  "code": 200,
  "message": "OK",
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
| key | string | 分类唯一标识 |
| name | string | 分类名称 |
| description | string\|null | 分类描述 |
| icon | string | 图标标识（App 内置图标映射） |
| index | int | 排序权重（越小越靠前） |
| links | LinkModel[] | 该分类下的链接列表 |

**LinkModel 字段：**

| 字段 | 类型 | 说明 |
|------|------|------|
| key | string | 链接唯一标识 |
| name | string | 链接名称 |
| url | string | 目标 URL |
| icon | string\|null | 图标标识 |
| description | string\|null | 链接描述 |
| index | int | 排序权重 |

---

### 5.11 地图 /map

地图接口用于管理校园 POI（兴趣点），支持按分类、校区筛选和关键词搜索。

#### `GET /map`

获取全部 POI。

**响应体 `data` 字段：** `MapPoiModel` 数组。

```json
{
  "code": 200,
  "message": "OK",
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
      "createdAt": "2025-01-01T00:00:00",
      "updatedAt": "2025-01-01T00:00:00"
    }
  ],
  "total": 1
}
```

#### `GET /map/{id}`

获取指定 ID 的 POI 详情。

**响应体 `data` 字段：** 单个 `MapPoiModel`。

#### `GET /map/category/{category}`

按分类筛选 POI。`category` 为分类名称（如"建筑"、"食堂"）。

#### `GET /map/campus/{campus}`

按校区筛选 POI。`campus` 为校区名称（如"草堂"、"雁塔"）。

#### `GET /map/search?keyword={keyword}`

关键词搜索 POI。

#### `GET /map/categories`

获取所有 POI 分类列表。

**响应体 `data` 字段：** 字符串数组。

```json
{
  "code": 200,
  "message": "OK",
  "data": ["建筑", "食堂", "宿舍", "运动场"]
}
```

#### `GET /map/campuses`

获取所有校区列表。

**响应体 `data` 字段：** 字符串数组。

```json
{
  "code": 200,
  "message": "OK",
  "data": ["草堂", "雁塔"]
}
```

**MapPoiModel 字段说明：**

| 字段 | 类型 | 必须 | 说明 |
|------|------|------|------|
| id | int | 否 | POI ID（服务端自动生成） |
| name | string(≤100) | 是 | POI 名称 |
| category | string(≤50) | 是 | 分类名称 |
| latitude | double | 是 | 纬度 |
| longitude | double | 是 | 经度 |
| description | string(≤500) | 否 | 描述 |
| address | string(≤200) | 否 | 地址 |
| campus | string(≤50) | 否 | 所属校区 |
| icon | string(≤200) | 否 | 图标标识 |
| is_active | boolean | 否 | 是否启用 |
| sort_order | int | 否 | 排序权重 |
| createdAt | datetime | 否 | 创建时间（服务端自动生成） |
| updatedAt | datetime | 否 | 更新时间（服务端自动生成） |

---

## 6. 错误处理

### 6.1 HTTP 状态码约定

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
| 503 | 服务不可用 | 显示错误信息 |

### 6.2 错误响应格式

错误响应同样使用 `ApiResponse` 包装器，`code` 字段表示对应的 HTTP 状态码：

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
{
  "error": "服务器内部错误"
}
```

**格式三（带消息的错误）：**

```json
{
  "message": "上游服务暂不可用",
  "error": "503 Service Unavailable"
}
```

### 6.3 网络超时

App 的请求超时设置为：
- 连接超时: 10秒
- 读取超时: 10秒
- 失败后自动重试 2 次（指数退避：500ms, 1000ms）

请确保你的接口在 10 秒内返回响应。

---

## 7. 接入检查清单

完成以下检查，确认你的后端与 App 完全兼容：

- [ ] 部署 HTTPS 服务（生产环境必须）
- [ ] 实现 `POST /login`，返回 `ApiResponse` 包装的 `{success, studentId, cookie}`
- [ ] 实现 `GET /info/Time`，返回 `{startTime, endTime}`（无需认证）
- [ ] 实现 `GET /course`，返回课程列表（需要认证）
- [ ] 实现 `GET /score/Semester` 和 `GET /score`，返回成绩（需要认证）
- [ ] 所有需要认证的接口在缺少/无效 Cookie 时返回 401
- [ ] Cookie 过期后返回 401（App 会自动重登）
- [ ] 使用 `ApiResponse` 统一包装响应（`code`、`message`、`data`、`total`）
- [ ] 接口响应时间 < 10 秒
- [ ] 数值字段可使用字符串或数字类型（App 均能解析）
- [ ] 接口支持 CORS（如需 Web 端访问）
- [ ] (可选) 实现校车、电费、校园卡、培养方案、地图等接口
