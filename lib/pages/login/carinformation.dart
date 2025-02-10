import 'dart:ui';



import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/pages/NavigatorPages/managevehicles.dart';
import 'package:flutter_driver/pages/login/landingpage.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jhijri_picker/_src/_jWidgets.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../login/login.dart';
import '../noInternet/nointernet.dart';
import 'requiredinformation.dart';

// ignore: must_be_immutable
class CarInformation extends StatefulWidget {
  int? frompage;

  CarInformation({this.frompage, Key? key}) : super(key: key);

  @override
  State<CarInformation> createState() => _CarInformationState();
}

bool isowner = false;
dynamic myVehicalType;
dynamic myVehicleIconFor = '';
List vehicletypelist = [];
dynamic vehicleColor;

dynamic identityNumber = '';
dynamic sequenceNumber = '';
dynamic dateOfBirthGregorian = '';
dynamic dateOfBirthHijri = '';

dynamic myServiceLocation;
dynamic myServiceId;
String vehicleModelId = '';
dynamic vehicleModelName;
dynamic modelYear;
String vehicleMakeId = '';
dynamic vehicleNumber;
dynamic vehicleMakeName;
String myVehicleId = '';
String mycustommake = '';
String mycustommodel = '';
List choosevehicletypelist = [];
List choosevehicletypelistlocal = [];

List chooseVdhiType = [
  {'name': 'vehicle type', 'list': []}
];

class _CarInformationState extends State<CarInformation> {
  JPickerValue? selectedDate;
  bool loaded = false;
  bool chooseWorkArea = false;
  bool _isLoading = false;
  String _error = '';
  bool chooseVehicleMake = false;
  bool chooseVehicleModel = false;
  bool chooseVehicleType = false;
  String dateError = '';
  bool vehicleAdded = false;
  String uploadError = '';
  bool iscustommake = false;
  dynamic tempServiceLocationId;
  dynamic tempVehicleMakeId;
  dynamic tempVehicleModelId;
  TextEditingController modelcontroller = TextEditingController();
  TextEditingController colorcontroller = TextEditingController();

  // TextEditingController _numberController = TextEditingController();
  TextEditingController referralcontroller = TextEditingController();
  TextEditingController sequenceController = TextEditingController();
  TextEditingController identifierController = TextEditingController();
  TextEditingController custommakecontroller = TextEditingController();
  TextEditingController custommodelcontroller = TextEditingController();
  double isbottom = -1000;
  bool serviceConfirmed = false;
  bool vehicleConfirmed = false;
  bool makeConfirmed = false;
  bool modelConfirmed = false;

  void _setupArabicToEnglishListener() {
    // Add a listener to replace Arabic numerals with English numerals
    _numberController.addListener(() {
      final text = _numberController.text;
      final convertedText = _convertArabicToEnglish(text);

      // Update the text field with the converted text if it has Arabic numerals
      if (text != convertedText) {
        _numberController.value = TextEditingValue(
          text: convertedText,
          selection: TextSelection.collapsed(offset: convertedText.length),
        );
      }
    });
  }

  String _convertArabicToEnglish(String input) {
    return input
        .replaceAll('٠', '0')
        .replaceAll('١', '1')
        .replaceAll('٢', '2')
        .replaceAll('٣', '3')
        .replaceAll('٤', '4')
        .replaceAll('٥', '5')
        .replaceAll('٦', '6')
        .replaceAll('٧', '7')
        .replaceAll('٨', '8')
        .replaceAll('٩', '9');
  }

  //navigate
  navigate() {
    Navigator.pop(context, true);
    serviceLocations.clear();
    vehicleMake.clear();
    vehicleModel.clear();
    vehicleType.clear();
  }

  navigateref() {
    Navigator.pop(context, true);
  }

  navigateLogout() {
    if (ownermodule == '1') {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LandingPage()),
            (route) => false);
      });
    } else {
      ischeckownerordriver = 'driver';
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
            (route) => false);
      });
    }
  }

  final TextEditingController _numberController = TextEditingController();
  final List<TextEditingController> _letterControllers =
      List.generate(3, (_) => TextEditingController());
  String formattedVehicleNumber = '';

  @override
  void initState() {
    getServiceLoc();
    _setupFormattingListener();
    _setupArabicToEnglishListener();
    super.initState();
  }

  void _setupFormattingListener() {
    void _updateFormattedVehicleNumber() {
      final letters =
          _letterControllers.map((controller) => controller.text).join();
      final numbers = _numberController.text;
      print('lettersletters $letters');
      print('lettersletters $numbers');
      print('vehicleNumber $vehicleNumber');
      setState(() {
        vehicleNumber = '$letters$numbers';
      });
    }

    // Add listeners to all controllers
    _numberController.addListener(_updateFormattedVehicleNumber);
    for (final controller in _letterControllers) {
      controller.addListener(_updateFormattedVehicleNumber);
    }
  }

