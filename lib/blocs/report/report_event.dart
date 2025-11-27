abstract class ReportEvent {}
class GenerateReport extends ReportEvent { final DateTime from; final DateTime to; GenerateReport({required this.from, required this.to}); }
