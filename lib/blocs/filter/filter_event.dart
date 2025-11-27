abstract class FilterEvent {}
class SetDateRange extends FilterEvent {
  final DateTime from;
  final DateTime to;
  SetDateRange({required this.from, required this.to});
}
class ClearFilters extends FilterEvent {}
