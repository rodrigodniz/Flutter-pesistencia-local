import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  String _shareMessage() {
    final b = StringBuffer();
    b.writeln('Tarefa: ${task.title}');
    if (task.description.isNotEmpty)
      b.writeln('Descrição: ${task.description}');
    b.writeln('Prioridade: ${task.priority}');
    b.writeln(
      'Criada em: ${DateFormat('dd/MM/yyyy HH:mm').format(task.createdAt)}',
    );
    if (task.dueDate != null) {
      b.writeln(
        'Vencimento: ${DateFormat('dd/MM/yyyy').format(task.dueDate!)}',
      );
    }
    b.writeln(task.completed ? 'Status: Concluída' : 'Status: Pendente');
    return b.toString();
  }

  Color _priorityColor() {
    switch (task.priority) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _priorityColor(), width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(value: task.completed, onChanged: (_) => onToggle()),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.completed ? Colors.grey : Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.completed
                              ? Colors.grey
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          df.format(task.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (task.dueDate != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.event,
                            size: 14,
                            color: task.dueDate!.isBefore(DateTime.now())
                                ? Colors.red
                                : Colors.grey,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            DateFormat('dd/MM/yyyy').format(task.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: task.dueDate!.isBefore(DateTime.now())
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: task.dueDate!.isBefore(DateTime.now())
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => Share.share(_shareMessage()),
                icon: const Icon(Icons.share),
                color: Colors.blue,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
