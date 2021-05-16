import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:medicine/config/strings.dart';
import 'package:medicine/database/repository.dart';
import 'package:medicine/helpers/platform_flat_button.dart';
import 'package:medicine/helpers/snack_bar.dart';
import 'package:medicine/models/medicine_type.dart';
import 'package:medicine/models/pill.dart';
import 'package:medicine/notifications/notifications.dart';
import 'package:medicine/screens/add_new_medicine/slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AddNewMedicine extends StatefulWidget {
  final int medicineId;
  final bool shouldEdit;

  const AddNewMedicine({Key key, this.medicineId, this.shouldEdit})
      : super(key: key);

  @override
  _AddNewMedicineState createState() => _AddNewMedicineState();
}

enum HowLong { days, weeks }

class _AddNewMedicineState extends State<AddNewMedicine> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final Snackbar snackbar = Snackbar();

  //medicine types
  final List<String> weightValues = ["Piliulės", "mililitrai", "miligramai"];
  List<String> mealValues = ["Prieš", "Po"];
  List<String> withLiquid = ["Taip", "Ne"];

  //list of medicines forms objects
  final List<MedicineType> medicineTypes = [
    MedicineType("Syrupas", Image.asset("assets/images/syrup.png"), true),
    MedicineType("Piliulės", Image.asset("assets/images/pills.png"), false),
    MedicineType("Kapsulės", Image.asset("assets/images/capsule.png"), false),
    MedicineType("Kremas", Image.asset("assets/images/cream.png"), false),
    MedicineType("Lašai", Image.asset("assets/images/drops.png"), false),
    MedicineType("Injekcijos", Image.asset("assets/images/syringe.png"), false),
  ];

  int howManyWeeks = 1;
  int howManyDays = 1;
  int howManyTimes = 0;
  List<String> freq = ["Vieną kartą", "Du kartus", "Tris kartus"];
  HowLong _duration = HowLong.days;
  int beforeOrAfterMeal = 0;
  String selectWeight;
  String selectLiquid;
  DateTime setDate = DateTime.now();
  DateTime setDate1 = DateTime.now();
  DateTime setDate2 = DateTime.now();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController maxAmountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Database and notifications
  final Repository _repository = Repository();
  final Notifications _notifications = Notifications();

  final TextStyle titleTextStyle = TextStyle(
      color: Colors.grey[800], fontSize: 18.0, fontWeight: FontWeight.w600);

  final TextStyle widgetTextStyle = TextStyle(
      color: Colors.black, fontWeight: FontWeight.w400, fontSize: 16.0);

  int _currentPage = 0;

  final _controller = PageController(initialPage: 0);
  final _animDuration = Duration(milliseconds: 300);
  final _curve = Curves.easeInOutCubic;
  Pill editedPill;

  bool editingMode = false;

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    amountController.dispose();
    maxAmountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selectWeight = weightValues[0];
    selectLiquid = withLiquid[0];

    initNotifies();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page.round();
      });
    });

    initTime();

    if (widget.shouldEdit == true) {
      _repository.getPillDataFromDB("Pills", widget.medicineId).then((value) {
        editedPill = new Pill().pillMapToObject(value.single);
        print("editing " + value.asMap().values.toList().first.toString());
        setState(() {
          nameController.text = editedPill.name;
          amountController.text = editedPill.amount;
          notesController.text = editedPill.notes;
          maxAmountController.text = editedPill.maxPills.toString();
          editingMode = true;
          setDate = DateTime.fromMillisecondsSinceEpoch(editedPill.time);
          setDate1 = DateTime.fromMillisecondsSinceEpoch(editedPill.time1);
          setDate2 = DateTime.fromMillisecondsSinceEpoch(editedPill.time2);
          setDate = DateTime(setDate.year, setDate.month, setDate.day,
              setDate.hour, setDate.minute);
          setDate1 = DateTime(setDate.year, setDate.month, setDate.day,
              setDate1.hour, setDate1.minute);
          setDate2 = DateTime(setDate.year, setDate.month, setDate.day,
              setDate2.hour, setDate2.minute);
          howManyTimes = editedPill.dailyFreq;
          beforeOrAfterMeal = editedPill.afterMeal;
          howManyDays = editedPill.howManyDays;
          howManyWeeks = editedPill.howManyWeeks;
          selectLiquid = withLiquid[editedPill.withLiquid];
          selectWeight = editedPill.type;
          _duration = editedPill.dayOrWeek == 0 ? HowLong.days : HowLong.weeks;
        });
      });
    }
  }

  initTime() async {
    var time = TimeOfDay(hour: 8, minute: 00);
    var time1 = TimeOfDay(hour: 13, minute: 00);
    var time2 = TimeOfDay(hour: 18, minute: 00);
    DateTime now = new DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setDate = DateTime.fromMillisecondsSinceEpoch(prefs.getInt("breakfast") ??
        DateTime(now.year, now.month, now.day, time.hour, time.minute)
            .millisecondsSinceEpoch);
    setDate1 = DateTime.fromMillisecondsSinceEpoch(prefs.getInt("lunch") ??
        DateTime(now.year, now.month, now.day, time1.hour, time1.minute)
            .millisecondsSinceEpoch);
    setDate2 = DateTime.fromMillisecondsSinceEpoch(prefs.getInt("dinner") ??
        DateTime(now.year, now.month, now.day, time2.hour, time2.minute)
            .millisecondsSinceEpoch);
    setDate =
        DateTime(now.year, now.month, now.day, setDate.hour, setDate.minute);
    setDate1 =
        DateTime(now.year, now.month, now.day, setDate1.hour, setDate1.minute);
    setDate2 =
        DateTime(now.year, now.month, now.day, setDate2.hour, setDate2.minute);
  }

  Future initNotifies() async => flutterLocalNotificationsPlugin =
      await _notifications.initNotifies(context);

  @override
  Widget build(BuildContext context) {
    final focus = FocusScope.of(context);

    final deviceSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        if (_currentPage == 1) {
          setState(() {
            _controller.animateToPage(0,
                duration: _animDuration, curve: _curve);
          });
        } else {
          Navigator.pop(context);
        }
        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () {
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        },
        child: Stack(
          children: [
            Hero(
              tag: "FAB",
              child: Container(),
            ),
            Scaffold(
              key: _scaffoldKey,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: Text(
                  Strings.ADD_PILLS,
                  style: Theme.of(context).textTheme.headline3.copyWith(
                        color: Colors.black,
                        fontSize: 24,
                      ),
                ),
              ),
              body: SafeArea(
                child: PageView(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: _controller,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(height: 10),
                          SizedBox(height: 10),
                          Text(
                            Strings.ADD_DETAILS,
                            style: titleTextStyle,
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 7.5),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Container(
                                              child: TextFormField(
                                                textInputAction:
                                                    TextInputAction.next,
                                                controller: nameController,
                                                style: widgetTextStyle,
                                                decoration: getInputDecoration(
                                                    Strings.PILLS_NAME),
                                                validator: (value) =>
                                                    validateForm(value),
                                                onEditingComplete: () =>
                                                    focus.nextFocus(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            child: Container(
                                              child: TextFormField(
                                                textInputAction:
                                                    TextInputAction.done,
                                                controller: amountController,
                                                keyboardType:
                                                    TextInputType.number,
                                                style: widgetTextStyle,
                                                decoration: getInputDecoration(
                                                    Strings.PILLS_AMOUNT),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Prašome įvesti kiekį';
                                                  }
                                                  return null;
                                                },
                                                onEditingComplete: () =>
                                                    focus.nextFocus(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Container(
                                              child: TextFormField(
                                                textInputAction:
                                                    TextInputAction.next,
                                                controller: maxAmountController,
                                                keyboardType:
                                                    TextInputType.number,
                                                style: widgetTextStyle,
                                                decoration: getInputDecoration(
                                                    Strings.PILLS_MAX),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Prašome įvesti maksimalią dienos dozę';
                                                  }
                                                  return null;
                                                },
                                                onEditingComplete: () =>
                                                    focus.nextFocus(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            child: Container(
                                              child: DropdownButtonFormField(
                                                onTap: () => focus.unfocus(),
                                                // onSaved: (_) =>
                                                //     TextInputAction.next,
                                                decoration: getInputDecoration(
                                                    Strings.LIQUID),
                                                items: withLiquid
                                                    .map(
                                                      (weight) =>
                                                          DropdownMenuItem(
                                                        child: Text(weight,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                widgetTextStyle),
                                                        value: weight,
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) =>
                                                    popUpLiquidChanged(value),
                                                value: selectLiquid,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            flex: 1,
                                            child: Container(
                                              child: DropdownButtonFormField(
                                                  onTap: () => focus.unfocus(),
                                                  // onSaved: (_) =>
                                                  //     TextInputAction.next,
                                                  decoration:
                                                      getInputDecoration(
                                                          Strings.PILLS_TYPE),
                                                  items: weightValues
                                                      .map((weight) =>
                                                          DropdownMenuItem(
                                                            child: Text(
                                                              weight,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            value: weight,
                                                          ))
                                                      .toList(),
                                                  onChanged: (value) =>
                                                      popUpMenuItemChanged(
                                                          value),
                                                  value: selectWeight),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Container(
                                              child: TextFormField(
                                                textInputAction:
                                                    TextInputAction.done,
                                                controller: notesController,
                                                style: widgetTextStyle,
                                                decoration: getInputDecoration(
                                                    Strings.PILLS_NOTE),
                                                maxLines: 3,
                                                maxLength: 150,
                                                onEditingComplete: () =>
                                                    focus.unfocus(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 7.5),
                          Container(
                            height: 55,
                            width: deviceSize.width * .85,
                            child: PlatformFlatButton(
                              handler: () async {
                                focus.unfocus();
                                bool validated =
                                    _formKey.currentState.validate();
                                if (validated) {
                                  _controller.animateToPage(1,
                                      duration: _animDuration, curve: _curve);
                                }
                              },
                              color: Theme.of(context).primaryColor,
                              buttonChild: Text(
                                "Toliau",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                Strings.HOW_LONG,
                                style: titleTextStyle,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Radio<HowLong>(
                                activeColor: Theme.of(context).primaryColor,
                                value: HowLong.days,
                                groupValue: _duration,
                                onChanged: (HowLong value) {
                                  setState(() {
                                    _duration = value;
                                  });
                                },
                              ),
                              Text("Dienos"),
                              Radio<HowLong>(
                                activeColor: Theme.of(context).primaryColor,
                                value: HowLong.weeks,
                                groupValue: _duration,
                                onChanged: (HowLong value) {
                                  setState(() {
                                    _duration = value;
                                  });
                                },
                              ),
                              Text("Savaitės"),
                            ],
                          ),
                          Container(
                            child: UserSlider(
                                _duration == HowLong.days
                                    ? daysSliderChanged
                                    : sliderChanged,
                                _duration == HowLong.days
                                    ? this.howManyDays
                                    : this.howManyWeeks),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: FittedBox(
                              child: _duration == HowLong.days
                                  ? Text('$howManyDays Dienos(a)')
                                  : Text('$howManyWeeks Savaites(e)'),
                            ),
                          ),
                          Text(
                            Strings.HOW_MANY_TIMES,
                            style: titleTextStyle,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List<Widget>.generate(
                              3,
                              (int index) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7.5, vertical: 0),
                                  child: RawChip(
                                    elevation: 5,
                                    showCheckmark: true,
                                    selectedColor:
                                        Theme.of(context).primaryColor,
                                    label: Text('${freq[index]}'),
                                    selected: howManyTimes == index,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        howManyTimes = selected ? index : index;
                                      });
                                    },
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List<Widget>.generate(
                              2,
                              (int index) {
                                List<String> freq = [
                                  "Prieš maistą",
                                  "Po maisto",
                                ];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7.5, vertical: 0),
                                  child: RawChip(
                                    elevation: 5,
                                    selectedColor:
                                        Theme.of(context).primaryColor,
                                    showCheckmark: true,
                                    label: Text('${freq[index]}'),
                                    selected: beforeOrAfterMeal == index,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        beforeOrAfterMeal =
                                            selected ? index : index;
                                      });
                                    },
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                          SizedBox(height: 10),
                          Text(
                            Strings.MED_FORM,
                            style: titleTextStyle,
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 100,
                            child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: <Widget>[
                                ...medicineTypes.map((type) {
                                  if (widget.shouldEdit && editingMode) {
                                    medicineTypes.forEach((medicineType) =>
                                        medicineType.isChoose = false);
                                    medicineTypes[medicineTypes.indexWhere(
                                            (element) =>
                                                element.name ==
                                                editedPill.medicineForm)]
                                        .isChoose = true;
                                    editingMode = false;
                                  }
                                  return Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => medicineTypeClick(type),
                                        child: Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: type.isChoose
                                                  ? Color.fromRGBO(
                                                      7, 190, 200, 1)
                                                  : Colors.white,
                                            ),
                                            width: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Spacer(),
                                                Container(
                                                    width: 50,
                                                    height: 50.0,
                                                    child: type.image),
                                                Spacer(),
                                                Container(
                                                  child: Text(
                                                    type.name,
                                                    style: TextStyle(
                                                        color: type.isChoose
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                                Spacer(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 7.5,
                                      )
                                    ],
                                  );
                                })
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          howManyTimes != 0
                              ? howManyTimes == 1
                                  ? SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          getTimeWidget("1 Laikas", setDate),
                                          getTimeWidget("2 Laikas", setDate1),
                                          getDateWidget("Nuo", setDate)
                                        ],
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          getTimeWidget("1 Laikas", setDate),
                                          getTimeWidget("2 Laikas", setDate1),
                                          getTimeWidget("3 Laikas", setDate2),
                                          getDateWidget("Nuo", setDate)
                                        ],
                                      ),
                                    )
                              : Container(
                                  width: double.infinity,
                                  height: 60,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: double.infinity,
                                          child: PlatformFlatButton(
                                            handler: () => openTimePicker(
                                                setDate, "Breakfast"),
                                            buttonChild: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Spacer(),
                                                Text(
                                                  DateFormat.Hm()
                                                      .format(this.setDate),
                                                  style: TextStyle(
                                                      fontSize: 28.0,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Spacer(),
                                                Icon(
                                                  Icons.access_time,
                                                  size: 28,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                Spacer()
                                              ],
                                            ),
                                            color: Color.fromRGBO(
                                                7, 190, 200, 0.1),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: double.infinity,
                                          child: PlatformFlatButton(
                                            handler: () =>
                                                openDatePicker("Breakfast"),
                                            buttonChild: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Spacer(),
                                                Text(
                                                  DateFormat("dd.MM")
                                                      .format(this.setDate),
                                                  style: TextStyle(
                                                      fontSize: 28.0,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Spacer(),
                                                Icon(
                                                  Icons.event,
                                                  size: 28,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                Spacer()
                                              ],
                                            ),
                                            color: Color.fromRGBO(
                                                7, 190, 200, 0.1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 55,
                            width: deviceSize.width * .85,
                            child: PlatformFlatButton(
                              handler: () async {
                                if (nameController.text.isNotEmpty &&
                                    amountController.text.isNotEmpty) {
                                  savePill(context);
                                } else {
                                  snackbar.showSnack(
                                      "Patikrinkite pavadinimą ir kiekį",
                                      context,
                                      null);
                                }
                              },
                              color: Theme.of(context).primaryColor,
                              buttonChild: Text(
                                Strings.DONE,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18.0),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //slider changer
  void sliderChanged(double value) =>
      setState(() => this.howManyWeeks = value.round());

  //slider changer
  void daysSliderChanged(double value) =>
      setState(() => this.howManyDays = value.round());

  //choose popum menu item
  void popUpMenuItemChanged(String value) =>
      setState(() => this.selectWeight = value);

  //choose popum menu item
  void popUpLiquidChanged(String value) =>
      setState(() => this.selectLiquid = value);

  Future<void> openTimePicker(DateTime setDate, String time) async {
    await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: setDate.hour, minute: setDate.minute),
            helpText: "Choose Time")
        .then((value) {
      DateTime newDate = DateTime(
          setDate.year,
          setDate.month,
          setDate.day,
          value != null ? value.hour : setDate.hour,
          value != null ? value.minute : setDate.minute);
      setState(() {
        if (time == "1 Laikas" || time == "Nuo") {
          this.setDate = newDate;
        } else if (time == "2 Laikas") {
          setDate1 = newDate;
        } else if (time == "3 Laikas") {
          setDate2 = newDate;
        }
        this.setDate = DateTime(newDate.year, newDate.month, newDate.day,
            this.setDate.hour, this.setDate.minute);
        setDate1 = DateTime(newDate.year, newDate.month, newDate.day,
            setDate1.hour, setDate1.minute);
        setDate2 = DateTime(newDate.year, newDate.month, newDate.day,
            setDate2.hour, setDate2.minute);
      });
      print(newDate);
    });
  }

  Future<void> openDatePicker(String time) async {
    await showDatePicker(
            context: context,
            initialDate: setDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 100000)))
        .then((value) {
      DateTime newDate = DateTime(
          value != null ? value.year : setDate.year,
          value != null ? value.month : setDate.month,
          value != null ? value.day : setDate.day,
          setDate.hour,
          setDate.minute);
      setState(() {
        if (time == "1 Laikas" || time == "Nuo") {
          this.setDate = newDate;
        } else if (time == "2 Laikas") {
          setDate1 = newDate;
        } else if (time == "3 Laikas") {
          setDate2 = newDate;
        }
        this.setDate = DateTime(newDate.year, newDate.month, newDate.day,
            this.setDate.hour, this.setDate.minute);
        setDate1 = DateTime(newDate.year, newDate.month, newDate.day,
            setDate1.hour, setDate1.minute);
        setDate2 = DateTime(newDate.year, newDate.month, newDate.day,
            setDate2.hour, setDate2.minute);
      });
      print(setDate);
    });
  }

  Future saveNotification(Pill pill, int notifyTime) async {
    return await _notifications.showNotification(
        pill.name,
        pill.amount + " " + pill.medicineForm + " " + pill.type,
        notifyTime,
        pill.notifyId,
        flutterLocalNotificationsPlugin);
  }

  Future savePill(BuildContext context) async {
    //check if medicine time is lower than actual time only when saving a single medicine
    if (setDate.millisecondsSinceEpoch <=
            DateTime.now().millisecondsSinceEpoch &&
        howManyDays == 1 &&
        _duration == HowLong.days &&
        howManyTimes == 0) {
      snackbar.showSnack(Strings.CHECK_TIME, context, null);
    } else if (int.parse(amountController.text) * (howManyTimes + 1) >
        int.parse(maxAmountController.text)) {
      snackbar.showSnack(Strings.CHECK_AMOUNT, context, null);
    } else {
      // create pill object
      Pill pill = Pill(
        amount: amountController.text,
        howManyWeeks: howManyWeeks,
        medicineForm: medicineTypes[
                medicineTypes.indexWhere((element) => element.isChoose == true)]
            .name,
        name: nameController.text,
        time: setDate.millisecondsSinceEpoch,
        type: selectWeight,
        notifyId: Random().nextInt(10000000),
        time1: setDate1.millisecondsSinceEpoch,
        time2: setDate2.millisecondsSinceEpoch,
        howManyDays: howManyDays,
        withLiquid: selectLiquid == "Yes" ? 0 : 1,
        afterMeal: beforeOrAfterMeal,
        dailyFreq: howManyTimes,
        dayOrWeek: _duration == HowLong.days ? 0 : 1,
        notes: notesController.text,
        maxPills: int.parse(maxAmountController.text),
        uniqueId: Random().nextInt(10000000),
      );

      // Delete old pills when in editing mode
      if (widget.shouldEdit) {
        // query all pills with unique id to figure out their notifyId to remove notify
        await Repository()
            .getAllPillsForEdit('Pills', editedPill.uniqueId)
            .then((value) async {
          print("deleting notifications...nn");
          print(value.toList().length);
          Pill pill;
          for (int i = 0; i < value.toList().length; i++) {
            pill = new Pill().pillMapToObject(value.elementAt(i));
            await Notifications()
                .removeNotify(pill.notifyId, flutterLocalNotificationsPlugin)
                .then((value) => print(pill.notifyId));
          }
        }).then((value) async {
          //then delete all pills by their uniqueId from db
          await Repository().deleteAllPills('Pills', editedPill.uniqueId);
        });
      }

      // Save as many medicines as many user checks
      int numberOfNotifications = 1;
      int daysToAdd = 1;
      _duration == HowLong.weeks
          ? numberOfNotifications = howManyWeeks * 7
          : numberOfNotifications = howManyDays;

      for (int i = 0; i < numberOfNotifications; i++) {
        dynamic result;
        DateTime tempDate = setDate;
        for (int j = 0; j < (howManyTimes + 1); j++) {
          // update main time based on daily freq
          if (j == 0) {
            tempDate = setDate;
          } else if (j == 1) {
            tempDate = setDate1;
          } else if (j == 2) {
            tempDate = setDate2;
          }
          // update pill object time
          pill.time = tempDate.millisecondsSinceEpoch;
          // push it to db
          result = await _repository.insertData(
            "Pills",
            pill.pillToMap(),
          );
          // if failed show error
          if (result == null) {
            snackbar.showSnack(Strings.ERROR, context, null);
            return;
          } else {
            //set the notification schedule
            tz.initializeTimeZones();
            tz.setLocalLocation(
              tz.local,
            );
            // if a valid date then save a notification
            if (tempDate.millisecondsSinceEpoch >=
                DateTime.now().millisecondsSinceEpoch) {
              await saveNotification(pill, time(tempDate));
            }
            pill.notifyId = Random().nextInt(10000000);
          }
        }
        // increment day each time loop runs for as many days
        setDate = setDate.add(Duration(days: daysToAdd));
        setDate1 = setDate1.add(Duration(days: daysToAdd));
        setDate2 = setDate2.add(Duration(days: daysToAdd));
      }
      if (widget.shouldEdit) {
        snackbar.showSnack(Strings.EDITED, context, null);
        Navigator.pop(context, true);
      } else {
        snackbar.showSnack(Strings.SAVED, context, null);
        Navigator.pop(context, false);
      }
    }
  }

  void medicineTypeClick(MedicineType medicine) {
    setState(() {
      medicineTypes.forEach((medicineType) => medicineType.isChoose = false);
      medicineTypes[medicineTypes.indexOf(medicine)].isChoose = true;
    });
  }

  //get time difference
  int time(DateTime tempTime) {
    return tempTime.millisecondsSinceEpoch -
        tz.TZDateTime.now(tz.local).millisecondsSinceEpoch;
  }

  Widget getDateWidget(String time, DateTime date) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: PlatformFlatButton(
        handler: () => openDatePicker(time),
        buttonChild: Column(
          children: [
            Text(time),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat("dd.MM").format(date),
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.event,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                // Spacer()
              ],
            ),
          ],
        ),
        color: Color.fromRGBO(7, 190, 200, 0.1),
      ),
    );
  }

  Widget getTimeWidget(String time, DateTime date) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: PlatformFlatButton(
        handler: () => openTimePicker(date, time),
        buttonChild: Column(
          children: [
            Text(time),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat.Hm().format(date),
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ],
        ),
        color: Color.fromRGBO(7, 190, 200, 0.1),
      ),
    );
  }

  String validateForm(String value) {
    if ((value.length < 3) && value.isEmpty) {
      return "Prašome įvesti pavadinimą";
    }
    return null;
  }

  InputDecoration getInputDecoration(String label) {
    final InputDecoration inputDecoration = InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(width: 0.5, color: Colors.grey),
      ),
    );
    return inputDecoration;
  }
}
