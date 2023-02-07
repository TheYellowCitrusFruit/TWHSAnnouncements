import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twhs_announcements/entities/announcement_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:twhs_announcements/entities/settings.dart';
import 'firebase_options.dart';
import 'package:isar/isar.dart';


/*
class AnnouncementInfo {
  final String? date;
  final int num_cards;
  final List<AnnouncementCardInfo>? cards;

  AnnouncementInfo({
    this.date,
    required this.num_cards,
    this.cards,
  });

  factory AnnouncementInfo.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    //SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return AnnouncementInfo(
      date: data?['date'],
      num_cards: data?['num_cards'],
      cards:
          data?['cards'] is Iterable ? List.generate(
            data?['num_cards'], 
            (int index) => AnnouncementCardInfo.fromFirestoreData(
              List.from(data?['cards']).elementAt(index)
            ),
          ) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (date != null) "date": date,
      if (num_cards != null) "num_cards": num_cards,
      if (cards != null) "cards": List.generate(
        num_cards,
        (int index) => cards?.elementAt(index).toFirestore(),
      ),
    };
  }
  @override
  String toString() {
    return "$date $num_cards ${cards} + ";
  }
}


class AnnouncementCardInfo{
  final String? title;
  final String? subtitle;
  final String? body;
  final String? time;

  AnnouncementCardInfo({
    this.title, 
    this.subtitle, 
    this.body, 
    this.time,
  });

  factory AnnouncementCardInfo.fromFirestoreData(
      data
  ) {
    return AnnouncementCardInfo(
      title: data?['title'],
      subtitle: data?['subtitle'],
      body: data?['body'],
      time: data?['time'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (title != null) "title": title,
      if (subtitle != null) "subtitle": subtitle,
      if (body != null) "body": body,
      if (time != null) "time":time,
    };
  }
}*/


class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<void> checkSettings() async {
    final isar = await db;
    if ((await isar.appSettings.get(1)) == null){
      await isar.writeTxn(() async {
        isar.appSettings.put(AppSettings());
      });
    }
  }

  Future<int> gotAnAnnouncementTime() async{
    final isar = await db;
    final int lastGotTime = (await isar.appSettings.get(1))!.lastDateTime;
    return lastGotTime;
  }
  void gotAnAnnouncement(int millisecondsSinceEpoch) async{
    final isar = await db;
    await isar.writeTxn(() async {
      final AppSettings setting = await isar.appSettings.get(1) as AppSettings;
      setting.lastDateTime = millisecondsSinceEpoch;
      await isar.appSettings.put(setting);
    });
  }
  void setLastChecked(int millisecondsSinceEpoch) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final AppSettings setting = await isar.appSettings.get(1) as AppSettings;
      setting.lastCheckedTime = millisecondsSinceEpoch;
      await isar.appSettings.put(setting);
    });
  }
  Future<int> getLastChecked() async{
    final isar = await db;
    int lastCheckedTime = ((await isar.appSettings.get(1))  as AppSettings).lastCheckedTime;
    return lastCheckedTime;
  }

  Future<bool> addAnnouncement(AnnouncementInfo newAnnouncement) async {
    final isar = await db;
    AppSettings settings = (await isar.appSettings.get(1)) as AppSettings;
    final int MAX_ID = settings.MAX_ANNOUNCEMENTS;
    int updateID = settings.mostRecentAnnouncementID + 1;
    
    if (updateID==10) updateID = 0;
    newAnnouncement.id = updateID;
    await isar.writeTxn(() async {
      await isar.announcementInfos.put(newAnnouncement);
    });
    await updateRecentDayID(updateID);
    return true;
  }

  Future<List<AnnouncementInfo>> getAllAnnouncements() async {
    final isar = await db;
    return await isar.announcementInfos.where().sortByDate().findAll();
  }

  Future<DateTime> getLastDay() async{
    final isar = await db;
    final int lastID = (await isar.appSettings.get(1))!.mostRecentAnnouncementID;
    int milliSinceEpoch = (await isar.announcementInfos.get(lastID))!.date;
    return DateTime.fromMillisecondsSinceEpoch(milliSinceEpoch);
  }

  Future<void> updateRecentDayID(int newDayID) async{
    final isar = await db;
    await isar.writeTxn(() async {
      final AppSettings setting = await isar.appSettings.get(1) as AppSettings;
      setting.mostRecentAnnouncementID = newDayID;
      await isar.appSettings.put(setting);
    });
  }

  // Get index of day
  Future<int> indexOfDayFrom (int numberOfDaysAgo) async{
    final isar = await db;
    final int currentID = (await isar.appSettings.get(1))!.mostRecentAnnouncementID;
    final int MAX_ID = (await isar.appSettings.get(1))!.MAX_ANNOUNCEMENTS;  
    if(numberOfDaysAgo > MAX_ID) return -1;
    int index =  ((currentID + MAX_ID - numberOfDaysAgo -1) % MAX_ID) ;
    //if (index==-1) index=9;
    return index;
  }

  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [AnnouncementInfoSchema, AppSettingsSchema],
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }
}
bool sameDate(DateTime t1, DateTime t2){
  return t1.year == t2.year && t1.month == t2.month
           && t1.day == t2.day;
}

