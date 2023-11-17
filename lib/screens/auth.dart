import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

var _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  AuthScreen({super.key});
  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _formkey = GlobalKey<FormState>();
  var _enteredemail = '';
  var _enteredpassword = '';
  var _enteredusename = '';
  File? selectedimage;
  bool isAuthenticating = false;
  void submit() async {
    var isvalid = _formkey.currentState!.validate();
    if (!isvalid) {
      return;
    }

    if (!_login && selectedimage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload Image')),
      );
      return;
    }
    try {
      setState(() {
        isAuthenticating = true;
      });
      if (_login) {
        final usercredential = await _firebase.signInWithEmailAndPassword(
            email: _enteredemail, password: _enteredpassword);
      } else {
        final usercrendital = await _firebase.createUserWithEmailAndPassword(
            email: _enteredemail, password: _enteredpassword);
        final storageref = await FirebaseStorage.instance
            .ref()
            .child('User_Images')
            .child('${usercrendital.user!.uid}.jpg');
        await storageref.putFile(selectedimage!);
        final imageurl = await storageref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(usercrendital.user!.uid)
            .set(
          {
            'username': _enteredusename,
            'email': _enteredemail,
            'image_url': imageurl,
          },
        );
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Error in Account Creation'),
        ),
      );
      setState(() {
        isAuthenticating = false;
      });
    }
    _formkey.currentState!.save();
  }

  @override
  var _login = true;
  Widget build(context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_login)
                            UserImagePicker(
                              onpickedimage: (pickedImage) {
                                selectedimage = pickedImage;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Email Address'),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid Email Address';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredemail = value!;
                            },
                          ),
                          if (!_login)
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text('User Name'),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().length < 4 ||
                                    value.isEmpty) {
                                  return 'Enter 4 characters';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredusename = value!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Password'),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Please enter a valid Password';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredpassword = value!;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!isAuthenticating)
                            ElevatedButton(
                              onPressed: submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(_login ? 'Login' : 'SingUp'),
                            ),
                          if (!isAuthenticating)
                            TextButton(
                              onPressed: () => setState(
                                () {
                                  _login = !_login;
                                },
                              ),
                              child: Text(_login
                                  ? 'Create An Account'
                                  : 'Already Have An Account'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
