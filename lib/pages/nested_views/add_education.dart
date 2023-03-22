import 'package:cv_builder/widgets/button.dart';
import 'package:cv_builder/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class AddEducation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Add",
            ),
            Text(
              "Education",
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 3),
              content: Text('Data Updated')));
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 10.0),
            CustomTextField(
              labelText: "Years",
              hintText: "2016-2012",
              iconText: Icon(Feather.layers),
              ratio: 1.0,
            ),
            SizedBox(height: 10.0),
            CustomTextField(
              labelText: "School",
              hintText: "",
              iconText: Icon(Icons.school),
              ratio: 1.0,
            ),
            SizedBox(height: 10.0),
            CustomTextField(
              labelText: "Faculty",
              hintText: "",
              iconText: Icon(Icons.person_outline),
              ratio: 1.0,
            ),
            SizedBox(height: 10.0),
            CustomTextField(
              labelText: "Department",
              hintText: "",
              iconText: Icon(Icons.person_outline),
              ratio: 1.0,
            ),
            SizedBox(height: 10.0),
            CustomTextField(
              labelText: "Grade",
              hintText: "",
              iconText: Icon(Icons.note_add),
              ratio: 1.0,
            ),
            SizedBox(height: 10.0),
            CustomTextField(
              labelText: "Additional Notes",
              hintText: "",
              iconText: Icon(Icons.note_add),
              ratio: 1.0,
            ),
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}
