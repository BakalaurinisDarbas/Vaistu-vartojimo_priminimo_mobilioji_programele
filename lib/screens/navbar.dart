import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:flutter/material.dart';
import 'package:medicine/config/strings.dart';
import 'package:medicine/screens/home/home.dart';
import 'package:medicine/screens/profile_screen.dart';
import 'package:medicine/screens/stats_screen.dart';
import 'package:medicine/screens/tips_screen.dart';
import 'package:medicine/utils/gradient_container.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;

  AnimationController _animationController;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _pages = [
      {
        'page': Center(
          child: Home(),
        ),
        'title': Strings.JOURNAL,
      },
      {
        'page': Center(
          child: TipsScreen(),
        ),
        'title': Strings.NOTIFICATIONS,
      },
      {
        'page': Center(
          child: StatsScreen(),
        ),
        'title': Strings.STATS,
      },
      {
        'page': Center(
          child: ProfilePage(),
        ),
        'title': Strings.PROFILE,
      },
    ];
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    // print('disposed');
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Icon(Icons.medical_services_outlined),
        ),
        elevation: 5,
        actions: [
          InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ShakeAnimatedWidget(
                enabled: true,
                duration: Duration(milliseconds: 2000),
                curve: Curves.linear,
                shakeAngle: Rotation.deg(z: 30),
                child: Icon(
                  Icons.notifications_none,
                  size: 30.0,
                ),
              ),
            ),
          )
        ],
        title: Text(
          _pages[_selectedPageIndex]['title'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        textTheme: Theme.of(context).textTheme,
      ),
      body: GradientContainer(
        child: _pages[_selectedPageIndex]['page'],
      ),
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              label: Strings.NAV_HOME,
              icon: const Icon(Icons.calendar_today_outlined),
              activeIcon: const Icon(Icons.calendar_today),
            ),
            BottomNavigationBarItem(
              label: Strings.NOTIFICATIONS,
              icon: const Icon(Icons.notifications_none_outlined),
              activeIcon: const Icon(Icons.notifications_active),
            ),
            BottomNavigationBarItem(
              label: Strings.NAV_STATS,
              icon: const Icon(Icons.bar_chart_outlined),
              activeIcon: const Icon(Icons.stacked_bar_chart),
            ),
            BottomNavigationBarItem(
              label: Strings.PROFILE,
              icon: const Icon(Icons.account_circle_outlined),
              activeIcon: const Icon(Icons.account_circle),
            ),
          ],
          unselectedItemColor: Colors.black,
          selectedItemColor: Theme.of(context).accentColor,
          //backgroundColor: Colors.blue,
          currentIndex: _selectedPageIndex,
          onTap: _selectPage,
        ),
      ),
    );
  }
}
