class Pill {
  int id;
  int uniqueId;
  String name;
  String amount;
  String type;
  int howManyWeeks;
  String medicineForm;
  int notifyId;
  int time;
  int time1;
  int time2;
  int withLiquid;
  int howManyDays;
  int afterMeal;
  int dailyFreq;
  int dayOrWeek;
  String notes;
  int maxPills;

  Pill({
    this.id,
    this.uniqueId,
    this.howManyWeeks,
    this.time,
    this.time1,
    this.time2,
    this.withLiquid,
    this.afterMeal,
    this.dailyFreq,
    this.dayOrWeek,
    this.howManyDays,
    this.amount,
    this.medicineForm,
    this.name,
    this.type,
    this.notifyId,
    this.notes,
    this.maxPills,
  });

  Map<String, dynamic> pillToMap() {
    Map<String, dynamic> map = Map();
    map['id'] = this.id;
    map['uniqueId'] = this.uniqueId;
    map['name'] = this.name;
    map['amount'] = this.amount;
    map['type'] = this.type;
    map['howManyWeeks'] = this.howManyWeeks;
    map['medicineForm'] = this.medicineForm;
    map['time'] = this.time;
    map['notifyId'] = this.notifyId;
    map['time1'] = this.time1;
    map['time2'] = this.time2;
    map['withLiquid'] = this.withLiquid;
    map['afterMeal'] = this.afterMeal;
    map['dailyFreq'] = this.dailyFreq;
    map['howManyDays'] = this.howManyDays;
    map['dayOrWeek'] = this.dayOrWeek;
    map['notes'] = this.notes;
    map['maxPills'] = this.maxPills;
    return map;
  }

  Pill pillMapToObject(Map<String, dynamic> pillMap) {
    return Pill(
      id: pillMap['id'],
      name: pillMap['name'],
      amount: pillMap['amount'],
      type: pillMap['type'],
      howManyWeeks: pillMap['howManyWeeks'],
      medicineForm: pillMap['medicineForm'],
      time: pillMap['time'],
      notifyId: pillMap['notifyId'],
      time1: pillMap['time1'],
      time2: pillMap['time2'],
      withLiquid: pillMap['withLiquid'],
      afterMeal: pillMap['afterMeal'],
      dailyFreq: pillMap['dailyFreq'],
      howManyDays: pillMap['howManyDays'],
      dayOrWeek: pillMap['dayOrWeek'],
      notes: pillMap['notes'],
      maxPills: pillMap['maxPills'],
      uniqueId: pillMap['uniqueId'],
    );
  }

  String get image {
    switch (this.medicineForm) {
      case "Syrup":
        return "assets/images/syrup.png";
        break;
      case "Pill":
        return "assets/images/pills.png";
        break;
      case "Capsule":
        return "assets/images/capsule.png";
        break;
      case "Cream":
        return "assets/images/cream.png";
        break;
      case "Drops":
        return "assets/images/drops.png";
        break;
      case "Syringe":
        return "assets/images/syringe.png";
        break;
      default:
        return "assets/images/pills.png";
        break;
    }
  }
}
