import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/category.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/screens/category_management_screen.dart';
import 'package:todo_app/screens/task_editor_screen.dart';
import 'package:todo_app/state/task_store.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    final tasks = store.filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        actions: [
          DropdownButton<TaskStatusFilter>(
            value: store.statusFilter,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(
                value: TaskStatusFilter.all,
                child: Text('Todas'),
              ),
              DropdownMenuItem(
                value: TaskStatusFilter.pending,
                child: Text('Pendentes'),
              ),
              DropdownMenuItem(
                value: TaskStatusFilter.completed,
                child: Text('Concluídas'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                store.setStatusFilter(value);
              }
            },
          ),
          IconButton(
            tooltip: 'Gerenciar categorias',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoryManagementScreen(),
                ),
              );
            },
            icon: const Icon(Icons.category_outlined),
          ),
        ],
      ),
      body: store.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (store.categories.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: DropdownButtonFormField<int?>(
                        value: store.categoryFilterId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Filtrar categoria',
                        ),
                        items: <DropdownMenuItem<int?>>[
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Todas as categorias'),
                          ),
                          ...store.categories.map((category) {
                            return DropdownMenuItem<int?>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }),
                        ],
                        onChanged: (categoryId) {
                          store.setCategoryFilter(categoryId);
                        },
                      ),
                    ),
                  ),
                Expanded(
                  child: tasks.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Nenhuma tarefa encontrada.\nAdicione uma nova tarefa para começar.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            final categoryName = _categoryNameFor(task, store.categories);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: Checkbox(
                                  value: task.completed,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    store.updateTask(task.copyWith(completed: value));
                                  },
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: task.completed ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (task.description != null && task.description!.isNotEmpty)
                                      Text(task.description!),
                                    if (categoryName.isNotEmpty)
                                      Text('Categoria: $categoryName'),
                                    if (task.dueDateTime != null)
                                      Text(
                                        'Vence: ${DateFormat('dd/MM/yyyy HH:mm').format(task.dueDateTime!)}',
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        task.completed ? 'Concluída' : 'Pendente',
                                        style: TextStyle(
                                          color: task.completed ? Colors.green : Colors.orange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TaskEditorScreen(task: task),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TaskEditorScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
    );
  }

  String _categoryNameFor(Task task, List<Category> categories) {
    if (task.categoryId == null) {
      return '';
    }

    final match = categories.firstWhere(
      (category) => category.id == task.categoryId,
      orElse: () => const Category(name: ''),
    );

    return match.name;
  }
}
