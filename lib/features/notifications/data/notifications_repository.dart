import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import 'notifications_api_service.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) =>
      NotificationsRepositoryImpl(ref.watch(notificationsApiServiceProvider)),
);

abstract class NotificationsRepository {
  Future<List<AppNotification>> fetchNotifications(String role);
  Future<List<AppNotification>> markAsRead(String role, String id);
  Future<List<AppNotification>> markAllAsRead(String role);
}

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsApiService _service;

  const NotificationsRepositoryImpl(this._service);

  @override
  Future<List<AppNotification>> fetchNotifications(String role) =>
      _service.fetchNotifications(role);

  @override
  Future<List<AppNotification>> markAsRead(String role, String id) =>
      _service.markAsRead(role, id);

  @override
  Future<List<AppNotification>> markAllAsRead(String role) =>
      _service.markAllAsRead(role);
}
