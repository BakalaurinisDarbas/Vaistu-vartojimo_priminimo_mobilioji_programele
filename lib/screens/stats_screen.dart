import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:medicine/config/assets.dart';
import 'package:medicine/config/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final List<String> dailyFreq = ["Vieną kartą", "Du kartus", "Tris kartus"];

  var _color = const Color(0xff0f4a3c);

  final TextStyle _titleTextStyle = const TextStyle(
      color: const Color(0xff0f4a3c),
      fontSize: 20,
      fontWeight: FontWeight.bold);

  var time = TimeOfDay(hour: 8, minute: 00);
  var time1 = TimeOfDay(hour: 13, minute: 00);
  var time2 = TimeOfDay(hour: 18, minute: 00);

  DateTime breakfastTime = new DateTime.now();
  DateTime lunchTime = new DateTime.now();
  DateTime dinnerTime = new DateTime.now();

  @override
  void initState() {
    super.initState();
    initTime();
  }

  initTime() async {
    DateTime now = new DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // get saved times from shared prefs, if null then use default values.
    int getBreak = prefs.getInt("breakfast") ??
        DateTime(now.year, now.month, now.day, time.hour, time.minute)
            .millisecondsSinceEpoch;
    int getlunch = prefs.getInt("lunch") ??
        DateTime(now.year, now.month, now.day, time1.hour, time1.minute)
            .millisecondsSinceEpoch;
    int getdinner = prefs.getInt("dinner") ??
        DateTime(now.year, now.month, now.day, time2.hour, time2.minute)
            .millisecondsSinceEpoch;
    // convert that time to DateTime format
    setState(() {
      breakfastTime = DateTime.fromMillisecondsSinceEpoch(getBreak);
      lunchTime = DateTime.fromMillisecondsSinceEpoch(getlunch);
      dinnerTime = DateTime.fromMillisecondsSinceEpoch(getdinner);
    });

    // print all times
    print(breakfastTime.toString() +
        " " +
        lunchTime.toString() +
        " " +
        dinnerTime.toString());
  }

  @override
  Widget build(BuildContext context) {
    // final deviceSize = MediaQuery.of(context).size;
    return Scrollbar(
      thickness: 10,
      radius: Radius.circular(12),
      isAlwaysShown: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.8,
            child: Lottie.asset(
              Assets.anim_doctor,
              fit: BoxFit.fitWidth,
              repeat: true,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    "Mitybos įpročiai",
                    style: _titleTextStyle,
                  ),
                  Text(
                    "Paspauskite ant kortelės jei norite pakeisti laiką",
                    style: TextStyle(
                        color: _color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  getCardWidget("Pusryčių laikas", breakfastTime),
                  getCardWidget("Pietų laikas", lunchTime),
                  getCardWidget("Vakarienės laikas", dinnerTime),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    Strings.TIPS,
                    style: _titleTextStyle,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  getTipsCard(Strings.MEDICINE_TIP_TITLE1,
                      Strings.MEDICINE_TIP_DESCRIPTION1, "asset"),
                  getTipsCard(Strings.MEDICINE_TIP_TITLE2,
                      Strings.MEDICINE_TIP_DESCRIPTION2, "asset"),
                  getTipsCard(Strings.MEDICINE_TIP_TITLE3,
                      Strings.MEDICINE_TIP_DESCRIPTION3, "asset"),
                  getTipsCard(Strings.MEDICINE_TIP_TITLE4,
                      Strings.MEDICINE_TIP_DESCRIPTION4, "asset"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> openTimePicker(DateTime setDate, String time) async {
    TimeOfDay picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: setDate.hour, minute: setDate.minute),
            helpText: "Choose New Time")
        .then((value) async {
      DateTime newDate = DateTime(
          setDate.year,
          setDate.month,
          setDate.day,
          value != null ? value.hour : setDate.hour,
          value != null ? value.minute : setDate.minute);
      setState(() {
        if (time == "Pusryčių laikas" || time == "Nuo") {
          breakfastTime = newDate;
        } else if (time == "Pietų laikas") {
          lunchTime = newDate;
        } else if (time == "Vakarienės laikas") {
          dinnerTime = newDate;
        }
      });
      print(newDate.hour.toString() + ":" + newDate.minute.toString());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("breakfast", breakfastTime.millisecondsSinceEpoch);
      prefs.setInt("lunch", lunchTime.millisecondsSinceEpoch);
      prefs.setInt("dinner", dinnerTime.millisecondsSinceEpoch);
      return TimeOfDay(hour: newDate.hour, minute: newDate.minute);
    });

    if (picked != null &&
        picked != TimeOfDay(hour: setDate.hour, minute: setDate.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Išsaugoma...",
          textAlign: TextAlign.center,
        ),
        duration: Duration(milliseconds: 800),
      ));
    }
  }

  Widget getTitleTip(String asset) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TyperAnimatedTextKit(
        textStyle: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.start,
        alignment: Alignment.centerLeft,
        text: [asset],
        isRepeatingAnimation: false,
        speed: Duration(
          milliseconds: 80,
        ),
      ),
    );
  }

  Widget getTips(String asset) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        asset,
        style: TextStyle(
          fontSize: 14.0,
          backgroundColor: Colors.white,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget getCardWidget(String title, DateTime time) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.5),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () => openTimePicker(time, title),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          color: _color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        DateFormat.jm().format(time),
                        style: TextStyle(
                          color: _color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    "assets/images/breakfast.png",
                    width: 100,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getTipsCard(String title, String description, String asset) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15.0),
              child: Wrap(
                children: [
                  Column(
                    children: [
                      getTitleTip(title),
                      Divider(color: Colors.black12, height: 1, thickness: 1),
                      getTips(description),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
