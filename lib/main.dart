import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

var shareDesc = <Map>[];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
      theme: ThemeData(primarySwatch: Colors.red),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // nameController = TextEditingController();
    // descController = TextEditingController();
    // amountController = TextEditingController();
  }

  var friends = <Map<String, dynamic>>[];

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController descController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    // var expenseTitle = <String> [];
    // var amount = <num> [];
    return Scaffold(
        appBar: AppBar(
          title: const Text('Expense Splitter'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text("About"),
                      ),
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('Expense Splitter by Ninad Naik',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey)),
                            // IconButton(onPressed: () => launchUrl(Uri.parse('https://github.com/ninadnaik10')), icon: const FaIcon(FontAwesomeIcons.github))
                          ],
                        ),
                      ),
                    );
                  }));
                },
                icon: Icon(Icons.info_outline))
          ],
        ),
        body: friends.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Press ',
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                        Icon(
                          Icons.add,
                          color: Colors.grey,
                        ),
                        Text(
                          ' button to add descriptions',
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Text("You can swipe an entry to delete.", style: TextStyle(fontSize: 20, color: Colors.grey))
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.only(top: 10.0),
                // <-- SEE HERE
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final item = friends[index];
                  return Dismissible(
                      key: Key(item['Name']),
                      onDismissed: (direction) {
                        // Remove the item from the data source.
                        setState(() {
                          friends.removeAt(index);
                        });
                      },
                      background: Container(color: Colors.red),
                      child: ListTile(
                        title: Text(friends[index]['Name'],
                            style: const TextStyle(fontSize: 22)),
                        subtitle: Text(friends[index]['Description'],
                            style: const TextStyle(fontSize: 16)),
                        trailing: Text(
                          "\u{20B9} ${friends[index]['Amount']}",
                          style: const TextStyle(fontSize: 22),
                        ),
                      ));
                },
                separatorBuilder: (context, index) {
                  // <-- SEE HERE
                  return const Divider();
                },
              ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(direction: Axis.vertical, children: [
            FloatingActionButton(
              heroTag: "btn2",
              child: const Icon(Icons.calculate),
              onPressed: () {
                if (friends.length < 2) {
                  Fluttertoast.showToast(msg: "Enter atleast 2 descriptions");
                  return;
                }
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    calculateShare();
                    return Scaffold(
                        appBar: AppBar(
                          title: const Text('Result'),
                        ),
                        body: ListView.separated(
                          padding: const EdgeInsets.only(top: 10.0),
                          itemCount: shareDesc.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Row(
                                children: [
                                  Text(shareDesc[index]['Sender'],
                                      style: const TextStyle(fontSize: 22)),
                                  const Padding(padding: EdgeInsets.all(2.0)),
                                  const Icon(Icons.arrow_forward),
                                  const Padding(padding: EdgeInsets.all(2.0)),
                                  Text(shareDesc[index]['Receiver'],
                                      style: const TextStyle(fontSize: 22))
                                ],
                              ),
                              trailing: Text(
                                  "\u{20B9} ${shareDesc[index]['Amount'].toStringAsFixed(2)}",
                                  style: const TextStyle(fontSize: 22)),
                            );
                          },
                          separatorBuilder: (context, index) {
                            // <-- SEE HERE
                            return const Divider();
                          },
                        ));
                  },
                ));
              },
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: "btn1",
              child: const Icon(Icons.add),
              onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                    backgroundColor: const Color(0XFFFFFFFF),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Enter a description',
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 15),
                          // Text("Enter the Data"),
                          TextField(
                              controller: nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Enter Name')),
                          const SizedBox(height: 15),
                          TextField(
                              controller: descController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Enter Description')),
                          const SizedBox(height: 15),
                          TextField(
                            controller: amountController,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Enter Amount'),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Close'),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton(
                                  onPressed: () {
                                    if (nameController.text == '' ||
                                        amountController.text == '' ||
                                        descController.text == '') {
                                      Fluttertoast.showToast(
                                          msg: 'All fields are required');
                                      return;
                                    }
                                    setState(() {
                                      friends.add({
                                        'Name': nameController.text,
                                        'Description': descController.text,
                                        'Amount':
                                            num.parse(amountController.text)
                                      });
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Add'))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ]),
        ));
  }

  void calculateShare() {
    shareDesc = [];
    num totalExpense = 0;
    var friendsTemp = jsonDecode(jsonEncode(friends));
    num average = 0;
    for (int i = 0; i < friendsTemp.length; i++) {
      totalExpense += friendsTemp[i]['Amount'];
    }
    average = totalExpense / friendsTemp.length;
    for (int i = 0; i < friendsTemp.length; i++) {
      if (friendsTemp[i]['Amount'] > average) {
        for (int j = 0; j < friendsTemp.length; j++) {
          if (friendsTemp[j]['Amount'] < average) {
            var diff = friendsTemp[i]['Amount'] - average;
            if ((friendsTemp[j]['Amount'] + diff) > average) {
              shareDesc.add({
                'Sender': friendsTemp[j]['Name'],
                'Receiver': friendsTemp[i]['Name'],
                'Amount': average - friendsTemp[j]['Amount']
              });
              // sender.add(friendsTemp[i]);
              // receiver.add(friendsTemp[j]);
              friendsTemp[i]['Amount'] -= (average - friendsTemp[j]['Amount']);
              friendsTemp[j]['Amount'] += average - friendsTemp[j]['Amount'];
            } else {
              shareDesc.add({
                'Sender': friendsTemp[j]['Name'],
                'Receiver': friendsTemp[i]['Name'],
                'Amount': diff
              });
              // sender.add(friendsTemp[j]);
              // receiver.add(friendsTemp[i]);
              friendsTemp[j]['Amount'] += diff;
              friendsTemp[i]['Amount'] -= diff;
            }
          }
        }
      }
    }
  }
}
