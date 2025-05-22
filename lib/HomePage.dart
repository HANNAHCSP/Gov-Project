import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:bgam3/PollCard.dart';
import 'package:bgam3/classes/vote.dart';
import 'package:bgam3/providers/Advertisementprovider.dart';
import 'package:bgam3/providers/PollsProvider.dart';
import 'package:provider/provider.dart';
import 'providers/Announcementprovider.dart';
import 'package:bgam3/providers/Authprovider.dart';
import 'classes/announcement.dart';
import 'AnnouncementCard.dart';
import 'classes/poll.dart';
import 'AdvertisementCard.dart';
import 'classes/advertisement.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool fetchedAnnouncements = false;
  bool fetchedPolls = false;
  bool fetchedAds = false;
  @override
  Widget build(BuildContext context) {
    final announcementProvider = Provider.of<AnnouncementProvider>(context);
    if (announcementProvider.announcements.isEmpty && !fetchedAnnouncements) {
      announcementProvider.getAnnouncementsFromServer(
        Provider.of<AuthProvider>(context, listen: false).token,
        Provider.of<AuthProvider>(context, listen: false).userId,
      );
      setState(() {
        fetchedAnnouncements = true;
      });
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final pollsProvider = Provider.of<PollsProvider>(context);
    List<Vote> myVotes = [];

    if (pollsProvider.polls.isEmpty && !fetchedPolls) {
      pollsProvider.getPollsFromServer(authProvider.token, authProvider.userId);
      setState(() {
        fetchedPolls = true;
      });
    }

    final advertisementProvider = Provider.of<AdvertisementProvider>(context);
    if (advertisementProvider.advertisements.isEmpty && !fetchedAds) {
      advertisementProvider.getAdvertisementsFromServer(
        authProvider.token,
        authProvider.userId,
      );
      setState(() {
        fetchedAds = true;
      });
    }

    Future<void> fetchAnnouncements() async {
      announcementProvider.getAnnouncementsFromServer(
        authProvider.token,
        authProvider.userId,
      );
    }

    Future<void> fetchPolls() async {
      pollsProvider.getPollsFromServer(authProvider.token, authProvider.userId);
    }

    Future<void> fetchAdvertisements() async {
      advertisementProvider.getAdvertisementsFromServer(
        authProvider.token,
        authProvider.userId,
      );
    }

    Future<void> deleteAnnouncement(String announcementId) async {
      announcementProvider.deleteAnnouncement(
        authProvider.token,
        authProvider.role,
        announcementId,
      );
    }

    Future<void> deletePoll(String pollId) async {
      pollsProvider.deletePoll(
        authProvider.token,
        authProvider.role,
        authProvider.userId,
        pollId,
      );
    }

    Future<void> fetchAll() async {
      fetchAnnouncements();
      fetchPolls();
      fetchAdvertisements();
    }

    Future<void> voteInPoll(String option, Poll currentPoll, Vote vote) async {
      setState(() {
        print("Id of vote is ${vote.id}");
        print("Entered func");
        if (vote.userId == authProvider.userId) {
          pollsProvider.deleteVote(
            authProvider.token,
            authProvider.userId,
            currentPoll.id,
            vote.id,
          );
        }
        pollsProvider.voteInPoll(
          authProvider.token,
          authProvider.userId,
          currentPoll.id,
          option,
        );
      });
    }

    SplayTreeMap<DateTime, Object> allPosts = SplayTreeMap();

    for (var announcement in announcementProvider.announcements) {
      print("date is ${announcement.date}");
      allPosts[announcement.date.toUtc()] = announcement;
    }

    for (var advertisement in advertisementProvider.advertisements) {
      print("Date is ${advertisement.date}");
      allPosts[advertisement.date.toUtc()] = advertisement;
    }

    for (var poll in pollsProvider.polls) {
      print("Date is ${poll.date}");
      allPosts[poll.date.toUtc()] = poll;
    }

    print("All posts are $allPosts");

    List<Object> allPostsList = [];

    for (Object object in allPosts.values) {
      allPostsList.add(object);
    }

    allPostsList = allPostsList.reversed.toList();

    return RefreshIndicator(
      onRefresh: fetchAll,
      child: ListView.builder(
        itemCount: allPosts.length,
        itemBuilder: (context, index) {
          var post = allPostsList[index];
          if (post is Poll) {
            return PollCard(
              poll: post,
              onTap: voteInPoll,
              onDelete: deletePoll,
              votes: pollsProvider.votes,
              userId: authProvider.userId,
              role: authProvider.role,
            );
          } else if (post is Announcement) {
            return AnnouncementCard(
              announcement: post,
              swipeToDelete: deleteAnnouncement,
              role: authProvider.role,
            );
          } else if (post is Advertisement) {
            return AdvertisementCard(advertisement: post);
          }
        },
      ),
    );
  }
}
