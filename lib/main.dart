import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'auth_page.dart';
import 'auth_provider.dart';
import 'home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: AuthProvider(),
        ),
      ],
      child:
      Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.purple,
          ),
          home: auth.isAuthenticated
              ? HomePage()
              : FutureBuilder(
            future: auth.autoLogin(),
            builder: (context, authResult) =>
            authResult.connectionState == ConnectionState.waiting
                ? Scaffold(
              body: Center(
                child: Text("Insta"),
              ),
            )
                : AuthPage(),
          ),
        ),
      ),

    );
  }
}

