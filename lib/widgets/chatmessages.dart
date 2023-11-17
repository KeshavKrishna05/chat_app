import 'package:chat_app/widgets/messagebubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  void setupPushNotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token = fcm.getToken();
    print(token);
  }

  @override
  void initState() {
    super.initState();
    setupPushNotification();
  }

  Widget build(context) {
    final authenticateduser = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No Message Found'),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something Went Wrong'),
          );
        }
        final loadeddata = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(left: 14, right: 14, bottom: 40),
          reverse: true,
          itemCount: loadeddata.length,
          itemBuilder: (context, index) {
            final chatmessage = loadeddata[index].data();
            final nextmessage = index + 1 < loadeddata.length
                ? loadeddata[index + 1].data()
                : null;
            final currentMessageuserId = chatmessage['userId'];
            final nextMessageuserId =
                nextmessage != null ? nextmessage['userId'] : null;
            final nextuserISSame = currentMessageuserId == nextMessageuserId;
            if (nextuserISSame) {
              return MessageBubble.next(
                  message: chatmessage['text'],
                  isMe: currentMessageuserId == authenticateduser!.uid);
            } else {
              return MessageBubble.first(
                  userImage: chatmessage['userimage'],
                  username: chatmessage['username'],
                  message: chatmessage['text'],
                  isMe: currentMessageuserId == authenticateduser!.uid);
            }
          },
        );
      },
    );
  }
}
