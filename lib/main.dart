import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';

void main() {
  runApp(const GeoFenceApp());
}

class GeoFenceApp extends StatefulWidget {
  const GeoFenceApp({Key? key}) : super(key: key);

  @override
  _GeoFenceAppState createState() => _GeoFenceAppState();
}

class _GeoFenceAppState extends State<GeoFenceApp> {
  final _activityStreamController = StreamController<Activity>();
  final _geofenceStreamController = StreamController<Geofence>();

  // Create a [GeofenceService] instance and set options.
  final _geofenceService = GeofenceService.instance.setup(
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      useActivityRecognition: true,
      allowMockLocations: true,
      printDevLog: false,
      geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

  // Create a [Geofence] list.
  final _geofenceList = <Geofence>[
    Geofence(
      id: 'USP_Library',
      latitude: -18.149084,
      longitude: 178.444460,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
      ],
    ),
    Geofence(
      id: 'Dining_Hall',
      latitude: -18.149551,
      longitude: 178.443569,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
      ],
    ),
    Geofence(
      id: 'Book_Centre',
      latitude: -18.150553,
      longitude: 178.443979,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
      ],
    ),
    Geofence(
      id: 'USP_Student_Association',
      latitude: -18.149793,
      longitude: 178.443947,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
      ],
    ),
    Geofence(
      id: 'USP_Health_Centre',
      latitude: -18.150113,
      longitude: 178.443635,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
      ],
    ),
    Geofence(
      id: 'USP_Westpac_Branch',
      latitude: -18.150471,
      longitude: 178.443455,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
      ],
    ),
    Geofence(
      id: 'USP_SPACE_Building',
      latitude: -18.150143,
      longitude: 178.444556,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
      ],
    ),
    Geofence(
      id: 'USP_SAFE_Rooms',
      latitude: -18.150941,
      longitude: 178.445447,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
      ],
    ),
    Geofence(
      id: 'USP_SBM_Rooms',
      latitude: -18.150498,
      longitude: 178.445878,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
      ],
    ),
    Geofence(
      id: 'USP_ICT_Centre',
      latitude: -18.148071,
      longitude: 178.443253,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
      ],
    ),
    Geofence(
      id: 'USP_Science_Building',
      latitude: -18.149400,
      longitude: 178.446181,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
      ],
    ),
    Geofence(
      id: 'USP_Fitness_Centre',
      latitude: -18.149242,
      longitude: 178.447096,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
      ],
    ),
    Geofence(
      id: 'AUSAID_Lecture_Theatre',
      latitude: -18.148310,
      longitude: 178.445751,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
      ],
    ),
    Geofence(
      id: 'USP_Main_Admin_Building',
      latitude: -18.148071,
      longitude: 178.444665,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
      ],
    ),
  ];

  // This function is to be called when the geofence status is changed.
  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    print('geofence: ${geofence.toJson()}');
    print('geofenceRadius: ${geofenceRadius.toJson()}');
    print('geofenceStatus: ${geofenceStatus.toString()}');
    _geofenceStreamController.sink.add(geofence);
  }

  // This function is to be called when the activity has changed.
  void _onActivityChanged(Activity prevActivity, Activity currActivity) {
    print('prevActivity: ${prevActivity.toJson()}');
    print('currActivity: ${currActivity.toJson()}');
    _activityStreamController.sink.add(currActivity);
  }

  // This function is to be called when the location has changed.
  void _onLocationChanged(Location location) {
    print('location: ${location.toJson()}');
  }

  // This function is to be called when a location services status change occurs
  // since the service was started.
  void _onLocationServicesStatusChanged(bool status) {
    print('isLocationServicesEnabled: $status');
  }

  // This function is used to handle errors that occur in the service.
  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }

    print('ErrorCode: $errorCode');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      _geofenceService.addLocationChangeListener(_onLocationChanged);
      _geofenceService.addLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
      _geofenceService.addActivityChangeListener(_onActivityChanged);
      _geofenceService.addStreamErrorListener(_onError);
      _geofenceService.start(_geofenceList).catchError(_onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // A widget used when you want to start a foreground task when trying to minimize or close the app.
      // Declare on top of the [Scaffold] widget.
      home: WillStartForegroundTask(
        onWillStart: () async {
          // You can add a foreground task start condition.
          return _geofenceService.isRunningService;
        },
        foregroundTaskOptions: const ForegroundTaskOptions(
          interval: 5000,
          autoRunOnBoot: false,
          allowWifiLock: true,
        ),
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'geofence_service_notification_channel',
          channelName: 'Geofence Service Notification',
          channelDescription: 'This notification appears when the geofence service is running in the background.',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          isSticky: false,
        ),
        iosNotificationOptions: const IOSNotificationOptions(),
        notificationTitle: 'Geofence Service is running',
        notificationText: 'Tap to return to the app',
        child: Scaffold(
          appBar: AppBar(
            title: const Text('CS427 Geofence App'),
            centerTitle: true,
          ),
          body: _buildContentView(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _activityStreamController.close();
    _geofenceStreamController.close();
    super.dispose();
  }

  Widget _buildContentView() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      children: [
        _buildActivityMonitor(),
        const SizedBox(height: 20.0, width: double.infinity),
        _buildGeofenceMonitor(),
      ],
    );
  }

  Widget _buildActivityMonitor() {
    return StreamBuilder<Activity>(
      stream: _activityStreamController.stream,
      builder: (context, snapshot) {
        final updatedDateTime = DateTime.now();
        final content = snapshot.data?.toJson().toString() ?? '';

        return Container(
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [BoxShadow(blurRadius: 5.0, color: Colors.black38, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•\t\tCurrent Location Activity (updated: $updatedDateTime)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20.0, width: double.infinity),
              Text(content),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGeofenceMonitor() {
    return StreamBuilder<Geofence>(
      stream: _geofenceStreamController.stream,
      builder: (context, snapshot) {
        final updatedDateTime = DateTime.now();
        final content = snapshot.data?.toJson().toString() ?? '';

        return Container(
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [BoxShadow(blurRadius: 5.0, color: Colors.black38, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•\t\tGeofence Detected (updated: $updatedDateTime)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20.0, width: double.infinity),
              Text(content),
            ],
          ),
        );
      },
    );
  }
}
