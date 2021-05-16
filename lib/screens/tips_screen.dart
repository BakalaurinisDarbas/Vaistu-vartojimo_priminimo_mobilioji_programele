import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:medicine/database/repository.dart';
import 'package:medicine/models/calendar_day_model.dart';
import 'package:medicine/models/pill.dart';
import 'package:medicine/notifications/notifications.dart';

class TipsScreen extends StatefulWidget {
  @override
  _TipsScreenState createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  final Notifications _notifications = Notifications();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  List<Pill> allListOfPills = [];
  final Repository _repository = Repository();
  List<Pill> dailyPills = [];

  final CalendarDayModel _days = CalendarDayModel();
  List<CalendarDayModel> _daysList;

  int _lastChooseDay = 0;
  final List<String> dailyFreq = ["Vieną kartą", "Du kartus", "Tris kartus"];

  var _color = const Color(0xff0f4a3c);

  final TextStyle _titleTextStyle = const TextStyle(
      color: const Color(0xff0f4a3c),
      fontSize: 20,
      fontWeight: FontWeight.bold);

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

  @override
  void initState() {
    super.initState();
    initNotifies();
    setData();
    _daysList = _days.getCurrentDays();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thickness: 10,
      radius: Radius.circular(12),
      isAlwaysShown: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                "Priminimų istorija",
                style: _titleTextStyle,
              ),
              SizedBox(
                height: 10,
              ),
              ListView.builder(
                itemBuilder: (context, index) {
                  // check if the medicine time is lower than actual
                  bool isEnd = DateTime.now().millisecondsSinceEpoch >
                      dailyPills[index].time;
                  return isEnd && dailyPills.isNotEmpty
                      ? Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 7.5),
                          child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            shadowColor: Colors.black54,
                            margin: EdgeInsets.symmetric(vertical: 7.0),
                            color: Colors.white,
                            child: ListTile(
                              onTap: () {},
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 7.5),
                              title: Text(
                                dailyPills[index].name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    .copyWith(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                        decoration: isEnd
                                            ? TextDecoration.lineThrough
                                            : null),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              isThreeLine: false,
                              subtitle: Text(
                                "${dailyPills[index].amount} ${dailyPills[index].medicineForm} ${dailyFreq[dailyPills[index].dailyFreq]}/dieną "
                                "${dailyPills[index].withLiquid == 0 ? "su" : "be"} skysčiais ${dailyPills[index].afterMeal == 0 ? "prieš maistą" : "po maisto"}",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(
                                        color: Colors.grey[600],
                                        fontSize: 14.0,
                                        decoration: isEnd
                                            ? TextDecoration.lineThrough
                                            : null),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Column(
                                // direction: Axis.vertical,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 18,
                                  ),
                                  Text(
                                    "${DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(dailyPills[index].time))}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        decoration: isEnd
                                            ? TextDecoration.lineThrough
                                            : null),
                                  ),
                                ],
                              ),
                              minLeadingWidth: 55,
                              leading: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 10,
                                      offset: Offset(1.5, 1.5),
                                      color: Colors.black12,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Container(
                                    padding: EdgeInsets.all(1),
                                    color: Colors.grey.shade300,
                                    child: Container(
                                      width: 55.0,
                                      height: 55.0,
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                          isEnd
                                              ? Colors.white
                                              : Colors.transparent,
                                          BlendMode.saturation,
                                        ),
                                        child: Image.asset(
                                            dailyPills[index].image),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container();
                },
                itemCount: dailyPills.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
            ],
          ),
        ),
      ),
    );
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
