import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NewMessage extends StatefulWidget {
  NewMessage({super.key});
  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  var messagecontroller = TextEditingController();
  void submit() async {
    final enteredmessage = messagecontroller.text;
    if (enteredmessage.trim().isEmpty) {
      return;
    }
    messagecontroller.clear();
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser!;
    final userdata = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();
    FirebaseFirestore.instance.collection('chat').add(
      {
        'text': enteredmessage,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': userdata.data()!['username'],
        'userimage': userdata.data()!['image_url'],
      },
    );
  }

  @override
  void dispose() {
    messagecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messagecontroller,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(
                label: const Text('Send Message...'),
              ),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: submit,
            icon: const Icon(
              Icons.send,
            ),
          ),
        ],
      ),
    );
  }
}
