import 'package:flutter/material.dart';
import 'package:twhs_announcements/server_functions.dart';
import 'package:twhs_announcements/entities/announcement_info.dart';
import 'package:intl/intl.dart';

// TODO re-implement this properly with dataset containing all info in mind
/*
{
  Day1 : {
    date : "example date",
    contents: {
      numCards : n,
      cards : {
        card1 : {
          Title : "title",
          Time : "time",
          Body : "body text",
          // For future maybe add customisation like logos or colors
        },
        card2 : {...},
        ...
        cardn : {...}
      }
    }
  }
}
*/

class HomePage extends StatefulWidget {
  final IsarService isarService;
  List<Widget> _list = <Widget>[];
  
  HomePage(this.isarService, {super.key}) {
    /*List<AnnouncementInfo> data = <AnnouncementInfo>[];
    void getData() async{
      Future<List<AnnouncementInfo>> temp = isarService.getAllAnnouncements();
      data = await temp;
    }
    getData();
    int i = 0;
    for (i = 0; i < data.length; i++) {
        _list.add(
            Center(child: AnnouncementDay(data:data[0])) //isarService.indexOfDayFrom(i) as int
        );
        _list.add(
            Center(child: Text("they can show up...$i"))
        );
    }*/
    /*
    List<AnnouncementInfo> data = <AnnouncementInfo>[];
    void getData() async{
      List<AnnouncementInfo> temp = await isarService.getAllAnnouncements(); //Why is this breaking
      _list.add(Center(child: Text("hello")));
      data = temp;
    }
    getData();*/
  }
  
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  PageController controller=PageController();
  // TODO replace this with getting info from server (most likely firebase)
  int _curr=0;
  GlobalKey<ScaffoldState> _key = GlobalKey();
  // widget.db to get database


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(),
        appBar: AppBar(
          title: Text('Announcements'),
          backgroundColor: const Color.fromARGB(255, 71, 71, 71),
          leading:Builder(builder: (context) => // Ensure Scaffold is in context
            IconButton(
              icon: const Icon(Icons.menu),
              tooltip: "Enter Sidebar Menu",
              onPressed: () => Scaffold.of(context).openDrawer()
          ),),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings), // TODO Put custom TWHS pastabots logo instead
              tooltip: "Settings OR TWHS Pastabots website",
              onPressed: (){}, 
            )
          ]
        ),
        floatingActionButton: Stack(
          children: [
            Positioned(
              right: 0, bottom: 10, // There is padding on the right
              child: FloatingActionButton(
                // TODO: gray out button when at the end
                onPressed: () {
                  setState(() {
                    controller.nextPage(
                      duration: const Duration(milliseconds: 500), 
                      curve: Curves.ease);
                  });
                },
                tooltip: "Next Announcement",
                child: const Icon(Icons.arrow_right),
            )),
            Positioned(
              left: 30, bottom: 10,
              child: FloatingActionButton(
                // TODO: gray out button when at the start
                onPressed: () {
                  setState(() {
                    controller.previousPage(
                      duration: const Duration(milliseconds: 500), 
                      curve: Curves.ease);
                  });
                },
                tooltip: "Previous Announcement",
                child: const Icon(Icons.arrow_left),
            )),
          ],
        ),
        body: SafeArea(child:
            FutureBuilder<List<AnnouncementInfo>>(
              future: widget.isarService.getAllAnnouncements(),
              builder: (context, AsyncSnapshot<List<AnnouncementInfo>> snapshot) {
                if (snapshot.hasData) {
                  List<AnnouncementInfo> data = snapshot.data!;
                  final days = data.map((day) {
                    return Center(child: AnnouncementDay(data:day));
                  }).toList();
                  //TODO fix this somehow, just loops forever right now
                  return PageView(
                    scrollDirection: Axis.horizontal,
                      // reverse: true,
                      // physics: const BouncingScrollPhysics(),
                    controller: controller,
                    onPageChanged: (num){
                      setState(() {
                        _curr=num;
                      });
                    },
                    children: days,
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
        ),
    );
  }
}

class AnnouncementDay extends StatelessWidget{
  final data;
  AnnouncementDay({super.key, this.data});
  @override
  Widget build(BuildContext context) {
   return PageData(data:data);
  }
}

class PageData extends StatefulWidget{
  //const PageData({super.key, date});
  final AnnouncementInfo data;
  const PageData({super.key, required this.data});

  @override
  _PageDataState createState() => _PageDataState();
}

class _PageDataState extends State<PageData> {
  //List<InfoPanel> _panels = generateInfoPanels();
  Color _textColor = Colors.white;
  
  String _converDate(int millisecondsSinceEpoch) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    final DateFormat formatter = DateFormat('MM-dd-yyyy');
    return formatter.format(dateTime);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container( //messed up as list view covers this
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Text(
            _converDate(widget.data.date),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              //fontFamily: "",
            ),
          ),
        ),
        Expanded(child: ListView(
          padding: const EdgeInsets.all(10),
          children: _makeCards(widget.data.cards),
        )
        ),
      ]
    );
  }

  List<Widget> _makeCards(List<AnnouncementCardInfo> cardsIn){//cardList, numCards){
    int num_cards = cardsIn.length;
    
    List<Widget> cards = <Widget>[];
    int i = 0;
    for (i = 0; i < num_cards; i++) {
        cards.add(
            Card(
              color: const Color.fromARGB(255, 110, 110, 110),
              child: ExpansionTile(
                title: Text(cardsIn[i].title as String,
                  style: TextStyle(
                      fontSize: 18,
                      color: _textColor,
                ),),
                subtitle: Text(cardsIn[i].subtitle as String,
                  style: TextStyle(
                      fontSize: 18,
                      color: _textColor,
                ),),
                children: <Widget>[Text(cardsIn[i].body as String)],
            ),), 
        );
    }
    return cards;
  }
}
/*
List<Widget> makeCards(){
  return <Widget>[
    for ()
  ];
}*/