// ============================================================
// Assignment #1 - MAD (Mobile Application Development) 2026
// Szabist University
//
// Group Members:
//   1. Hafiz Abrar Iqbal       - Roll# 2280142
//   2. [Member 2 Name]         - Roll# [ID]
//   3. [Member 3 Name]         - Roll# [ID]
// ============================================================

import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/todo_service.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with TickerProviderStateMixin {
  // ── Services & controllers ─────────────────────────────────────────────────
  final TodoService _todoService = TodoService();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _fabAnimController;

  // ── State ──────────────────────────────────────────────────────────────────
  List<Todo> _todos = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String _errorMsg = '';

  // ── Filter ─────────────────────────────────────────────────────────────────
  String _filter = 'All'; // 'All' | 'Pending' | 'Done'

  List<Todo> get _filteredTodos {
    switch (_filter) {
      case 'Pending':
        return _todos.where((t) => !t.completed).toList();
      case 'Done':
        return _todos.where((t) => t.completed).toList();
      default:
        return _todos;
    }
  }

  // ── Theme colours ──────────────────────────────────────────────────────────
  static const Color _primary = Color(0xFF6C63FF);
  static const Color _secondary = Color(0xFF3ECFCF);
  static const Color _bg = Color(0xFF0F0E17);
  static const Color _surface = Color(0xFF1A1826);
  static const Color _cardBg = Color(0xFF221F35);
  static const Color _textPrimary = Color(0xFFEEEBFF);
  static const Color _textSecondary = Color(0xFF9390B0);
  static const Color _done = Color(0xFF3ECFCF);
  static const Color _pending = Color(0xFFFFA552);

  // ──────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fetchTodos();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 150) {
      if (!_isLoading && _hasMore) _fetchTodos();
    }
  }

  // ── Data methods ───────────────────────────────────────────────────────────

  Future<void> _fetchTodos() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      final newTodos = await _todoService.getTodos(_currentPage);
      setState(() {
        _currentPage++;
        final existingIds = _todos.map((t) => t.id).toSet();
        for (final t in newTodos) {
          if (!existingIds.contains(t.id)) _todos.add(t);
        }
        if (newTodos.length < 10) _hasMore = false;
      });
    } catch (e) {
      setState(() => _errorMsg = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _todos.clear();
      _currentPage = 1;
      _hasMore = true;
      _errorMsg = '';
    });
    await _fetchTodos();
  }

  Future<void> _toggleTodo(int index) async {
    final todo = _filteredTodos[index];
    final globalIdx = _todos.indexOf(todo);
    try {
      final updated = await _todoService.updateTodo(todo);
      setState(() => _todos[globalIdx] = updated);
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }
  }

  Future<void> _deleteTodo(int index) async {
    final todo = _filteredTodos[index];
    final globalIdx = _todos.indexOf(todo);
    setState(() => _todos.removeAt(globalIdx));
    try {
      await _todoService.deleteTodo(todo.id);
      _showSnack('Todo deleted');
    } catch (_) {
      // JSONPlaceholder always succeeds — silently ignore
    }
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'dismiss',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (ctx, anim, __, ___) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              bool loading = false;
              return AlertDialog(
                backgroundColor: _surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_task,
                          color: _primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('New Todo',
                        style: TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ],
                ),
                content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDialogField(
                        controller: titleCtrl,
                        label: 'Title',
                        hint: 'What needs to be done?',
                        icon: Icons.title,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Title required';
                          if (v.trim().length < 3)
                            return 'At least 3 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildDialogField(
                        controller: descCtrl,
                        label: 'Description',
                        hint: 'Any extra details…',
                        icon: Icons.notes,
                        maxLines: 3,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Description required'
                                : null,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancel',
                        style: TextStyle(color: _textSecondary)),
                  ),
                  StatefulBuilder(builder: (_, setBtn) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: loading
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setBtn(() => loading = true);
                              try {
                                final newTodo = await _todoService.addTodo(
                                  titleCtrl.text.trim(),
                                  descCtrl.text.trim(),
                                );
                                if (!ctx.mounted) return;
                                Navigator.pop(ctx);
                                setState(
                                    () => _todos.insert(0, newTodo));
                                _showSnack('Todo added ✨');
                              } catch (e) {
                                setBtn(() => loading = false);
                                _showSnack('Error: $e', isError: true);
                              }
                            },
                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : const Text('Add',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                    );
                  }),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: _textPrimary),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _primary, size: 20),
        labelStyle: const TextStyle(color: _textSecondary),
        hintStyle: TextStyle(color: _textSecondary.withOpacity(0.5)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        filled: true,
        fillColor: _bg,
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : _primary,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      // ── App Bar ─────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primary, _secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.checklist_rtl,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'TaskFlow',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _textSecondary),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      // ── FAB ─────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Task',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 8,
      ),
      body: Column(
        children: [
          // ── Student info card ──────────────────────────────────────────
          _buildInfoCard(),
          // ── Stats row ─────────────────────────────────────────────────
          _buildStatsRow(),
          // ── Filter chips ──────────────────────────────────────────────
          _buildFilterRow(),
          // ── Main list ─────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: _primary,
              backgroundColor: _surface,
              onRefresh: _refresh,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sub-widgets ────────────────────────────────────────────────────────────

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary.withOpacity(0.25), _secondary.withOpacity(0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _primary.withOpacity(0.3),
            child: const Icon(Icons.person_rounded,
                color: _primary, size: 22),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hafiz Abrar Iqbal',
                style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              SizedBox(height: 2),
              Text(
                'Roll# 2280142  •  Szabist MAD 2026',
                style: TextStyle(color: _textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final total = _todos.length;
    final done = _todos.where((t) => t.completed).length;
    final pending = total - done;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _StatChip(label: 'Total', value: total, color: _primary),
          const SizedBox(width: 10),
          _StatChip(label: 'Done', value: done, color: _done),
          const SizedBox(width: 10),
          _StatChip(label: 'Pending', value: pending, color: _pending),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final filters = ['All', 'Pending', 'Done'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: filters.map((f) {
          final active = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? _primary : _cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: active
                          ? _primary
                          : _primary.withOpacity(0.2)),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: active ? Colors.white : _textSecondary,
                    fontWeight: active
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody() {
    final list = _filteredTodos;

    // Initial loading
    if (list.isEmpty && _isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: _primary));
    }

    // Error state
    if (_errorMsg.isNotEmpty && list.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    size: 70, color: Colors.redAccent),
                const SizedBox(height: 12),
                const Text('Connection Failed',
                    style: TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(_errorMsg,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: _textSecondary)),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _refresh,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Empty state
    if (list.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _filter == 'Done'
                      ? Icons.check_circle_outline
                      : Icons.inbox_rounded,
                  size: 80,
                  color: _textSecondary.withOpacity(0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  _filter == 'All'
                      ? 'No tasks yet!'
                      : 'No ${_filter.toLowerCase()} tasks',
                  style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600),
                ),
                if (_filter == 'All') ...[
                  const SizedBox(height: 6),
                  const Text('Tap + to add your first task',
                      style: TextStyle(color: _textSecondary, fontSize: 13)),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Main list
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: list.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == list.length) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
                child:
                    CircularProgressIndicator(color: _primary)),
          );
        }
        return _TodoCard(
          todo: list[i],
          onToggle: () => _toggleTodo(i),
          onDelete: () => _deleteTodo(i),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Todo Card Widget
// ═══════════════════════════════════════════════════════════════════════════════

class _TodoCard extends StatefulWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TodoCard({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<_TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<_TodoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  static const Color _primary = Color(0xFF6C63FF);
  static const Color _cardBg = Color(0xFF221F35);
  static const Color _textPrimary = Color(0xFFEEEBFF);
  static const Color _textSecondary = Color(0xFF9390B0);
  static const Color _done = Color(0xFF3ECFCF);
  static const Color _pending = Color(0xFFFFA552);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween(begin: 1.0, end: 0.97).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todo = widget.todo;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Dismissible(
          key: Key(todo.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_rounded,
                color: Colors.redAccent, size: 26),
          ),
          onDismissed: (_) => widget.onDelete(),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: todo.completed
                    ? _done.withOpacity(0.3)
                    : _primary.withOpacity(0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              leading: GestureDetector(
                onTap: widget.onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: todo.completed
                        ? _done
                        : Colors.transparent,
                    border: Border.all(
                      color: todo.completed ? _done : _textSecondary,
                      width: 2.5,
                    ),
                  ),
                  child: todo.completed
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18)
                      : null,
                ),
              ),
              title: Text(
                todo.title,
                style: TextStyle(
                  color: todo.completed ? _textSecondary : _textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  decoration: todo.completed
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: _textSecondary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  todo.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _textSecondary.withOpacity(0.7),
                    fontSize: 12,
                    decoration: todo.completed
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: _textSecondary,
                  ),
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (todo.completed ? _done : _pending)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      todo.completed ? 'Done' : 'Pending',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: todo.completed ? _done : _pending,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Stat Chip Widget
// ═══════════════════════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  color: Color(0xFF9390B0), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
