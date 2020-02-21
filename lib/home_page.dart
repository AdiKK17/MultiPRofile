import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'auth_provider.dart';
import 'auth_page.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AuthProvider>(context);

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.tealAccent,
                  title: Text("Choose an Account"),
                  content: Container(
                    color: Colors.red,
                    height: 400,
                    width: 300,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text(model.loggedInUserAccounts[index]
                                    ["username"]),
                                onTap: () {
                                  model.setProfile(
                                      model.loggedInUserAccounts[index]);
                                  Navigator.pop(context);
                                },
                              );
                            },
                            itemCount: model.loggedInUserAccounts.length,
                          ),
                        ),
                        RaisedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            model.profileChange();
                          },
                          child: Text("Add New Account"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Row(
            children: <Widget>[
              Text(model.username),
              SizedBox(
                width: 2,
              ),
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.all_out),
              onPressed: () {
                model.logout();
              }),
        ],
      ),
      body: Center(
        child: Text("Welcome"),
      ),
    );
  }
}
