abstract class ReportState {}
class ReportInitial extends ReportState {}
class ReportLoading extends ReportState {}
class ReportGenerated extends ReportState {
  final Map<String, double> totalsByCategory;
  ReportGenerated(this.totalsByCategory);
}
class ReportError extends ReportState { final String message; ReportError(this.message); }
