import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

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

void main() {
  // Show a loading indicator immediately
  runApp(const LoadingApp());

  // Initialize the app in the background
  initializeApp();
}

class LoadingApp extends StatelessWidget {
  const LoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Loading...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(CourseModelAdapter());

  // Open boxes
  final userBox = await Hive.openBox<UserModel>('users');
  final courseBox = await Hive.openBox<CourseModel>('courses');
  final settingsBox = await Hive.openBox<String>('settings');

  // Create UUID instance
  final uuid = Uuid();

  // Create data sources
  final userLocalDataSource = UserLocalDataSourceImpl(
    userBox: userBox,
    settingsBox: settingsBox,
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

  // Launch the actual app
  runApp(
    MyApp(
      userRepository: userRepository,
      courseRepository: courseRepository,
      courseBox: courseBox,
    ),
  );
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  final CourseRepository courseRepository;
  final Box<CourseModel> courseBox;

  const MyApp({
    super.key,
    required this.userRepository,
    required this.courseRepository,
    required this.courseBox,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create:
              (context) =>
                  AuthBloc(userRepository: userRepository)
                    ..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<CourseBloc>(
          create: (context) => CourseBloc(courseRepository: courseRepository),
        ),
        BlocProvider<FileBloc>(
          create: (context) => FileBloc(courseBox: courseBox),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Edutech',
        // Enable Material 3
        theme: ThemeData(
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
        ),
        // Dark theme
        darkTheme: ThemeData(
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
        ),
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
      ),
    );
  }
}
