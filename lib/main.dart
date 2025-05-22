import 'package:flutter/material.dart';
import 'package:bgam3/classes/poll.dart';
import 'package:provider/provider.dart';
import 'admin_emergency.dart';
import 'emergency_page.dart';
import 'providers/Authprovider.dart';
import "LoginScreen.dart";
import "Tabs_Controller_Screen.dart";
import 'providers/Announcementprovider.dart';
import 'Addpage.dart';
import 'AddAnnouncement.dart';
import 'AddPoll.dart';
import 'providers/PollsProvider.dart';
import 'classes/announcement.dart';
import 'AnnouncementInfoPage.dart';
import 'PollInfoCard.dart';
import 'AdveritserApplication.dart';
import 'providers/RequestProvider.dart';
import 'AdminRequestsPage.dart';
import 'providers/Advertisementprovider.dart';
import 'Addadvertisement.dart';
import 'ViewAds.dart';
import 'ViewMyAds.dart';
import 'EditAnnouncement.dart';
import 'EditAdvertisement.dart';
import 'classes/advertisement.dart';
import 'adminreportpage.dart';
import 'reportpage.dart';
import 'providers/reportprovider.dart';
import 'forums_page.dart';
import 'messages_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'suggestions.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Add more detailed error logging here
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => PollsProvider()),
        ChangeNotifierProvider(create: (ctx) => RequestProvider()),
        ChangeNotifierProvider(create: (ctx) => AdvertisementProvider()),
        ChangeNotifierProvider(create: (ctx) => ReportProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.red),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (ctx) => LoginScreen(),
          '/Home': (ctx) => TabsControllerScreen(),
          '/AnnRoute':
              (ctx) => AnnouncementInfoPage(
                announcement:
                    ModalRoute.of(ctx)!.settings.arguments as Announcement,
              ),
          '/PollRoute':
              (ctx) => PollInfoCard(
                poll: ModalRoute.of(ctx)!.settings.arguments as Poll,
              ),
          '/AddAnnouncement': (ctx) => AddAnnouncement(),
          '/ApplyAdvertiser': (ctx) => AdvertiserApplication(),
          '/AddPoll': (ctx) => AddPoll(),
          '/AddPage': (ctx) => AddPage(),
          '/AddAdvertisement': (ctx) => AddAdvertisement(),
          '/MessagesPage': (ctx) => MessagesPage(),
          '/ForumsPage': (ctx) => ForumsPage(),
          '/AdRequests': (ctx) => AdminRequestsPage(),
          '/RequestedAdvertisements': (ctx) => ViewAds(),
          '/MyAds': (ctx) => ViewMyAds(),
          '/EditAd':
              (ctx) => EditAdvertisement(
                advertisement:
                    ModalRoute.of(ctx)!.settings.arguments as Advertisement,
              ),
          '/EditAnnouncement':
              (ctx) => EditAnnouncement(
                announcement:
                    ModalRoute.of(ctx)!.settings.arguments as Announcement,
              ),
          '/ReportPage': (ctx) => ReportPage(),
          '/AdminReportPage': (ctx) => AdminReportPage(),
          '/emergency': (ctx) => EmergencyPage(),
          '/suggestions': (ctx) => SuggestionsScreen(),
          '/admin-emergency': (ctx) => AdminEmergencyScreen(),
        },
      ),
    );
  }
}
