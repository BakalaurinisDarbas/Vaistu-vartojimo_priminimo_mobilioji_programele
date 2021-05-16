import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medicine/config/assets.dart';
import 'package:medicine/config/strings.dart';
import 'package:medicine/helpers/platform_flat_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  Future<void> checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('first_time') ?? false);
    if (_seen) {
      goToHomeScreen();
      //return "/nav_bar";
    } else {
      return "/";
    }
  }

  void goToHomeScreen() async {
    Navigator.pushReplacementNamed(context, "/nav_bar");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('first_time', true);
  }

  @override
  void initState() {
    // TODO: implement initState
    checkFirstSeen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    return FutureBuilder(
        future: checkFirstSeen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: deviceHeight * 0.04,
                    ),
                    Lottie.asset(Assets.anim_doctor,
                        width: double.infinity, height: deviceHeight * 0.4),
                    Spacer(),
                    Column(
                      children: [
                        Container(
                          height: deviceHeight * 0.15,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 40.0),
                            child: AutoSizeText(
                              Strings.TITLE,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline1
                                  .copyWith(color: Colors.black, height: 1.3),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        Container(
                          height: deviceHeight * 0.15,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 40.0),
                            child: AutoSizeText(
                              Strings.DESC,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .copyWith(
                                    color: Colors.grey[600],
                                    height: 1.3,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Container(
                      height: deviceHeight * 0.09,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 35.0, right: 35.0),
                        child: PlatformFlatButton(
                          handler: goToHomeScreen,
                          color: Theme.of(context).primaryColor,
                          buttonChild: FittedBox(
                            child: Text(
                              Strings.CONTINUE,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            );
          }
        });
  }
}
