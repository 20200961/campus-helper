import 'package:flutter/material.dart';
import '../community/post_list_page.dart';
import '../timetable/timetable_grid_page.dart';
import '../alarm/alarm_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const PostListPage(),
    const TimetableGridPage(),
    const AlarmPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: '커뮤니티'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '시간표',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: '알람'),
        ],
      ),
    );
  }
}
