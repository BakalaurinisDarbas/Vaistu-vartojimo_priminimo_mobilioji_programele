import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:medicine/config/assets.dart';
import 'package:medicine/config/strings.dart';
import 'package:medicine/database/repository.dart';
import 'package:medicine/models/calendar_day_model.dart';
import 'package:medicine/models/pill.dart';
import 'package:medicine/notifications/notifications.dart';
import 'package:medicine/screens/add_new_medicine/add_new_medicine.dart';
import 'package:medicine/screens/home/medicine_card.dart';

import 'calendar.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Notifications _notifications = Notifications();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  List<Pill> allListOfPills = [];
  final Repository _repository = Repository();
  List<Pill> dailyPills = [];

  final CalendarDayModel _days = CalendarDayModel();
  List<CalendarDayModel> _daysList;

  int _lastChooseDay = 0;

  @override
  void initState() {
    super.initState();
    initNotifies();
    setData();
    _daysList = _days.getCurrentDays();
    // print all pills list from database
    _repository
        .getAllDATAFromDB("Pills")
        .then((value) => log(value.asMap().values.toList().toString()));
  }

  // init notifications
  Future initNotifies() async => flutterLocalNotificationsPlugin =
      await _notifications.initNotifies(context);

  Future setData() async {
    allListOfPills.clear();
    (await _repository.getAllData("Pills")).forEach((pillMap) {
      allListOfPills.add(Pill().pillMapToObject(pillMap));
    });
    chooseDay(_daysList[_lastChooseDay]);
  }

  final TextStyle _titleTextStyle = const TextStyle(
      color: const Color(0xff0f4a3c),
      fontSize: 20,
      fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    final double deviceHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    final Widget addButton = FloatingActionButton.extended(
      heroTag: "FAB",
      elevation: 7.0,
      onPressed: () async {
        await Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => AddNewMedicine(
                  medicineId: 1234,
                  shouldEdit: false,
                ),
              ),
            )
            .then((value) => setData());
      },
      icon: Icon(
        Icons.add,
        color: Colors.black,
        size: 28.0,
      ),
      label: Text(
        "Pridėti priminimą",
        style:
            _titleTextStyle.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );

    // bool isFinished = false;
    // for (int i = 0; i <= dailyPills.length - 1; i++) {
    //   if (DateTime.now().millisecondsSinceEpoch > dailyPills[i].time) {
    //     isFinished = true;
    //     print("expired med found " + dailyPills.length.toString());
    //   }
    // }

    return Scaffold(
      floatingActionButton: addButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: Color.fromRGBO(248, 248, 248, 1),
      body: SafeArea(
        child: Scrollbar(
          isAlwaysShown: true,
          thickness: 10,
          radius: Radius.circular(12),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  top: 0.0, left: 25.0, right: 25.0, bottom: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: deviceHeight * 0.03),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Calendar(chooseDay, _daysList),
                    ),
                  ),
                  SizedBox(height: deviceHeight * 0.02),
                  Divider(color: Colors.black12, height: 1, thickness: 1),
                  SizedBox(height: deviceHeight * 0.01),
                  Column(
                    children: [
                      dailyPills.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  Assets.anim_pills,
                                  repeat: true,
                                  fit: BoxFit.contain,
                                  height: 150,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  height: 100,
                                  child: TyperAnimatedTextKit(
                                    textStyle: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                    alignment: Alignment.center,
                                    text: [Strings.ADD_MEDS],
                                    isRepeatingAnimation: false,
                                    speed: Duration(
                                      milliseconds: 80,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              itemBuilder: (context, index) {
                                return MedicineCard(dailyPills[index], setData,
                                    flutterLocalNotificationsPlugin);
                              },
                              itemCount: dailyPills.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                            ),
                      // isFinished
                      //     ? Container(
                      //         alignment: Alignment.center,
                      //         height: 100,
                      //         child: TyperAnimatedTextKit(
                      //           textStyle: TextStyle(
                      //             fontSize: 16.0,
                      //             fontWeight: FontWeight.normal,
                      //             color: Colors.black,
                      //           ),
                      //           textAlign: TextAlign.center,
                      //           alignment: Alignment.center,
                      //           text: [Strings.NO_MORE_MEDS],
                      //           isRepeatingAnimation: false,
                      //           speed: Duration(
                      //             milliseconds: 80,
                      //           ),
                      //         ),
                      //       )
                      //     : Container(),
                      Container(
                        height: 20,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void chooseDay(CalendarDayModel clickedDay) {
    setState(() {
      _lastChooseDay = _daysList.indexOf(clickedDay);
      _daysList.forEach((day) => day.isChecked = false);
      CalendarDayModel chooseDay = _daysList[_daysList.indexOf(clickedDay)];
      chooseDay.isChecked = true;
      dailyPills.clear();
      allListOfPills.forEach((pill) {
        DateTime pillDate =
            DateTime.fromMicrosecondsSinceEpoch(pill.time * 1000);
        if (chooseDay.dayNumber == pillDate.day &&
            chooseDay.month == pillDate.month &&
            chooseDay.year == pillDate.year) {
          dailyPills.add(pill);
        }
      });
      dailyPills.sort((pill1, pill2) => pill1.time.compareTo(pill2.time));
    });
  }
}
