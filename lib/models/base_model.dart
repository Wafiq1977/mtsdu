abstract class BaseModel {
  String id;

  BaseModel({required this.id});

  Map<String, dynamic> toMap();

  // fromMap is usually factory in subclasses, so not defined here
}
