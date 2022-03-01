import 'package:flutter/material.dart';
import 'package:facebook_app_events/facebook_app_events.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final facebookAppEvents = FacebookAppEvents();
  String _error;

  _handleError(dynamic err, StackTrace stack) {
    print("error catched: $err $stack");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                child: Text("Set Application Id = null"),
                onPressed: () async {
                  await facebookAppEvents
                      .setApplicationId(null)
                      .catchError(_handleError);
                  setState(() => {});
                },
              ),
              MaterialButton(
                child: Text("Set Application Id = a"),
                onPressed: () async {
                  await facebookAppEvents
                      .setApplicationId("a")
                      .catchError(_handleError);
                  setState(() => {});
                },
              ),
              MaterialButton(
                child: Text("Set Application Id = b"),
                onPressed: () async {
                  await facebookAppEvents
                      .setApplicationId("b")
                      .catchError(_handleError);
                  setState(() => {});
                },
              ),
              FutureBuilder(
                future: facebookAppEvents.getApplicationId(),
                builder: (context, snapshot) {
                  final id = snapshot.data ?? '???';

                  if (snapshot.hasError) {
                    _handleError(snapshot.error, snapshot.stackTrace);
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Application ID: $id'),
                  );
                },
              ),
              FutureBuilder(
                future: facebookAppEvents.getAnonymousId(),
                builder: (context, snapshot) {
                  final id = snapshot.data ?? '???';

                  if (snapshot.hasError) {
                    _handleError(snapshot.error, snapshot.stackTrace);
                  }

                  return Text('Anonymous ID: $id');
                },
              ),
              MaterialButton(
                child: Text("Click me!"),
                onPressed: () {
                  facebookAppEvents.logEvent(
                    name: 'button_clicked',
                    parameters: {
                      'button_id': 'the_clickme_button',
                    },
                  ).catchError(_handleError);
                },
              ),
              MaterialButton(
                child: Text("Set user data"),
                onPressed: () {
                  facebookAppEvents
                      .setUserData(
                        email: 'opensource@oddbit.id',
                        firstName: 'Oddbit',
                        dateOfBirth: '2019-10-19',
                        city: 'Denpasar',
                        country: 'Indonesia',
                      )
                      .catchError(_handleError);
                },
              ),
              MaterialButton(
                child: Text("Test logAddToCart"),
                onPressed: () {
                  facebookAppEvents
                      .logAddToCart(
                        id: '1',
                        type: 'product',
                        price: 99.0,
                        currency: 'TRY',
                      )
                      .catchError(_handleError);
                },
              ),
              MaterialButton(
                child: Text("Test purchase!"),
                onPressed: () {
                  facebookAppEvents
                      .logPurchase(amount: 1, currency: "USD")
                      .catchError(_handleError);
                },
              ),
              MaterialButton(
                child: Text("Enable advertise tracking!"),
                onPressed: () {
                  facebookAppEvents
                      .setAdvertiserTracking(enabled: true)
                      .catchError(_handleError);
                },
              ),
              MaterialButton(
                child: Text("Disabled advertise tracking!"),
                onPressed: () {
                  facebookAppEvents
                      .setAdvertiserTracking(enabled: false)
                      .catchError(_handleError);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
