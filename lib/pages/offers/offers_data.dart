import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../functions/functions.dart';
import 'package:http/http.dart' as http;

import '../../translation/translation.dart';

void fetchOffers() async {
  var result = await getOffers();
  if (result is List<Offer>) {
    // Success - handle the offers
    List<Offer> offers = result;
    // Update your UI or state with the offers
  } else if (result == 'logout') {
    // Handle logout - perhaps navigate to login screen
  } else {
    // Handle error message
    String errorMessage = result.toString();
    // Show error message to user
  }
}

Future<dynamic> getOffers() async {
  dynamic result;
  List<Offer> offers = [];

  try {
    var response = await http.get(
      Uri.parse('${url}api/v1/driver/offers'),
      headers: {
        'Authorization': 'Bearer ${bearerToken[0].token}',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['data'] != null) {
        offers = (jsonResponse['data'] as List)
            .map((item) => Offer.fromJson(item))
            .toList();
        result = offers;
      }
    } else if (response.statusCode == 401) {
      result = 'logout';
    } else if (response.statusCode == 422) {
      debugPrint(response.body);
      var error = jsonDecode(response.body)['errors'];
      result = error[error.keys.toList()[0]]
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .toString();
    } else {
      debugPrint(response.body);
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = languages[choosenLanguage]['no internet'];
    } else {
      debugPrint(e.toString());
      result = 'Something went wrong';
    }
  }
  return result;
}

class Offer {
  final String id;
  final String subject;
  final int requestNumber;
  final double earningPrice;
  final DateTime fromDate;
  final DateTime toDate;
  final bool isActive;
  final int offerDriverCount;
  final int requiredTrips;
  final int completedTrips;
  final bool isSubscribed;

  Offer({
    required this.id,
    required this.subject,
    required this.requestNumber,
    required this.earningPrice,
    required this.fromDate,
    required this.toDate,
    required this.isActive,
    required this.offerDriverCount,
    required this.requiredTrips,
    required this.completedTrips,
    required this.isSubscribed,
  });

  // Factory constructor to create an Offer from JSON
  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as String,
      subject: json['subject'] as String,
      requestNumber: json['request_number'] as int,
      earningPrice: double.parse(json['earning_price'] as String),
      fromDate: DateTime.parse(json['from_date']),
      toDate: DateTime.parse(json['to_date']),
      isActive: json['active'] == 1,
      offerDriverCount: json['offer_driver_count'] as int,
      // These fields might come from a different endpoint or have different names
      requiredTrips: json['required_trips'] ?? 7,
      // Default from UI example
      completedTrips: json['completed_trips'] ?? 0,
      isSubscribed: json['is_subscribed'] ?? true,
    );
  }

  // Convert Offer to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'request_number': requestNumber,
      'earning_price': earningPrice.toString(),
      'from_date': fromDate.toIso8601String(),
      'to_date': toDate.toIso8601String(),
      'active': isActive ? 1 : 0,
      'offer_driver_count': offerDriverCount,
      'required_trips': requiredTrips,
      'completed_trips': completedTrips,
      'is_subscribed': isSubscribed,
    };
  }

  // Get formatted time remaining
  String getTimeRemaining() {
    final now = DateTime.now();
    if (now.isAfter(toDate)) return '00:00:00';

    final difference = toDate.difference(now);
    final hours = difference.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = difference.inMinutes.remainder(60).toString().padLeft(2, '0');

    final fromDateFormatted = '${now.day}-${now.month}-${now.year}';
    final toDateFormatted = '${toDate.day}-${toDate.month}-${toDate.year}';

    return 'From $fromDateFormatted to $toDateFormatted | $hours:$minutes';
  }

  // Get formatted date range
  String getDateRange() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return '${dateFormat.format(fromDate)} to ${dateFormat.format(toDate)}';
  }

  // Get formatted time range
  String getTimeRange() {
    final timeFormat = DateFormat('HH:mm');
    return '${timeFormat.format(fromDate)} - ${timeFormat.format(toDate)}';
  }

  // Check if offer is currently valid
  bool isCurrentlyValid() {
    final now = DateTime.now();
    return now.isAfter(fromDate) && now.isBefore(toDate) && isActive;
  }

  // Get progress percentage
  double getProgressPercentage() {
    if (requiredTrips == 0) return 0.0;
    return (completedTrips / requiredTrips) * 100;
  }

  // Get remaining trips
  int getRemainingTrips() {
    return requiredTrips - completedTrips;
  }

  // Copy with method for immutability
  Offer copyWith({
    String? id,
    String? subject,
    int? requestNumber,
    double? earningPrice,
    DateTime? fromDate,
    DateTime? toDate,
    bool? isActive,
    int? offerDriverCount,
    int? requiredTrips,
    int? completedTrips,
    bool? isSubscribed,
  }) {
    return Offer(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      requestNumber: requestNumber ?? this.requestNumber,
      earningPrice: earningPrice ?? this.earningPrice,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      isActive: isActive ?? this.isActive,
      offerDriverCount: offerDriverCount ?? this.offerDriverCount,
      requiredTrips: requiredTrips ?? this.requiredTrips,
      completedTrips: completedTrips ?? this.completedTrips,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }

  @override
  String toString() {
    return 'Offer(id: $id, subject: $subject, requestNumber: $requestNumber, '
        'earningPrice: $earningPrice, fromDate: $fromDate, toDate: $toDate, '
        'isActive: $isActive, offerDriverCount: $offerDriverCount, '
        'requiredTrips: $requiredTrips, completedTrips: $completedTrips, '
        'isSubscribed: $isSubscribed)';
  }
}

// Example usage extension
extension OfferListExtension on List<Offer> {
  List<Offer> get activeOffers =>
      where((offer) => offer.isCurrentlyValid()).toList();

  List<Offer> get expiredOffers =>
      where((offer) => !offer.isCurrentlyValid()).toList();
}