import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/clubServices/api_client.dart';
import 'package:ios_club_app/clubModels/resource_model.dart';

class ResourceService {
  /// 获取所有资源
  static Future<List<ResourceModel>?> getAllResources() async {
    try {
      final response = await ApiClient.get('/Resource');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ResourceModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching all resources: $e');
      }
    }
    return null;
  }

  /// 创建资源
  static Future<ResourceModel?> createResource(ResourceModel resourceData) async {
    try {
      final response = await ApiClient.post('/Resource', body: resourceData.toJson());
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ResourceModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating resource: $e');
      }
    }
    return null;
  }

  /// 更新资源
  static Future<bool> updateResource(ResourceModel resourceData) async {
    try {
      final response = await ApiClient.put('/Resource', body: resourceData.toJson());
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating resource: $e');
      }
    }
    return false;
  }

  /// 根据ID获取资源
  static Future<ResourceModel?> getResourceById(String id) async {
    try {
      final response = await ApiClient.get('/Resource/$id');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ResourceModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching resource by ID: $e');
      }
    }
    return null;
  }

  /// 删除资源
  static Future<bool> deleteResource(String id) async {
    try {
      final response = await ApiClient.delete('/Resource/$id');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting resource: $e');
      }
    }
    return false;
  }

  /// 根据标签获取资源
  static Future<List<ResourceModel>?> getResourcesByTag(String tag) async {
    try {
      final response = await ApiClient.get('/Resource/tag/$tag');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ResourceModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching resources by tag: $e');
      }
    }
    return null;
  }

  /// 根据名称搜索资源
  static Future<List<ResourceModel>?> searchResourcesByName(String name) async {
    try {
      final response = await ApiClient.get('/Resource/search/$name');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ResourceModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching resources by name: $e');
      }
    }
    return null;
  }

  /// 获取所有标签
  static Future<List<String>?> getAllTags() async {
    try {
      final response = await ApiClient.get('/Resource/tags');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as String).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching all tags: $e');
      }
    }
    return null;
  }

  /// 获取资源统计信息
  static Future<bool> getResourceStatistics() async {
    try {
      final response = await ApiClient.get('/Resource/statistics');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching resource statistics: $e');
      }
    }
    return false;
  }
}