import 'package:flutter/material.dart';
import 'package:tutoriel_flutter/models/user.model.dart';
import 'package:tutoriel_flutter/models/topic.model.dart';
import 'package:tutoriel_flutter/pages/login.page.dart';
import 'package:tutoriel_flutter/services/locator.service.dart';
import 'package:tutoriel_flutter/services/topic/topic.abstract.service.dart';

import 'new.topics.page.dart';


class TopicsPage extends StatefulWidget {
  TopicsPage({Key? key}) : super(key: key);

  _TopicsPageState createState() => _TopicsPageState();

}

class _TopicsPageState extends State<TopicsPage> {
  late User user;

  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final List<int> colorCodes = <int>[700, 600, 500, 400];

  TopicService _topicService = locator<TopicService>();
  late List<Topic> topics;

  @override
  void initState() {
    super.initState();
  }

  _getTopics() async {
    topics = await _topicService.getTopics();
    return topics;
  }

  Widget _getTopicsView() {
    return FutureBuilder(
        future: _getTopics(),
        builder:(context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (topics.isEmpty) {
            return Center(child:Text('No topics.'));
          } else {
            return Container(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    itemCount: topics.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      return new GestureDetector(
                        onTap: () {
                        },
                        child:  Container(
                          height: 70,
                          color: Colors.blue[colorCodes[index%4]],
                          child: Center(child: Text('${topics[index].name}')),
                        ),

                      );
                    }
                )
            );
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('My Topics'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    LoginPage()
            ),
          ),
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

          child: Column(
              children: <Widget>[
                Container(
                    child: TextFormField(),
                ),
                Container(
                    child: _getTopicsView()
                ), Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(onPressed: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => NewTopicsPage(title: 'New Topic')),
                            )
                          }, child: Text('New'))
                        ],
                      )
                    ],
                  ),
                )
              ]
          )
      ),
    );
  }
}