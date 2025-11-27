import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/database_service.dart';
import '../services/sensor_service.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../screens/task_form_screen.dart';
import '../widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();

    // Shake
    SensorService.instance.startShakeDetection(() {
      _showShakeDialog();
    });

    // Quando a sync terminar, recarrega
    SyncService.instance.onSyncCompleted = () {
      _loadTasks();
    };

    // Quando mudar status de rede, atualiza banner
    ConnectivityService.instance.onStatusChange = (_) {
      setState(() {});
    };
  }

  @override
  void dispose() {
    SensorService.instance.stop();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await DatabaseService.instance.readAll();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  // -------------------------------------------------- SHAKE
  void _showShakeDialog() {
    final pending = _tasks.where((t) => !t.completed).toList();
    if (pending.isEmpty) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Shake detectado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: pending.take(3).map((task) {
            return ListTile(
              title: Text(task.title),
              trailing: IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => _completeByShake(task),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeByShake(Task task) async {
    final updated = task.copyWith(
      completed: true,
      completedBy: 'shake',
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await DatabaseService.instance.updateTask(updated);
    await SyncService.instance.syncUpdate(updated);

    if (mounted) {
      Navigator.pop(context);
      _loadTasks();
    }
  }

  // -------------------------------------------------- DELETE
  Future<void> _deleteTask(Task task) async {
    await DatabaseService.instance.deleteTask(task.id!);
    await SyncService.instance.syncDelete(task.id!);
    await _loadTasks();
  }

  // -------------------------------------------------- BANNER ONLINE/OFFLINE
  Widget _buildConnectionBanner() {
    final online = ConnectivityService.instance.isOnline;

    return Container(
      width: double.infinity,
      color: online ? Colors.green : Colors.red,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Text(
          online ? 'ONLINE' : 'OFFLINE - alterações serão sincronizadas depois',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // -------------------------------------------------- BUILD
  @override
  Widget build(BuildContext context) {
    final tasks = _tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await SyncService.instance.syncNow();
              _loadTasks();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildConnectionBanner(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (_, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskFormScreen(task: task),
                            ),
                          );
                          if (result == true) _loadTasks();
                        },
                        onDelete: () => _deleteTask(task),
                        onCheckboxChanged: (_) async {
                          final updated = task.copyWith(
                            completed: !task.completed,
                            completedAt: !task.completed
                                ? DateTime.now()
                                : null,
                            completedBy: !task.completed ? 'manual' : null,
                            updatedAt: DateTime.now(),
                            isSynced: false,
                          );

                          await DatabaseService.instance.updateTask(updated);
                          await SyncService.instance.syncUpdate(updated);
                          _loadTasks();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskFormScreen()),
          );
          if (result == true) _loadTasks();
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        'Nenhuma tarefa ainda.\nToque no + para adicionar.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}
