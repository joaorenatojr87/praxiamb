import 'package:crud_sqlite/main.dart';
import 'package:flutter/material.dart';
import 'database.dart';
import 'person.dart';

class EditPerson extends StatefulWidget {
  final bool edit;
  final Person person;
  final Function _callback;
  EditPerson(this.edit, {this.person, @required void atualizaLista()})
      : assert(edit == true || person == null),
        _callback = atualizaLista;

  @override
  _EditPersonState createState() => _EditPersonState();
}

class _EditPersonState extends State<EditPerson> {
  TextEditingController nameEditingController = TextEditingController();
  TextEditingController cityEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.edit == true) {
      nameEditingController.text = widget.person.name;
      cityEditingController.text = widget.person.city;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.edit ? "Edit Person" : "Add person"),
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlutterLogo(
                    size: 300,
                  ),
                  textFormField(nameEditingController, "Name", "Enter Name",
                      Icons.person, widget.edit ? widget.person.name : "s"),
                  textFormField(cityEditingController, "City", "Enter City",
                      Icons.place, widget.edit ? widget.person.city : "jk"),
                  RaisedButton(
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState.validate()) {
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text('Processing Data')));
                        setState(() {});
                      } else if (widget.edit == true) {
                        PersonDatabaseProvider.db.updatePerson(new Person(
                            name: nameEditingController.text,
                            city: cityEditingController.text,
                            id: widget.person.id));
                        setState(() {
                          widget?._callback();
                        });
                        Navigator.pop(context);
                      } else {
                        await PersonDatabaseProvider.db.addPersonToDatabase(
                            new Person(
                                name: nameEditingController.text,
                                city: cityEditingController.text));
                        setState(() {
                          widget?._callback();
                        });
                        Navigator.pop(context);
                      }
                    },
                  )
                ],
              ),
            ),
          )),
    );
  }

  textFormField(TextEditingController t, String label, String hint,
      IconData iconData, String initialValue) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
      ),
      child: TextFormField(
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter some text';
          }
        },
        controller: t,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
            prefixIcon: Icon(iconData),
            hintText: hint,
            labelText: label,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }
}
