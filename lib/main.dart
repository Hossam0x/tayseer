import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/shared/network/local_network.dart';
import 'package:tayseer/core/utils/simple_bloc_observer.dart';
import 'package:tayseer/tayser_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await CachNetwork.cacheInitializaion();
  await setupGetIt();
  Bloc.observer = SimpleBlocObserver();
  runApp(const tayseerApp());
}