//TODO add check before fetching from server
//TODO if the local current date is the current date (or current date is before stored date), don't look at server
//TODO add value to server indicating most recent update
//TODO compare this value to a local value, with timeout in between checks
//     to prevent constant checking (2 minutes)
class ServerFunctions{
  final db;
  
  ServerFunctions({
    required this.db,
  });

  // Can only add most recent day 
  // TODO implement this functionality
  addDay(AnnouncementInfo announcementInfo, String name) async {
    await db.collection("announcement").doc('day').set(announcementInfo.toFirestore());
    await db.collection("date").doc('1').set({"date": announcementInfo.date});
  }

  Future<bool> checkToday(DateTime today) async{
    bool b = false;
  
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("date").doc('1').get();
    b = sameDate(today, DateTime.fromMillisecondsSinceEpoch(snapshot.get('date')));
    
    return b;
  }

  Future<AnnouncementInfo> getDay() async{
    //final snapshot = db.collection("announcement").doc("day").get();
    AnnouncementInfo temp = AnnouncementInfo.n(
      date: DateTime(2020, 1, 1, 1, 1, 1, 1).millisecondsSinceEpoch,
      num_cards: 1,
      cards:[AnnouncementCardInfo.n(
        title: "please work",
        time : "now",
        subtitle: "with a cherry on top",
        body: "thank you",
      )]
    );
    //Map<String, dynamic> data = <String, dynamic>{};
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("announcement").doc('day').get();
    dynamic card_data =  snapshot.get('cards');
    //temp.cards.first.body = card_data.runtimeType.toString();
    temp.date = snapshot.get('date');
    temp.num_cards = snapshot.get('num_cards');
    temp.cards = _makeCards(card_data);  
    
    //temp.date = data['date'];
    //temp.num_cards = data['num_cards'];
    //temp.cards = temp.cards;
    //temp.cards.first.body = data.keys.isEmpty.toString();
    return temp;
  }
  List<AnnouncementCardInfo> _makeCards(List<dynamic> cardsIn){
    int length = cardsIn.length;
    
    List<AnnouncementCardInfo> cards = <AnnouncementCardInfo>[];
    int i = 0;
    for (var item in cardsIn) {
      cards.add(AnnouncementCardInfo.n(
        title: item['title'],
        time: item['time'],
        body: item['body'],
        subtitle: item['subtitle'],
      ));
    }
    return cards;
  }
}

/*
current_day = dayx
// something for cycling through days as we change pages (prob a list)
// simple function getting the indicated day (most likely using (current + 1) % max_num_days)

final docRef = db
    .collection("announcements")
    .withConverter(
      fromFirestore: City.fromFirestore,
      toFirestore: (City city, options) => city.toFirestore(),
    )
    .doc("day-1");
await docRef.set(city);
*/