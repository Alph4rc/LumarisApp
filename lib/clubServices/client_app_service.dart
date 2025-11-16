import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/clubServices/api_client.dart';
import 'package:ios_club_app/clubModels/client_application.dart';
import 'package:ios_club_app/clubModels/create_client_app_model.dart';
import 'package:ios_club_app/clubModels/update_client_app_model.dart';
import 'package:ios_club_app/clubModels/regenerate_secret_result.dart';

class ClientAppService {
  /// 获取所有客户端应用
  static Future<List<ClientApplication>?> getAllClientApps() async {
    try {
      final response = await ApiClient.get('/ClientApp');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ClientApplication.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching all client apps: $e');
      }
    }
    return null;
  }

  /// 创建客户端应用
  static Future<ClientApplication?> createClientApp(CreateClientAppModel appData) async {
    try {
      final response = await ApiClient.post('/ClientApp', body: appData.toJson());
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ClientApplication.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating client app: $e');
      }
    }
    return null;
  }

  /// 根据客户端ID获取应用
  static Future<ClientApplication?> getClientAppById(String clientId) async {
    try {
      final response = await ApiClient.get('/ClientApp/$clientId');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ClientApplication.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching client app by ID: $e');
      }
    }
    return null;
  }

  /// 更新客户端应用
  static Future<bool> updateClientApp(String clientId, UpdateClientAppModel appData) async {
    try {
      final response = await ApiClient.put('/ClientApp/$clientId', body: appData.toJson());
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating client app: $e');
      }
    }
    return false;
  }

  /// 删除客户端应用
  static Future<bool> deleteClientApp(String clientId) async {
    try {
      final response = await ApiClient.delete('/ClientApp/$clientId');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting client app: $e');
      }
    }
    return false;
  }

  /// 重新生成客户端密钥
  static Future<RegenerateSecretResult?> regenerateClientSecret(String clientId) async {
    try {
      final response = await ApiClient.post('/ClientApp/$clientId/regenerate-secret');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return RegenerateSecretResult.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error regenerating client secret: $e');
      }
    }
    return null;
  }
}