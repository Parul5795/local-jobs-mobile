import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../models/job_model.dart';
import 'jobs_repository.dart';

final savedJobsRepositoryProvider = Provider<SavedJobsRepository>((ref) {
  return SavedJobsRepositoryImpl(
    ref.watch(secureStorageServiceProvider),
    ref.watch(jobsRepositoryProvider),
  );
});

abstract class SavedJobsRepository {
  Future<List<Job>> loadSavedJobs(String userId);
  Future<void> saveJobIds(String userId, List<String> jobIds);
}

class SavedJobsRepositoryImpl implements SavedJobsRepository {
  final SecureStorageService _storage;
  final JobsRepository _jobsRepository;

  const SavedJobsRepositoryImpl(this._storage, this._jobsRepository);

  String _keyFor(String userId) => 'saved_jobs_$userId';

  @override
  Future<List<Job>> loadSavedJobs(String userId) async {
    final raw = await _storage.readValue(_keyFor(userId));
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    final ids = decoded.whereType<String>().toList();
    final jobs = await Future.wait(ids.map(_jobsRepository.fetchJobById));
    return jobs.whereType<Job>().toList(growable: false);
  }

  @override
  Future<void> saveJobIds(String userId, List<String> jobIds) async {
    final uniqueIds = jobIds.toSet().toList(growable: false);
    await _storage.writeValue(
      key: _keyFor(userId),
      value: jsonEncode(uniqueIds),
    );
  }
}
