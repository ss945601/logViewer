import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:latticework/bloc/app_bloc.dart';
import 'package:latticework/page/file_browser.dart';
import 'package:latticework/page/log_analysis_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latticework/page/virtual_amber_page.dart';

void main() {
  runApp(GetMaterialApp(
    home: MyApp(),
    builder: EasyLoading.init(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Log Tool'),
              onTap: () {
                appBloc.switchPageSink.add(PageName.logPage);
                Navigator.pop(context);
              },
            ),
            if (!kIsWeb)
              ListTile(
                title: Text('Arb Tool'),
                onTap: () {
                  appBloc.switchPageSink.add(PageName.arbPage);
                  Navigator.pop(context);
                },
              ),
            if (!kIsWeb)
              ListTile(
                title: Text('virtual amber Tool'),
                onTap: () {
                  appBloc.switchPageSink.add(PageName.virtualAmberPage);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
      body: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({
    super.key,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Widget arbPage = FileBrowserPage();
  final Widget logPage = LogAnalysisPage();
  final Widget virtualAmberPage = VirtualAmberPage();
  late Widget currentPage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentPage = logPage;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: appBloc.switchPageStream,
        builder: (context, page) {
          switch (page.data ?? "") {
            case PageName.arbPage:
              currentPage = arbPage;
              break;
            case PageName.logPage:
              currentPage = logPage;
              break;
            case PageName.virtualAmberPage:
              currentPage = virtualAmberPage;
              break;
            default:
              currentPage = logPage;
              break;
          }
          return currentPage;
        });
  }
}
