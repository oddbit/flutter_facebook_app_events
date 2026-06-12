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
          child: SingleChildScrollView(
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
                      city: 'Denpasar',
                      country: 'Indonesia',
                      externalId: 'example-user-42',
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
                  child: Text("Enable advertiser ID collection"),
                  onPressed: () {
                    facebookAppEvents.setAdvertiserIdCollectionEnabled(true);
                  },
                ),
                MaterialButton(
                  child: Text("Disable advertiser ID collection"),
                  onPressed: () {
                    facebookAppEvents.setAdvertiserIdCollectionEnabled(false);
                  },
                ),
                MaterialButton(
                  child: Text("Limit event and data usage"),
                  onPressed: () {
                    facebookAppEvents.setLimitEventAndDataUsage(true);
                  },
                ),
                MaterialButton(
                  child: Text("Enable Limited Data Use (LDU)"),
                  onPressed: () {
                    facebookAppEvents.setDataProcessingOptions(
                      ['LDU'],
                      country: 0,
                      state: 0,
                    );
                  },
                ),
                MaterialButton(
                  child: Text("Log product item"),
                  onPressed: () {
                    facebookAppEvents.logProductItem(
                      itemId: 'SKU-1',
                      availability: ProductAvailability.inStock,
                      condition: ProductCondition.newItem,
                      description: 'Comfortable running shoes',
                      imageLink: 'https://example.com/shoes.png',
                      link: 'https://example.com/shoes',
                      title: 'Running Shoes',
                      priceAmount: 79.99,
                      currency: 'USD',
                      gtin: '0123456789012',
                    );
                  },
                ),
                MaterialButton(
                  child: Text("Flush events explicitly only"),
                  onPressed: () {
                    facebookAppEvents
                        .setFlushBehavior(FlushBehavior.explicitOnly);
                  },
                ),
                MaterialButton(
                  child: Text("Register push token"),
                  onPressed: () {
                    facebookAppEvents
                        .setPushNotificationsDeviceToken('example-token');
                  },
                ),
                MaterialButton(
                  child: Text("Clear email user data"),
                  onPressed: () {
                    facebookAppEvents
                        .clearUserDataForType(FacebookUserDataField.email);
                  },
                ),
                MaterialButton(
                  child: Text("Enable SDK debug logging"),
                  onPressed: () {
                    facebookAppEvents.setDebugLoggingEnabled(true);
                  },
                ),
                MaterialButton(
                  child: Text("Log search"),
                  onPressed: () {
                    facebookAppEvents.logSearched(
                      searchString: 'running shoes',
                      contentType: 'product',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
