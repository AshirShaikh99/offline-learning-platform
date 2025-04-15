import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/course_local_data_source.dart';
import 'data/datasources/user_local_data_source.dart';
import 'data/models/course_model.dart';
import 'data/models/user_model.dart';
import 'data/repositories/course_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/course_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/course/course_bloc.dart';
import 'presentation/blocs/file/file_bloc.dart';
import 'presentation/screens/login_screen.dart';

void main() async {
  // Preserve splash screen until initialization complete
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters - this must happen before opening boxes
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(CourseModelAdapter());

  // Open only the essential box first (user settings)
  final settingsBox = await Hive.openBox<String>('settings');

  runApp(MyApp.loading(settingsBox));

  // Continue initialization in the background
  _completeInitialization().then((appDependencies) {
    runApp(
      MyApp(
        userRepository: appDependencies.userRepository,
        courseRepository: appDependencies.courseRepository,
        courseBox: appDependencies.courseBox,
      ),
    );
    // Remove splash screen when initialization is complete
    FlutterNativeSplash.remove();
  });
}

class AppDependencies {
  final UserRepository userRepository;
  final CourseRepository courseRepository;
  final Box<CourseModel> courseBox;

  AppDependencies({
    required this.userRepository,
    required this.courseRepository,
    required this.courseBox,
  });
}

Future<AppDependencies> _completeInitialization() async {
  // Open remaining boxes in parallel
  final futures = await Future.wait([
    Hive.openBox<UserModel>('users'),
    Hive.openBox<CourseModel>('courses'),
  ]);

  final userBox = futures[0] as Box<UserModel>;
  final courseBox = futures[1] as Box<CourseModel>;

  // Create UUID instance
  final uuid = Uuid();

  // Create data sources
  final userLocalDataSource = UserLocalDataSourceImpl(
    userBox: userBox,
    settingsBox: await Hive.openBox<String>('settings'),
    uuid: uuid,
  );

  final courseLocalDataSource = CourseLocalDataSourceImpl(
    courseBox: courseBox,
    uuid: uuid,
  );

  // Create repositories
  final userRepository = UserRepositoryImpl(
    localDataSource: userLocalDataSource,
  );

  final courseRepository = CourseRepositoryImpl(
    localDataSource: courseLocalDataSource,
  );

  return AppDependencies(
    userRepository: userRepository,
    courseRepository: courseRepository,
    courseBox: courseBox,
  );
}

class MyApp extends StatelessWidget {
  final UserRepository? userRepository;
  final CourseRepository? courseRepository;
  final Box<CourseModel>? courseBox;
  final bool isLoading;
  final Box<String>? settingsBox;

  const MyApp({
    super.key,
    required this.userRepository,
    required this.courseRepository,
    required this.courseBox,
  }) : isLoading = false,
       settingsBox = null;

  const MyApp.loading(this.settingsBox, {super.key})
    : userRepository = null,
      courseRepository = null,
      courseBox = null,
      isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Edutech',
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create:
              (context) =>
                  AuthBloc(userRepository: userRepository!)
                    ..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<CourseBloc>(
          create: (context) => CourseBloc(courseRepository: courseRepository!),
        ),
        BlocProvider<FileBloc>(
          create: (context) => FileBloc(courseBox: courseBox!),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Edutech',
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTheme.primaryColor,
        brightness: Brightness.light,
      ),
      // Typography
      textTheme: TextTheme(
        displayLarge: AppTheme.headlineLarge,
        displayMedium: AppTheme.headlineMedium,
        titleLarge: AppTheme.titleLarge,
        bodyLarge: AppTheme.bodyLarge,
        bodyMedium: AppTheme.bodyMedium,
        labelLarge: AppTheme.labelLarge,
      ),
      // Component themes
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
        titleTextStyle: AppTheme.titleLarge.copyWith(
          color: AppTheme.primaryColor,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTheme.primaryColor,
        brightness: Brightness.dark,
      ),
      // Typography
      textTheme: TextTheme(
        displayLarge: AppTheme.headlineLarge,
        displayMedium: AppTheme.headlineMedium,
        titleLarge: AppTheme.titleLarge,
        bodyLarge: AppTheme.bodyLarge,
        bodyMedium: AppTheme.bodyMedium,
        labelLarge: AppTheme.labelLarge,
      ),
      // Component themes
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        titleTextStyle: AppTheme.titleLarge.copyWith(color: Colors.white),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1E1E1E),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
