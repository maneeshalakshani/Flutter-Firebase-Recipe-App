import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/recipe.dart';

class Recipes extends StatelessWidget {
  const Recipes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RecipePage(),
    );
  }
}

class RecipePage extends StatefulWidget {
  const RecipePage({Key? key}) : super(key: key);

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController ingredientsController = TextEditingController();
  bool isEditing = false;
  bool textFieldVisibility = false;
  String fireStoreCollectionName = "Recipes";
  late Recipe currentRecipe;

  getAllRecipes() {
    return FirebaseFirestore.instance.collection(fireStoreCollectionName).snapshots();
  }

  addRecipe() async {
    Recipe recipe = Recipe(title: titleController.text, description: descriptionController.text, ingredients: ingredientsController.text);
    try{
      FirebaseFirestore.instance.runTransaction(
         (Transaction transaction) async {
            await FirebaseFirestore.instance.collection(fireStoreCollectionName).doc().set(recipe.toJson());
         }
      );
    }catch(e){
      print(e.toString());
    }
  }

  updateRecipe(Recipe recipe, String title, String description, String ingredients){
    try{
      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.update(recipe.documentReference, {'title': title, 'description': description, 'ingredients': ingredients});
      });
    }catch(e){
      print(e.toString());
    }
  }

  updateIfEditing(){
    if(isEditing){
      updateRecipe(currentRecipe, titleController.text, descriptionController.text, ingredientsController.text);
      setState(() {
        isEditing = false;
      });
    }
  }

  deleteRecipe(Recipe recipe){
    FirebaseFirestore.instance.runTransaction(
      (Transaction transaction) async {
        await transaction.delete(recipe.documentReference);
      }
    );
  }

  Widget buildBody(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: getAllRecipes(),
      builder: (context, snapshot) {
        if(snapshot.hasError){
          return Text('Error ${snapshot.error}');
        }
        if(snapshot.hasData){
          print("Dcument -> ${snapshot.data?.docs.length}");
          return buildList(context, snapshot.data?.docs);
        }
        // return const SizedBox();
        return buildList(context, snapshot.data?.docs);
      },
    );
  }

  Widget buildList(BuildContext context, List<DocumentSnapshot>? snapshot){
    return ListView.builder(
      itemCount: snapshot!.length,
      itemBuilder: (context, index){
        return listItemBuilder(context, snapshot[index]);
      },
    );
  }

  Widget listItemBuilder(BuildContext context, DocumentSnapshot data){
    final recipe = Recipe.fromSnapshot(data);
    return Padding(
      key: ValueKey(recipe.title),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.yellow,
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(recipe.description),
                    Text('Ingredients${recipe.ingredients}'),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: (){
                        deleteRecipe(recipe);
                      },
                      icon: Icon(Icons.delete, color: Colors.red,),
                    ),
                    IconButton(
                      onPressed: (){
                        setUpdateUI(recipe);
                      },
                      icon: Icon(Icons.update, color: Colors.green,),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  setUpdateUI(Recipe recipe){
    titleController.text = recipe.title;
    descriptionController.text = recipe.description;
    ingredientsController.text = recipe.ingredients;
    setState(() {
      isEditing = true;
      textFieldVisibility = true;
      currentRecipe = recipe;
    });
  }

  button(){
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          if(isEditing == true){
            updateIfEditing();
          }else{
            addRecipe();
          }
          setState(() {
            textFieldVisibility = false;
          });
        },
        child: Text(isEditing ? "Update" : "Add"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recipe List CC"),
                IconButton(
                  onPressed: (){
                    setState(() {
                      textFieldVisibility = !textFieldVisibility;
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.red),
                )
              ],
            ),
            textFieldVisibility
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: "Recipe Title",
                        ),
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: "Recipe Description",
                        ),
                      ),
                      TextFormField(
                        controller: ingredientsController,
                        decoration: const InputDecoration(
                          labelText: "Ingredients",
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        child: button(),
                      ),
                    ],
                  )
                : SizedBox(),
            Text("Recipe List"),
            SizedBox(
              height: 20,
            ),
            Flexible(
              child: buildBody(context),
            ),
          ],
        ),
      ),
    );
  }
}