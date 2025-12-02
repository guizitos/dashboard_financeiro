import 'package:bloc/bloc.dart';
import '../../data/db_provider.dart';
import '../../models/category.dart';
import 'category_event.dart';
import 'category_state.dart';
//Lógica de categorias
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryInitial()) {
    on<LoadCategories>((event, emit) async {
      emit(CategoryLoading());
      try {
        final db = await DBProvider.db.database;
        final res = await db.query('categories', orderBy: 'name ASC');
        final cats = res.map((e) => CategoryModel.fromMap(e)).toList();
        emit(CategoryLoaded(cats));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<AddCategory>((event, emit) async {
      if (state is CategoryLoaded) {
        final db = await DBProvider.db.database;
        await db.insert('categories', event.category.toMap());
        add(LoadCategories());
      }
    });
  }
}
