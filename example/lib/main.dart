import 'package:flutter/material.dart';
import 'package:facebook_app_events/facebook_app_events.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static final facebookAppEvents = FacebookAppEvents();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: RaisedButton(
            color: Colors.green,
            child: Text("Click me!"),
            onPressed: () {
              facebookAppEvents.logEvent(
                name: 'button_clicked',
                parameters: {
                  'button_id': 'the_clickme_button',
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
