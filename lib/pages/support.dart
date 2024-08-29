import 'package:flutter/material.dart';

// final _formKey = GlobalKey<FormState>();

class Support extends StatelessWidget {
  @override
  Widget build (BuildContext context) => new Scaffold(

    //App Bar
    appBar: new AppBar(
      title: new Text(
        'Support', 
        style: new TextStyle(
          fontSize: Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
        ),
      ),
      elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
    ),

    //Content of tabs
    body: new PageView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            // key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Please enter a search term'
                  ),
                ),
                InkWell(
                  onTap: () {
                    Future<DateTime?> selectedDate = showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2018),
                      lastDate: DateTime(2030),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.light(),
                          child: child!,
                        );
                      },
                    );
                  },
                  child: IgnorePointer(
                    child: new TextFormField(
                      decoration: new InputDecoration(
                        hintText: 'Select a date'
                      ),
                      // validator: validateDob,
                      onSaved: (String? val) {},
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate returns true if the form is valid, or false
                      // otherwise.
                      // if (_formKey.currentState.validate()) {
                      //   // If the form is valid, display a Snackbar.
                      //   Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing Data')));
                      // }
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            )
          ),
        ),
      ],
    ),
  );
}