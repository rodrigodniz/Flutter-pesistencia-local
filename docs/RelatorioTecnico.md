# Relatório – Laboratório 2: Interface Profissional

## 1. Implementações Realizadas
Neste laboratório, foi desenvolvida uma aplicação Flutter chamada **Task Manager Pro**, responsável pelo gerenciamento de tarefas com persistência local em SQLite.  
Foram implementadas as seguintes funcionalidades:
- Criação, edição e exclusão de tarefas.  
- Formulário completo com validação em tempo real.  
- Filtros de visualização (todas, pendentes e concluídas).  
- Exibição de estatísticas (total, pendentes e concluídas).  
- Estados visuais personalizados (vazio, carregando e sucesso).  
- Cards personalizados representando cada tarefa.  

**Componentes Material Design 3 utilizados:**
- `AppBar`, `Card`, `ElevatedButton`, `OutlinedButton`, `SnackBar`, `AlertDialog`, `DropdownButtonFormField`,  
  `TextFormField`, `SwitchListTile`, `FloatingActionButton`, `NavigationBar` e `CircularProgressIndicator`.  

---

## 2. Desafios Encontrados
Durante o desenvolvimento, o principal desafio foi configurar corretamente o **banco de dados SQLite** para funcionar em múltiplas plataformas (Android e Windows).  
Foi necessário substituir o uso de `sqflite_common_ffi_web` pelo **`sqflite_common_ffi`**, que garante compatibilidade com desktops.  
Outro desafio foi ajustar o **tema visual** do app, devido a mudanças recentes nas classes do Flutter (`CardThemeData` substituindo `CardTheme`).

---

## 3. Melhorias Implementadas
Além das exigências do roteiro, foram adicionadas:
- **Compartilhamento de tarefas** usando o pacote `share_plus`.  
- **Ordenação de tarefas** por prioridade e data de criação.  
- **Feedbacks visuais aprimorados**, com SnackBars coloridas e mensagens contextuais.  
- **Cores dinâmicas e tipografia consistente** seguindo o Material Design 3.  
- Adaptação completa para **Windows Desktop**, facilitando testes sem emulador.

---

## 4. Aprendizados
Durante o laboratório, aprimorei o entendimento sobre:
- **Material Design 3** e suas diretrizes de espaçamento, cor e tipografia.  
- **Gerenciamento de estado e navegação** com o `Navigator.push` e `Navigator.pop`.  
- **Integração de persistência local** com o pacote `sqflite_common_ffi`.  

Em relação ao Lab 1, este projeto apresentou uma estrutura muito mais profissional, com camadas bem definidas  
(models, services, screens e widgets) e foco em UX e boas práticas de código.

---

## 5. Próximos Passos
Para as próximas etapas, pretendo:
- Implementar **notificações locais** para alertar sobre prazos de tarefas.  
- Adicionar **datas de vencimento e categorias** para classificação.  
- Criar **sincronização com a nuvem** (Firebase) para salvar tarefas online.  
- Incluir um **modo escuro** e animações de transição entre telas.  