//get service loc data
  getServiceLoc() async {
    choosevehicletypelist.clear();
    vehicletypelist.clear();
    myServiceId = '';
    myServiceLocation = '';
    vehicleMakeId = '';
    vehicleModelId = '';
    myVehicleId = '';
    mycustommake = '';
    mycustommodel = '';
    vehicletypelist = [];
    // ignore: unused_local_variable, prefer_typing_uninitialized_variables
    var result;
    if (isowner == true) {
      await getvehicleType();
    } else {
      if (enabledModule == 'both') {
        transportType = '';
      }
      result = await getServiceLocation();
    }

    if (mounted) {
      setState(() {
        loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/carinfo.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Positioned(
                  child: Container(
                color: Colors.transparent.withOpacity(0.2),
                padding: EdgeInsets.all(media.width * 0.05),
                height: media.height,
                width: media.width,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).padding.top,
                    ),
                    SizedBox(
                      width: media.width * 0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(media.width * 0.05),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: media.width * 0.11,
                                  width: media.width * 0.11,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 0.5),
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(0.17)),
                                  child: Icon(
                                    Icons.arrow_back,
                                    size: media.width * 0.05,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(media.width * 0.05),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                              child: Container(
                                width: media.width * 0.6,
                                height: media.width * 0.11,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white, width: 0.5),
                                    borderRadius: BorderRadius.circular(
                                        (media.width * 0.11) / 2),
                                    color: Colors.black.withOpacity(0.17)),
                                alignment: Alignment.center,
                                child: MyText(
                                  text: languages[choosenLanguage]
                                      ['text_car_info'],
                                  size: media.width * sixteen,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: media.width * 0.05,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    Expanded(
                        child: ClipRRect(
                      borderRadius: BorderRadius.circular(media.width * 0.05),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                        child: Container(
                          width: media.width * 0.9,
                          padding: EdgeInsets.only(
                              left: media.width * 0.05,
                              right: media.width * 0.05),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white, width: 0.5),
                              borderRadius: BorderRadius.circular(
                                  (media.width * 0.11) / 2),
                              color: Colors.black.withOpacity(0.17)),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                if (isowner == false)
                                  Column(
                                    children: [
                                      if (enabledModule == 'both')
                                        Column(
                                          children: [
                                            SizedBox(
                                              height: media.width * 0.05,
                                            ),
                                            SizedBox(
                                                width: media.width * 0.8,
                                                child: MyText(
                                                  text:
                                                      languages[choosenLanguage]
                                                          ['text_register_for'],
                                                  size: media.width * fourteen,
                                                  fontweight: FontWeight.w600,
                                                  maxLines: 1,
                                                  color: whiteText,
                                                )),
                                            SizedBox(
                                              height: media.height * 0.012,
                                            ),
                                            SizedBox(
                                              width: media.width * 0.8,
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: media.width *
                                                              0.025,
                                                          right: media.width *
                                                              0.01),
                                                      width: media.width * 0.25,
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            transportType =
                                                                'taxi';
                                                            myVehicleId = '';
                                                            vehicleMakeId = '';
                                                            vehicleModelId = '';
                                                            myServiceId = '';
                                                            choosevehicletypelist
                                                                .clear();
                                                            _numberController
                                                                .clear();
                                                            _letterControllers
                                                                .map((e) =>
                                                                    e.clear());

                                                            colorcontroller
                                                                .clear();
                                                            modelcontroller
                                                                .clear();
                                                            referralcontroller
                                                                .clear();
                                                          });
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              height:
                                                                  media.width *
                                                                      0.05,
                                                              width:
                                                                  media.width *
                                                                      0.05,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color:
                                                                          whiteText,
                                                                      width:
                                                                          1.2)),
                                                              child: (transportType ==
                                                                      'taxi')
                                                                  ? Center(
                                                                      child:
                                                                          Icon(
                                                                      Icons
                                                                          .done,
                                                                      color:
                                                                          whiteText,
                                                                      size: media
                                                                              .width *
                                                                          0.04,
                                                                    ))
                                                                  : Container(),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.025,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.15,
                                                              child: MyText(
                                                                text: languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_taxi_'],
                                                                size: media
                                                                        .width *
                                                                    fourteen,
                                                                fontweight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    whiteText,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: media.width *
                                                              0.025,
                                                          right: media.width *
                                                              0.01),
                                                      width: media.width * 0.3,
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            transportType =
                                                                'delivery';
                                                            myVehicleId = '';

                                                            vehicleMakeId = '';
                                                            vehicleModelId = '';
                                                            myServiceId = '';
                                                            choosevehicletypelist
                                                                .clear();
                                                            _numberController
                                                                .clear();
                                                            _letterControllers
                                                                .map((e) =>
                                                                    e.clear());
                                                            colorcontroller
                                                                .clear();
                                                            modelcontroller
                                                                .clear();
                                                            referralcontroller
                                                                .clear();
                                                          });
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              height:
                                                                  media.width *
                                                                      0.05,
                                                              width:
                                                                  media.width *
                                                                      0.05,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color:
                                                                          whiteText,
                                                                      width:
                                                                          1.2)),
                                                              child: (transportType ==
                                                                      'delivery')
                                                                  ? Center(
                                                                      child:
                                                                          Icon(
                                                                      Icons
                                                                          .done,
                                                                      color:
                                                                          whiteText,
                                                                      size: media
                                                                              .width *
                                                                          0.04,
                                                                    ))
                                                                  : Container(),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.025,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.18,
                                                              child: MyText(
                                                                text: languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_delivery'],
                                                                size: media
                                                                        .width *
                                                                    fourteen,
                                                                fontweight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    whiteText,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: media.width *
                                                              0.025,
                                                          right: media.width *
                                                              0.01),
                                                      width: media.width * 0.25,
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            transportType =
                                                                'both';
                                                            myVehicleId = '';
                                                            vehicleMakeId = '';
                                                            vehicleModelId = '';
                                                            myServiceId = '';
                                                            choosevehicletypelist
                                                                .clear();
                                                            _numberController
                                                                .clear();
                                                            _letterControllers
                                                                .map((e) =>
                                                                    e.clear());
                                                            colorcontroller
                                                                .clear();
                                                            modelcontroller
                                                                .clear();
                                                            referralcontroller
                                                                .clear();
                                                          });
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              height:
                                                                  media.width *
                                                                      0.05,
                                                              width:
                                                                  media.width *
                                                                      0.05,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color:
                                                                          whiteText,
                                                                      width:
                                                                          1.2)),
                                                              child: (transportType ==
                                                                      'both')
                                                                  ? Center(
                                                                      child:
                                                                          Icon(
                                                                      Icons
                                                                          .done,
                                                                      color:
                                                                          whiteText,
                                                                      size: media
                                                                              .width *
                                                                          0.04,
                                                                    ))
                                                                  : Container(),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.025,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.15,
                                                              child: MyText(
                                                                text: languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_both'],
                                                                size: media
                                                                        .width *
                                                                    fourteen,
                                                                fontweight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    whiteText,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      SizedBox(
                                          width: media.width * 0.8,
                                          child: MyText(
                                            text: languages[choosenLanguage]
                                                ['text_service_location'],
                                            size: media.width * fourteen,
                                            fontweight: FontWeight.w600,
                                            maxLines: 2,
                                            color: whiteText,
                                          )),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (transportType != '' ||
                                              enabledModule != 'both') {
                                            tempServiceLocationId = myServiceId;
                                            serviceConfirmed = false;
                                            await showModalBottomSheet(
                                                context: context,
                                                builder: (builder) {
                                                  return StatefulBuilder(
                                                      builder:
                                                          (BuildContext context,
                                                              setState) {
                                                    return Container(
                                                      padding: EdgeInsets.all(
                                                          media.width * 0.05),
                                                      width: media.width,
                                                      decoration: BoxDecoration(
                                                          color: page,
                                                          borderRadius: BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      media.width *
                                                                          0.05),
                                                              topRight: Radius
                                                                  .circular(media
                                                                          .width *
                                                                      0.05))),
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            width: media.width *
                                                                0.9,
                                                            child: MyText(
                                                              text: languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_service_loc'],
                                                              size:
                                                                  media.width *
                                                                      sixteen,
                                                              fontweight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          Expanded(
                                                              child:
                                                                  SingleChildScrollView(
                                                            child: Column(
                                                              children:
                                                                  serviceLocations
                                                                      .asMap()
                                                                      .map((k,
                                                                              value) =>
                                                                          MapEntry(
                                                                              k,
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    tempServiceLocationId = serviceLocations[k]['id'];
                                                                                  });
                                                                                },
                                                                                child: Container(
                                                                                  padding: EdgeInsets.all(media.width * 0.05),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Container(
                                                                                        width: media.width * 0.05,
                                                                                        height: media.width * 0.05,
                                                                                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1, color: theme)),
                                                                                        alignment: Alignment.center,
                                                                                        child: (tempServiceLocationId == serviceLocations[k]['id'])
                                                                                            ? Container(
                                                                                                width: media.width * 0.025,
                                                                                                height: media.width * 0.025,
                                                                                                decoration: BoxDecoration(shape: BoxShape.circle, color: theme),
                                                                                              )
                                                                                            : Container(),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        width: media.width * 0.025,
                                                                                      ),
                                                                                      Expanded(child: MyText(text: serviceLocations[k]['name'], size: media.width * sixteen)),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              )))
                                                                      .values
                                                                      .toList(),
                                                            ),
                                                          )),
                                                          Button(
                                                              onTap: () {
                                                                // setState((){
                                                                //           myServiceId =
                                                                // tempServiceLocationId;
                                                                // });
                                                                serviceConfirmed =
                                                                    true;
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              text: languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_confirm'])
                                                        ],
                                                      ),
                                                    );
                                                  });
                                                });
                                            if (myServiceId !=
                                                    tempServiceLocationId &&
                                                serviceConfirmed == true) {
                                              myServiceId =
                                                  tempServiceLocationId;
                                              setState(() {
                                                _error = '';

                                                _isLoading = true;
                                              });
                                              var result =
                                                  await getvehicleType();
                                              if (result != 'success') {
                                                _error = result;
                                              } else {
                                                choosevehicletypelist.clear();
                                                mycustommake = '';
                                                mycustommodel = '';
                                                vehicleMakeId = '';
                                                vehicleModelId = '';
                                              }

                                              setState(() {
                                                _isLoading = false;
                                              });
                                            }
                                          }
                                        },
                                        child: Container(
                                          height: media.width * 0.13,
                                          width: media.width * 0.8,
                                          decoration: BoxDecoration(
                                            color: (transportType != '' ||
                                                    enabledModule != 'both')
                                                ? Colors.transparent
                                                : const Color(0xFFD9D9D9)
                                                    .withOpacity(0.31),
                                            borderRadius: BorderRadius.circular(
                                                media.width * 0.01),
                                            border:
                                                Border.all(color: whiteText),
                                          ),
                                          padding: EdgeInsets.only(
                                              left: media.width * 0.05,
                                              right: media.width * 0.05),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                // width: media.width * 0.7,
                                                child: MyText(
                                                    text: (widget.frompage ==
                                                                1 &&
                                                            myServiceId == '')
                                                        ? languages[
                                                                choosenLanguage]
                                                            ['text_service_loc']
                                                        : (myServiceId !=
                                                                    null &&
                                                                myServiceId !=
                                                                    '')
                                                            ? serviceLocations
                                                                    .isNotEmpty
                                                                ? serviceLocations
                                                                    .firstWhere(
                                                                        (element) =>
                                                                            element['id'] ==
                                                                            myServiceId)[
                                                                        'name']
                                                                    .toString()
                                                                : ''
                                                            : userDetails[
                                                                'service_location_name'],
                                                    size:
                                                        media.width * fourteen,
                                                    color: (widget.frompage ==
                                                                1 &&
                                                            myServiceId == '')
                                                        ? whiteText
                                                        : whiteText),
                                              ),
                                              Icon(
                                                (transportType != '' ||
                                                        enabledModule != 'both')
                                                    ? Icons.keyboard_arrow_down
                                                    : Icons
                                                        .lock_outline_rounded,
                                                size: media.width * 0.05,
                                                color: whiteText,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                SizedBox(
                                  width: media.width * 0.8,
                                  child: MyText(
                                    text: languages[choosenLanguage]
                                        ['text_vehicle_type'],
                                    size: media.width * fifteen,
                                    fontweight: FontWeight.w500,
                                    color: whiteText,
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                InkWell(
                                  onTap: () async {
                                    if (myServiceId != '') {
                                      vehicleConfirmed = false;
                                      choosevehicletypelistlocal.clear();
                                      for (var element
                                          in choosevehicletypelist) {
                                        choosevehicletypelistlocal.add(element);
                                      }
                                      await showModalBottomSheet(
                                          context: context,
                                          builder: (builder) {
                                            return StatefulBuilder(builder:
                                                (BuildContext context,
                                                    setState) {
                                              return Container(
                                                padding: EdgeInsets.all(
                                                    media.width * 0.05),
                                                width: media.width,
                                                decoration: BoxDecoration(
                                                    color: page,
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topLeft: Radius
                                                                .circular(media
                                                                        .width *
                                                                    0.05),
                                                            topRight: Radius
                                                                .circular(media
                                                                        .width *
                                                                    0.05))),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      width: media.width * 0.9,
                                                      child: MyText(
                                                        text: languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_vehicle_type'],
                                                        size: media.width *
                                                            sixteen,
                                                        fontweight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child:
                                                            SingleChildScrollView(
                                                      child: Column(
                                                        children: vehicleType
                                                            .asMap()
                                                            .map(
                                                                (k, value) =>
                                                                    MapEntry(
                                                                        k,
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            if (choosevehicletypelistlocal.isEmpty) {
                                                                              choosevehicletypelistlocal.add(vehicleType[k]);
                                                                            } else {
                                                                              choosevehicletypelistlocal = [];
                                                                              choosevehicletypelistlocal.add(vehicleType[k]);
                                                                            }
                                                                            setState(() {});
                                                                            // printWrapped(choosevehicletypelistlocal.toString());
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                EdgeInsets.all(media.width * 0.025),
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                if (vehicleType[k]['icon'] != null)
                                                                                  Image.network(
                                                                                    vehicleType[k]['icon'].toString(),
                                                                                    fit: BoxFit.contain,
                                                                                    width: media.width * 0.1,
                                                                                    height: media.width * 0.08,
                                                                                  ),
                                                                                const SizedBox(
                                                                                  width: 10,
                                                                                ),
                                                                                Expanded(
                                                                                    child: MyText(
                                                                                  text: vehicleType[k]['name'],
                                                                                  size: media.width * fourteen,
                                                                                )),
                                                                                const SizedBox(
                                                                                  width: 10,
                                                                                ),
                                                                                Container(
                                                                                  height: media.width * 0.05,
                                                                                  width: media.width * 0.05,
                                                                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1, color: theme)),
                                                                                  alignment: Alignment.center,
                                                                                  child: (choosevehicletypelistlocal.contains(vehicleType[k]))
                                                                                      ? Container(
                                                                                          width: media.width * 0.025,
                                                                                          height: media.width * 0.025,
                                                                                          decoration: BoxDecoration(shape: BoxShape.circle, color: theme),
                                                                                        )
                                                                                      : Container(),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        )))
                                                            .values
                                                            .toList(),
                                                      ),
                                                    )),
                                                    Button(
                                                        onTap: () {
                                                          vehicleConfirmed =
                                                              true;
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        text: languages[
                                                                choosenLanguage]
                                                            ['text_confirm'])
                                                  ],
                                                ),
                                              );
                                            });
                                          });

                                      if (vehicleConfirmed == true &&
                                          choosevehicletypelistlocal
                                              .isNotEmpty) {
                                        setState(() {
                                          _isLoading = true;
                                          _error = '';
                                        });
                                        choosevehicletypelist.clear();
                                        for (var element
                                            in choosevehicletypelistlocal) {
                                          choosevehicletypelist.add(element);
                                        }
                                        var val = await getVehicleMake(
                                            transportType: transportType,
                                            myVehicleIconFor:
                                                choosevehicletypelist[0]
                                                        ['icon_types_for']
                                                    .toString());
                                        if (val != 'success') {
                                          _error = val;
                                        } else {
                                          mycustommake = '';
                                          mycustommodel = '';
                                          vehicleMakeId = '';
                                          vehicleModelId = '';
                                        }
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: media.width * 0.13,
                                    width: media.width * 0.9,
                                    decoration: BoxDecoration(
                                      color: (myServiceId != '')
                                          ? Colors.transparent
                                          : const Color(0xFFD9D9D9)
                                              .withOpacity(0.31),
                                      // color:(myServiceId != '') ? page : Color(0xFFE8EAE9),
                                      borderRadius: BorderRadius.circular(
                                          media.width * 0.01),
                                      border: Border.all(color: whiteText),
                                    ),
                                    padding: EdgeInsets.only(
                                        left: (languageDirection == 'ltr')
                                            ? (choosevehicletypelist.isEmpty)
                                                ? media.width * 0.05
                                                : 0
                                            : media.width * 0.05,
                                        right: (languageDirection == 'rtl')
                                            ? (choosevehicletypelist.isEmpty)
                                                ? media.width * 0.05
                                                : 0
                                            : media.width * 0.05),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          // width: media.width * 0.7,
                                          child: (choosevehicletypelist.isEmpty)
                                              ? MyText(
                                                  text:
                                                      languages[choosenLanguage]
                                                          ['text_vehicle_type'],
                                                  size: media.width * fourteen,
                                                  color:
                                                      (widget.frompage == 1 &&
                                                              myVehicleId == '')
                                                          ? whiteText
                                                          : whiteText)
                                              : SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    children:
                                                        choosevehicletypelist
                                                            .asMap()
                                                            .map((k, value) =>
                                                                MapEntry(
                                                                    k,
                                                                    Container(
                                                                      padding: EdgeInsets.fromLTRB(
                                                                          media.width *
                                                                              0.05,
                                                                          0,
                                                                          media.width *
                                                                              0.05,
                                                                          0),
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child:
                                                                          MyText(
                                                                        text: choosevehicletypelist[k]
                                                                            [
                                                                            'name'],
                                                                        size: media.width *
                                                                            fourteen,
                                                                        color:
                                                                            whiteText,
                                                                      ),
                                                                    )))
                                                            .values
                                                            .toList(),
                                                  ),
                                                ),
                                        ),

                                        //  if(myServiceId == '')
                                        Icon(
                                          (myServiceId == '')
                                              ? Icons.lock_outline_rounded
                                              : Icons.keyboard_arrow_down,
                                          size: media.width * 0.05,
                                          color: whiteText,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                SizedBox(
                                    width: media.width * 0.8,
                                    child: MyText(
                                      text: 'What make of vehicle is it?',
                                      size: media.width * fourteen,
                                      fontweight: FontWeight.w600,
                                      maxLines: 2,
                                      color: whiteText,
                                    )),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                InkWell(
                                  onTap: () async {
                                    if (myServiceId != '') {
                                      makeConfirmed = false;
                                      custommakecontroller.clear();
                                      if (vehicleMakeId != '') {
                                        tempVehicleMakeId = vehicleMake
                                            .firstWhere((e) =>
                                                e['id'].toString() ==
                                                vehicleMakeId)['name']
                                            .toString();
                                      } else {
                                        tempVehicleMakeId = '';
                                      }

                                      // choosevehicletypelistlocal = choosevehicletypelist;
                                      await showModalBottomSheet(
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (builder) {
                                            return StatefulBuilder(builder:
                                                (BuildContext context,
                                                    setState) {
                                              return Container(
                                                height: media.height * 0.7,
                                                padding: EdgeInsets.all(
                                                    media.width * 0.05),
                                                width: media.width,
                                                decoration: BoxDecoration(
                                                    color: page,
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topLeft: Radius
                                                                .circular(media
                                                                        .width *
                                                                    0.05),
                                                            topRight: Radius
                                                                .circular(media
                                                                        .width *
                                                                    0.05))),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      width: media.width * 0.9,
                                                      child: MyText(
                                                        text:
                                                            'What make of vehicle is it?',
                                                        size: media.width *
                                                            sixteen,
                                                        fontweight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          media.width * 0.05,
                                                    ),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              media.width *
                                                                  0.05,
                                                              0,
                                                              media.width *
                                                                  0.05,
                                                              media.width *
                                                                  0.01),
                                                      height:
                                                          media.width * 0.13,
                                                      width: media.width * 0.9,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: textColor),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: InputField(
                                                        color: (tempVehicleMakeId !=
                                                                null)
                                                            ? (isDarkTheme ==
                                                                    true)
                                                                ? borderLines
                                                                    .withOpacity(
                                                                        0.5)
                                                                : borderLines
                                                            : textColor,
                                                        onTap: (v) {
                                                          setState(() {
                                                            if (tempVehicleMakeId !=
                                                                null) {
                                                              tempVehicleMakeId =
                                                                  null;
                                                            }
                                                          });
                                                        },
                                                        text:
                                                            'Choose from below or enter custom name',
                                                        textController:
                                                            custommakecontroller,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          media.width * 0.05,
                                                    ),
                                                    if (custommakecontroller
                                                        .text.isNotEmpty)
                                                      Column(
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets
                                                                .all(media
                                                                        .width *
                                                                    0.025),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: media
                                                                          .width *
                                                                      0.05,
                                                                  height: media
                                                                          .width *
                                                                      0.05,
                                                                  decoration: BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      border: Border.all(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              theme)),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: (tempVehicleMakeId ==
                                                                          null)
                                                                      ? Container(
                                                                          width:
                                                                              media.width * 0.025,
                                                                          height:
                                                                              media.width * 0.025,
                                                                          decoration: BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: theme),
                                                                        )
                                                                      : Container(),
                                                                ),
                                                                SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.025,
                                                                ),
                                                                Expanded(
                                                                    child:
                                                                        MyText(
                                                                  text:
                                                                      custommakecontroller
                                                                          .text,
                                                                  size: media
                                                                          .width *
                                                                      fourteen,
                                                                )),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    Expanded(
                                                        child:
                                                            SingleChildScrollView(
                                                      child: Column(
                                                        children: vehicleMake
                                                            .asMap()
                                                            .map((k, value) =>
                                                                MapEntry(
                                                                    k,
                                                                    (custommakecontroller.text.isEmpty ||
                                                                            vehicleMake[k]['name'].toString().toLowerCase().contains(custommakecontroller.text.toLowerCase()))
                                                                        ? InkWell(
                                                                            onTap:
                                                                                () {
                                                                              setState(() {
                                                                                tempVehicleMakeId = vehicleMake[k]['name'];
                                                                              });
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              padding: EdgeInsets.all(media.width * 0.025),
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    width: media.width * 0.05,
                                                                                    height: media.width * 0.05,
                                                                                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1, color: theme)),
                                                                                    alignment: Alignment.center,
                                                                                    child: (tempVehicleMakeId == vehicleMake[k]['name'])
                                                                                        ? Container(
                                                                                            width: media.width * 0.025,
                                                                                            height: media.width * 0.025,
                                                                                            decoration: BoxDecoration(shape: BoxShape.circle, color: theme),
                                                                                          )
                                                                                        : Container(),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: media.width * 0.025,
                                                                                  ),
                                                                                  Expanded(
                                                                                      child: MyText(
                                                                                    text: vehicleMake[k]['name'],
                                                                                    size: media.width * fourteen,
                                                                                  )),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Container()))
                                                            .values
                                                            .toList(),
                                                      ),
                                                    )),
                                                    Button(
                                                        onTap: () {
                                                          makeConfirmed = true;
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        text: languages[
                                                                choosenLanguage]
                                                            ['text_confirm'])
                                                  ],
                                                ),
                                              );
                                            });
                                          });

                                      if (makeConfirmed == true &&
                                          tempVehicleMakeId != null) {
                                        setState(() {
                                          _isLoading = true;
                                          _error = '';
                                        });
                                        vehicleMakeId = vehicleMake
                                            .firstWhere((e) =>
                                                e['name'] ==
                                                tempVehicleMakeId)['id']
                                            .toString();
                                        mycustommake = '';
                                        var val = await getVehicleModel();
                                        if (val != 'success') {
                                          _error = val;
                                        }
                                        mycustommodel = '';
                                        custommodelcontroller.clear();
                                        vehicleModelId = '';
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      } else if (makeConfirmed == true &&
                                          custommakecontroller
                                              .text.isNotEmpty) {
                                        setState(() {
                                          vehicleMakeId = '';
                                          mycustommake =
                                              custommakecontroller.text;
                                          custommodelcontroller.clear();
                                          mycustommodel = '';
                                          vehicleModelId = '';
                                        });
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: media.width * 0.13,
                                    width: media.width * 0.9,
                                    decoration: BoxDecoration(
                                      color: (choosevehicletypelist.isNotEmpty)
                                          ? Colors.transparent
                                          : const Color(0xFFD9D9D9)
                                              .withOpacity(0.31),
                                      // color:(myServiceId != '') ? page : Color(0xFFE8EAE9),
                                      borderRadius: BorderRadius.circular(
                                          media.width * 0.01),
                                      border: Border.all(color: whiteText),
                                    ),
                                    padding: EdgeInsets.only(
                                        left: media.width * 0.05,
                                        right: media.width * 0.05),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          // width: media.width * 0.7,
                                          child: MyText(
                                              text: (vehicleMakeId != '')
                                                  ? (vehicleMake.isNotEmpty)
                                                      ? vehicleMake
                                                          .firstWhere(
                                                              (element) =>
                                                                  element['id']
                                                                      .toString() ==
                                                                  vehicleMakeId)[
                                                              'name']
                                                          .toString()
                                                      : ''
                                                  : (mycustommake != '')
                                                      ? mycustommake
                                                      : languages[
                                                              choosenLanguage]
                                                          ['text_sel_make'],
                                              size: media.width * fourteen,
                                              color: (widget.frompage == 1 &&
                                                      myVehicleId == '')
                                                  ? whiteText
                                                  : whiteText),
                                        ),

                                        //  if(myServiceId == '')
                                        Icon(
                                          (choosevehicletypelist.isEmpty)
                                              ? Icons.lock_outline_rounded
                                              : Icons.keyboard_arrow_down,
                                          size: media.width * 0.05,
                                          color: whiteText,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                SizedBox(
                                    width: media.width * 0.8,
                                    child: MyText(
                                      text: 'What model of vehicle is it?',
                                      size: media.width * fourteen,
                                      fontweight: FontWeight.w600,
                                      maxLines: 2,
                                      color: whiteText,
                                    )),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                InkWell(
                                  onTap: () async {
                                    if (vehicleMakeId != '') {
                                      modelConfirmed = false;
                                      if (vehicleModelId != '') {
                                        tempVehicleModelId = vehicleModel
                                            .firstWhere((e) =>
                                                e['id'].toString() ==
                                                vehicleModelId)['name']
                                            .toString();
                                      } else {
                                        tempVehicleMakeId = '';
                                      }

                                      // choosevehicletypelistlocal = choosevehicletypelist;
                                      await showModalBottomSheet(
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (builder) {
                                            return StatefulBuilder(builder:
                                                (BuildContext context,
                                                    setState) {
                                              return Container(
                                                height: media.height * 0.7,
                                                padding: EdgeInsets.all(
                                                    media.width * 0.05),
                                                width: media.width,
                                                decoration: BoxDecoration(
                                                    color: page,
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topLeft: Radius
                                                                .circular(media
                                                                        .width *
                                                                    0.05),
                                                            topRight: Radius
                                                                .circular(media
                                                                        .width *
                                                                    0.05))),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      width: media.width * 0.9,
                                                      child: MyText(
                                                        text:
                                                            'What model of vehicle is it?',
                                                        size: media.width *
                                                            sixteen,
                                                        fontweight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          media.width * 0.05,
                                                    ),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              media.width *
                                                                  0.05,
                                                              0,
                                                              media.width *
                                                                  0.05,
                                                              media.width *
                                                                  0.01),
                                                      height:
                                                          media.width * 0.13,
                                                      width: media.width * 0.9,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: textColor),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: InputField(
                                                          color: (tempVehicleModelId !=
                                                                  null)
                                                              ? (isDarkTheme ==
                                                                      true)
                                                                  ? borderLines
                                                                      .withOpacity(
                                                                          0.5)
                                                                  : borderLines
                                                              : textColor,
                                                          onTap: (v) {
                                                            setState(() {
                                                              if (tempVehicleModelId !=
                                                                  null) {
                                                                tempVehicleModelId =
                                                                    null;
                                                              }
                                                            });
                                                          },
                                                          text:
                                                              'Choose from below or enter custom name',
                                                          textController:
                                                              custommodelcontroller),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          media.width * 0.05,
                                                    ),
                                                    if (custommodelcontroller
                                                        .text.isNotEmpty)
                                                      Column(
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets
                                                                .all(media
                                                                        .width *
                                                                    0.025),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: media
                                                                          .width *
                                                                      0.05,
                                                                  height: media
                                                                          .width *
                                                                      0.05,
                                                                  decoration: BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      border: Border.all(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              theme)),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: (tempVehicleModelId ==
                                                                          null)
                                                                      ? Container(
                                                                          width:
                                                                              media.width * 0.025,
                                                                          height:
                                                                              media.width * 0.025,
                                                                          decoration: BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: theme),
                                                                        )
                                                                      : Container(),
                                                                ),
                                                                SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.025,
                                                                ),
                                                                Expanded(
                                                                    child:
                                                                        MyText(
                                                                  text:
                                                                      custommodelcontroller
                                                                          .text,
                                                                  size: media
                                                                          .width *
                                                                      fourteen,
                                                                )),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    Expanded(
                                                        child:
                                                            SingleChildScrollView(
                                                      child: Column(
                                                        children: vehicleModel
                                                            .asMap()
                                                            .map((k, value) =>
                                                                MapEntry(
                                                                    k,
                                                                    (custommodelcontroller.text.isEmpty ||
                                                                            vehicleModel[k]['name'].toString().toLowerCase().contains(custommodelcontroller.text.toLowerCase()))
                                                                        ? InkWell(
                                                                            onTap:
                                                                                () {
                                                                              setState(() {
                                                                                tempVehicleModelId = vehicleModel[k]['name'];
                                                                              });
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              padding: EdgeInsets.all(media.width * 0.025),
                                                                              child: Row(
                                                                                children: [
                                                                                  Container(
                                                                                    width: media.width * 0.05,
                                                                                    height: media.width * 0.05,
                                                                                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1, color: theme)),
                                                                                    alignment: Alignment.center,
                                                                                    child: (tempVehicleModelId == vehicleModel[k]['name'])
                                                                                        ? Container(
                                                                                            width: media.width * 0.025,
                                                                                            height: media.width * 0.025,
                                                                                            decoration: BoxDecoration(shape: BoxShape.circle, color: theme),
                                                                                          )
                                                                                        : Container(),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: media.width * 0.025,
                                                                                  ),
                                                                                  Expanded(
                                                                                      child: MyText(
                                                                                    text: vehicleModel[k]['name'],
                                                                                    size: media.width * fourteen,
                                                                                  )),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Container()))
                                                            .values
                                                            .toList(),
                                                      ),
                                                    )),
                                                    Button(
                                                        onTap: () {
                                                          modelConfirmed = true;
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        text: languages[
                                                                choosenLanguage]
                                                            ['text_confirm'])
                                                  ],
                                                ),
                                              );
                                            });
                                          });

                                      if (modelConfirmed == true &&
                                          tempVehicleModelId != null) {
                                        setState(() {
                                          // _isLoading = true;
                                          _error = '';
                                          vehicleModelId = vehicleModel
                                              .firstWhere((e) =>
                                                  e['name'] ==
                                                  tempVehicleModelId)['id']
                                              .toString();
                                          mycustommodel = '';
                                        });

                                        // print('ff ' + choosevehicletypelist.toString());
                                        // var val = await getVehicleModel();
                                        // if(val != 'success'){
                                        //   _error = val;
                                        // }
                                        // setState(() {
                                        //   _isLoading = false;
                                        // });
                                      } else if (modelConfirmed == true &&
                                          custommodelcontroller
                                              .text.isNotEmpty) {
                                        vehicleModelId = '';
                                        mycustommodel =
                                            custommodelcontroller.text;
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: media.width * 0.13,
                                    width: media.width * 0.9,
                                    decoration: BoxDecoration(
                                      color: (vehicleMakeId != '' ||
                                              mycustommake != '')
                                          ? Colors.transparent
                                          : const Color(0xFFD9D9D9)
                                              .withOpacity(0.31),
                                      // color:(myServiceId != '') ? page : Color(0xFFE8EAE9),
                                      borderRadius: BorderRadius.circular(
                                          media.width * 0.01),
                                      border: Border.all(color: whiteText),
                                    ),
                                    padding: EdgeInsets.only(
                                        left: media.width * 0.05,
                                        right: media.width * 0.05),
                                    child: (mycustommake != '')
                                        ? Container(
                                            padding: EdgeInsets.only(
                                                bottom: media.width * 0.0125),
                                            child: InputField(
                                              onTap: (v) {
                                                mycustommodel = v.toString();
                                              },
                                              text: 'Enter Custom Model',
                                              textController:
                                                  custommodelcontroller,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                // width: media.width * 0.7,
                                                child: MyText(
                                                    text: (vehicleModelId != '')
                                                        ? vehicleModel
                                                            .firstWhere(
                                                                (element) =>
                                                                    element['id']
                                                                        .toString() ==
                                                                    vehicleModelId)[
                                                                'name']
                                                            .toString()
                                                        : (mycustommodel != '')
                                                            ? mycustommodel
                                                            : languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_sel_model'],
                                                    size:
                                                        media.width * fourteen,
                                                    color: (widget.frompage ==
                                                                1 &&
                                                            myVehicleId == '')
                                                        ? whiteText
                                                        : whiteText),
                                              ),

                                              //  if(vehicleMakeId == '')
                                              Icon(
                                                (vehicleMakeId != '' ||
                                                        mycustommake != '')
                                                    ? Icons.keyboard_arrow_down
                                                    : Icons
                                                        .lock_outline_rounded,
                                                size: media.width * 0.05,
                                                color: whiteText,
                                              )
                                            ],
                                          ),
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                SizedBox(
                                    width: media.width * 0.8,
                                    child: MyText(
                                      text: languages[choosenLanguage]
                                          ['text_vehicle_model_year'],
                                      size: media.width * fourteen,
                                      fontweight: FontWeight.w600,
                                      maxLines: 2,
                                      color: whiteText,
                                    )),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Container(
                                  height: media.width * 0.13,
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: (vehicleModelId != '' ||
                                            mycustommodel != '')
                                        ? Colors.transparent
                                        : const Color(0xFFD9D9D9)
                                            .withOpacity(0.31),
                                    // color:(myServiceId != '') ? page : Color(0xFFE8EAE9),
                                    borderRadius: BorderRadius.circular(
                                        media.width * 0.01),
                                    border: Border.all(color: whiteText),
                                  ),
                                  padding: EdgeInsets.only(
                                      left: media.width * 0.05,
                                      right: media.width * 0.05),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              bottom: media.width * 0.0125),
                                          child: InputField(
                                            onTap: (v) {
                                              setState(() {
                                                modelYear = v.toString();
                                              });
                                            },
                                            maxLength: 4,
                                            readonly: (vehicleModelId == '' &&
                                                mycustommodel == ''),
                                            inputType: TextInputType.number,
                                            text: languages[choosenLanguage][
                                                'text_enter_vehicle_model_year'],
                                            textController: modelcontroller,
                                            color: whiteText,
                                          ),
                                        ),
                                      ),
                                      if (vehicleModelId == '' &&
                                          mycustommodel == '')
                                        Icon(
                                          Icons.lock_outline_rounded,
                                          size: media.width * 0.05,
                                          color: whiteText,
                                        )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                SizedBox(
                                    width: media.width * 0.8,
                                    child: MyText(
                                      text: languages[choosenLanguage]
                                          ['text_enter_vehicle'],
                                      size: media.width * fourteen,
                                      fontweight: FontWeight.w600,
                                      maxLines: 2,
                                      color: whiteText,
                                    )),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Container(
                                  height: media.width * 0.15,
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: (modelcontroller.text.isNotEmpty)
                                        ? Colors.transparent
                                        : const Color(0xFFD9D9D9)
                                            .withOpacity(0.31),
                                    // color:(myServiceId != '') ? page : Color(0xFFE8EAE9),
                                    borderRadius: BorderRadius.circular(
                                        media.width * 0.01),
                                  ),
                                  padding: EdgeInsets.only(
                                      top: 5,
                                      bottom: 5,
                                      left: media.width * 0.05,
                                      right: media.width * 0.05),
                                  child: Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Row(
                                      children: [
                                        // Numeric part input (large box for 1234)
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: TextField(
                                              readOnly:kDebugMode?false :
                                              modelcontroller.text.isEmpty,
                                              controller: _numberController,
                                              maxLength: 4,
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: media.width * 0.05,
                                                fontWeight: FontWeight.bold,
                                                color: whiteText,
                                              ),
                                              decoration: const InputDecoration(
                                                counterText: '',
                                                hintText: '1234',
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: media.width * 0.02),

                                        // Letter part inputs (smaller boxes for Arabic letters)
                                        ...List.generate(3, (index) {
                                          return Expanded(
                                            flex: 1,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: TextField(
                                                readOnly:kDebugMode?false :  modelcontroller
                                                    .text.isEmpty,
                                                controller:
                                                    _letterControllers[index],
                                                maxLength: 1,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: media.width * 0.05,
                                                  fontWeight: FontWeight.bold,
                                                  color: whiteText,
                                                ),
                                                decoration: InputDecoration(
                                                  counterText: '',
                                                  hintText: [
                                                    'ب',
                                                    'ر',
                                                    'د'
                                                  ][index],
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          );
                                        })
                                            .expand((widget) => [
                                                  widget,
                                                  SizedBox(
                                                      width: media.width * 0.02)
                                                ])
                                            .toList(),

                                        /*      Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(bottom: media.width * 0.0125),
                                            child: InputField(
                                              onTap: (v) {
                                                setState(() {
                                                  vehicleNumber = v.toString();
                                                });
                                              },
                                              readonly: modelcontroller.text.isEmpty,
                                              text: languages[choosenLanguage]['text_enter_vehicle'],
                                              textController: _numberController,
                                              color: whiteText,
                                            ),
                                          ),
                                        )
                                        ,*/

                                        /* Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                bottom: media.width * 0.0125),
                                            child: InputField(
                                              onTap: (v) {
                                                setState(() {
                                                  vehicleNumber = v.toString();
                                                });
                                              },
                                              readonly:
                                                  modelcontroller.text.isEmpty,
                                              text: languages[choosenLanguage]
                                                  ['text_enter_vehicle'],
                                              textController: _numberController,
                                              color: whiteText,
                                            ),
                                          ),
                                        ),*/
                                        if (modelcontroller.text.isEmpty)
                                          Icon(
                                            Icons.lock_outline_rounded,
                                            size: media.width * 0.05,
                                            color: whiteText,
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                SizedBox(
                                    width: media.width * 0.8,
                                    child: MyText(
                                      text: languages[choosenLanguage]
                                          ['text_vehicle_color'],
                                      size: media.width * fourteen,
                                      fontweight: FontWeight.w600,
                                      maxLines: 2,
                                      color: whiteText,
                                    )),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
// Vehicle Color Field Container
                                Container(
                                  height: media.width * 0.13,
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: (_numberController.text.isNotEmpty)
                                        ? Colors.transparent
                                        : const Color(0xFFD9D9D9)
                                            .withOpacity(0.31),
                                    borderRadius: BorderRadius.circular(
                                        media.width * 0.01),
                                    border: Border.all(color: whiteText),
                                  ),
                                  padding: EdgeInsets.only(
                                    left: media.width * 0.05,
                                    right: media.width * 0.05,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              bottom: media.width * 0.0125),
                                          child: InputField(
                                            onTap: (v) {
                                              setState(() {
                                                vehicleColor = v.toString();
                                              });
                                            },
                                            readonly:
                                                _numberController.text.isEmpty,
                                            text: languages[choosenLanguage]
                                                ['Text_enter_vehicle_color'],
                                            textController: colorcontroller,
                                            color: whiteText,
                                          ),
                                        ),
                                      ),
                                      if (_numberController.text.isEmpty)
                                        Icon(
                                          Icons.lock_outline_rounded,
                                          size: media.width * 0.05,
                                          color: whiteText,
                                        )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),

                                SizedBox(
                                    width: media.width * 0.8,
                                    child: MyText(
                                      text: languages[choosenLanguage]
                                          ['Text_identity_number'],
                                      size: media.width * fourteen,
                                      fontweight: FontWeight.w600,
                                      maxLines: 2,
                                      color: whiteText,
                                    )),

                                SizedBox(
                                  height: media.width * 0.05,
                                ),
// Vehicle Color Field Container
// Identity Number Field Container
                                Container(
                                  height: media.width * 0.13,
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: (_numberController.text.isNotEmpty)
                                        ? Colors.transparent
                                        : const Color(0xFFD9D9D9)
                                            .withOpacity(0.31),
                                    borderRadius: BorderRadius.circular(
                                        media.width * 0.01),
                                    border: Border.all(color: whiteText),
                                  ),
                                  padding: EdgeInsets.only(
                                    left: media.width * 0.05,
                                    right: media.width * 0.05,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              bottom: media.width * 0.0125),
                                          child: InputField(
                                            onTap: (v) {
                                              print('vvv $v');
                                              identityNumber =
                                                  identifierController.text;
                                            },
                                            readonly: kDebugMode
                                                ? false
                                                : _numberController
                                                    .text.isEmpty,
                                            text: languages[choosenLanguage]
                                                ['Text_enter_identity_number'],
                                            textController:
                                                identifierController,
                                            /*TextEditingController(
                                                    text: identityNumber
                                                        ?.toString()),*/
                                            color: whiteText,
                                          ),
                                        ),
                                      ),
                                      if (_numberController.text.isEmpty)
                                        Icon(
                                          Icons.lock_outline_rounded,
                                          size: media.width * 0.05,
                                          color: whiteText,
                                        )
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: media.width * 0.05,
                                ),

                                SizedBox(
                                    width: media.width * 0.8,
                                    child: MyText(
                                      text: languages[choosenLanguage]
                                          ['Text_sequence_number'],
                                      size: media.width * fourteen,
                                      fontweight: FontWeight.w600,
                                      maxLines: 2,
                                      color: whiteText,
                                    )),

                                SizedBox(
                                  height: media.width * 0.05,
                                ),

                                Container(
                                  height: media.width * 0.13,
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: (_numberController.text.isNotEmpty)
                                        ? Colors.transparent
                                        : const Color(0xFFD9D9D9)
                                            .withOpacity(0.31),
                                    borderRadius: BorderRadius.circular(
                                        media.width * 0.01),
                                    border: Border.all(color: whiteText),
                                  ),
                                  padding: EdgeInsets.only(
                                    left: media.width * 0.05,
                                    right: media.width * 0.05,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              bottom: media.width * 0.0125),
                                          child: InputField(
                                            onTap: (v) {
                                              sequenceNumber =
                                                  sequenceController.text;
                                            },
                                            readonly: kDebugMode
                                                ? false
                                                : _numberController
                                                    .text.isEmpty,
                                            text: languages[choosenLanguage]
                                                ['Text_enter_sequence_number'],
                                            textController: sequenceController,
                                            color: whiteText,
                                          ),
                                        ),
                                      ),
                                      if (_numberController.text.isEmpty)
                                        Icon(
                                          Icons.lock_outline_rounded,
                                          size: media.width * 0.05,
                                          color: whiteText,
                                        )
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: media.width * 0.05,
                                ),

                                SizedBox(
                                    width: media.width * 0.8,
                                    child: MyText(
                                      text: languages[choosenLanguage]
                                          ['Text_dob_gregorian'],
                                      size: media.width * fourteen,
                                      fontweight: FontWeight.w600,
                                      maxLines: 2,
                                      color: whiteText,
                                    )),

                                SizedBox(
                                  height: media.width * 0.05,
                                ),

                                Container(
                                  height: media.width * 0.13,
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: (_numberController.text.isNotEmpty)
                                        ? Colors.transparent
                                        : const Color(0xFFD9D9D9)
                                            .withOpacity(0.31),
                                    borderRadius: BorderRadius.circular(
                                        media.width * 0.01),
                                    border: Border.all(color: whiteText),
                                  ),
                                  padding: EdgeInsets.only(
                                    left: media.width * 0.05,
                                    right: media.width * 0.05,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              _selectGregorianDate(context),
                                          child: Container(
                                            color: Colors.transparent,
                                            padding: EdgeInsets.only(
                                                bottom: media.width * 0.0125),
                                            child: InputField(
                                              enabled: false,
                                              onTap: (v) {
                                                setState(() {
                                                  dateOfBirthGregorian =
                                                      v.toString();
                                                });
                                              },
                                              readonly: _numberController
                                                  .text.isEmpty,
                                              text: languages[choosenLanguage]
                                                  ['Text_enter_dob_gregorian'],
                                              textController:
                                                  TextEditingController(
                                                      text: dateOfBirthGregorian
                                                          ?.toString()),
                                              color: whiteText,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (_numberController.text.isEmpty)
                                        Icon(
                                          Icons.lock_outline_rounded,
                                          size: media.width * 0.05,
                                          color: whiteText,
                                        )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),

                                SizedBox(
                                    width: media.width * 0.8,
                                    child: MyText(
                                      text: languages[choosenLanguage]
                                          ['Text_dob_hijri'],
                                      size: media.width * fourteen,
                                      fontweight: FontWeight.w600,
                                      maxLines: 2,
                                      color: whiteText,
                                    )),

                                SizedBox(
                                  height: media.width * 0.05,
                                ),
// Vehicle Color Field Container
// Date of Birth Hijri Field Container
                                Container(
                                  height: media.width * 0.13,
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: (_numberController.text.isNotEmpty)
                                        ? Colors.transparent
                                        : const Color(0xFFD9D9D9)
                                            .withOpacity(0.31),
                                    borderRadius: BorderRadius.circular(
                                        media.width * 0.01),
                                    border: Border.all(color: whiteText),
                                  ),
                                  padding: EdgeInsets.only(
                                    left: media.width * 0.05,
                                    right: media.width * 0.05,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => selectHijriDate(context),
                                          child: Container(
                                            color: Colors.transparent,
                                            padding: EdgeInsets.only(
                                                bottom: media.width * 0.0125),
                                            child: InputField(
                                              enabled: false,
                                              onTap: (v) {
                                                setState(() {
                                                  dateOfBirthHijri =
                                                      v.toString();
                                                });
                                              },
                                              readonly: _numberController
                                                  .text.isEmpty,
                                              text: languages[choosenLanguage]
                                                  ['Text_enter_dob_hijri'],
                                              textController:
                                                  TextEditingController(
                                                      text: dateOfBirthHijri
                                                          ?.toString()),
                                              color: whiteText,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (_numberController.text.isEmpty)
                                        Icon(
                                          Icons.lock_outline_rounded,
                                          size: media.width * 0.05,
                                          color: whiteText,
                                        )
                                    ],
                                  ),
                                ),

                                if (userDetails.isEmpty)
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      SizedBox(
                                          width: media.width * 0.8,
                                          child: MyText(
                                            text: languages[choosenLanguage]
                                                ['text_referral_optional'],
                                            size: media.width * fourteen,
                                            fontweight: FontWeight.w600,
                                            maxLines: 2,
                                            color: whiteText,
                                          )),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      Container(
                                        height: media.width * 0.13,
                                        width: media.width * 0.9,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          // color:(myServiceId != '') ? page : Color(0xFFE8EAE9),
                                          borderRadius: BorderRadius.circular(
                                              media.width * 0.01),
                                          border: Border.all(color: whiteText),
                                        ),
                                        padding: EdgeInsets.only(
                                            left: media.width * 0.05,
                                            right: media.width * 0.05),
                                        child: InputField(
                                          text: languages[choosenLanguage]
                                              ['text_enter_referral'],
                                          textController: referralcontroller,
                                          color: whiteText,
                                        ),
                                      ),
                                    ],
                                  ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    if (_error != '')
                      Column(
                        children: [
                          Container(
                              // width: media.width*0.9,
                              constraints: BoxConstraints(
                                  maxWidth: media.width * 0.9,
                                  minWidth: media.width * 0.5),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color:
                                      const Color(0xffFFFFFF).withOpacity(0.5)),
                              child: MyText(
                                text: _error,
                                size: media.width * sixteen,
                                color: Colors.red,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                fontweight: FontWeight.w500,
                              )),
                          SizedBox(
                            height: media.width * 0.025,
                          ),
                        ],
                      ),
                    Button(
                      onTap: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (colorcontroller.text.isNotEmpty &&
                            modelcontroller.text.isNotEmpty) {
                          setState(() {
                            _error = '';
                            _isLoading = true;
                          });
                          if (widget.frompage == 1 &&
                              userDetails.isNotEmpty &&
                              isowner != true) {
                            if (referralcontroller.text.isNotEmpty) {
                              var val =
                                  await updateReferral(referralcontroller.text);
                              if (val == 'true') {
                                carInformationCompleted = true;
                                navigateref();
                              } else {
                                setState(() {
                                  referralcontroller.clear();
                                  _error = languages[choosenLanguage]
                                      ['text_referral_code'];
                                  _isLoading = false;
                                });
                              }
                            } else {
                              carInformationCompleted = true;
                              navigateref();
                            }
                          } else if (userDetails.isEmpty) {
                            vehicletypelist.clear();
                            for (Map<String, dynamic> json
                                in choosevehicletypelist) {
                              // Get the value of the key.
                              vehicletypelist.add(json['id']);
                            }

                            var reg = await registerDriver();

                            if (reg == 'true') {
                              if (referralcontroller.text.isNotEmpty) {
                                var val = await updateReferral(
                                    referralcontroller.text);
                                if (val == 'true') {
                                  carInformationCompleted = true;
                                  navigateref();
                                } else {
                                  setState(() {
                                    referralcontroller.clear();
                                    _error = languages[choosenLanguage]
                                        ['text_referral_code'];
                                    _isLoading = false;
                                  });
                                }
                              } else {
                                carInformationCompleted = true;
                                navigateref();
                              }
                            } else {
                              setState(() {
                                _error = reg.toString();
                              });
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          } else if (userDetails['role'] == 'owner') {
                            vehicletypelist.add(choosevehicletypelist[0]['id']);
                            var reg = await addDriver();
                            setState(() {
                              _isLoading = false;
                            });
                            if (reg == 'true') {
                              // ignore: use_build_context_synchronously
                              // setState(() {
                              //   vehicleAdded = true;
                              // });
                              showModalBottomSheet(
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  isScrollControlled: false,
                                  isDismissible: false,
                                  builder: (context) {
                                    return Container(
                                      padding:
                                          EdgeInsets.all(media.width * 0.05),
                                      width: media.width * 1,
                                      height: media.width * 0.4,
                                      decoration: BoxDecoration(
                                          color: page,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(
                                                  media.width * 0.05),
                                              topRight: Radius.circular(
                                                  media.width * 0.05))),
                                      child: Column(
                                        // crossAxisAlignment:
                                        //     CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                              width: media.width * 0.9,
                                              child: MyText(
                                                text: languages[choosenLanguage]
                                                    ['text_vehicle_added'],
                                                size: media.width * sixteen,
                                                fontweight: FontWeight.bold,
                                                textAlign: TextAlign.center,
                                              )),
                                          SizedBox(
                                            height: media.width * 0.1,
                                          ),
                                          Button(
                                              onTap: () {
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const ManageVehicles()));
                                              },
                                              text: languages[choosenLanguage]
                                                  ['text_ok'])
                                        ],
                                      ),
                                    );
                                  });
                            } else if (reg == 'logout') {
                              navigateLogout();
                            } else {
                              setState(() {
                                _error = reg.toString();
                              });
                            }
                          } else {
                            vehicletypelist.clear();
                            for (Map<String, dynamic> json
                                in choosevehicletypelist) {
                              // Get the value of the key.
                              vehicletypelist.add(json['id']);
                            }

                            var update = await updateVehicle();
                            if (update == 'success') {
                              navigate();
                            } else if (update == 'logout') {
                              navigateLogout();
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        } else {
                          setState(() {
                            _error =
                                'Please enter all details to proceed further';
                          });
                        }
                      },
                      text: languages[choosenLanguage]['text_submit'],
                      width: media.width * 0.5,
                    )
                  ],
                ),
              )),

              //no internet
              (internet == false)
                  ? Positioned(
                      top: 0,
                      child: NoInternet(
                        onTap: () {
                          setState(() {
                            internetTrue();
                          });
                        },
                      ))
                  : Container(),
              //loader
              (_isLoading == true)
                  ? const Positioned(top: 0, child: Loading())
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectGregorianDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30 * 12 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 30 * 12 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Change this to match your theme
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateOfBirthGregorian = intl.DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> selectHijriDate(BuildContext context) async {
    final picked = await showDialog(
      context: context,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  JGlobalDatePicker(
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                    onOk: (val) {
                      selectedDate = val;
                      Navigator.of(context).pop();
                    },
                    okButtonColor: Colors.blue,
                    okButtonText: languages[choosenLanguage]['text_ok'],
                    cancelButtonText: languages[choosenLanguage]['text_cancel'],
                    widgetType: WidgetType.JDialog,
                    pickerType: PickerType.JHijri,
                    primaryColor: Colors.blue,
                    calendarTextColor: Colors.black,
                    backgroundColor: Colors.white,
                    locale: const Locale('ar'),
                    // adjust as needed
                    borderRadius: const Radius.circular(10),
                    headerTitle: Center(
                      child: Text(languages[choosenLanguage]
                              ['text_hijri_calendar'] ??
                          ''),
                    ),
                    startDate: JDateModel(dateTime: DateTime(1940)),
                    selectedDate: JDateModel(
                        dateTime: DateTime.now()
                            .subtract(const Duration(days: 30 * 12 * 18))),
                    endDate: JDateModel(
                        dateTime: DateTime.now()
                            .subtract(const Duration(days: 30 * 12 * 18))),
                    pickerMode: DatePickerMode.day,
                    pickerTheme: Theme.of(context),
                    textDirection: TextDirection.rtl,
                    onChange: (val) {
                      selectedDate = val;
                      debugPrint(val.toString());
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );

    if (selectedDate != null) {
      setState(() {
        dateOfBirthHijri =
            '${(selectedDate)!.jhijri.year}-${(selectedDate)!.jhijri.month}-${(selectedDate)!.jhijri.day}';
      });
    }
  }
}
