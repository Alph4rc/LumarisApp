import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';
import 'package:ios_club_app/features/club/models/resource_model.dart';
import 'package:ios_club_app/features/club/utils/api_response_helper.dart';

class ResourceService {
  /// 获取所有资源
  static Future<List<ResourceModel>?> getAllResources() async {
    try {
      final response = await ApiClient.get('/Resource');
      return await ApiResponseHelper.parseList(
        response,
        ResourceModel.fromJson,
        errorMessage: 'Error fetching all resources',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching all resources: $e');
      }
      return null;
    }
  }

  /// 创建资源
  static Future<ResourceModel?> createResource(ResourceModel resourceData) async {
    try {
      final response = await ApiClient.post('/Resource', body: resourceData.toJson());
      return await ApiResponseHelper.parseSingleObject(
        response,
        ResourceModel.fromJson,
        errorMessage: 'Error creating resource',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating resource: $e');
      }
      return null;
    }
  }

  /// 更新资源
  static Future<bool> updateResource(ResourceModel resourceData) async {
    try {
      final response = await ApiClient.put('/Resource', body: resourceData.toJson());
      return await ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error updating resource',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating resource: $e');
      }
      return false;
    }
  }

  /// 根据ID获取资源
  static Future<ResourceModel?> getResourceById(String id) async {
    try {
      final response = await ApiClient.get('/Resource/$id');
      return await ApiResponseHelper.parseSingleObject(
        response,
        ResourceModel.fromJson,
        errorMessage: 'Error fetching resource by ID',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching resource by ID: $e');
      }
      return null;
    }
  }

  /// 删除资源
  static Future<bool> deleteResource(String id) async {
    try {
      final response = await ApiClient.delete('/Resource/$id');
      return await ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error deleting resource',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting resource: $e');
      }
      return false;
    }
  }

  /// 根据标签获取资源
  static Future<List<ResourceModel>?> getResourcesByTag(String tag) async {
    try {
      final response = await ApiClient.get('/Resource/tag/$tag');
      return await ApiResponseHelper.parseList(
        response,
        ResourceModel.fromJson,
        errorMessage: 'Error fetching resources by tag',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching resources by tag: $e');
      }
      return null;
    }
  }

  /// 根据名称搜索资源
  static Future<List<ResourceModel>?> searchResourcesByName(String name) async {
    try {
      final response = await ApiClient.get('/Resource/search/$name');
      return await ApiResponseHelper.parseList(
        response,
        ResourceModel.fromJson,
        errorMessage: 'Error searching resources by name',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error searching resources by name: $e');
      }
      return null;
    }
  }

  /// 获取所有标签
  static Future<List<String>?> getAllTags() async {
    try {
      final response = await ApiClient.get('/Resource/tags');
      final data = await ApiResponseHelper.parseRaw<List<dynamic>>(
        response,
        errorMessage: 'Error fetching all tags',
      );
      if (data != null) {
        return data.map((e) => e as String).toList();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching all tags: $e');
      }
      return null;
    }
  }

  /// 获取资源统计信息
  static Future<bool> getResourceStatistics() async {
    try {
      final response = await ApiClient.get('/Resource/statistics');
      return await ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error fetching resource statistics',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching resource statistics: $e');
      }
      return false;
    }
  }
}