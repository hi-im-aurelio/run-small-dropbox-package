/// **rPath Function**
///
/// Ensures the accuracy of the provided file or folder path by ensuring it starts with a '/'.
///
/// The Dropbox API requires paths to start with a '/', and this function helps
/// ensure that the provided path complies with this requirement. If the given path
/// does not start with '/', it is prefixed with one to ensure correctness.
///
/// Parameters:
/// - `path`: The file or folder path to be validated and formatted.
///
/// Returns:
/// A formatted path with a leading '/' if not present initially.
///
/// Example:
/// ```dart
/// // Validate and format the path
/// var path = rPath('Documents/movies/file.txt');
/// print('Formatted Path: $path');
/// ```
String rPath(String path) {
  if (path.isEmpty) return path;

  if (!path.startsWith('/')) path = '/$path';

  return path;
}
