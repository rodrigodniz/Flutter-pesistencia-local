import 'package:flutter/material.dart';

import '../models/task.dart';
import 'database_service.dart';
import 'connectivity_service.dart';

class SyncService {
  SyncService._internal();
  static final SyncService instance = SyncService._internal();

  /// Chamado pela TaskListScreen quando a sincronização termina
  VoidCallback? onSyncCompleted;

  bool get _canSync => ConnectivityService.instance.isOnline;

  // ------------------------------------------------------------
  // CRIAR
  // ------------------------------------------------------------
  Future<void> syncCreate(Task task) async {
    if (!_canSync || task.id == null) return;

    // Aqui você chamaria a API remota.
    // Para o lab, vamos apenas marcar como sincronizado.
    await DatabaseService.instance.markSynced(task.id!);
    onSyncCompleted?.call();
  }

  // Alias para compatibilidade (caso em algum ponto tenha ficado syncAdd)
  Future<void> syncAdd(Task task) => syncCreate(task);

  // ------------------------------------------------------------
  // ATUALIZAR
  // ------------------------------------------------------------
  Future<void> syncUpdate(Task task) async {
    if (!_canSync || task.id == null) return;

    await DatabaseService.instance.markSynced(task.id!);
    onSyncCompleted?.call();
  }

  // ------------------------------------------------------------
  // DELETAR
  // ------------------------------------------------------------
  Future<void> syncDelete(int id) async {
    if (!_canSync) return;

    // Em cenário real: chamar DELETE na API.
    onSyncCompleted?.call();
  }

  // ------------------------------------------------------------
  // SYNC MANUAL (botão refresh)
  // ------------------------------------------------------------
  Future<void> syncNow() async {
    if (!_canSync) return;

    await DatabaseService.instance.markAllSynced();
    onSyncCompleted?.call();
  }
}
