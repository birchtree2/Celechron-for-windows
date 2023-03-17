import 'grade.dart';
import 'semester.dart';
import '../spider/spider.dart';

class User {
  // 爬虫区
  final String _username;
  final String _password;
  late Spider _spider;

  // 所有学期的成绩都存一起，方便算重修
  Map<String, List<Grade>> grades = {};

  // 学期详细数据，包括该学期的所有科目、考试、课表、均绩等
  List<Semester> semesters = [];

  // 保研数据区
  double fivePointGpa = 0.0;
  double fourPointGpa = 0.0;
  double hundredPointGpa = 0.0;

  // 出国数据区
  double aboardFivePointGpa = 0.0;
  double aboardFourPointGpa = 0.0;
  double aboardHundredPointGpa = 0.0;

  //学分不会变的
  double credit = 0.0;

  //主修数据区
  double majorGpa = 0.0;
  double majorCredit = 0.0;

  // 通过用户名和密码构造
  User(this._username, this._password) {
    _spider = Spider(_username, _password);
  }

  // 初始化以获取Cookies
  Future<bool> init() async {
    await _spider.init();
    return await refresh();
  }

  // 刷新数据
  Future<bool> refresh() async {
    grades.clear();
    await Future.wait([
      _spider.getSemesterDetails(semesters, grades).then((value) {
        // 保研成绩，只取第一次
        var netGrades = grades.values.map((e) => e.first);
        if (netGrades.isNotEmpty) {
          var gpa = Grade.calculateGpa(netGrades);
          fivePointGpa = gpa[0];
          fourPointGpa = gpa[1];
          hundredPointGpa = gpa[2];
        }
        // 出国成绩，取最高的一次
        var aboardNetGrades = grades.values.map((e) {
          e.sort((a, b) => a.hundredPoint.compareTo(b.hundredPoint));
          return e.last;
        });
        if (aboardNetGrades.isNotEmpty) {
          var gpa = Grade.calculateGpa(aboardNetGrades);
          aboardFivePointGpa = gpa[0];
          aboardFourPointGpa = gpa[1];
          aboardHundredPointGpa = gpa[2];
        }
        // 这个算的是所获学分，不包括挂科的。因为出国成绩单取最高的一次成绩，所以就把挂科的学分算对了
        credit =
            aboardNetGrades.fold<double>(0.0, (p, e) => p + e.effectiveCredit);
      }),
      _spider.getMajorGrade().then((value) {
        majorGpa = value[0];
        majorCredit = value[1];
      })
    ]);

    return true;
  }
}
