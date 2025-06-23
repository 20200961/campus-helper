import 'package:flutter/material.dart';

class TimetableGridPage extends StatefulWidget {
  const TimetableGridPage({super.key});

  @override
  State<TimetableGridPage> createState() => _TimetableGridPageState();
}

class _TimetableGridPageState extends State<TimetableGridPage> {
  // 시간 (9시 ~ 18시)
  final List<String> times = List.generate(10, (index) => '${9 + index}:00');

  // 요일 (월~금)
  final List<String> days = ['월', '화', '수', '목', '금'];

  // 시간표 데이터: [요일][시간] = 과목명
  Map<String, Map<String, String>> timetable = {};

  @override
  void initState() {
    super.initState();
    for (var day in days) {
      timetable[day] = {};
      for (var time in times) {
        timetable[day]![time] = '';
      }
    }
  }

  void _showAddSubjectDialog(String day, String time) {
    final controller = TextEditingController(text: timetable[day]![time]);
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('$day $time 과목 추가/수정'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: '과목명 입력'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    timetable[day]![time] = controller.text.trim();
                  });
                  Navigator.pop(context);
                },
                child: const Text('저장'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalColumns = days.length + 1;

    return Scaffold(
      appBar: AppBar(title: const Text('시간표')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: totalColumns * 100),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    // 요일 헤더
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 40,
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Text('시간\\요일'),
                        ),
                        ...days.map(
                          (day) => Container(
                            width: 100,
                            height: 40,
                            color: Colors.grey[300],
                            alignment: Alignment.center,
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 시간표 행
                    ...times.map((time) {
                      return Row(
                        children: [
                          // 시간 칸
                          Container(
                            width: 100,
                            height: 60,
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: Text(time),
                          ),

                          // 요일별 과목 칸
                          ...days.map((day) {
                            final subject = timetable[day]![time]!;
                            return GestureDetector(
                              onTap: () => _showAddSubjectDialog(day, time),
                              child: Container(
                                width: 100,
                                height: 60,
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color:
                                      subject.isEmpty
                                          ? Colors.white
                                          : Colors.orange[200],
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  subject.isEmpty ? '-' : subject,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        subject.isEmpty
                                            ? Colors.grey
                                            : Colors.black,
                                    fontWeight:
                                        subject.isEmpty
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
