import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/mock/mock_auth_service.dart';
import 'data/services/mock/mock_weapon_service.dart';
import 'data/services/api/api_auth_service.dart';
import 'data/services/api/api_weapon_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/weapon_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() {
  runApp(const GenshinImportApp());
}

class GenshinImportApp extends StatelessWidget {
  const GenshinImportApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bool useRealApi = false;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(useRealApi ? ApiAuthService() : MockAuthService()),
        ),
        ChangeNotifierProvider(
          create: (_) => WeaponProvider(
            useRealApi ? ApiWeaponService() : MockWeaponService(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Genshin Import',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
