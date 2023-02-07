import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';

part 'announcement_info.g.dart';

@collection
class AnnouncementInfo {
  
  Id? id;
  late int date; //milliseconds from epoch
  late int num_cards;
  late List<AnnouncementCardInfo> cards;

  AnnouncementInfo();

  AnnouncementInfo.n({
    this.id,
    required this.date,
    required this.num_cards,
    required this.cards,
  });

  factory AnnouncementInfo.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    //SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return AnnouncementInfo.n(
      date: data?['date'],
      num_cards: data?['num_cards'],
      cards:
          List.generate(
            data?['num_cards'], 
            (int index) => AnnouncementCardInfo.fromFirestoreData(
              List.from(data?['cards']).elementAt(index)
            ),
          ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (date != null) "date": date,
      if (num_cards != null) "num_cards": num_cards,
      if (cards != null) "cards": List.generate(
        num_cards,
        (int index) => cards.elementAt(index).toFirestore(),
      ),
    };
  }
  @override
  String toString() {
    return "$date $num_cards ${cards} + ";
  }
}

@embedded
class AnnouncementCardInfo{
  String? title;
  String? subtitle;
  String? body;
  String? time;

  AnnouncementCardInfo();

  AnnouncementCardInfo.n({
    this.title, 
    this.subtitle, 
    this.body, 
    this.time,
  });

  factory AnnouncementCardInfo.fromFirestoreData(
      data
  ) {
    return AnnouncementCardInfo.n(
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
}