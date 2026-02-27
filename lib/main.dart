import 'dart:ui';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cadastro_cliente_page.dart';
import 'For_Cid.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: true,
      ), //scrollBehavior: const MaterialScrollBehavior().copyWith(

      //  dragDevices: {
      //    PointerDeviceKind.mouse,
      //    PointerDeviceKind.touch,
      //    PointerDeviceKind.trackpad,
      //  },
      //),
      debugShowCheckedModeBanner: false,
      title: 'Controle Administrativo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: Brightness.light,
            ).copyWith(
              primary: Colors.blueGrey.shade700,
              secondary: Colors.blueGrey.shade400,
              surface: Colors.blueGrey.shade200,
            ),
        scaffoldBackgroundColor: Colors.blueGrey.shade400,
      ),
      home: const MenuPage(),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  const MyCustomScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return Scrollbar(
      controller: details.controller,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      child: child,
    );
  }
}

class _Modulo {
  final String id;
  final String titulo;
  final Widget widget;

  _Modulo({required this.id, required this.titulo, required this.widget});
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final List<_Modulo> _modulosAbertos = [];
  int? _moduloAtivoIndex;
  bool _encerrado = false;

  /// ============================
  /// CONTROLE DE MÓDULOS (MDI)
  /// ============================

  void _abrirModulo(_Modulo modulo) {
    final existenteIndex = _modulosAbertos.indexWhere((m) => m.id == modulo.id);

    setState(() {
      if (existenteIndex != -1) {
        _moduloAtivoIndex = existenteIndex;
      } else {
        _modulosAbertos.add(modulo);
        _moduloAtivoIndex = _modulosAbertos.length - 1;
      }
    });

    Navigator.of(context).pop(); // fecha drawer
  }

  void _fecharModulo(String id) {
    final index = _modulosAbertos.indexWhere((m) => m.id == id);

    if (index == -1) return;

    setState(() {
      _modulosAbertos.removeAt(index);

      if (_modulosAbertos.isEmpty) {
        _moduloAtivoIndex = null;
      } else {
        _moduloAtivoIndex = _modulosAbertos.length - 1;
      }
    });
  }

  void _sairSistema() {
    if (kIsWeb) {
      setState(() {
        _encerrado = true;
        _modulosAbertos.clear();
        _moduloAtivoIndex = null;
      });
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      exit(0);
    } else {
      SystemNavigator.pop();
    }
  }

  /// ============================
  /// DRAWER (ÚNICO MENU DO APP)
  /// ============================

  Widget _buildDrawer() {
    return Drawer(
      width: 200,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Center(
              child: Text(
                'Controle',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_city, color: Colors.white),
            title: const Text('Cidades', style: TextStyle(color: Colors.white)),
            onTap: () {
              _abrirModulo(
                _Modulo(
                  id: 'cidades',
                  titulo: 'Cidades',
                  widget: ForCid(onClose: () => _fecharModulo('cidades')),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text(
              'Clientes',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              _abrirModulo(
                _Modulo(
                  id: 'clientes',
                  titulo: 'Clientes',
                  widget: CadastroClientePage(
                    onClose: () => _fecharModulo('clientes'),
                  ),
                ),
              );
            },
          ),
          const Divider(color: Colors.white54),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('Sair', style: TextStyle(color: Colors.white)),
            onTap: _sairSistema,
          ),
        ],
      ),
    );
  }

  /// ============================
  /// ÁREA MDI
  /// ============================
  Widget _buildMDI() {
    if (_modulosAbertos.isEmpty) {
      final bool isDesktop = MediaQuery.of(context).size.width >= 900;
      if (isDesktop) {
        // TELA GRANDE → mostra texto
        return const Center(
          child: Text(
            'Bem-vindo ao Sistema',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
          ),
        );
      } else {
        // MOBILE → mostra ícone central
        return Center(
          child: Icon(
            Icons.business,
            size: 120,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ),
        );
      }
    }
    return IndexedStack(
      index: _moduloAtivoIndex ?? 0,
      children: _modulosAbertos.map((m) => m.widget).toList(),
    );
  }

  /// ============================
  /// BUILD
  /// ============================
  @override
  Widget build(BuildContext context) {
    if (_encerrado) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    // MOBILE
    if (!isDesktop) {
      return Scaffold(
        appBar: AppBar(title: const Text('Controle Administrativo')),
        drawer: _buildDrawer(),
        body: _buildMDI(),
      );
    }

    // DESKTOP
    return Scaffold(
      appBar: AppBar(title: const Text('Controle Administrativo')),
      drawer: _buildDrawer(),
      body: Row(
        children: [
          // 🔵 RETÂNGULO LATERAL (AGORA ABAIXO DA APPBAR)
          Container(
            width: 200,
            color: Theme.of(context).colorScheme.primary,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business, size: 90, color: Colors.white70),
                SizedBox(height: 20),
                Text(
                  'Controle\nAdministrativo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 CONTEÚDO
          Expanded(child: _buildMDI()),
        ],
      ),
    );
  }
}
