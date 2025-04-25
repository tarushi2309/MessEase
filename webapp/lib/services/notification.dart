import 'dart:async';
import 'dart:convert';
import 'dart:html';

Future<void> sendMailViaGAS({
  required List<String> to,
  required String subject,
  required String body,
}) async {
  final completer = Completer<void>();
  const url = 'https://script.google.com/macros/s/AKfycbyKS1QbMArU7Hw7WcbZC9XfTfe3bdxF3EH4nJbqiQidXvDC02op-tL1t3WJWi-ywg61vA/exec';
  final request = HttpRequest();

  request.onLoad.listen((_) {
    if (request.status == 200) {
      print('Emails sent: ${request.responseText}');
      completer.complete();
    } else {
      completer.completeError('Error ${request.status}: ${request.responseText}');
    }
  });

  request.onError.listen((e) => completer.completeError('Network error: $e'));

  try {
    request.open('POST', url);
    request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    final params = {
      'to': to.join(','), // Comma-separated string
      'subject': subject,
      'body': body,
    };
    request.send(Uri(queryParameters: params).query);
  } catch (e) {
    completer.completeError('Request error: $e');
  }

  return completer.future;
}
