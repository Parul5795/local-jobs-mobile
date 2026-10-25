import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../localjobs/models/localjobs_models.dart';
import '../../localjobs/models/localjobs_requests.dart';
import '../../localjobs/data/localjobs_repository.dart';
import '../../localjobs/providers/localjobs_providers.dart';

class CreateLocalAdScreen extends ConsumerStatefulWidget {
  final String? adId;
  final ClassifiedAd? initialAd;
  const CreateLocalAdScreen({super.key, this.adId, this.initialAd});
  @override
  ConsumerState<CreateLocalAdScreen> createState() =>
      _CreateLocalAdScreenState();
}

class _CreateLocalAdScreenState extends ConsumerState<CreateLocalAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController(),
      _description = TextEditingController(),
      _area = TextEditingController(),
      _price = TextEditingController(),
      _images = TextEditingController();
  int? _categoryId, _cityId;
  bool _isActive = true, _saving = false, _loadingExisting = false;
  @override
  void initState() {
    super.initState();
    if (widget.adId != null) Future.microtask(_loadExisting);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _area.dispose();
    _price.dispose();
    _images.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    setState(() => _loadingExisting = true);
    try {
      final ad =
          widget.initialAd ??
          await ref.read(localJobsRepositoryProvider).getAd(widget.adId!);
      _title.text = ad.title;
      _description.text = ad.description;
      _area.text = ad.area ?? '';
      _price.text = ad.price?.toString() ?? '';
      _images.text = ad.imageUrls.join(', ');
      _categoryId = ad.categoryId;
      _cityId = ad.cityId;
      _isActive = ad.isActive;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load this ad.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(adCategoriesProvider),
        citiesState = ref.watch(citiesProvider);
    final categories = categoriesState.asData?.value ?? const <LookupItem>[];
    final cities = citiesState.asData?.value ?? const <CityItem>[];
    if (categories.isNotEmpty && _categoryId == null) {
      _categoryId = categories.first.id;
    }
    if (cities.isNotEmpty && _cityId == null) _cityId = cities.first.id;
    final isEditing = widget.adId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit advertisement' : 'Create an advertisement',
        ),
      ),
      body: _loadingExisting
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (categoriesState.hasError || citiesState.hasError)
                        const Text(
                          'Could not load categories or cities. Please retry.',
                        ),
                      DropdownButtonFormField<int>(
                        initialValue: _categoryId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: [
                          for (final category in categories)
                            DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _categoryId = value),
                        validator: (value) =>
                            value == null ? 'Choose a category' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        initialValue: _cityId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'City'),
                        items: [
                          for (final city in cities)
                            DropdownMenuItem(
                              value: city.id,
                              child: Text(city.label),
                            ),
                        ],
                        onChanged: (value) => setState(() => _cityId = value),
                        validator: (value) =>
                            value == null ? 'Choose a city' : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(label: 'Area (optional)', controller: _area),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Title',
                        controller: _title,
                        validator: _required,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Description',
                        controller: _description,
                        maxLines: 4,
                        validator: _required,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Price (optional)',
                        controller: _price,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final price = double.tryParse(value.trim());
                          return price == null || price < 0
                              ? 'Enter a valid non-negative price'
                              : null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Image URLs (optional, comma separated)',
                        controller: _images,
                        hint: 'https://…',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ads do not currently support phone contact details or file uploads.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed:
                            _saving || categories.isEmpty || cities.isEmpty
                            ? null
                            : _submit,
                        child: _saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(),
                              )
                            : Text(
                                isEditing
                                    ? 'Save changes'
                                    : 'Post advertisement',
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _categoryId == null ||
        _cityId == null) {
      return;
    }
    setState(() => _saving = true);
    try {
      final imageUrls = _images.text
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList();
      final request = AdWriteRequest(
        title: _title.text,
        description: _description.text,
        adCategoryId: _categoryId!,
        cityId: _cityId!,
        price: _price.text.trim().isEmpty
            ? null
            : double.parse(_price.text.trim()),
        area: _area.text,
        imageUrls: imageUrls,
        isActive: widget.adId == null ? null : _isActive,
      );
      if (widget.adId == null) {
        await ref.read(localJobsRepositoryProvider).createAd(request);
      } else {
        await ref
            .read(localJobsRepositoryProvider)
            .updateAd(widget.adId!, request);
      }
      ref.invalidate(myAdsProvider);
      ref.invalidate(localAdsFeedProvider);
      if (widget.adId != null) ref.invalidate(adDetailsProvider(widget.adId!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.adId == null
                  ? 'Advertisement posted.'
                  : 'Advertisement updated.',
            ),
          ),
        );
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is ApiException
                  ? error.message
                  : 'Could not save this advertisement. Please check the details and retry.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
