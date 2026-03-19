import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart';

// Core & Constants
import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';

// Features Logic
import 'features/auth/logic/auth_provider.dart';
import 'features/book/logic/book_provider.dart';
import 'features/cart/logic/cart_provider.dart';
import 'features/order/logic/order_provider.dart';
import 'features/payment/logic/payment_provider.dart';

// UI Screens
import 'features/auth/ui/login_screen.dart';
import 'shared/layouts/main_layout.dart';
import 'shared/ui/initializing_screen.dart';

Future<void> main() async {
  // 1. System Boot
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    Stripe.publishableKey = ApiConstants.stripePublishableKey;
    await Stripe.instance.applySettings();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: const BookShopApp(),
    ),
  );
}

class BookShopApp extends StatefulWidget {
  const BookShopApp({super.key});

  @override
  State<BookShopApp> createState() => _BookShopAppState();
}

class _BookShopAppState extends State<BookShopApp> {
  late Future<void> _initAuthFuture;

  @override
  void initState() {
    super.initState();
    // Load user session once at startup
    _initAuthFuture = context.read<AuthProvider>().loadCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monolithic Book Shop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Single Entry Point
      home: FutureBuilder(
        future: _initAuthFuture,
        builder: (context, snapshot) {
          // If still checking JWT, show the Minimalist Loader
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const InitializingScreen();
          }

          // Animated Switcher for a smooth fade between Login and Main Dashboard
          return Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeIn,
                child: auth.user == null
                    ? const LoginScreen(key: ValueKey('login'))
                    : const MainLayout(key: ValueKey('layout')),
              );
            },
          );
        },
      ),
    );
  }
}
