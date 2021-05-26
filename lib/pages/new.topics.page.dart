import 'package:flutter/material.dart';
import 'package:tutoriel_flutter/models/user.model.dart';
import 'package:tutoriel_flutter/models/topic.model.dart';
import 'package:tutoriel_flutter/pages/topics.page.dart';
import 'package:tutoriel_flutter/services/locator.service.dart';
import 'package:tutoriel_flutter/services/topic/topic.abstract.service.dart';

class NewTopicsPage extends StatefulWidget {
  NewTopicsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  _NewTopicsPageState createState() => _NewTopicsPageState();
}

class _NewTopicsPageState extends State<NewTopicsPage> {
  late User user;

  final nameController = TextEditingController();

  TopicService _topicService = locator<TopicService>();
  late Topic topic;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final _formKey = GlobalKey<FormState>();

    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
            child: Container(
          margin: EdgeInsets.all(30),
          child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Invoke "debug painting" (press "p" in the console, choose the
              // "Toggle Debug Paint" action from the Flutter Inspector in Android
              // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
              // to see the wireframe for each widget.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Please choose a name for your new diary topic!',
                ),
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.

                Form(
                    key: _formKey,
                    child: Column(children: <Widget>[
                      // Add TextFormFields and ElevatedButton here.
                      TextFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Enter your topic name',
                        ),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the topic name';
                          }
                          return null;
                        },
                        controller: nameController,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Validate returns true if the form is valid, or false otherwise.
                          if (_formKey.currentState!.validate()) {
                            // If the form is valid, display a snackbar. In the real world,
                            // you'd often call a server or save the information in a database.
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Creating topic...')));
                            topic = Topic(name: nameController.text);
                            _topicService.createTopic(topic).then((value) => {
                                  ScaffoldMessenger.of(context)
                                      .removeCurrentSnackBar(),
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('Topic created.'))),
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TopicsPage()),
                                  )
                                });
                          }
                        },
                        child: Text('Create'),
                      ),
                    ])),
              ]),
        )));
  }
}
