import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/user_model.dart';
import '../models/update_user_request.dart';
import 'user_account_api_service.dart';

final userAccountRepositoryProvider = Provider<UserAccountRepository>(
  (ref) => UserAccountRepository(ref.watch(userAccountApiServiceProvider)),
);

class UserAccountRepository {
  final UserAccountApiService _service;
  const UserAccountRepository(this._service);

  Future<UserModel> getMe() => _service.getMe();
  Future<UserModel> updateMe(UpdateUserRequest request) =>
      _service.updateMe(request);
}
