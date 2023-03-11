import 'dart:convert';

import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:localstore/localstore.dart';
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
  FocusNode focusNode = FocusNode();
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
                        title: const Text("About"),
                      ),
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Expense Splitter by Ninad Naik',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey)),
                            IconButton(
                              onPressed: () => launchUrl(Uri.parse(
                                  'https://github.com/ninadnaik10/expense-splitter')),
                              icon: const Icon(SimpleIcons.github),
                            )
                            // IconButton(onPressed: () => launchUrl(Uri.parse('https://github.com/ninadnaik10')), icon: const FaIcon(FontAwesomeIcons.github))
                          ],
                        ),
                      ),
                    );
                  }));
                },
                icon: const Icon(Icons.info_outline))
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
                    const Text("You can swipe an entry to delete.",
                        style: TextStyle(fontSize: 20, color: Colors.grey))
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
                showGeneralDialog<String>(
                    transitionBuilder: (ctx, a1, a2, child) {
                      var curve = Curves.easeInOut.transform(a1.value);
                      return Transform.scale(
                        scale: curve,
                        child: Dialog(
                          backgroundColor: const Color(0XFFFFFFFF),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0))),
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
                                // TextField(
                                //     controller: nameController,
                                //     textCapitalization: TextCapitalization.words,
                                //     decoration: const InputDecoration(
                                //         border: OutlineInputBorder(),
                                //         labelText: 'Enter Name')),
                                // AutoCompleteTextField(
                                //   suggestions: friends,
                                //   itemFilter: (map, query) {
                                //     return map['Name'].toLowerCase().startsWith(query.toLowerCase());
                                //   },
                                //   itemSorter: (a, b) {
                                //     return a['name'].compareTo(b['name']);
                                //   },
                                //   itemSubmitted: (map) {
                                //     print('Selected item: ${map['name']}');
                                //   },
                                //   itemBuilder: (context, map) {
                                //     return ListTile(
                                //       title: Text(map['Name']),
                                //     );
                                //   }, key: key,
                                // ), List listOfNames =
                                //                                   friends.map((map) => map['Name']).toList() as <String>;
                                EasyAutocomplete(
                                  suggestions: friends
                                      .map((map) => map['Name'])
                                      .toSet()
                                      .toList()
                                      .cast<String>(),
                                  controller: nameController,
                                  focusNode: focusNode,
                                  suggestionBuilder: (data) {
                                    return GestureDetector(
                                      onTap: () {
                                        nameController.text = data;
                                        focusNode.nextFocus();
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(1),
                                        padding: const EdgeInsets.all(5),
                                        child: Text(data,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 22,
                                            )),
                                      ),
                                    );
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Enter Name',
                                  ),
                                ),

                                const SizedBox(height: 15),
                                TextField(
                                    textInputAction: TextInputAction.next,
                                    controller: descController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Enter Description')),
                                const SizedBox(height: 15),
                                TextField(
                                  textInputAction: TextInputAction.done,
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
                                              'Description':
                                                  descController.text,
                                              'Amount': num.parse(
                                                  amountController.text)
                                            });
                                            // final id =
                                            //     db.collection('transaction').doc().id;
                                            // db.collection('transaction').doc(id).set({
                                            //   'Name': nameController.text,
                                            //   'Description': descController.text,
                                            //   'Amount':
                                            //       num.parse(amountController.text)
                                            // });
                                            // final data = await db.collection('transaction').doc(id).get();
                                            // print(data);
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
                    transitionDuration: const Duration(milliseconds: 300),
                    context: context,
                    pageBuilder: (ctx, a1, a2) {
                      return Container();
                    });
              },
            ),
          ]),
        ));
  }

  void calculateShare() {
    shareDesc = [];
    num totalExpense = 0;
    var friendsTemp = jsonDecode(jsonEncode(friends));
    List<Map<String, dynamic>> modFriendsTemp = [];
    for (var map in friendsTemp) {
      bool found = false;
      for (var modMap in modFriendsTemp) {
        if (modMap['Name'] == map['Name']) {
          modMap['Amount'] += map['Amount'];
          found = true;
          break;
        }
      }
      if (!found) {
        modFriendsTemp.add({"Name": map['Name'], "Amount": map['Amount']});
      }
    }
    num average = 0;
    for (int i = 0; i < modFriendsTemp.length; i++) {
      totalExpense += modFriendsTemp[i]['Amount'];
    }
    average = totalExpense / modFriendsTemp.length;
    for (int i = 0; i < modFriendsTemp.length; i++) {
      //todo refactoring as var i in modFriendsTemp
      if (modFriendsTemp[i]['Amount'] > average) {
        for (int j = 0; j < modFriendsTemp.length; j++) {
          if (modFriendsTemp[j]['Amount'] < average) {
            var diff = modFriendsTemp[i]['Amount'] - average;
            if ((modFriendsTemp[j]['Amount'] + diff) > average) {
              shareDesc.add({
                'Sender': modFriendsTemp[j]['Name'],
                'Receiver': modFriendsTemp[i]['Name'],
                'Amount': average - modFriendsTemp[j]['Amount']
              });
              // sender.add(friendsTemp[i]);
              // receiver.add(friendsTemp[j]);
              modFriendsTemp[i]['Amount'] -=
                  (average - modFriendsTemp[j]['Amount']);
              modFriendsTemp[j]['Amount'] +=
                  average - modFriendsTemp[j]['Amount'];
            } else {
              shareDesc.add({
                'Sender': modFriendsTemp[j]['Name'],
                'Receiver': modFriendsTemp[i]['Name'],
                'Amount': diff
              });
              // sender.add(friendsTemp[j]);
              // receiver.add(friendsTemp[i]);
              modFriendsTemp[j]['Amount'] += diff;
              modFriendsTemp[i]['Amount'] -= diff;
            }
          }
        }
      }
    }
  }
  // FutureOr<Iterable<String>> getNames(TextEditingValue textEditingValue) {
  //   if (textEditingValue.text == '') {
  //     return const Iterable<String>.empty();
  //   }
  //   return friends.where((Map<String, dynamic> place) {
  //     return place['Name'].toLowerCase().contains(textEditingValue.text.toLowerCase());
  //   }).toList();
  // }
}
