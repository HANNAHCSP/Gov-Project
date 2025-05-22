import 'package:flutter/material.dart';
import 'package:bgam3/providers/Advertisementprovider.dart';
import 'package:provider/provider.dart';
import 'providers/Authprovider.dart';
import 'AdvertisementAdminCard.dart';

class ViewAds extends StatefulWidget {
  @override
  _ViewAdsState createState() => _ViewAdsState();
}

class _ViewAdsState extends State<ViewAds> {
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

    var allAdvertisements = advertisementProvider.getPendingAdvertisements();

    return Scaffold(
      appBar: AppBar(
        title: Text("View Requested Advertisements"),
        backgroundColor: Colors.red,
        actions: [],
      ),
      body: ListView.builder(
        itemCount: allAdvertisements.length,
        itemBuilder: (context, index) {
          var advertisement = allAdvertisements[index];
          return AdvertisementAdminCard(
            advertisement: advertisement,
            approveAd: (String advertisementId) async {
              advertisementProvider.approveAdvertisement(
                Provider.of<AuthProvider>(context, listen: false).token,
                Provider.of<AuthProvider>(context, listen: false).userId,
                Provider.of<AuthProvider>(context, listen: false).role,
                advertisementId,
              );

              setState(() {});
            },
            rejectAd: (String advertisementId) async {
              advertisementProvider.rejectAdvertisement(
                Provider.of<AuthProvider>(context, listen: false).token,
                Provider.of<AuthProvider>(context, listen: false).userId,
                Provider.of<AuthProvider>(context, listen: false).role,
                advertisementId,
              );

              setState(() {});
            },
          );
        },
      ),
    );
  }
}
