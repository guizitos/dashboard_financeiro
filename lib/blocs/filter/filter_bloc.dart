import 'package:bloc/bloc.dart';
import 'filter_event.dart';
import 'filter_state.dart';
//Filtros de transações
class FilterBloc extends Bloc<FilterEvent, FilterState> {
  FilterBloc() : super(FilterInitial()) {
    on<SetDateRange>((event, emit) {
      emit(FilterApplied(event.from, event.to));
    });

    on<ClearFilters>((event, emit) {
      emit(FilterInitial());
    });
  }
}
