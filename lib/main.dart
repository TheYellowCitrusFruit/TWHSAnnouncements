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
    date:DateTime.now().millisecondsSinceEpoch,
    num_cards: 1,
    cards: <AnnouncementCardInfo>[AnnouncementCardInfo.n(
      title: "Example Announcements (expanded)",
      subtitle: "Room XYZ @hh:mm",
      body: "Room XYZ @hh:mm \nThere will be a description of the announcement here. \nI guess this is all of the information I have for this. \nClick card again to collapse body.",
      time: "5 o clock" //TODO
    ),
    AnnouncementCardInfo.n(
      title: "Example Announcements (collapsed)",
      subtitle: "Room XYZ @hh:mm - Click to expand and view body",
      body: "There will be a description of the announcement here. I guess this is all of the information I have for this. \nClick card again to collapse body.",
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
    num_cards: 12,
    cards: <AnnouncementCardInfo>[AnnouncementCardInfo.n(
      title: "Welcome to TWHS Announcements DAY 5",
      subtitle: "This is the fifth test",
      body: "You have opened the body \ndoes it look nice \nAny Feedback?",
      time: "7 o clock" //TODO
    ),
    AnnouncementCardInfo.n(
      title: "The color scheme has yet to be set in stone",
      subtitle: "Do you have any ideas",
      body: "Regarding :\nCard color\nText color (body, title, etc.)",
      time: "7 o clock" //TODO
    ),
    AnnouncementCardInfo.n(
      title: "The rest of these are the same as yesterday",
      subtitle: "Primarily scrolling testing",
      body: "This one for a large body \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
      time: "7 o clock"
    ),
    AnnouncementCardInfo.n(
      title: "The rest of these are for testing",
      subtitle: "Primarily scrolling testing",
      body: "This one for a large body \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
      time: "7 o clock"
    ),
    AnnouncementCardInfo.n(
      title: "The rest of these are for testing",
      subtitle: "Primarily scrolling testing",
      body: "This one for a large body \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
      time: "7 o clock"
    ),
    AnnouncementCardInfo.n(
      title: "The rest of these are for testing",
      subtitle: "Primarily scrolling testing",
      body: "This one for a large body \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
      time: "7 o clock"
    ),
    AnnouncementCardInfo.n(
      title: "The rest of these are for testing",
      subtitle: "Primarily scrolling testing",
      body: "This one for a large body \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
      time: "7 o clock"
    ),
    AnnouncementCardInfo.n(
      title: "The rest of these are for testing",
      subtitle: "Primarily scrolling testing",
      body: "This one for a large body \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
      time: "7 o clock"
    ),
    AnnouncementCardInfo.n(
      title: "The rest of these are for testing",
      subtitle: "Primarily scrolling testing",
      body: "This one for a large body \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
      time: "7 o clock"
    ),
    AnnouncementCardInfo.n(
      title: "The rest of these are for testing",
      subtitle: "Primarily scrolling testing",
      body: "This one for a large body \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
      time: "7 o clock"
    ),
    AnnouncementCardInfo.n(
      title: "The rest of these are for testing",
      subtitle: "Primarily scrolling testing",
      body: "This one for a large body \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
      time: "7 o clock"
    ),
    AnnouncementCardInfo.n(
      title: "The rest of these are for testing",
      subtitle: "Primarily scrolling testing",
      body: "This one for a large body \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
      time: "7 o clock"
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

  server.addDay(announcementInfo3, "day");

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
    service.addAnnouncement(announcementInfo);
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
  //timeCheckStuff();


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