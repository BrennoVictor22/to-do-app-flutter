import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/app.dart';
import 'package:todo_app/services/database_service.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:todo_app/state/task_store.dart';

void main() {
  testWidgets('app loads task list screen', (WidgetTester tester) async {
    final store = TaskStore(DatabaseService.instance, NotificationService());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TaskStore>.value(value: store),
        ],
        child: const ToDoApp(),
      ),
    );

    expect(find.text('Minhas Tarefas'), findsOneWidget);
  });
}
