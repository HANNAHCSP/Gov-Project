import 'package:flutter/material.dart';
import 'package:bgam3/providers/Advertisementprovider.dart';
import 'package:provider/provider.dart';
import 'providers/Authprovider.dart';
import 'AdvertisementAdsCard.dart';

class ViewMyAds extends StatefulWidget {
  @override
  _ViewMyAdsState createState() => _ViewMyAdsState();
}

class _ViewMyAdsState extends State<ViewMyAds> {
  bool fetchedAds = false;
  @override
  Widget build(BuildContext context) {
    final advertisementProvider = Provider.of<AdvertisementProvider>(context);
    if (advertisementProvider.advertisements.isEmpty && !fetchedAds) {
      advertisementProvider.getAdvertisementsFromServer(
        Provider.of<AuthProvider>(context, listen: false).token,
        Provider.of<AuthProvider>(context, listen: false).userId,
      );
      setState(() {
        fetchedAds = true;
      });
    }

    var allAdvertisements = advertisementProvider.allAdvertisements;

    allAdvertisements.removeWhere(
      (element) =>
          element.userId !=
          Provider.of<AuthProvider>(context, listen: false).userId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("View My Advertisements"),
        backgroundColor: Colors.red,
        actions: [],
      ),
      body: ListView.builder(
        itemCount: allAdvertisements.length,
        itemBuilder: (context, index) {
          var advertisement = allAdvertisements[index];
          return SwipeableAdvertisementCard(advertisement: advertisement);
        },
      ),
    );
  }
}
