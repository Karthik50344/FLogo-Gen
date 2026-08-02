// This app targets Flutter Web specifically, so it's safe to depend on
// dart:html directly (equivalent of the original's URL.createObjectURL +
// <a download> click flow).
import 'dart:html' as html;
import 'dart:typed_data';

class DownloadHelper {
  DownloadHelper._();

  static void downloadBytes(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes], 'application/zip');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = filename
      ..style.display = 'none';
    html.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
    Future.delayed(const Duration(seconds: 5), () => html.Url.revokeObjectUrl(url));
  }
}
