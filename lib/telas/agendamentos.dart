import 'package:material_ui/material_ui.dart';

import '../api/api_service.dart';
import '../model/agendamentos.dart';
import '../model/cliente.dart';
import '../model/procedimento.dart';

class AgendamentosPage extends StatefulWidget {
  const AgendamentosPage({super.key});

  @override
  State<AgendamentosPage> createState() => _AgendamentosPageState();
}

class _AgendamentosPageState extends State<AgendamentosPage> {
  final ApiService api = ApiService();

  List<Agendamento> lista = [];
  List<Cliente> clientes = [];
  List<Procedimento> procedimentos = [];

  bool carregando = true;
  String? erro;

  // Filtros da agenda
  String filtroStatus = 'TODOS';
  DateTime? filtroData;

  // Retorna somente os agendamentos que atendem aos filtros
  List<Agendamento> get listaFiltrada {
    return lista.where((agendamento) {
      final statusCorresponde =
          filtroStatus == 'TODOS' ||
          agendamento.status?.toUpperCase() == filtroStatus;

      final data = agendamento.dataHora;
      final dataCorresponde = filtroData == null ||
          (data != null &&
              data.year == filtroData!.year &&
              data.month == filtroData!.month &&
              data.day == filtroData!.day);

      return statusCorresponde && dataCorresponde;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  // Busca os dados reais do backend
  Future<void> _carregarDados() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final agendamentos = await api.buscarAgendamentos();

      // Organiza os agendamentos por data e horário
      agendamentos.sort((a, b) {
        return a.dataHora!.compareTo(b.dataHora!);
      });

      final clientesApi = await api.buscarClientes();
      final procedimentosApi = await api.buscarProcedimentos();

      if (!mounted) return;

      setState(() {
        lista = agendamentos;
        clientes = clientesApi;
        procedimentos = procedimentosApi;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        erro = e.toString();
        carregando = false;
      });
    }
  }

  // Formata data
  String _formatarData(DateTime? data) {
    if (data == null) return '';

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  // Formata horário
  String _formatarHora(DateTime? data) {
    if (data == null) return '';

    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  // Abre formulário de cadastro ou edição
  Future<void> _inserirOuEditar({Agendamento? agendamento}) async {
    if (clientes.isEmpty || procedimentos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastre pelo menos um cliente e um procedimento antes.',
          ),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();

    final observacoesController = TextEditingController(
      text: agendamento?.observacoes ?? '',
    );

    int? clienteId = agendamento?.clienteId;
    int? procedimentoId = agendamento?.procedimentoId;

    // Confere se os IDs ainda existem nas listas
    if (!clientes.any((c) => c.id == clienteId)) {
      clienteId = null;
    }

    if (!procedimentos.any((p) => p.id == procedimentoId)) {
      procedimentoId = null;
    }

    DateTime dataHora = agendamento?.dataHora ?? DateTime.now();

    String status = agendamento?.status?.toUpperCase() ?? 'AGENDADO';

    final editando = agendamento != null;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(
                editando ? 'Editar Agendamento' : 'Novo Agendamento',
                textAlign: TextAlign.center,
              ),

              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Seleção de cliente
                        DropdownButtonFormField<int>(
                          initialValue: clienteId,
                          isExpanded: true,

                          decoration: const InputDecoration(
                            labelText: 'Selecione o cliente',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),

                          items: clientes.map((cliente) {
                            return DropdownMenuItem<int>(
                              value: cliente.id,
                              child: Text(cliente.nome),
                            );
                          }).toList(),

                          onChanged: (value) {
                            setDialogState(() {
                              clienteId = value;
                            });
                          },

                          validator: (value) {
                            if (value == null) {
                              return 'Selecione um cliente.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Seleção de procedimento
                        DropdownButtonFormField<int>(
                          initialValue: procedimentoId,
                          isExpanded: true,

                          decoration: const InputDecoration(
                            labelText: 'Selecione o procedimento',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.spa),
                          ),

                          items: procedimentos.map((procedimento) {
                            return DropdownMenuItem<int>(
                              value: procedimento.id,
                              child: Text(procedimento.nome),
                            );
                          }).toList(),

                          onChanged: (value) {
                            setDialogState(() {
                              procedimentoId = value;
                            });
                          },

                          validator: (value) {
                            if (value == null) {
                              return 'Selecione um procedimento.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Data do atendimento
                        ListTile(
                          contentPadding: EdgeInsets.zero,

                          leading: const Icon(
                            Icons.calendar_month,
                            color: Colors.pink,
                          ),

                          title: const Text('Data do atendimento'),

                          subtitle: Text(_formatarData(dataHora)),

                          trailing: const Icon(Icons.edit_calendar),

                          onTap: () async {
                            final data = await showDatePicker(
                              context: dialogContext,
                              initialDate: dataHora,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );

                            if (data != null) {
                              setDialogState(() {
                                dataHora = DateTime(
                                  data.year,
                                  data.month,
                                  data.day,
                                  dataHora.hour,
                                  dataHora.minute,
                                );
                              });
                            }
                          },
                        ),

                        const Divider(),

                        // Horário do atendimento
                        ListTile(
                          contentPadding: EdgeInsets.zero,

                          leading: const Icon(
                            Icons.access_time,
                            color: Colors.pink,
                          ),

                          title: const Text('Horário'),

                          subtitle: Text(_formatarHora(dataHora)),

                          trailing: const Icon(Icons.edit),

                          onTap: () async {
                            final horario = await showTimePicker(
                              context: dialogContext,
                              initialTime: TimeOfDay.fromDateTime(dataHora),
                            );

                            if (horario != null) {
                              setDialogState(() {
                                dataHora = DateTime(
                                  dataHora.year,
                                  dataHora.month,
                                  dataHora.day,
                                  horario.hour,
                                  horario.minute,
                                );
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 12),

                        // Status: disponível na edição
                        if (editando)
                          DropdownButtonFormField<String>(
                            initialValue: status.toUpperCase(),
                            isExpanded: true,

                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.check_circle_outline),
                            ),

                            items: const [
                              DropdownMenuItem(
                                value: 'AGENDADO',
                                child: Text('Agendado'),
                              ),
                              DropdownMenuItem(
                                value: 'CONFIRMADO',
                                child: Text('Confirmado'),
                              ),
                              DropdownMenuItem(
                                value: 'CONCLUIDO',
                                child: Text('Concluído'),
                              ),
                              DropdownMenuItem(
                                value: 'CANCELADO',
                                child: Text('Cancelado'),
                              ),
                            ],

                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  status = value;
                                });
                              }
                            },
                          ),

                        if (editando) const SizedBox(height: 18),

                        // Observações
                        TextFormField(
                          controller: observacoesController,
                          maxLines: 3,

                          decoration: const InputDecoration(
                            labelText: 'Observações',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.notes),
                            alignLabelWithHint: true,
                          ),
                        ),

                        if (!editando) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'O status inicial será definido pelo backend.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Botões organizados
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (editando)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () async {
                              final confirmar = await showDialog<bool>(
                                context: dialogContext,
                                builder: (context) => AlertDialog(
                                  title: const Text('Excluir agendamento?'),
                                  content: const Text(
                                    'Deseja realmente excluir este atendimento?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmar != true) return;

                              try {
                                await api.delete(
                                  '/agendamentos/${agendamento.id}',
                                );

                                if (!mounted || !dialogContext.mounted) return;

                                Navigator.pop(dialogContext);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Agendamento excluído com sucesso!',
                                    ),
                                  ),
                                );

                                await _carregarDados();
                              } catch (e) {
                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro ao excluir: $e'),
                                  ),
                                );
                              }
                            },

                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),

                            label: const Text(
                              'Excluir agendamento',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),

                      const Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            child: const Text('Cancelar'),
                          ),

                          const SizedBox(width: 8),

                          ElevatedButton.icon(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }

                              final dados = <String, dynamic>{
                                'clienteId': clienteId,
                                'procedimentoId': procedimentoId,
                                'dataHora': dataHora.toIso8601String(),
                                'observacoes': observacoesController.text
                                    .trim(),
                              };

                              try {
                                if (editando) {
                                  dados['status'] = status;

                                  await api.patch(
                                    '/agendamentos/${agendamento.id}',
                                    dados,
                                  );
                                } else {
                                  await api.post('/agendamentos', dados);
                                }

                                if (!mounted || !dialogContext.mounted) return;

                                Navigator.pop(dialogContext);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      editando
                                          ? 'Agendamento atualizado com sucesso!'
                                          : 'Agendamento cadastrado com sucesso!',
                                    ),
                                  ),
                                );

