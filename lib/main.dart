import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart';

// Import Core & Theme
import 'core/theme/app_theme.dart';

// Import Features
import 'features/auth/logic/auth_provider.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/book/logic/book_provider.dart';
import 'features/cart/logic/cart_provider.dart';
import 'features/order/logic/order_provider.dart';
import 'features/payment/logic/payment_provider.dart';
import 'core/constants/api_constants.dart';

// Import Shared Layout
import 'shared/layouts/main_layout.dart';

Future<void> main() async {
  // Required for accessing platform-specific features like Secure Storage before runApp
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    Stripe.publishableKey = ApiConstants.stripePublishableKey;
    await Stripe.instance.applySettings();
  }

  runApp(
    MultiProvider(
      providers: [
        // AuthProvider is initialized here and available globally
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
  // We store the future in a variable to prevent FutureBuilder from
  // re-triggering the login check every time the widget rebuilds.
  late Future<void> _initAuthFuture;

  @override
  void initState() {
    super.initState();
    // We call loadCurrentUser once. This checks local storage and the /me endpoint.
    _initAuthFuture = context.read<AuthProvider>().loadCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    // We 'watch' the AuthProvider so the UI swaps automatically when user logs in/out
    final auth = context.watch<AuthProvider>();

    return FutureBuilder(
      future: _initAuthFuture,
      builder: (context, snapshot) {
        // 1. While the app is checking the JWT token...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF1B6EF3),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "INITIALIZING SYSTEM...",
                      style: TextStyle(
                        color: Color(0xFF7A8699),
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // 2. Once the check is done, show the actual App
        return MaterialApp(
          title: 'Monolithic Book Shop',
          debugShowCheckedModeBanner: false,

          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,

          // GATEKEEPER LOGIC:
          // If auth.user is null, the Gatekeeper stays at Login.
          // If auth.user has data, the Gatekeeper opens the MainLayout.
          home: auth.user == null ? const LoginScreen() : const MainLayout(),
        );
      },
    );
  }
}
