import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/constants/api_constants.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/token_storage.dart';
import 'data/datasources/citas_datasource.dart';
import 'data/datasources/clientes_datasource.dart';
import 'data/datasources/dashboard_datasource.dart';
import 'data/datasources/pagos_datasource.dart';
import 'data/datasources/pedidos_datasource.dart';

import 'data/datasources/ventas_datasource.dart';
import 'data/models/usuario_model.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/citas_repository_impl.dart';
import 'data/repositories/clientes_repository_impl.dart';
import 'data/repositories/dashboard_repository_impl.dart';
import 'data/repositories/pagos_repository_impl.dart';
import 'data/repositories/pedidos_repository_impl.dart';
import 'data/repositories/ventas_repository_impl.dart';
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';
import 'domain/usecases/citas/cambiar_estado_cita_usecase.dart';
import 'domain/usecases/citas/get_citas_usecase.dart';
import 'domain/usecases/clientes/get_clientes_usecase.dart';
import 'domain/usecases/dashboard/get_dashboard_usecase.dart';
import 'domain/usecases/pagos/cambiar_estado_pago_usecase.dart';
import 'domain/usecases/pagos/get_pagos_usecase.dart';
import 'domain/usecases/pedidos/cambiar_estado_pedido_usecase.dart';
import 'domain/usecases/pedidos/get_pedidos_usecase.dart';
import 'domain/usecases/pedidos/get_estados_servicio_usecase.dart';
import 'domain/usecases/ventas/get_estado_pagos_usecase.dart';
import 'domain/usecases/ventas/get_ventas_usecase.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/main_shell.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/citas_provider.dart';
import 'presentation/providers/clientes_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/pagos_provider.dart';
import 'presentation/providers/pedidos_provider.dart';
import 'presentation/providers/ventas_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await PushNotificationService.init();
  } catch (e) {
    debugPrint('Push init falló: $e');
  }
  runApp(const SoftwArtApp());
}

class SoftwArtApp extends StatelessWidget {
  const SoftwArtApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Repositorios
    final authRepo = AuthRepositoryImpl();
    final citasRepo = CitasRepositoryImpl(CitasDatasource());
    final pedidosRepo = PedidosRepositoryImpl(PedidosDatasource());
    final ventasRepo = VentasRepositoryImpl(VentasDatasource());
    final clientesRepo = ClientesRepositoryImpl(ClientesDatasource());
    final dashboardRepo = DashboardRepositoryImpl(DashboardDatasource());
    final pagosRepo = PagosRepositoryImpl(PagosDatasource());

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUsecase: LoginUsecase(authRepo),
            logoutUsecase: LogoutUsecase(authRepo),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(
            getStatsUsecase: GetDashboardUsecase(dashboardRepo),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CitasProvider(
            getCitasUsecase: GetCitasUsecase(citasRepo),
            cambiarEstadoUsecase: CambiarEstadoCitaUsecase(citasRepo),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PedidosProvider(
            getPedidosUsecase: GetPedidosUsecase(pedidosRepo),
            getEstadosUsecase: GetEstadosServicioUsecase(pedidosRepo),
            cambiarEstadoUsecase: CambiarEstadoPedidoUsecase(pedidosRepo),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => VentasProvider(
            getVentasUsecase: GetVentasUsecase(ventasRepo),
            getEstadoPagosUsecase: GetEstadoPagosUsecase(ventasRepo),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ClientesProvider(
            getClientesUsecase: GetClientesUsecase(clientesRepo),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PagosProvider(
            getPagosUsecase: GetPagosUsecase(pagosRepo),
            cambiarEstadoUsecase: CambiarEstadoPagoUsecase(pagosRepo),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'SoftwArt',
        scaffoldMessengerKey: PushNotificationService.messengerKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _Splash(),
        routes: {
          '/login': (_) => const LoginPage(),
          '/home':  (_) => const MainShell(),
        },
      ),
    );
  }
}

// Splash que verifica el token y redirige
class _Splash extends StatefulWidget {
  const _Splash();

  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> {
  // Mismos tiempos que el frontend web (useBackendWakeup):
  static const _showMessageAfter = Duration(milliseconds: 800); // muestra el mensaje si tarda
  static const _requestTimeout   = Duration(seconds: 5);        // timeout por intento + espera entre reintentos

  bool _showMessage = false;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    // El spinner aparece siempre; el mensaje de conexión solo si tarda más de 800ms.
    _messageTimer = Timer(_showMessageAfter, () {
      if (mounted) setState(() => _showMessage = true);
    });
    _boot();
  }

  Future<void> _boot() async {
    await _wakeBackend();        // despierta el backend (cold start) antes de navegar
    _messageTimer?.cancel();
    if (!mounted) return;
    await _checkAuth();
  }

  // Pinga /services (ruta pública) hasta que el backend responda — reintenta hasta conectar.
  Future<void> _wakeBackend() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/services');
    while (mounted) {
      try {
        await http.get(uri).timeout(_requestTimeout);
        return; // backend despierto
      } catch (_) {
        // aún no responde — espera antes de reintentar (igual que el frontend)
        await Future.delayed(_requestTimeout);
      }
    }
  }

  Future<void> _checkAuth() async {
    final hasToken = await TokenStorage.hasValidToken();

    if (!mounted) return;

    if (hasToken) {
      final token = await TokenStorage.getToken();
      if (token != null) {
        try {
          final usuario = _decodeUsuarioFromToken(token);
          if (!mounted) return;
          context.read<AuthProvider>().setAuthenticated(
            usuario: usuario,
            token: token,
          );
          Navigator.of(context).pushReplacementNamed('/home');
          return;
        } catch (_) {
          await TokenStorage.deleteToken();
        }
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  UsuarioModel _decodeUsuarioFromToken(String token) {
    final parts = token.split('.');
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final Map<String, dynamic> jsonPayload = jsonDecode(decoded);
    return UsuarioModel.fromJson(jsonPayload);
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF002926), Color(0xFF003D3A), Color(0xFF1B3F3D)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/images/softwart-logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'SoftwArt',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _showMessage ? 'Conectando con el servidor…' : 'Iniciando…',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(flex: 2),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 32, height: 1, color: Colors.white24),
                  const SizedBox(width: 12),
                  Text(
                    'ARTESANÍA & PRECISIÓN',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 2.5,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 32, height: 1, color: Colors.white24),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
