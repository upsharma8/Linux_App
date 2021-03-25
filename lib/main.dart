import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

var command;
var fsconnect = FirebaseFirestore.instance;

var data;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  mydata() async {
    var url = "http://192.168.29.151/cgi-bin/date.py/?c=$command";
    var r = await http.get(url);
    setState(() {
      data = r.body;
    });

    fsconnect.collection("users").add({
      'command': command,
      'output': data,
    });
    print("My data is inserted in the database Successfully");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/terminal.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Linux Terminal"),
          backgroundColor: Colors.white30,
          actions: [Icon(Icons.person), Icon(Icons.more_vert)],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            width: size.width,
            height: size.height,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                TextField(
                  onChanged: (value) {
                    command = value;
                  },
                  autofocus: true,
                  cursorColor: Colors.amber,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    hintText: "Enter Your Command",
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.phone_android),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                FlatButton(
                  autofocus: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  onPressed: () {
                    mydata();
                  },
                  child: Text("Run Command"),
                  color: Colors.blueAccent,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: size.height * 0.6,
                  width: size.width * 0.8,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.blue),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: StreamBuilder<QuerySnapshot>(
                      builder: (context, snapshot) {
                        print('new data comes');

                        var msg = snapshot.data.docs;
                        // print(msg);
                        // print(msg[0].data());

                        List<Widget> y = [];
                        for (var d in msg) {
                          // print(d.data()['sender']);
                          var msgText = d.data()['command'];
                          var msgSender = d.data()['output'];
                          var msgWidget = Text(
                            "$msgText : $msgSender",
                            style: TextStyle(color: Colors.amber),
                          );

                          y.add(msgWidget);
                        }

                        print(y);

                        return Container(
                          child: Column(
                            children: y,
                          ),
                        );
                      },
                      stream: fsconnect.collection("users").snapshots(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
