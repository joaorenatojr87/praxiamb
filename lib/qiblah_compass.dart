import 'dart:async';
import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'flutter_qiblah.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';

import 'loading_indicator.dart';
import 'location_error_widget.dart';
import 'utils.dart';

class QiblahCompass extends StatefulWidget {
  @override
  _QiblahCompassState createState() => _QiblahCompassState();
}

class _QiblahCompassState extends State<QiblahCompass> {
  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();

  get stream => _locationStreamController.stream;

  @override
  void initState() {
    _checkLocationStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: stream,
        builder: (context, AsyncSnapshot<LocationStatus> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return LoadingIndicator();
          if (snapshot.data.enabled == true) {
            switch (snapshot.data.status) {
              case LocationPermission.always:
              case LocationPermission.whileInUse:
                return QiblahCompassWidget();

              case LocationPermission.denied:
                return LocationErrorWidget(
                  error: "Location service permission denied",
                  callback: _checkLocationStatus,
                );
              case LocationPermission.deniedForever:
                return LocationErrorWidget(
                  error: "Location service Denied Forever !",
                  callback: _checkLocationStatus,
                );
              // case GeolocationStatus.unknown:
              //   return LocationErrorWidget(
              //     error: "Unknown Location service error",
              //     callback: _checkLocationStatus,
              //   );
              default:
                return Container();
            }
          } else {
            return LocationErrorWidget(
              error: "Please enable Location service",
              callback: _checkLocationStatus,
            );
          }
        },
      ),
    );
  }

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled &&
        locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final s = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(s);
    } else
      _locationStreamController.sink.add(locationStatus);
  }

  @override
  void dispose() {
    super.dispose();
    _locationStreamController.close();
    FlutterQiblah().dispose();
  }
}

class QiblahCompassWidget extends StatefulWidget {
  @override
  _QiblahCompassWidget createState() => _QiblahCompassWidget();
}

class _QiblahCompassWidget extends State<QiblahCompassWidget> {
  Position userLocation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocation().then((position) {
      userLocation = position;
    });
  }

  final _compassSvg = SvgPicture.asset('assets/compass.svg');
  final _needleSvg = SvgPicture.asset(
    'assets/needle.svg',
    fit: BoxFit.contain,
    height: 300,
    alignment: Alignment.center,
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return LoadingIndicator();

        final qiblahDirection = snapshot.data;

        return Scaffold(
          body: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Transform.rotate(
                angle: ((qiblahDirection.direction ?? 0) * (pi / 180) * -1),
                child: _compassSvg,
              ),
              Transform.rotate(
                angle: ((qiblahDirection.qiblah ?? 0) * (pi / 180) * -1),
                alignment: Alignment.center,
                child: _needleSvg,
              ),
              Positioned(
                bottom: 8,
                child: Text(
                    "Graus em relação ao norte: ${qiblahDirection.offset.toStringAsFixed(3)}°"),
              ),
              Positioned(
                  top: 0,
                  child: Text("Sua posição atual: " +
                      userLocation.latitude.toString() +
                      " " +
                      userLocation.longitude.toString())),
              Positioned(
                  top: 20,
                  child: Text("Posição do elemento: " +
                      Utils.elemLat.toString() +
                      " " +
                      Utils.elemLong.toString())),
              Positioned(
                  top: 80, child: Text("A AGULHA APONTA PARA O ELEMENTO")),
              Positioned(
                  top: 95, child: Text("O COMPASSO APONTA PARA O NORTE")),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _getLocation().then((value) {
                setState(() {
                  userLocation = value;
                });
              });
            },
            tooltip: 'Atualiza posição corrente',
            child: Icon(
              Icons.my_location_sharp,
            ),
          ),
        );
      },
    );
  }
}

Future<Position> _getLocation() async {
  var currentLocation;
  try {
    currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  } catch (e) {
    currentLocation = null;
  }
  return currentLocation;
}
