import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/category.dart';
import 'package:todo_app/state/task_store.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
      ),
      body: store.categories.isEmpty
          ? const Center(
              child: Text('Nenhuma categoria criada ainda.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: store.categories.length,
              itemBuilder: (context, index) {
                final category = store.categories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(category.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _renameCategory(context, category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteCategory(context, category, store),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createCategory(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova categoria'),
      ),
    );
  }

  Future<void> _createCategory(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova categoria'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nome da categoria',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) {
                  return;
                }
                Navigator.pop(context, value);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) {
      return;
    }

    final store = context.read<TaskStore>();
    await store.addCategory(Category(name: result));
  }

  Future<void> _renameCategory(BuildContext context, Category category) async {
    final controller = TextEditingController(text: category.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Renomear categoria'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Novo nome',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) {
                  return;
                }
                Navigator.pop(context, value);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) {
      return;
    }

    final store = context.read<TaskStore>();
    await store.updateCategory(category.copyWith(name: result));
  }

  Future<void> _deleteCategory(
    BuildContext context,
    Category category,
    TaskStore store,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir categoria'),
          content: Text(
            'As tarefas vinculadas a "${category.name}" serão mantidas sem categoria.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || category.id == null) {
      return;
    }

    await store.deleteCategory(category.id!);
  }
}
