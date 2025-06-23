import 'package:flutter/material.dart';
import '../utils/alarm_service.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController _titleController = TextEditingController();

  void _pickDateTime() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    setState(() {
      selectedDate = pickedDate;
      selectedTime = pickedTime;
    });
  }

  Future<void> _scheduleAlarm() async {
    if (selectedDate == null || selectedTime == null) return;

    final title =
        _titleController.text.trim().isEmpty
            ? '일정'
            : _titleController.text.trim();

    final dateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    await AlarmService.scheduleAlarm(dateTime, title: title);
    _titleController.clear(); // 입력창 초기화
    setState(() {}); // 알람 리스트 다시 로드
  }

  @override
  Widget build(BuildContext context) {
    final alarms = AlarmService.getScheduledAlarms();

    return Scaffold(
      appBar: AppBar(title: const Text("일정 기능")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '일정 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _pickDateTime,
              child: const Text("날짜와 시간 선택"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _scheduleAlarm,
              child: const Text("일정 예약"),
            ),
            const SizedBox(height: 24),
            const Text("일정 목록", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: alarms.length,
                itemBuilder: (context, index) {
                  final alarm = alarms[index];
                  return ListTile(
                    leading: const Icon(Icons.alarm),
                    title: Text(alarm.title),
                    subtitle: Text(alarm.scheduledDateTime.toString()),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () async {
                        await AlarmService.cancelAlarm(alarm.id);
                        setState(() {});
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
