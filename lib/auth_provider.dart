import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//import 'home_page.dart';


class AuthProvider extends ChangeNotifier {

  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  String _username;

  final List<Map<String,dynamic>> _loggedInUserAccounts = [];

  final ngrokUrl = "https://9fbaebc1.ngrok.io";


  String get username{
    return _username;
  }

  List<Map<String,dynamic>> get loggedInUserAccounts{
    return List.from(_loggedInUserAccounts);
  }

  bool get isAuthenticated {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  void _showErrorDialog(BuildContext context, String message) {
    print(message);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("An error Occured!"),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Okay"),
          ),
        ],
      ),
    );
  }

  Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      final response = await http.post(
          "$ngrokUrl/user/login",
          body: json.encode(
            {
              "email": email,
              "password": password,
            },
          ),
          headers: {"Content-type": "application/json"}
      );

      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData["error"] != null) {
        _showErrorDialog(context, responseData["error"]);
        return;
      }

      _token = responseData["token"];
      _userId = responseData["userId"];
      _username = responseData["name"];
      _expiryDate = DateTime.now().add(Duration(hours: 12),);

      autoLogout();
      notifyListeners();

    await loggedInUserLists();

    } catch(error){
      _showErrorDialog(context, error.toString());
    }

  }



  Future<void> loggedInUserLists() async {

    final prefs = await SharedPreferences.getInstance();
    final userAuthData = json.encode(
      {
        "token": _token,
        "userId": _userId,
        "username": _username,
        "expiryDate": _expiryDate.toIso8601String(),
      },
    );

    //general setting of data
    prefs.setString("userAuthData", userAuthData);



    //setting list of names
      List<String> usersName =  [];
      if(prefs.getStringList("usersName") != null) {
      usersName = prefs.getStringList("usersName");
      }

      if(!usersName.contains("$_username")){
        usersName.add(_username);
        prefs.setStringList("usersName", usersName);
      }


    //setting name with data
      prefs.setString("$_username", userAuthData);


    if(prefs.getStringList("usersName") != null){
      _loggedInUserAccounts.clear();
      final userNames = prefs.getStringList("usersName");
      userNames.forEach((name) {
          final extractedUserAuthData =
          json.decode(prefs.getString("$name")) as Map<String, Object>;
          _loggedInUserAccounts.add(
            {
              "token": extractedUserAuthData["token"],
              "userId": extractedUserAuthData["userId"],
              "username": extractedUserAuthData["username"],
              "expiryDate": extractedUserAuthData["expiryDate"],
            },
          );
        });
      }

  }




  Future<void> signUp(
      BuildContext context, String name,String username ,String email, String password) async {

    final response = await http.put("$ngrokUrl/user/signup",
        body: json.encode(
          {
            "name": name,
            "username": username,
            "email": email,
            "password": password,
          },
        ),
        headers: {"Content-type": "application/json"});

    final responseData = json.decode(response.body);
    print(responseData);

    if (responseData["error"] != null) {
      _showErrorDialog(context, responseData["error"]);
      return;
    }

    await login(context, email, password);
  }

  Future<void> logout() async {
    _userId = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();

    prefs.remove("userAuthData");
    prefs.remove("$_username");

    _loggedInUserAccounts.removeWhere((user) => user["username"] == _username);

    //setting list of names
    final userNames = prefs.getStringList("usersName");
    userNames.removeWhere((name) => name == _username);
    prefs.setStringList("usersName", userNames);

    notifyListeners();
  }



  Future<void> profileChange() async {
    _userId = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove("userAuthData");

    notifyListeners();
  }

  Future<void> setProfile(Map<String,dynamic> userData) async {

    _token = userData["token"];
    _userId = userData["userId"];
    _username = userData["username"];
    _expiryDate = DateTime.parse(userData["expiryDate"]);

    print(_token);
    print(_userId);
    print(_username);
    print(_expiryDate);


    final prefs = await SharedPreferences.getInstance();
    final userAuthData = json.encode(
      {
        "token": _token,
        "userId": _userId,
        "username": _username,
        "expiryDate": _expiryDate.toIso8601String(),
      },
    );

    //general setting of data
    prefs.setString("userAuthData", userAuthData);

    notifyListeners();
  }


  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("userAuthData")) {
      return false;
    }

    final extractedUserAuthData =
    json.decode(prefs.getString("userAuthData")) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserAuthData["expiryDate"]);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _username = extractedUserAuthData["username"];
    _token = extractedUserAuthData["token"];
    _expiryDate = expiryDate;

//    _loggedInUserAccounts.clear();

    final userNames = prefs.getStringList("usersName");
    userNames.forEach((name) {
      final extractedUserAuthData =
      json.decode(prefs.getString("$name")) as Map<String, Object>;
      _loggedInUserAccounts.add(
        {
          "token": extractedUserAuthData["token"],
          "userId": extractedUserAuthData["userId"],
          "username": extractedUserAuthData["username"],
          "expiryDate": extractedUserAuthData["expiryDate"],
        },
      );
    });

    notifyListeners();
    autoLogout();

    return true;
  }

  void autoLogout(){
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final expiryTime = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: expiryTime), logout);
  }

}