import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmailService {
  static Future<bool> sendOtp(String email, String otp) async {
    final username = 'alatheiri123@gmail.com';
    final password = 'tagj erie tymz atol'; // Gmail App password

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'HealthTracker App')
      ..recipients.add(email)
      ..subject = 'Your OTP Code'
      ..text = 'Your OTP code is: $otp';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      return true;
    } catch (e) {
      print('Message not sent. $e');
      return false;
    }
  }
}
