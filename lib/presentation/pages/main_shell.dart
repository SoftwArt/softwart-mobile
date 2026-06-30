import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/push_notification_service.dart';
import '../providers/dashboard_provider.dart';
import '../providers/citas_provider.dart';
import '../providers/pedidos_provider.dart';
import '../providers/ventas_provider.dart';
import '../providers/pagos_provider.dart';
import '../providers/clientes_provider.dart';
import 'dashboard/dashboard_page.dart';
import 'citas/citas_page.dart';
import 'pedidos/pedidos_page.dart';
import 'ventas/ventas_page.dart';
import 'clientes/clientes_page.dart';
import 'pagos/pagos_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  // Clave estática para abrir el drawer desde cualquier página
  static final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    DashboardPage(),
    CitasPage(),
    PedidosPage(),
    VentasPage(),
    PagosPage(),
    ClientesPage(),
  ];

  static const _destinos = [
    (Icons.dashboard_outlined,    Icons.dashboard_rounded,    'Dashboard'),
    (Icons.event_outlined,        Icons.event_rounded,        'Citas'),
    (Icons.inventory_2_outlined,  Icons.inventory_2_rounded,  'Servicios'),
    (Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Ventas'),
    (Icons.payments_outlined,     Icons.payments_rounded,     'Pagos'),
    (Icons.people_outline,        Icons.people_rounded,       'Clientes'),
  ];

  @override
  void initState() {
    super.initState();
    // Refresca listas en vivo cuando llega un push (cita nueva)
    PushNotificationService.onMessageTick.addListener(_onPushMessage);
  }

  @override
  void dispose() {
    PushNotificationService.onMessageTick.removeListener(_onPushMessage);
    super.dispose();
  }

  void _onPushMessage() {
    if (!mounted) return;
    // Una cita nueva afecta a Citas y al Dashboard
    context.read<CitasProvider>().cargar();
    context.read<DashboardProvider>().cargar();
  }

  // Recarga (silenciosa) la lista del módulo al que se navega
  void _refrescar(int i) {
    switch (i) {
      case 0: context.read<DashboardProvider>().cargar(); break;
      case 1: context.read<CitasProvider>().cargar(); break;
      case 2: context.read<PedidosProvider>().cargar(); break;
      case 3: context.read<VentasProvider>().cargar(); break;
      case 4: context.read<PagosProvider>().cargar(); break;
      case 5: context.read<ClientesProvider>().cargar(); break;
    }
  }

  void _navegar(int i) {
    setState(() => _selectedIndex = i);
    Navigator.of(context).pop();
    _refrescar(i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: MainShell.scaffoldKey,
      drawer: Drawer(
        backgroundColor: const Color(0xFF002926),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/softwart-logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SoftwArt',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Panel de gestión',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'MÓDULOS',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              // Items de navegación
              for (int i = 0; i < _destinos.length; i++)
                _DrawerItem(
                  icon: _destinos[i].$1,
                  iconSelected: _destinos[i].$2,
                  label: _destinos[i].$3,
                  selected: _selectedIndex == i,
                  onTap: () => _navegar(i),
                ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData iconSelected;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.iconSelected,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: selected
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.transparent,
        leading: Icon(
          selected ? iconSelected : icon,
          color: selected ? AppColors.accent : Colors.white70,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
