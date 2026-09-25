import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/state/task_store.dart';

class TaskEditorScreen extends StatefulWidget {
  const TaskEditorScreen({super.key, this.task});

  final Task? task;

  @override
  State<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends State<TaskEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late bool _completed;
  DateTime? _dueDateTime;
  int? _categoryId;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _completed = task?.completed ?? false;
    _dueDateTime = task?.dueDateTime;
    _categoryId = task?.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Nova tarefa' : 'Editar tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Informe um título válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Data e hora'),
                      subtitle: Text(
                        _dueDateTime == null
                            ? 'Sem vencimento'
                            : DateFormat('dd/MM/yyyy HH:mm').format(_dueDateTime!),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickDueDateTime,
                    ),
                  ),
                  if (_dueDateTime != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _dueDateTime = null),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int?>(
                value: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: <DropdownMenuItem<int?>>[
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Sem categoria'),
                  ),
                  ...store.categories.map((category) {
                    return DropdownMenuItem<int?>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }),
                ],
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _completed,
                title: const Text('Concluída'),
                onChanged: (value) => setState(() => _completed = value),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saveTask,
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
              ),
              const SizedBox(height: 12),
              if (widget.task != null)
                TextButton.icon(
                  onPressed: _deleteTask,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Excluir tarefa'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDueDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDateTime ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDateTime ?? DateTime.now()),
    );

    if (time == null) return;

    setState(() {
      _dueDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final store = context.read<TaskStore>();
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    final task = (widget.task ?? Task(
      title: title,
      completed: false,
      createdAt: DateTime.now(),
    )).copyWith(
      title: title,
      description: description.isEmpty ? null : description,
      completed: _completed,
      dueDateTime: _dueDateTime,
      categoryId: _categoryId,
    );

    if (widget.task == null) {
      await store.addTask(task);
    } else {
      await store.updateTask(task);
    }

    if (!context.mounted) return;
    Navigator.pop(context);
  }

  Future<void> _deleteTask() async {
    final task = widget.task;
    if (task == null || task.id == null) {
      return;
    }

    final store = context.read<TaskStore>();
    await store.deleteTask(task.id!);

    if (!context.mounted) return;
    Navigator.pop(context);
  }
}
