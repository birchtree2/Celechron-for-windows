import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../utils/utils.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'dart:io';
import 'package:const_date_time/const_date_time.dart';
import 'package:flutter/services.dart' show rootBundle;

// TZID=Asia/Shanghai

class Period {
  PeriodType periodType;
  String description;
  DateTime startTime;
  DateTime endTime;
  String location;
  String summary;

  Period({
    this.periodType = PeriodType.classes,
    this.description = "教师: 空之探险队的 Kate\n课程代码: PMD00001\n教学时间安排: 春夏 第1-2节",
    this.startTime = const ConstDateTime(2023, 3, 1, 8, 00),
    this.endTime = const ConstDateTime(2023, 3, 1, 9, 35),
    this.location = "胖可丁公会",
    this.summary = "不可思议迷宫导论",
  });

  Period copyWith({
    PeriodType? periodType,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? summary,
  }) {
    return Period(
      periodType: periodType ?? this.periodType,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      summary: summary ?? this.summary,
    );
  }

  String getTimePeriodHumanReadable() {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }
}

int comparePeriod(Period a, Period b) {
  if (a.startTime.compareTo(b.startTime) == 0) {
    return a.endTime.compareTo(b.endTime);
  }
  return a.startTime.compareTo(b.startTime);
}

DateTime formatToDateTime(String val) {
  return DateTime(
      int.parse(val.substring(0, 4)),
      int.parse(val.substring(4, 6)),
      int.parse(val.substring(6, 8)),
      int.parse(val.substring(9, 11)),
      int.parse(val.substring(11, 13)),
      int.parse(val.substring(13, 15)));
}

var basePeriodList = <Period>[];

Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/ugrsical.ics');
}

void updateBasePeriodList() async {
  var baseCalendar = ICalendar.fromString(await loadAsset());
  // ICalendar.fromLines(File('assets/ugrsical.ics').readAsLinesSync());
  var baseData = baseCalendar.data;

  basePeriodList.clear();
  for (var element in baseData) {
    if (element['type'] == 'VEVENT') {
      var newPeriod = Period();
      newPeriod.description =
          element['description']?.trim().replaceAll('\\n', '\n') ?? "";
      newPeriod.startTime = formatToDateTime(element['dtstart'].dt);
      newPeriod.endTime = formatToDateTime(element['dtend'].dt);
      newPeriod.location = element['location']?.trim() ?? "";
      newPeriod.summary = element['summary']?.trim();
      newPeriod.periodType = newPeriod.summary.contains('考试')
          ? PeriodType.test
          : PeriodType.classes;
      basePeriodList.add(newPeriod);
    }
  }
}