
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: MyHomePage(title: 'Flutter Permission Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future<void> requestPhotosAndCameraPermission () async{
    print('request send ...');
    Map<Permission, PermissionStatus> statues = await [
      Permission.camera,
      Permission.photos
    ].request();

    print('camera = ${statues[Permission.camera]}');
    print('photos = ${statues[Permission.photos]}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: Permission.values
              .where((permission) {
              if (Platform.isIOS) {
                return permission != Permission.unknown &&
                    permission != Permission.sms &&
                    permission != Permission.storage &&
                    permission != Permission.photos &&
                    permission != Permission.camera &&
                    permission != Permission.ignoreBatteryOptimizations &&
                    permission != Permission.accessMediaLocation &&
                    permission != Permission.activityRecognition &&
                    permission != Permission.manageExternalStorage &&
                    permission != Permission.systemAlertWindow &&
                    permission != Permission.requestInstallPackages &&
                    permission != Permission.accessNotificationPolicy;

              } else {
                return permission != Permission.unknown &&
                    permission != Permission.mediaLibrary &&
                    permission != Permission.photos &&
                    permission != Permission.camera &&
                    permission != Permission.photosAddOnly &&
                    permission != Permission.reminders &&
                    permission != Permission.appTrackingTransparency &&
                    permission != Permission.criticalAlerts;
              }
          }).map((permission) => PermissionWidget(permission)).toList()
              
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: requestPhotosAndCameraPermission,
        tooltip: 'Increment',
        child: Icon(Icons.camera),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class PermissionWidget extends StatefulWidget {
  const PermissionWidget(this._permission);

  final Permission _permission;
  @override
  _PermissionState createState() => _PermissionState(_permission);
}

class _PermissionState extends State<PermissionWidget> {
  _PermissionState(this._permission);

  final Permission _permission;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {

    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }

  Color getPermissionColor() {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return Colors.red;
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.limited:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        _permission.toString(),
        style: Theme.of(context).textTheme.bodyText1,
      ),
      subtitle: Text(
        _permissionStatus.toString(),
        style: TextStyle(color: getPermissionColor()),
      ),
      trailing: (_permission is PermissionWithService)
          ? IconButton(
          icon: const Icon(
            Icons.info,
            color: Colors.white,
          ),
          onPressed: () {
            checkServiceStatus(
                context, _permission as PermissionWithService);
          })
          : null,
      onTap: () {
        requestPermission(_permission);
      },
    );
  }

  void checkServiceStatus(
      BuildContext context, PermissionWithService permission) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text((await permission.serviceStatus).toString()),
    ));
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }
}

