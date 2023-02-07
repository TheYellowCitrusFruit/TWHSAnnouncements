import 'package:isar/isar.dart';

part 'settings.g.dart';

@Collection()
class AppSettings{
  Id id = 1;
  int MAX_ANNOUNCEMENTS = 10;
  int mostRecentAnnouncementID = 9;
  int lastCheckedTime = 0; // Milliseconds since epoch
  int lastDateTime = 0; // Milliseconds since epoch
}
