import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../localjobs/data/localjobs_repository.dart';
import '../localjobs/providers/localjobs_providers.dart';

Future<void> startWorkerContact(
  BuildContext context,
  WidgetRef ref,
  String workerUserId,
  String method,
) async {
  final repository = ref.read(localJobsRepositoryProvider);
  var trackingFailed = false;
  String? phone;
  try {
    phone = (await repository.contactWorker(workerUserId, method)).phoneNumber;
  } catch (_) {
    trackingFailed = true;
    phone = repository.cachedPhoneForWorker(workerUserId);
  }
  if (!context.mounted) return;
  if (phone == null || phone.trim().isEmpty) {
    _show(context, 'Contact details could not be retrieved. Please try again.');
    return;
  }
  final uri = method == 'Call'
      ? Uri(scheme: 'tel', path: phone.trim())
      : Uri.https('wa.me', '/${phone.replaceAll(RegExp(r'[^0-9]'), '')}');
  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!opened) {
      _show(context, 'Could not open $method on this device.');
    } else if (trackingFailed) {
      _show(context, '$method opened; contact tracking could not be recorded.');
    }
  } catch (_) {
    if (context.mounted) {
      _show(context, 'Could not open $method on this device.');
    }
  }
  ref.invalidate(publicWorkerProfileProvider(workerUserId));
  ref.invalidate(workerSearchProvider);
  ref.invalidate(homeWorkerPreviewProvider);
}

void _show(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
