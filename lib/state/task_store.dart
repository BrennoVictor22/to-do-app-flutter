import 'package:flutter/foundation.dart';
import 'package:todo_app/models/category.dart' as category_model;
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/database_service.dart';
import 'package:todo_app/services/notification_service.dart';

enum TaskStatusFilter { all, pending, completed }

class TaskStore extends ChangeNotifier {
  TaskStore(this._databaseService, this._notificationService);

  final DatabaseService _databaseService;
  final NotificationService _notificationService;

  List<Task> _tasks = [];
  List<category_model.Category> _categories = [];
  bool _isLoading = false;
  TaskStatusFilter _statusFilter = TaskStatusFilter.all;
  int? _categoryFilterId;

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<category_model.Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  TaskStatusFilter get statusFilter => _statusFilter;
  int? get categoryFilterId => _categoryFilterId;

  List<Task> get filteredTasks {
    return _tasks.where((task) {
      final matchesStatus = switch (_statusFilter) {
        TaskStatusFilter.all => true,
        TaskStatusFilter.pending => !task.completed,
        TaskStatusFilter.completed => task.completed,
      };

      final matchesCategory = _categoryFilterId == null || task.categoryId == _categoryFilterId;
      return matchesStatus && matchesCategory;
    }).toList();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final categories = await _databaseService.fetchCategories();
      final tasks = await _databaseService.fetchTasks();
      _categories = categories;
      _tasks = tasks;

      for (final task in _tasks) {
        if (task.id != null) {
          await _syncTaskNotification(task);
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStatusFilter(TaskStatusFilter filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setCategoryFilter(int? categoryId) {
    _categoryFilterId = categoryId;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    final createdTask = task.copyWith(
      createdAt: task.createdAt,
    );

    final taskId = await _databaseService.insertTask(createdTask);
    final savedTask = createdTask.copyWith(id: taskId);
    _tasks.insert(0, savedTask);

    await _syncTaskNotification(savedTask);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    if (task.id == null) {
      return;
    }

    await _databaseService.updateTask(task);
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }

    await _syncTaskNotification(task);
    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    final task = _tasks.firstWhere((item) => item.id == id, orElse: () => Task(
      title: '',
      completed: false,
      createdAt: DateTime.now(),
    ));

    await _databaseService.deleteTask(id);
    await _notificationService.cancelTask(task);
    _tasks.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> addCategory(category_model.Category category) async {
    final newId = await _databaseService.insertCategory(category);
    _categories.add(category.copyWith(id: newId));
    notifyListeners();
  }

  Future<void> updateCategory(category_model.Category category) async {
    if (category.id == null) {
      return;
    }

    await _databaseService.updateCategory(category);
    final index = _categories.indexWhere((item) => item.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
    notifyListeners();
  }

  Future<void> deleteCategory(int categoryId) async {
    await _databaseService.unlinkTasksFromCategory(categoryId);
    await _databaseService.deleteCategory(categoryId);

    _categories.removeWhere((item) => item.id == categoryId);
    _tasks = _tasks.map((task) {
      if (task.categoryId == categoryId) {
        return task.copyWith(categoryId: null);
      }
      return task;
    }).toList();

    if (_categoryFilterId == categoryId) {
      _categoryFilterId = null;
    }

    notifyListeners();
  }

  Future<void> _syncTaskNotification(Task task) async {
    if (task.id == null) {
      return;
    }

    if (task.dueDateTime != null && !task.completed && task.dueDateTime!.isAfter(DateTime.now())) {
      final notificationId = task.notificationId ?? task.id!;
      final scheduledTask = task.copyWith(notificationId: notificationId);
      await _notificationService.scheduleTask(scheduledTask);
      await _databaseService.updateTaskNotificationId(task.id!, notificationId);
    } else {
      await _notificationService.cancelTask(task);
      await _databaseService.updateTaskNotificationId(task.id!, null);
    }
  }
}
