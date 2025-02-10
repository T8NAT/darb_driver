import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_driver/pages/onTripPage/map_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import 'package:http/http.dart' as http;
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../language/languages.dart';
import '../login/landingpage.dart';
import '../login/login.dart';
import '../login/requiredinformation.dart';
import '../noInternet/nointernet.dart';
import '../onTripPage/rides.dart';
import 'loading.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

dynamic package;

class _LoadingPageState extends State<LoadingPage> {
  String dot = '.';
  bool updateAvailable = false;
  dynamic _package;
  dynamic _version;
  bool _error = false;
  bool _isLoading = false;
  bool _gifLoaded = false;
  Widget? nextPage;

  var demopage = TextEditingController();

  //navigate
  navigate() {
    print('userDetailsuserDetailsuserDetails $userDetails');
    if (userDetails['uploaded_document'] == true &&
        userDetails['approve'] == true) {
      //status approved
      if (userDetails['role'] != 'owner' &&
          userDetails['enable_bidding'] == true) {
        nextPage = RidePage();


      } else if (userDetails['role'] != 'owner' &&
          userDetails['enable_bidding'] == false) {

        nextPage = Maps();
      } else {
        nextPage = Maps();

      }
    } else {
      nextPage = RequiredInformation();
    }
  }

  @override
  void initState() {
    getLanguageDone();
    getOwnermodule();
    getLandingImages();
    super.initState();
  }

  getData() async {
    for (var i = 0; _error == true; i++) {
      await getLanguageDone();
    }
  }

//get language json and data saved in local (bearer token , choosen language) and find users current status
  getLanguageDone() async {
    _package = await PackageInfo.fromPlatform();
    try {
      if (platform == TargetPlatform.android) {
        _version = await FirebaseDatabase.instance
            .ref()
            .child('driver_android_version')
            .get();
      } else {
        _version = await FirebaseDatabase.instance
            .ref()
            .child('driver_ios_version')
            .get();
      }
      _error = false;
      if (_version.value != null) {
        var version = _version.value.toString().split('.');
        var package = _package.version.toString().split('.');

        for (var i = 0; i < version.length || i < package.length; i++) {
          if (i < version.length && i < package.length) {
            if (int.parse(package[i]) < int.parse(version[i])) {
              setState(() {
                updateAvailable = true;
              });
              break;
            } else if (int.parse(package[i]) > int.parse(version[i])) {
              setState(() {
                updateAvailable = false;
              });
              break;
            }
          } else if (i >= version.length && i < package.length) {
            setState(() {
              updateAvailable = false;
            });
            break;
          } else if (i < version.length && i >= package.length) {
            setState(() {
              updateAvailable = true;
            });
            break;
          }
        }
      }



      if (updateAvailable == false) {
        await getDetailsOfDevice();
        if (internet == true) {
          var val = await getLocalData();

          //if user is login and check waiting for approval status and send accordingly
          if (val == '3') {
            navigate();
          } else if (choosenLanguage == '') {
            // ignore: use_build_context_synchronously
            nextPage = Languages();
          } else if (val == '2') {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (ownermodule == '1') {
                nextPage = LandingPage();

              } else {
                ischeckownerordriver = 'driver';
                nextPage = Login();

              }
            });
          } else {
            nextPage = Languages();

          }
          setState(() {});
        }
      }
      if(updateAvailable)return;


      if (_gifLoaded) {
        if(nextPage!=null){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextPage!));

        }else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoadingPage()));
        }
      }

    } catch (e) {
      if (internet == true) {
        if (_error == false) {
          setState(() {
            _error = true;
          });
          getData();
        }
      } else {
        setState(() {});
      }
    }
  }

  void onGifLoaded() {
    if (!_gifLoaded) {
      _gifLoaded = true;
      if (nextPage == null) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextPage!));
    }
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/videos/splash.gif',
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.fill,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (frame == 145) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    onGifLoaded();
                  });
                }
                return child;
              },
            ),

            //update available

            (updateAvailable == true)
                ? Positioned(
                top: 0,
                bottom: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: media.width * 0.9,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: page,
                            ),
                            margin: EdgeInsets.all(media.width * 0.05),
                            padding: EdgeInsets.all(media.width * 0.05),
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/logo.png',
                                  height: 100,
                                ),
                                MyText(
                                  text: languages[choosenLanguage]?['new_version_available'] ?? 'تحديث جديد متوفر',
                                  size: media.width * sixteen,
                                  fontweight: FontWeight.w600,
                                ),
                                SizedBox(
                                  height: media.width * 0.02,
                                ),

                                MyText(
                                  text: languages[choosenLanguage]?['update_message'] ?? 'هناك تحديث جديد في المتجر، يرجى تحديثه لاستخدام الميزات الجديدة',
                                  size: media.width * fifteen,
                                  textAlign: TextAlign.start,
                                  fontweight: FontWeight.w500,

                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Button(
                                    onTap: () async {
                                      if (platform ==
                                          TargetPlatform.android) {
                                        openBrowser(
                                            'https://play.google.com/store/apps/details?id=${_package.packageName}');
                                      } else {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        var response = await http.get(Uri.parse(
                                            'http://itunes.apple.com/lookup?bundleId=${_package.packageName}'));
                                        if (response.statusCode == 200) {
                                          openBrowser(jsonDecode(
                                                  response.body)['results'][0]
                                              ['trackViewUrl']);
                                        }

                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    },
                                  text: languages[choosenLanguage]?['update'] ?? 'تحديث',
                                )
                              ],
                            ))
                      ],
                    ))
                : Container(),
            //internet is not connected
            (internet == false)
                ? Positioned(
                    top: 0,
                    child: NoInternet(
                      onTap: () {
                        //try again
                        setState(() {
                          internetTrue();
                          getLanguageDone();
                        });
                      },
                    ))
                : Container(),

            //loader
            (_isLoading == true && internet == true)
                ? const Positioned(top: 0, child: Loading())
                : Container(),
          ],
        ),
      ),
    );
  }
}
