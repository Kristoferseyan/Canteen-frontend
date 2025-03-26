// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class AddSubcategory extends StatefulWidget {
  final String? selectedParentCategoryName;
  const AddSubcategory({super.key, this.selectedParentCategoryName});

  @override
  State<AddSubcategory> createState() => _AddSubcategoryState();
}

class _AddSubcategoryState extends State<AddSubcategory> {
  final TextEditingController subCategoryName = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          "Add sub category",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold
          ),)),
      content: SizedBox(
        height: 200,
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(height: 2, thickness: 2, color: const Color.fromARGB(137, 33, 33, 33),),
            SizedBox(height: 10,),
            Text("Under → ${widget.selectedParentCategoryName}", 
            style: TextStyle(
              fontSize: 18
            ),),
            SizedBox(height: 10,),
            Center(
              child: TextField(
                controller: subCategoryName,
                decoration: InputDecoration(
                  label: Text("Sub category name"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  )
                ),
              ),
            ),
            SizedBox(height: 20,),
            Center(
              child: SizedBox(
                width: 130,
                child: ElevatedButton(
                  onPressed: (){}, 
                  child: Text("Add")),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}