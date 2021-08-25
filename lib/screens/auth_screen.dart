import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_waste_app/screens/products_overview_screen.dart';
import 'package:e_waste_app/screens/verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../providers/auth.dart';
// import '../models/http_exception.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final _auth = FirebaseAuth.instance;
    var _isLoading = false;

    void _submitAuthForm(
      String email,
      String password,
      int userMobile,
      bool isLogin,
      BuildContext ctx,
    ) async {
      UserCredential authResult;
      try {
        setState(() {
          _isLoading = true;
        });
        if (isLogin) {
          authResult = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          authResult = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          await authResult.user.sendEmailVerification();

          final inst = FirebaseFirestore.instance
              .collection('users')
              .doc(authResult.user.uid);

          await inst.set({'email': email, 'mobile': userMobile});
        }
        setState(() {
          _isLoading = false;
        });
        User user = FirebaseAuth.instance.currentUser;
        Navigator.of(context).canPop()
            ? Navigator.of(context).pop()
            : Navigator.of(context).pushReplacement(user.emailVerified
                ? MaterialPageRoute(builder: (ctx) => ProductsOverviewScreen())
                : MaterialPageRoute(builder: (ctx) => VerificationScreen()));
      } on FirebaseException catch (err) {
        var message = 'An error occurred, please check your credentials!';

        if (err.message != null) {
          message = err.message;
          print(message);
        }
        //.........
        // ScaffoldMessenger.of(ctx).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       message,
        //       style: TextStyle(
        //         color: Colors.white,
        //       ),
        //     ),
        //     backgroundColor: Colors.black54,
        //   ),
        // );
        setState(() {
          _isLoading = false;
        });
      } catch (err) {
        print(err);
        // setState(() {
        //   _isLoading = false;
        // });
      }
    }

    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0, left: 20, right: 20),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 50.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'e-Waste App',
                        maxLines: 2,
                        style: TextStyle(
                          color:
                              Theme.of(context).accentTextTheme.headline6.color,
                          fontSize: 48,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(_submitAuthForm, _isLoading),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  AuthCard(
    this.submitFn,
    this.isLoading,
  );

  final bool isLoading;
  final void Function(
    String email,
    String password,
    int userMobile,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  // var _isLoading = false;
  // final _passwordController = TextEditingController();
  AnimationController _controller;
  // Animation<Offset> _slideAnimation;
  // Animation<double> _opacityAnimation;
  var _isLogin = true;
  var _userEmail = '';
  var _userPassword = '';
  var _userMobile;
  TextEditingController _passwordController = TextEditingController();

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(
        _userEmail.trim(),
        _userPassword.trim(),
        _userMobile,
        _isLogin,
        context,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    // _slideAnimation = Tween<Offset>(
    //   begin: Offset(0, -1.5),
    //   end: Offset(0, 0),
    // ).animate(
    //   CurvedAnimation(
    //     parent: _controller,
    //     curve: Curves.fastOutSlowIn,
    //   ),
    // );
    // _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
    //   CurvedAnimation(
    //     parent: _controller,
    //     curve: Curves.easeIn,
    //   ),
    // );
    // _heightAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: !_isLogin ? 320 : 260,
        // height: _heightAnimation.value.height,
        constraints: BoxConstraints(minHeight: !_isLogin ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  key: ValueKey('email'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value.isEmpty ||
                        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email address',
                  ),
                  onSaved: (value) {
                    _userEmail = value;
                  },
                ),
                TextFormField(
                  key: ValueKey('password'),
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 7) {
                      return 'Password must be at least 7 characters long.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onSaved: (value) {
                    _userPassword = value;
                  },
                ),
                if (!_isLogin)
                  TextFormField(
                    key: ValueKey('mobile number'),
                    autocorrect: true,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value.isEmpty ||
                          value.length < 10 ||
                          value.isEmpty ||
                          value.length > 10) {
                        return 'Please enter exactly 10 digits.';
                      } else if (int.parse(value) == null) {
                        return 'Enter a 10-digit number only.';
                      }
                      return null;
                    },
                    enabled: !_isLogin,
                    decoration: InputDecoration(labelText: 'Mobile number'),
                    onSaved: (value) {
                      _userMobile = int.parse(value);
                    },
                  ),
                if (!_isLogin)
                  TextFormField(
                    enabled: !_isLogin,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                    ),
                    obscureText: true,
                    validator: !_isLogin
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                            return null;
                          }
                        : null,
                  ),

                // AnimatedContainer(
                //   constraints: BoxConstraints(
                //     minHeight: _isLogin ? 0 : 60,
                //     maxHeight: _isLogin ? 0 : 120,
                //   ),
                //   duration: Duration(milliseconds: 300),
                //   curve: Curves.easeIn,
                //   child: FadeTransition(
                //     opacity: _opacityAnimation,
                //     child: SlideTransition(
                //       position: _slideAnimation,
                //       child: TextFormField(
                //         key: ValueKey('mobile number'),
                //         autocorrect: true,
                //         textCapitalization: TextCapitalization.words,
                //         validator: (value) {
                //           if (value.isEmpty ||
                //               value.length < 10 ||
                //               value.isEmpty ||
                //               value.length > 10) {
                //             return 'Please enter exactly 10 digits.';
                //           } else if (int.parse(value) == null) {
                //             return 'Enter a 10-digit number only.';
                //           }
                //           return null;
                //         },
                //         enabled: !_isLogin,
                //         decoration: InputDecoration(labelText: 'Mobile number'),
                //         onSaved: (value) {
                //           _userMobile = int.parse(value);
                //         },
                //       ),
                //     ),
                //   ),
                // ),
                // AnimatedContainer(
                //   constraints: BoxConstraints(
                //     minHeight: !_isLogin ? 60 : 0,
                //     maxHeight: !_isLogin ? 120 : 0,
                //   ),
                //   duration: Duration(milliseconds: 300),
                //   curve: Curves.easeIn,
                //   child: FadeTransition(
                //     opacity: _opacityAnimation,
                //     child: SlideTransition(
                //       position: _slideAnimation,
                //       child: TextFormField(
                //         enabled: !_isLogin,
                //         decoration: InputDecoration(
                //           labelText: 'Confirm Password',
                //         ),
                //         obscureText: true,
                //         validator: !_isLogin
                //             ? (value) {
                //                 if (value != _userPassword) {
                //                   return 'Passwords do not match!';
                //                 }
                //                 return null;
                //               }
                //             : null,
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(
                  height: 20,
                ),
                if (widget.isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child: Text(_isLogin ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _trySubmit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 4)),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '${_isLogin ? 'SIGNUP' : 'LOGIN'} INSTEAD',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  // padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  // textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