                                await _carregarDados();
                              } catch (e) {
                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro ao salvar: $e')),
                                );
                              }
                            },

                            icon: const Icon(Icons.save),

                            label: const Text('Salvar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    observacoesController.dispose();
  }

  // Seleciona uma data para filtrar a agenda
  Future<void> _selecionarDataFiltro() async {
    final agora = DateTime.now();

    final data = await showDatePicker(
      context: context,
      initialDate: filtroData ?? agora,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (data != null && mounted) {
      setState(() {
        filtroData = data;
      });
    }
  }

  // Remove os filtros aplicados
  void _limparFiltros() {
    setState(() {
      filtroStatus = 'TODOS';
      filtroData = null;
    });
  }

  // Cor do status

  Color _corStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'CONFIRMADO':
        return Colors.green;

      case 'CONCLUIDO':
        return Colors.blue;

      case 'CANCELADO':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  // Cria o cabeçalho de cada dia da agenda
  Widget _cabecalhoDia(DateTime data) {
    final hoje = DateTime.now();

    final ehHoje =
        data.year == hoje.year &&
        data.month == hoje.month &&
        data.day == hoje.day;

    final amanha = hoje.add(const Duration(days: 1));

    final ehAmanha =
        data.year == amanha.year &&
        data.month == amanha.month &&
        data.day == amanha.day;

    String titulo;

    if (ehHoje) {
      titulo = 'Hoje';
    } else if (ehAmanha) {
      titulo = 'Amanhã';
    } else {
      titulo = _formatarData(data);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8, left: 8),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.pink, size: 19),
          const SizedBox(width: 10),
          Text(
            titulo,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Monta a agenda agrupando os atendimentos por dia
  List<Widget> _construirListaAgendamentos() {
    final widgets = <Widget>[];

    DateTime? ultimoDia;

    for (final obj in listaFiltrada) {
      final data = obj.dataHora!;

      final diaAtual = DateTime(data.year, data.month, data.day);

      // Cria cabeçalho quando muda o dia
      if (ultimoDia == null || diaAtual != ultimoDia) {
        widgets.add(_cabecalhoDia(data));
        ultimoDia = diaAtual;
      }

      // Cartão do agendamento
      widgets.add(
        Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),

            leading: const CircleAvatar(
              backgroundColor: Colors.pink,
              child: Icon(Icons.calendar_month, color: Colors.white),
            ),

            title: Text(
              obj.cliente ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Procedimento: ${obj.procedimento ?? ''}'),
                  Text('Horário: ${_formatarHora(data)}'),
                  const SizedBox(height: 5),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _corStatus(obj.status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      obj.status ?? 'AGENDADO',
                      style: TextStyle(
                        color: _corStatus(obj.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            trailing: const Icon(Icons.edit, color: Colors.grey),

            onTap: () {
              _inserirOuEditar(agendamento: obj);
            },
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        actions: [
          IconButton(
            onPressed: carregando ? null : _carregarDados,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar agendamentos',
          ),
        ],
      ),

      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 55,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Não foi possível carregar os dados.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(erro!, textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _carregarDados,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Área de filtros
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<String>(
                            key: ValueKey(filtroStatus),
                            initialValue: filtroStatus,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Filtrar por status',
                              prefixIcon: Icon(Icons.filter_list),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'TODOS',
                                child: Text('Todos os status'),
                              ),
                              DropdownMenuItem(
                                value: 'AGENDADO',
                                child: Text('Agendados'),
                              ),
                              DropdownMenuItem(
                                value: 'CONFIRMADO',
                                child: Text('Confirmados'),
                              ),
                              DropdownMenuItem(
                                value: 'CONCLUIDO',
                                child: Text('Concluídos'),
                              ),
                              DropdownMenuItem(
                                value: 'CANCELADO',
                                child: Text('Cancelados'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  filtroStatus = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _selecionarDataFiltro,
                                  icon: const Icon(Icons.calendar_month),
                                  label: Text(
                                    filtroData == null
                                        ? 'Todas as datas'
                                        : _formatarData(filtroData),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed:
                                    (filtroStatus == 'TODOS' &&
                                            filtroData == null)
                                        ? null
                                        : _limparFiltros,
                                tooltip: 'Limpar filtros',
                                icon: const Icon(Icons.filter_alt_off),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${listaFiltrada.length} agendamento(s) encontrado(s)',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Lista filtrada e agrupada por dia
                    Expanded(
                      child: listaFiltrada.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  lista.isEmpty
                                      ? 'Nenhum agendamento cadastrado.'
                                      : 'Nenhum agendamento encontrado para esses filtros.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _carregarDados,
                              child: ListView(
                                padding: const EdgeInsets.all(10),
                                children: _construirListaAgendamentos(),
                              ),
                            ),
                    ),
                  ],
                ),

      floatingActionButton: FloatingActionButton(
        onPressed: carregando || erro != null ? null : () => _inserirOuEditar(),

        child: const Icon(Icons.add),
      ),
    );
  }
}
