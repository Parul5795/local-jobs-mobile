import 'package:equatable/equatable.dart';

class JobFilters extends Equatable {
  final String query;
  final int? categoryId, cityId;
  final String? area;
  final String category, city;
  const JobFilters({
    this.query = '',
    this.categoryId,
    this.cityId,
    this.area,
    this.category = 'All',
    this.city = 'All',
  });
  JobFilters copyWith({
    String? query,
    int? categoryId,
    int? cityId,
    String? area,
    bool clearCategory = false,
    bool clearCity = false,
    bool clearArea = false,
    String? category,
    String? city,
  }) => JobFilters(
    query: query ?? this.query,
    categoryId: clearCategory ? null : categoryId ?? this.categoryId,
    cityId: clearCity ? null : cityId ?? this.cityId,
    area: clearArea ? null : area ?? this.area,
    category: category ?? this.category,
    city: city ?? this.city,
  );
  @override
  List<Object?> get props => [query, categoryId, cityId, area, category, city];
}
