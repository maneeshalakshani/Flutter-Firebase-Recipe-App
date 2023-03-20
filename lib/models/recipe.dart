import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  late String title;
  late String description;
  late String ingredients;

  late DocumentReference documentReference;

  Recipe({required this.title, required this.description, required this.ingredients});

  Recipe.fromMap(Map<String, dynamic> map, {required this.documentReference}){
    title = map["title"];
    description = map["description"];
    ingredients = map["ingredients"];
  }

  Recipe.fromSnapshot(DocumentSnapshot snapshot)
      :this.fromMap(
      snapshot.data() as Map<String, dynamic>,
      documentReference: snapshot.reference
  );

  toJson(){
    return {'title': title, 'description': description, 'ingredients': ingredients};
  }
}