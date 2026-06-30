import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/pedido.dart';
import '../../providers/pedidos_provider.dart';
import '../../widgets/estado_badge.dart';
import '../../widgets/user_menu_button.dart';
import '../../widgets/filtro_menu_button.dart';
import '../../widgets/loading_widget.dart';
import '../main_shell.dart';
import '../../widgets/error_widget.dart';
import 'pedido_detalle_page.dart';

class PedidosPage extends StatefulWidget {
  const PedidosPage({super.key});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _filtroEstado;

  static const _opcionesFiltro = [
    'Sin empezar',
    'En preparación',
    'Finalizado',
    'Cancelado',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PedidosProvider>().cargar();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Pedido> _filtrar(List<Pedido> todos) {
    return todos.where((p) {
      final matchQuery = _query.isEmpty ||
          (p.nombreServicio ?? '').toLowerCase().contains(_query.toLowerCase()) ||
          'venta #${p.idVenta}'.contains(_query.toLowerCase());
      final matchEstado = _filtroEstado == null ||
          p.estado.toLowerCase() == _filtroEstado!.toLowerCase();
      return matchQuery && matchEstado;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Servicios'),
        actions: const [UserMenuButton()],
      ),
      body: Consumer<PedidosProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(mensaje: 'Cargando servicios...');
          }
          if (provider.error != null) {
            return AppErrorWidget(
              mensaje: provider.error!,
              onRetry: () => provider.cargar(),
            );
          }

          final filtrados = _filtrar(provider.pedidos);

          return RefreshIndicator(
            onRefresh: () => provider.cargar(),
            child: Column(
              children: [
                // Buscador + botón filtro
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 4, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar por servicio o venta #...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                      FiltroMenuButton(
                        opciones: _opcionesFiltro,
                        filtroActual: _filtroEstado,
                        onSelect: (v) => setState(() => _filtroEstado = v),
                      ),
                    ],
                  ),
                ),
                // Filtro activo badge
                if (_filtroEstado != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _filtroEstado!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _filtroEstado = null),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                // Contador
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                  child: Row(
                    children: [
                      Text(
                        '${filtrados.length} servicio${filtrados.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista
                Expanded(
                  child: filtrados.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 48,
                                color: AppColors.muted.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No hay servicios que coincidan',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                          itemCount: filtrados.length,
                          itemBuilder: (context, index) {
                            final pedido = filtrados[index];
                            return _PedidoTile(
                              pedido: pedido,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PedidoDetallePage(pedido: pedido),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PedidoTile extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onTap;

  const _PedidoTile({required this.pedido, required this.onTap});

  String _formatNum(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: AppColors.warning,
            size: 20,
          ),
        ),
        title: Text(
          pedido.nombreServicio ?? 'Servicio #${pedido.idDetalle}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          'Venta #${pedido.idVenta}  •  \$${_formatNum(pedido.precio)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: EstadoBadge(texto: pedido.estado),
      ),
    );
  }
}
