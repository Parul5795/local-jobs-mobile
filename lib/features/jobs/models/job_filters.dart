import 'package:equatable/equatable.dart';

class JobFilters extends Equatable {
  final String query;
  final String category;
  final String city;

  const JobFilters({
    this.query = '',
    this.category = 'All',
    this.city = 'All',
  });

  JobFilters copyWith({
    String? query,
    String? category,
    String? city,
  }) {
    return JobFilters(
      query: query ?? this.query,
      category: category ?? this.category,
      city: city ?? this.city,
    );
  }

  @override
  List<Object?> get props => [query, category, city];
}
