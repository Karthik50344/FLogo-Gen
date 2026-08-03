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

  /// Opens the user's default mail client with a pre-filled recipient
  /// (and optional subject), via a plain mailto: anchor click — the
  /// same "build an off-DOM anchor, click it, remove it" pattern as
  /// downloadBytes above.
  static void openMailto(String email, {String? subject}) {
    final query = subject != null ? '?subject=${Uri.encodeComponent(subject)}' : '';
    final anchor = html.AnchorElement(href: 'mailto:$email$query')
      ..style.display = 'none';
    html.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
  }
}
