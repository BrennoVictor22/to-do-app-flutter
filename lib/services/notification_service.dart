import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:todo_app/models/task.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    try {
      final location = tz.getLocation('America/Sao_Paulo');
      tz.setLocalLocation(location);
    } catch (_) {
      // Fallback: keep system local time if the timezone is not available.
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }
  }

  Future<void> scheduleTask(Task task) async {
    final dueDate = task.dueDateTime;
    if (dueDate == null || task.completed || dueDate.isBefore(DateTime.now())) {
      await cancelTask(task);
      return;
    }

    final notificationId = task.notificationId ?? task.id ?? DateTime.now().millisecondsSinceEpoch;
    final scheduledDate = tz.TZDateTime.from(dueDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'todo_task_reminders',
      'Lembretes de tarefas',
      channelDescription: 'Notificações de vencimento de tarefas',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      notificationId,
      'Lembrete da tarefa',
      'Tarefa: ${task.title}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelTask(Task task) async {
    final notificationId = task.notificationId ?? task.id;
    if (notificationId == null) {
      return;
    }

    await _plugin.cancel(notificationId);
  }
}
