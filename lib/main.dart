
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/app.dart';
import 'package:todo_app/services/database_service.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:todo_app/state/task_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseService = DatabaseService.instance;
  await databaseService.init();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final store = TaskStore(databaseService, notificationService);
  store.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskStore>.value(value: store),
      ],
      child: const ToDoApp(),
    ),
  );
}
