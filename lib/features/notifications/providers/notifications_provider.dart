import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/auth_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/notifications_repository.dart';
import '../models/app_notification.dart';

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
      NotificationsNotifier.new,
    );

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  String _role = 'JobSeeker';

  @override
  Future<List<AppNotification>> build() async {
    final auth = ref.watch(authStateProvider);
    _role = auth is Authenticated ? auth.user.role : 'JobSeeker';
    return ref.read(notificationsRepositoryProvider).fetchNotifications(_role);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(notificationsRepositoryProvider).fetchNotifications(_role),
    );
  }

  Future<void> markAsRead(String id) async {
    final current = state.asData?.value;
    if (current == null) return;
    final updated = await ref
        .read(notificationsRepositoryProvider)
        .markAsRead(_role, id);
    state = AsyncData(updated);
  }

  Future<void> markAllAsRead() async {
    final current = state.asData?.value;
    if (current == null || current.every((item) => item.isRead)) return;
    final updated = await ref
        .read(notificationsRepositoryProvider)
        .markAllAsRead(_role);
    state = AsyncData(updated);
  }
}

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications =
      ref.watch(notificationsProvider).asData?.value ?? const [];
  return notifications.where((notification) => !notification.isRead).length;
});
