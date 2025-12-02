class CategoryModel {
  final int? id;
  final String name;
//Modelo de categoria
  CategoryModel({this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory CategoryModel.fromMap(Map<String, dynamic> map) =>
      CategoryModel(id: map['id'] as int?, name: map['name'] as String);
}
