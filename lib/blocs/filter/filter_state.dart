abstract class FilterState {}
class FilterInitial extends FilterState {}
class FilterApplied extends FilterState {
  final DateTime from;
  final DateTime to;
  FilterApplied(this.from, this.to);
}
