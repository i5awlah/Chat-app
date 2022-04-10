import 'package:intl/intl.dart';

class DateFormatter {

  DateTime now = DateTime.now();
  DateTime justNow = DateTime.now().subtract(Duration(minutes: 1));

  String getVerboseDateTimeRepresentation(String date) {
    DateTime conversationDate = DateTime.parse(date);
    if (!conversationDate
        .difference(justNow)
        .isNegative) {
      return "Just now";
    }

    final roughTimeString = DateFormat('jm').format(conversationDate);
    if (conversationDate.day == now.day && conversationDate.month == now.month && conversationDate.year == now.year) {
      return roughTimeString;
    }

    DateTime yesterday = now.subtract(Duration(days: 1));
    if (conversationDate.day == yesterday.day && conversationDate.month == yesterday.month && conversationDate.year == yesterday.year) {
      return 'Yesterday, ' + roughTimeString;
    }

    if (now.difference(conversationDate).inDays < 4) {
      String weekday = DateFormat('EEEE').format(conversationDate);
      return '$weekday, $roughTimeString';
    }

    return '${DateFormat('yMd').format(conversationDate)}, $roughTimeString';
  }

}