import 'package:equatable/equatable.dart';

class ApplicationFilters extends Equatable {
  final String? statusFilter;
  final String sortBy; // 'recent', 'oldest'

  const ApplicationFilters({
    this.statusFilter,
    this.sortBy = 'recent',
  });

  ApplicationFilters copyWith({
    String? statusFilter,
    String? sortBy,
  }) {
    return ApplicationFilters(
      statusFilter: statusFilter ?? this.statusFilter,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [statusFilter, sortBy];
}
