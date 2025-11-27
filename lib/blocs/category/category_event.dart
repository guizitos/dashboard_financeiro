import '../../models/category.dart';
abstract class CategoryEvent {}
class LoadCategories extends CategoryEvent {}
class AddCategory extends CategoryEvent { final CategoryModel category; AddCategory(this.category); }
