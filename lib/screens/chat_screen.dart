import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:intl/intl.dart';

FirebaseUser loginUser;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String messageText;
  final _auth = FirebaseAuth.instance;
  final _fireStore = Firestore.instance;
  final _textController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void signOut(context) {
    _auth.signOut();
    //Navigator.pop(context);
    Navigator.popAndPushNamed(context, 'welcome_screen');
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('SignOut!'),
        content: Text('Do you want to signout?'),
        actions: [
          FlatButton(
              onPressed: () => setState(() {
                    signOut(context);
                  }),
              child: Text('Yes')),
          FlatButton(onPressed: () => Navigator.pop(context), child: Text('No'))
        ],
      ),
    );
  }

  void getNewUser() async {
    try {
      final currentUser = await _auth.currentUser();
      if (currentUser != null) {
        loginUser = currentUser;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getNewUser();
    //WidgetsBinding is called after onCreate is done
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final snackBar = SnackBar(content: Text('Login Successfully!'),);
      scaffoldKey.currentState.showSnackBar(snackBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                signOut(context);
                //messageStream();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _fireStore.collection('messages').orderBy('messageDate', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlue),
                  );
                }
                List<Widget> messageWidget = [];
                for (var message in snapshot.data.documents) {
                  final messageText = message.data['text'];
                  final messageSender = message.data['sender'];
                  Timestamp t = message.data['messageDate'];
                  DateTime date = t.toDate();
                  var chatTime = DateFormat.jm().format(date);
                  messageWidget.add(MessageBubble(
                      text: messageText,
                      sender: messageSender,
                      time: chatTime,
                      isMe: loginUser.email == messageSender));
                }
                return Expanded(
                    child: ListView(
                      reverse: true,
                      children: messageWidget,
                ));
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    iconSize: 30.0,
                    color: Colors.lightBlue,
                    onPressed: () async {
                      setState(() {
                        _textController.clear();
                      });
                      try {
                        await _fireStore.collection('messages').add(
                            {'text': messageText, 'sender': loginUser.email, 'messageDate': Timestamp.now()});
                      } catch (e) {
                        print(e);
                      }
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.text, this.sender, this.isMe, this.time});
  final String text, sender;
  final String time;
  final bool isMe;

  @override
  Widget build(BuildContext context) {

    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$sender',
              style: TextStyle(color: Colors.black45),
            ),
            Material(
              borderRadius: isMe ? kBorderRadiusRight : kBorderRadiusLeft,
              color: isMe ? Colors.lightBlue : Colors.white,
              elevation: 2.0,
              child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: isMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children:  [
                        Text(
                          '$text',
                          style: TextStyle(
                            fontSize: 16,
                            color: isMe? Colors.white: Colors.black,
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.005,),
                        Text(
                          '$time',
                          textAlign: isMe? TextAlign.right : TextAlign.left,
                          style: TextStyle(
                            fontSize: 12,
                            color: isMe? Colors.white70: Colors.black38),
                          ),
                      ]
                ),
              ),
            ),
          ],
        )
    );
  }
}
