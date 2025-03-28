import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
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

void main() async {
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
        title: 'Offline School App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
      ),
    );
  }
}
