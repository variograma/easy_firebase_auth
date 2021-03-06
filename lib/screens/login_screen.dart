import 'package:apple_sign_in/apple_sign_in_button.dart' as asi;
import 'package:easy_firebase_auth/buttons/facebook_sign_in_button.dart';
import 'package:easy_firebase_auth/buttons/twitter_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:easy_firebase_auth/buttons/email_sign_in_button.dart';
import 'package:easy_firebase_auth/buttons/google_sign_in_button.dart';
import 'package:easy_firebase_auth/states/auth_state.dart';
import 'package:easy_firebase_auth/values/auth_strings.dart';
import 'package:provider/provider.dart';

import 'email_login_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool logInWithEmail, logInWithGoogle, logInWithTwitter, logInWithFacebook, logInWithApple, logInAnonymous;
  final bool darkMode;
  final Color backgroundColor;
  final Widget backgroundWidget, expandedWidget;
  final AuthStrings authStrings;
  final double buttonBorderRadius;

  final List<String> facebookPermissions;

  final WidgetBuilder emailLoginBuilder;

  final String twitterConsumerKey;
  final String twitterConsumerSecret;

  const LoginScreen(
      {Key key,
      this.emailLoginBuilder,
      this.buttonBorderRadius = 3.0,
      this.logInWithEmail = true,
      this.logInWithGoogle = true,
      this.logInWithTwitter = false,
      this.logInWithFacebook = false,
      this.logInWithApple = true,
      this.logInAnonymous = true,
      this.darkMode = false,

      this.twitterConsumerKey="",
      this.twitterConsumerSecret="",

      this.facebookPermissions=const ["email"],

      this.backgroundColor,
      this.backgroundWidget,
      this.expandedWidget,
      this.authStrings})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool supportsAppleSignIn = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    AuthStrings strings = widget.authStrings ?? AuthStrings.english();

    AuthState authState = Provider.of<AuthState>(context);
    authState.supportsAppleSignIn().then((value) {
      setState(() {
        supportsAppleSignIn = value;
      });
    });

    return SafeArea(
      child: Scaffold(
        backgroundColor: widget.backgroundColor,
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (widget.backgroundWidget != null)
              Container(
                width: double.infinity,
                height: double.infinity,
                child: widget.backgroundWidget,
              ),
            Column(
              children: <Widget>[
                Expanded(
                  child: widget.expandedWidget != null
                      ? widget.expandedWidget
                      : Container(),
                ),
                if (widget.logInWithEmail)
                  Container(
                    width: 300,
                    height: 40,
                    margin: EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 16),
                    child: EmailSignInButton(
                      borderRadius: widget.buttonBorderRadius,
                      buttonColor: Colors.green,
                      text: strings.signInWithEmail,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: widget.emailLoginBuilder ??
                                  (BuildContext context) => EmailLoginScreen(
                                        authStrings: strings,
                                      )),
                        );
                      },
                    ),
                  ),



                if (widget.logInWithGoogle)
                  Container(
                    width: 300,
                    height: 40,
                    margin: EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 16),
                    child: GoogleSignInButton(
                      borderRadius: widget.buttonBorderRadius,
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        var user = await authState.signInGoogle();
                        loading = false;
                        if (user == null) {
                          setState(() {});
                        }
                      },
                      darkMode: widget.darkMode,
                      text: strings.signInWithGoogle,

                    ),
                  ),



                if (widget.logInWithFacebook)
                  Container(
                    width: 300,
                    height: 40,
                    margin: EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 16),
                    child: FacebookSignInButton(
                      borderRadius: widget.buttonBorderRadius,
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        var user = await authState.signInFacebook(widget.facebookPermissions);
                        loading = false;
                        if (user == null) {
                          setState(() {});
                        }
                      },
                      text: strings.signInWithFacebook,
                    ),
                  ),

/*
                if (widget.logInWithTwitter)
                  Container(
                    width: 300,
                    height: 40,
                    margin: EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 16),
                    child: TwitterSignInButton(
                      borderRadius: widget.buttonBorderRadius,
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        var user = await authState.signInTwitter(widget.twitterConsumerKey, widget.twitterConsumerSecret);
                        loading = false;
                        if (user == null) {
                          setState(() {});
                        }
                      },
                      text: strings.signInWithTwitter,
                    ),
                  ),
*/

                if (widget.logInWithApple && supportsAppleSignIn)
                  Container(
                    width: 300,
                    height: 40,
                    margin: EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 16),
                    child: asi.AppleSignInButton(

                      style: widget.darkMode
                          ? asi.ButtonStyle.black
                          : asi.ButtonStyle.white,
                      type: asi.ButtonType.continueButton,
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        var user = await authState.signInApple();
                        loading = false;
                        if (user == null) {
                          setState(() {});
                        }
                      },
                    ),
                  ),
                if (widget.logInAnonymous)
                  Container(
                    width: 30,
                    child: Divider(
                      thickness: 1,
                      color: Colors.white,
                    ),
                  ),
                if (widget.logInAnonymous)
                  Container(
                    width: 300,
                    child: FlatButton(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        await authState.signInAnonymous();
                        setState(() {
                          loading = false;
                        });
                      },
                      child: Text(
                        strings.signInAnonymous,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            loading ? CircularProgressIndicator() : Container()
          ],
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}
