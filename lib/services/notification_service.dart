import 'dart:io';

import 'package:flutter/services.dart';
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
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'todo_task_reminders_v2',
          'Lembretes de tarefas',
          description: 'Notificações de vencimento de tarefas',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleTask(Task task) async {
    final dueDate = task.dueDateTime;
    final now = DateTime.now();
    if (dueDate == null || task.completed) {
      await cancelTask(task);
      return;
    }

    if (dueDate.isBefore(now.subtract(const Duration(seconds: 5)))) {
      await cancelTask(task);
      return;
    }

    final notificationId = task.notificationId ?? task.id ?? DateTime.now().millisecondsSinceEpoch;
    final scheduledDate = tz.TZDateTime.from(
      dueDate.isAfter(now) ? dueDate : now.add(const Duration(seconds: 1)),
      tz.local,
    );
    final androidScheduleMode = await _resolveAndroidScheduleMode();

    const androidDetails = AndroidNotificationDetails(
      'todo_task_reminders_v2',
      'Lembretes de tarefas',
      channelDescription: 'Notificações de vencimento de tarefas',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _plugin.zonedSchedule(
        notificationId,
        'Lembrete da tarefa',
        'Tarefa: ${task.title}',
        scheduledDate,
        details,
        androidScheduleMode: androidScheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on PlatformException catch (_) {
      await _plugin.zonedSchedule(
        notificationId,
        'Lembrete da tarefa',
        'Tarefa: ${task.title}',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<AndroidScheduleMode> _resolveAndroidScheduleMode() async {
    if (!Platform.isAndroid) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    final exactAlarmPermission = await Permission.scheduleExactAlarm.status;
    if (exactAlarmPermission.isGranted) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> cancelTask(Task task) async {
    final notificationId = task.notificationId ?? task.id;
    if (notificationId == null) {
      return;
    }

    await _plugin.cancel(notificationId);
  }
}
