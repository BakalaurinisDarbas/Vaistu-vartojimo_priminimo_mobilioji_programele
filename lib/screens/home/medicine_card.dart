import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:medicine/database/repository.dart';
import 'package:medicine/models/pill.dart';
import 'package:medicine/notifications/notifications.dart';
import 'package:medicine/screens/add_new_medicine/add_new_medicine.dart';

class MedicineCard extends StatefulWidget {
  final Pill medicine;
  final Function setData;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  MedicineCard(
      this.medicine, this.setData, this.flutterLocalNotificationsPlugin);

  @override
  _MedicineCardState createState() => _MedicineCardState();
}

class _MedicineCardState extends State<MedicineCard> {
  final List<String> dailyFreq = ["Vieną kartą", "Du kartus", "Tris kartus"];
  final TextStyle _notesTextStyle = const TextStyle(
      color: const Color(0xff0f4a3c),
      fontSize: 14,
      fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    //check if the medicine time is lower than actual
    final bool isEnd =
        DateTime.now().millisecondsSinceEpoch > widget.medicine.time;

    return !isEnd
        ? InkWell(
            borderRadius: BorderRadius.circular(10),
            onLongPress: () async {
              await _showDeleteDialog(context, widget.medicine.name,
                  widget.medicine.id, widget.medicine.notifyId);
              setState(() {});
            },
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              shadowColor: Colors.black54,
              margin: EdgeInsets.symmetric(vertical: 7.0),
              color: Colors.white,
              child: ExpansionTile(
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(10),
                childrenPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                expandedCrossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.medicine.notes != ""
                      ? Text(
                          widget.medicine.notes,
                          textAlign: TextAlign.center,
                          style: _notesTextStyle,
                        )
                      : Visibility(
                          child: Container(),
                          visible: false,
                        ),
                ],
                tilePadding:
                    EdgeInsets.symmetric(vertical: 5.0, horizontal: 7.5),
                title: Text(
                  widget.medicine.name,
                  style: _notesTextStyle.copyWith(
                      fontSize: 18.0,
                      decoration: isEnd ? TextDecoration.lineThrough : null),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // isThreeLine: false,
                subtitle: Text(
                  "${widget.medicine.amount} ${widget.medicine.medicineForm} "
                  "${widget.medicine.withLiquid == 0 ? "su" : "be"} skysčiu ${widget.medicine.afterMeal == 0 ? "Prieš maistą" : "Po maisto"}",
                  style: Theme.of(context).textTheme.headline5.copyWith(
                      color: Colors.grey[600],
                      fontSize: 14.0,
                      decoration: isEnd ? TextDecoration.lineThrough : null),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                    ),
                    Text(
                      "${DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(widget.medicine.time))}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          decoration:
                              isEnd ? TextDecoration.lineThrough : null),
                    ),
                  ],
                ),
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
                            isEnd ? Colors.white : Colors.transparent,
                            BlendMode.saturation,
                          ),
                          child: Image.asset(widget.medicine.image),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Visibility(
            child: Container(),
            visible: false,
          );
  }

  _showDeleteDialog(BuildContext context, String medicineName, int medicineId,
      int notifyId) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete ?"),
        content: Text("Are you sure to delete all $medicineName medicines?"),
        contentTextStyle: TextStyle(fontSize: 17.0, color: Colors.grey[800]),
        actions: [
          TextButton(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(
                Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              "Atšaukti",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: ButtonStyle(
              overlayColor:
                  MaterialStateProperty.all(Colors.green.withOpacity(0.3)),
            ),
            child: Text(
              "Pakeisti",
              style: TextStyle(color: Colors.green),
            ),
            onPressed: () async {
              final refresh = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddNewMedicine(
                    medicineId: medicineId,
                    shouldEdit: true,
                  ),
                ),
              );
              Navigator.pop(context);
              if (refresh != null && refresh) {
                setState(() {
                  widget.setData();
                });
              }
            },
          ),
          TextButton(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(
                  Theme.of(context).errorColor.withOpacity(0.3)),
            ),
            child: Text(
              "Ištrinti",
              style: TextStyle(color: Theme.of(context).errorColor),
            ),
            onPressed: () async {
              // Delete single pill
              // await Repository().deleteData('Pills', medicineId);
              // query all pills with unique id to figure out their notifyId to remove notify
              await Repository()
                  .getAllPillsForEdit('Pills', widget.medicine.uniqueId)
                  .then((value) async {
                print("Ištrinama");
                print(value.toList().length);
                Pill pill;
                for (int i = 0; i < value.toList().length; i++) {
                  pill = new Pill().pillMapToObject(value.elementAt(i));
                  await Notifications()
                      .removeNotify(
                          pill.notifyId, widget.flutterLocalNotificationsPlugin)
                      .then((value) => print(pill.notifyId));
                }
              }).then((value) async {
                //then delete all pills by their uniqueId from db
                await Repository()
                    .deleteAllPills('Pills', widget.medicine.uniqueId);
              });
              widget.setData();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
