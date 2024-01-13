/// **escapeNonAscii Function**
///
/// Escapes all non-ASCII characters in a given string by converting them
/// into Unicode escape sequences of the form '\uXXXX'.
///
/// This function is useful when non-ASCII characters need to be encoded
/// for systems that only accept ASCII characters, ensuring that the original
/// characters can be recovered and displayed correctly.
///
/// Parameters:
/// - `input`: The string containing the characters to be escaped.
///
/// Returns:
/// A new string where non-ASCII characters have been replaced with
/// their corresponding Unicode escape sequences.
///
/// Example:
/// ```dart
/// // Escape non-ASCII characters in the string
/// var escapedString = escapeNonAscii('Café');
/// print('Escaped String: $escapedString');
///
String escapeNonAscii(String input) {
  return input.replaceAllMapped(RegExp(r'[^\x00-\x7F]'), (match) {
    // Converte caracteres não ASCII para códigos de escape '\uXXXX'
    return '\\u${match.group(0)!.codeUnitAt(0).toRadixString(16).padLeft(4, '0')}';
  });
}
