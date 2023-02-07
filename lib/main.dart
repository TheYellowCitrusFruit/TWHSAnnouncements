import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'body.dart';
import 'package:twhs_announcements/entities/announcement_info.dart';
import 'firebase_options.dart';
import 'server_functions.dart';
import 'package:ntp/ntp.dart';
import 'package:intl/intl.dart';

// com.twhspastabots.announcementsaapp
// build\app\outputs\bundle\release\app-release.aab


bool sameDate(DateTime t1, DateTime t2){
  return t1.year == t2.year && t1.month == t2.month
           && t1.day == t2.day;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var announcementInfoServer;


  final AnnouncementInfo announcementInfo = AnnouncementInfo.n(
    date:DateTime.now().millisecondsSinceEpoch - 86400000,
    num_cards: 1,
    cards: <AnnouncementCardInfo>[AnnouncementCardInfo.n(
      title: "title",
      subtitle: "subtitle",
      body: "body",
      time: "5 o clock" //TODO
    ),
    ]
  );
  final AnnouncementInfo announcementInfo2 = AnnouncementInfo.n(
    date:DateTime.now().millisecondsSinceEpoch,
    num_cards: 1,
    cards: <AnnouncementCardInfo>[AnnouncementCardInfo.n(
      title: "title 2",
      subtitle: "subtitle 2",
      body: "body 2",
      time: "6 o clock" //TODO
    ),
    ]
  );
  final AnnouncementInfo announcementInfo3 = AnnouncementInfo.n(
    date:(await NTP.now()).millisecondsSinceEpoch,
    num_cards: 2,
    cards: <AnnouncementCardInfo>[AnnouncementCardInfo.n(
      title: "If you see this it worked",
      subtitle: "subtitle 3",
      body: "AHA Works",
      time: "7 o clock" //TODO
    ),
    AnnouncementCardInfo.n(
      title: "part 2",
      subtitle: "subtitle 3",
      body: "body 3",
      time: "7 o clock" //TODO
    ),
    ]
  );
  /*
  final db = FirebaseFirestore.instance;
  final server = ServerFunctions(db:db);
  //server.addDay(announcementInfo, "day");
  //final announcementInfoServer = server.getDay();
  */
  
  IsarService service = IsarService();
  final db = FirebaseFirestore.instance;
  final server = ServerFunctions(db:db);

  //server.addDay(announcementInfo3, "day");

  Future<void> asyncBubble() async{
    //await service.cleanDb();
    await service.checkSettings();
  }
  await asyncBubble();

  Future<bool> checkIfCanGet() async{
    DateTime _myTime = await NTP.now();
    _myTime = _myTime.toLocal();
    if (sameDate(DateTime.fromMillisecondsSinceEpoch((await service.gotAnAnnouncementTime())), _myTime)){
      return false;
    }

    if (_myTime.millisecondsSinceEpoch - (await service.getLastChecked()) > 300000){
      if(await server.checkToday(_myTime)){//check server if new announcement has been uploaded today
        //service.gotAnAnnouncement(_myTime.millisecondsSinceEpoch);
        return true;
      }
      else {
        service.setLastChecked(_myTime.millisecondsSinceEpoch);
      }
    }
    return false;
  }

  void timeCheckStuff() async{
    DateTime _myTime = await NTP.now();
    _myTime = _myTime.toLocal();
    if (DateFormat('EEEE').format(_myTime) == "Sunday" || DateFormat('EEEE').format(_myTime) == "Saturday"){
      return;
    }
    if ((_myTime.hour >= 9) || (_myTime.hour < 11 && _myTime.minute <= 30)){
      if (await checkIfCanGet()){
        service.gotAnAnnouncement(_myTime.millisecondsSinceEpoch);
        announcementInfoServer = await server.getDay();
        service.addAnnouncement(announcementInfoServer as AnnouncementInfo);
      }
    }
    else if( _myTime.hour >= 10 && _myTime.minute > 30){
      if (await checkIfCanGet()){
        service.gotAnAnnouncement(_myTime.millisecondsSinceEpoch);
        announcementInfoServer = server.getDay();
        service.addAnnouncement(announcementInfoServer as AnnouncementInfo);
      }
      else{
        service.gotAnAnnouncement(_myTime.millisecondsSinceEpoch);
      }
    }
  }
  timeCheckStuff();


  void tzTest() async{
    announcementInfoServer = await server.getDay();
    await service.addAnnouncement(announcementInfoServer as AnnouncementInfo);
  }
  //tzTest();

  runApp(MyApp(service));
}


class MyApp extends StatelessWidget{
  final isarService;
  MyApp(this.isarService, {super.key});
  
  //const MyApp({super.key});
  // Root of the application
  Widget build(BuildContext context){
    return MaterialApp(
      home: HomePage(isarService),
    );
  }
}


  //server.getDay();
  /*
  // Create a new user with a first and last name
  final user = <String, dynamic>{
    "first": "Ada",
    "last": "Lovelace",
    "born": 1815
  };

  // Add a new document with a generated ID
  db.collection("users").add(user).then((DocumentReference doc) =>
      print('DocumentSnapshot added with ID: ${doc.id}'));
  
  await db.collection("users").get().then((event) {
    for (var doc in event.docs) {
      print("${doc.id} => ${doc.data()}");
    }
  });*/