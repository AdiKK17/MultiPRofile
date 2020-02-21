import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'auth_provider.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AuthPage();
  }
}

enum AuthMode { Login, SignUp }

class _AuthPage extends State<AuthPage> {

  var _isLoading = false;
  AuthMode _authMode = AuthMode.Login;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();

  final Map<String, dynamic> _formData = {
    "name": null,
    "username": null,
    "email": null,
    "password": null,
  };

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelStyle: TextStyle(color: _authMode == AuthMode.Login ?  Colors.black54 : Colors.white),
        labelText: 'E-Mail',
        enabledBorder:
        UnderlineInputBorder(borderSide: BorderSide(color: _authMode == AuthMode.Login ?  Colors.black54 : Colors.white),),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildUsernameTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder:
        UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        labelText: 'UserName',
      ),
      keyboardType: TextInputType.text,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter a username';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['username'] = value;
      },
    );
  }

  Widget _buildNameTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          labelText: 'Name'),
      keyboardType: TextInputType.text,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['name'] = value;
      },
    );
  }


  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: _authMode == AuthMode.Login ?  Colors.black54 : Colors.white),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: _authMode == AuthMode.Login ?  Colors.black54 : Colors.white),
        ),
      ),
      obscureText: true,
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty || value.length < 1) {
          return 'Password invalid';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildPasswordConfirmTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          labelText: 'Confirm Password'),
      obscureText: true,
      validator: (String value) {
        if (_passwordTextController.text != value) {
          return 'Passwords do not match.';
        }
        return null;
      },
    );
  }



  Future<void> _submitForm() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    setState(() {
      _isLoading = true;
    });

    if (_authMode == AuthMode.Login) {
      await Provider.of<AuthProvider>(context, listen: false)
          .login(context, _formData["email"], _formData["password"]);
    } else {
      await Provider.of<AuthProvider>(context, listen: false).signUp(
        context,
        _formData["name"],
        _formData["username"],
        _formData["email"],
        _formData["password"],
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: _authMode == AuthMode.Login
          ? Container(
        height: double.infinity,
        width: double.infinity,
        child: Form(key: _formKey,child: SingleChildScrollView(
          child: Column(
            children: <Widget>[

             SizedBox(height: 100,),

              Container(
                child: _buildEmailTextField(),
                width: deviceWidth * 0.80,
              ),
              SizedBox(height: 15,),
              Container(
                child: _buildPasswordTextField(),
                width: deviceWidth * 0.80,
              ),

              SizedBox(height: 50,),

              _isLoading
                  ? CircularProgressIndicator()
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    _authMode == AuthMode.SignUp
                        ? "Sign up"
                        : "Sign In",
                    style: TextStyle(
                        color: Colors.black87, fontSize: 25,fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 90,
                  ),
                  GestureDetector(
                    onTap: () => _submitForm(),
                    child: CircleAvatar(
                      backgroundColor: Colors.black87,
                      child: Icon(Icons.arrow_forward,color: Colors.white,size: 35,),
                      radius: 35,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 90,),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 23,),
                  FlatButton(
                    onPressed: () {
                      setState(() {
                        if (_authMode == AuthMode.Login) {
                          _authMode = AuthMode.SignUp;
                        } else {
                          _authMode = AuthMode.Login;
                        }
                      });
                    },
                    child: Text(
                      _authMode == AuthMode.Login ? "Sign up" : "Login",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              )

            ],
          ),
        ),
        ),)

          : Container(
        height: double.infinity,
        width: double.infinity,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
//                  padding: EdgeInsets.only(top: 220),
                  padding: EdgeInsets.only(
                      left: 5,
                      top: MediaQuery.of(context).size.height * 0.10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Create \naccount ",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 40),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  child: _buildEmailTextField(),
                  width: deviceWidth * 0.85,
                ),
                SizedBox(
                  height: 15,
                ),
                _authMode == AuthMode.SignUp
                    ? Container(
                  child: _buildUsernameTextField(),
                  width: deviceWidth * 0.85,
                )
                    : Container(),
                SizedBox(
                  height: 10,
                ),
                _authMode == AuthMode.SignUp
                    ? Container(
                  child: _buildNameTextField(),
                  width: deviceWidth * 0.85,
                )
                    : Container(),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: _buildPasswordTextField(),
                  width: deviceWidth * 0.85,
                ),
                SizedBox(
                  height: 10,
                ),
                _authMode == AuthMode.SignUp
                    ? Container(
                  child: _buildPasswordConfirmTextField(),
                  width: deviceWidth * 0.85,
                )
                    : Container(),
                SizedBox(
                  height: 25,
                ),
                _isLoading
                    ? CircularProgressIndicator()
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      _authMode == AuthMode.SignUp
                          ? "Sign up"
                          : "Login",
                      style: TextStyle(
                          color: Colors.white, fontSize: 25),
                    ),
                    SizedBox(
                      width: 90,
                    ),
                    GestureDetector(
                      onTap: () => _submitForm(),
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.arrow_forward,color: Colors.white,size: 30,),
                        radius: 35,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 25,),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          if (_authMode == AuthMode.Login) {
                            _authMode = AuthMode.SignUp;
                          } else {
                            _authMode = AuthMode.Login;
                          }
                        });
                      },
                      child: Text(
                        _authMode == AuthMode.Login ? "Sign up" : "Login",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
