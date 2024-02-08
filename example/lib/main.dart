import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder(
                future: facebookAppEvents.getAnonymousId(),
                builder: (context, snapshot) {
                  final id = snapshot.data ?? '???';
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
                  );
                },
              ),
              MaterialButton(
                child: Text("Set user data"),
                onPressed: () {
                  facebookAppEvents.setUserData(
                    email: 'opensource@oddbit.id',
                    firstName: 'Oddbit',
                    dateOfBirth: '2019-10-19',
                    city: 'Denpasar',
                    country: 'Indonesia',
                  );
                },
              ),
              MaterialButton(
                child: Text("Test logAddToCart"),
                onPressed: () {
                  facebookAppEvents.logAddToCart(
                    id: '1',
                    type: 'product',
                    price: 99.0,
                    currency: 'TRY',
                  );
                },
              ),
              MaterialButton(
                child: Text("Test purchase!"),
                onPressed: () {
                  facebookAppEvents.logPurchase(amount: 1, currency: "USD");
                },
              ),
              MaterialButton(
                child: Text("Enable advertise tracking!"),
                onPressed: () {
                  facebookAppEvents.setAdvertiserTracking(enabled: true);
                },
              ),
              MaterialButton(
                child: Text("Disabled advertise tracking!"),
                onPressed: () {
                  facebookAppEvents.setAdvertiserTracking(enabled: false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
