import 'package:flutter/material.dart';

// Gerenciador de estado global para o Tema
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Task Manager',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4F46E5),
              brightness: Brightness.light,
              surface: const Color(
                0xFFF8FAFC,
              ),
            ),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
              brightness: Brightness.dark,
              surface: const Color(
                0xFF0F172A,
              ),
            ),
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          home: const TodoListScreen(),
        );
      },
    );
  }
}

enum FiltroTarefa { todas, pendentes, concluidas }

class Tarefa {
  String id;
  String titulo;
  bool concluida;
  DateTime dataCriacao;
  DateTime? dataConclusao;

  Tarefa({
    required this.id,
    required this.titulo,
    this.concluida = false,
    required this.dataCriacao,
    this.dataConclusao,
  });
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Tarefa> _tarefas = [];
  final TextEditingController _controller = TextEditingController();

  bool _isKanbanView = false;
  FiltroTarefa _filtroAtual = FiltroTarefa.todas;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final min = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes às $hora:$min';
  }

  void _adicionarTarefa() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _tarefas.insert(
          0,
          Tarefa(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            titulo: _controller.text.trim(),
            dataCriacao: DateTime.now(),
          ),
        );
      });
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _alternarConclusao(int index, bool? valor) {
    setState(() {
      bool concluida = valor ?? false;
      _tarefas[index].concluida = concluida;
      _tarefas[index].dataConclusao = concluida ? DateTime.now() : null;
    });
  }

  void _atualizarStatusKanban(Tarefa tarefa, bool novoStatus) {
    setState(() {
      final index = _tarefas.indexWhere((t) => t.id == tarefa.id);
      if (index != -1) {
        _tarefas[index].concluida = novoStatus;
        _tarefas[index].dataConclusao = novoStatus ? DateTime.now() : null;
      }
    });
  }

  void _removerTarefa(String id) {
    setState(() {
      _tarefas.removeWhere((tarefa) => tarefa.id == id);
    });
  }

  void _limparConcluidas() {
    setState(() {
      _tarefas.removeWhere((tarefa) => tarefa.concluida);
    });
  }

  List<Tarefa> get _tarefasFiltradas {
    switch (_filtroAtual) {
      case FiltroTarefa.pendentes:
        return _tarefas.where((t) => !t.concluida).toList();
      case FiltroTarefa.concluidas:
        return _tarefas.where((t) => t.concluida).toList();
      case FiltroTarefa.todas:
        return _tarefas;
    }
  }

  Widget _buildDashboardHeader(int total, int concluidas, bool isDark) {
    double progresso = total == 0 ? 0.0 : concluidas / total;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, Gustavo!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.grey.shade900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    total == 0
                        ? 'Seu dia está livre.'
                        : 'Você tem ${total - concluidas} tarefas pendentes.',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso diário',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
              Text(
                '${(progresso * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 8,
              backgroundColor: isDark
                  ? const Color(0xFF1E293B)
                  : Colors.grey.shade200,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        children: [
          _buildFilterChip('Todas', FiltroTarefa.todas, isDark),
          _buildFilterChip('Pendentes', FiltroTarefa.pendentes, isDark),
          _buildFilterChip('Concluídas', FiltroTarefa.concluidas, isDark),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, FiltroTarefa valorFiltro, bool isDark) {
    final bool selecionado = _filtroAtual == valorFiltro;
    return FilterChip(
      label: Text(label),
      selected: selecionado,
      onSelected: (bool selected) {
        setState(() {
          _filtroAtual = valorFiltro;
        });
      },
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
      selectedColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: selecionado
            ? Theme.of(context).colorScheme.primary
            : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
        fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    );
  }

  Widget _buildListView(bool isDark) {
    final tarefasParaExibir = _tarefasFiltradas;

    if (tarefasParaExibir.isEmpty) return _buildEmptyState(isDark);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: tarefasParaExibir.length,
      itemBuilder: (context, index) {
        final tarefa = tarefasParaExibir[index];
        final realIndex = _tarefas.indexWhere((t) => t.id == tarefa.id);

        return Dismissible(
          key: Key(tarefa.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24.0),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete_sweep_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          onDismissed: (_) => _removerTarefa(tarefa.id),
          child: _buildTaskCard(tarefa, realIndex, isDark),
        );
      },
    );
  }

  Widget _buildKanbanView(bool isDark) {
    final pendentes = _tarefasFiltradas.where((t) => !t.concluida).toList();
    final concluidas = _tarefasFiltradas.where((t) => t.concluida).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        double columnWidth = constraints.maxWidth > 650
            ? (constraints.maxWidth - 48) / 2
            : constraints.maxWidth * 0.85;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: columnWidth,
                  child: _buildKanbanColumn(
                    'Pendentes',
                    pendentes,
                    false,
                    isDark,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: columnWidth,
                  child: _buildKanbanColumn(
                    'Concluídas',
                    concluidas,
                    true,
                    isDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKanbanColumn(
    String titulo,
    List<Tarefa> tarefasColuna,
    bool isConcluidaColumn,
    bool isDark,
  ) {
    return DragTarget<Tarefa>(
      onAcceptWithDetails: (details) =>
          _atualizarStatusKanban(details.data, isConcluidaColumn),
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : (isDark
                      ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isConcluidaColumn
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      titulo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF334155)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tarefasColuna.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  itemCount: tarefasColuna.length,
                  itemBuilder: (context, index) {
                    final tarefa = tarefasColuna[index];
                    final realIndex = _tarefas.indexWhere(
                      (t) => t.id == tarefa.id,
                    );

                    return Draggable<Tarefa>(
                      data: tarefa,
                      feedback: Material(
                        elevation: 12,
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.transparent,
                        child: SizedBox(
                          width:
                              MediaQuery.of(context).size.width *
                              (MediaQuery.of(context).size.width > 650
                                  ? 0.4
                                  : 0.8),
                          child: _buildTaskCard(tarefa, realIndex, isDark),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _buildTaskCard(tarefa, realIndex, isDark),
                      ),
                      child: _buildTaskCard(tarefa, realIndex, isDark),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(Tarefa tarefa, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 8.0,
        ),
        leading: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            value: tarefa.concluida,
            onChanged: (valor) => _alternarConclusao(index, valor),
            activeColor: const Color(0xFF10B981),
            side: BorderSide(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              width: 2,
            ),
          ),
        ),
        title: Text(
          tarefa.titulo,
          style: TextStyle(
            fontSize: 16,
            decoration: tarefa.concluida ? TextDecoration.lineThrough : null,
            color: tarefa.concluida
                ? Colors.grey.shade500
                : (isDark ? Colors.white : Colors.grey.shade800),
            fontWeight: tarefa.concluida ? FontWeight.normal : FontWeight.w500,
          ),
        ),
        // Exibição das Datas
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Criada: ${_formatarData(tarefa.dataCriacao)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              if (tarefa.concluida && tarefa.dataConclusao != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Concluída: ${_formatarData(tarefa.dataConclusao!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _filtroAtual == FiltroTarefa.pendentes
                  ? Icons.celebration_rounded
                  : Icons.coffee_rounded,
              size: 80,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _filtroAtual == FiltroTarefa.pendentes
                ? 'Nenhuma tarefa pendente!'
                : 'Tudo tranquilo por aqui.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Que tal adicionar uma nova meta?',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalTarefas = _tarefas.length;
    int tarefasConcluidas = _tarefas.where((t) => t.concluida).length;

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                ),
              ],
              border: isDark
                  ? Border.all(color: const Color(0xFF334155))
                  : null,
            ),
            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              ),
              color: isDark ? Colors.amber.shade300 : Colors.indigo.shade400,
              tooltip: isDark ? 'Modo Claro' : 'Modo Escuro',
              onPressed: () {
                themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                ),
              ],
              border: isDark
                  ? Border.all(color: const Color(0xFF334155))
                  : null,
            ),
            child: IconButton(
              icon: Icon(
                _isKanbanView
                    ? Icons.splitscreen_rounded
                    : Icons.space_dashboard_rounded,
              ),
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              tooltip: _isKanbanView ? 'Modo Lista' : 'Modo Kanban',
              onPressed: () => setState(() => _isKanbanView = !_isKanbanView),
            ),
          ),
          if (tarefasConcluidas > 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                  ),
                ],
                border: isDark
                    ? Border.all(color: const Color(0xFF334155))
                    : null,
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_sweep_rounded),
                color: const Color(0xFFEF4444),
                tooltip: 'Limpar Concluídas',
                onPressed: _limparConcluidas,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  _buildDashboardHeader(
                    totalTarefas,
                    tarefasConcluidas,
                    isDark,
                  ),
                  _buildFiltros(isDark),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isKanbanView
                      ? _buildKanbanView(isDark)
                      : _buildListView(isDark),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
              border: isDark
                  ? const Border(top: BorderSide(color: Color(0xFF1E293B)))
                  : null,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.done,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            onSubmitted: (_) => _adicionarTarefa(),
                            decoration: InputDecoration(
                              hintText: 'Adicionar nova tarefa...',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade500,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                const Color(0xFF6366F1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            padding: const EdgeInsets.all(14),
                            onPressed: _adicionarTarefa,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
