# AIFile project notes and change log

Documentation created: **2026-10-22, 00:45:58 PKT (Asia/Karachi, UTC+05:00)**.

For future entries, record the date and time in PKT, affected files, code added or changed, reasons, removals/replacements, and validation results. Append new entries to preserve the history. Line references below describe the files as inspected at this timestamp and may move after later edits.

## Project files

Inventory recorded: **2026-10-22, 00:45:58 PKT**.

| File or directory | Purpose |
| --- | --- |
| `lib/main.dart` | Starts Flutter, builds the app, receives Android PDF channel messages, and opens the viewer. |
| `lib/screens/file_selection_screen.dart` | Home screen; its add button selects a PDF with `file_picker` and navigates to the viewer. |
| `lib/screens/pdf_viewer_screen.dart` | Accepts a local `filePath` and renders it with `PdfViewer.file` from `pdfrx`. |
| `android/app/src/main/kotlin/com/example/aifile/MainActivity.kt` | Android activity; reads incoming PDF intents and passes local file paths to Flutter. |
| `android/app/src/main/AndroidManifest.xml` | Declares the activity, launcher, existing PDF VIEW/SEND intent filters, and `singleTop` launch mode. |
| `android/app/build.gradle.kts` | Android/Kotlin/Flutter build setup, application ID, SDK settings, Java/Kotlin 17, and signing configuration. |
| `pubspec.yaml` | Project metadata, Dart constraint, Flutter configuration, and dependencies including `file_picker` and `pdfrx`. |
| `pubspec.lock` | Resolved dependency versions. |
| `analysis_options.yaml` | Dart analysis and lint configuration. |
| `test/widget_test.dart` | Existing starter counter test; its counter expectations do not match the current file-selection app. |
| `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/` | Platform runners and build configuration. The new intent channel is implemented only on Android. |
| `README.md` | Existing project readme. |
| `.dart_tool/`, `.flutter-plugins-dependencies` | Generated Dart/Flutter tooling and plugin metadata. |
| `PROJECT_CHANGELOG.md` | This project overview and timestamped change history. |

## Entry 1: Open incoming PDFs on cold and hot starts

Recorded: **2026-10-22, 00:45:58 PKT**. The earlier implementation's exact edit time was not captured; this is the documentation timestamp, not a reconstructed edit timestamp.

Request: keep the implementation simple and display PDFs received from Android when the app launches or is already running.

Edited application files:

- `lib/main.dart`
- `android/app/src/main/kotlin/com/example/aifile/MainActivity.kt`

The original Kotlin file only logged VIEW intents; it did not contain a method channel. Both ends of the channel were therefore implemented. No dependencies were added.

### `lib/main.dart`: additions and replacements

All rows belong to the entry timestamp above. Code excerpts use the current file's line numbers; structural braces and unchanged boilerplate are grouped with the relevant code.

| Line(s) | Code | Brief explanation |
| --- | --- | --- |
| 2 | `import 'package:aifile/screens/pdf_viewer_screen.dart';` | Adds access to the existing PDF screen. |
| 4 | `import 'package:flutter/services.dart';` | Imports the method channel and platform exception types. |
| 6–8 | `void main() { runApp(const AIFile()); }` | Retains the existing application entry point. |
| 10 | `class AIFile extends StatefulWidget` | Replaces `StatelessWidget` so the app can register and clean up a channel handler through lifecycle methods. |
| 13–17 | `State<AIFile> createState() => _AIFileState();` / `class _AIFileState extends State<AIFile>` | Introduces the state object that owns intent handling and navigation. |
| 18 | `static const _channel = MethodChannel('aifile/pdf');` | Connects to the identically named Kotlin channel. |
| 19 | `final _navigatorKey = GlobalKey<NavigatorState>();` | Allows channel callbacks to navigate without a screen's build context. |
| 21–24 | `void initState()` / `super.initState();` / `_channel.setMethodCallHandler((call) async {` | Registers Android-to-Flutter callbacks when the app state starts. |
| 25–26 | `if (call.method == 'openPdf')` / `_openPdf(call.arguments as String?);` | Receives a local PDF path for a hot start and opens it. |
| 27–28 | `else if (call.method == 'pdfError')` / `_showError();` | Shows an error when Kotlin cannot read an incoming PDF. |
| 31–32 | `WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialPdf());` | Waits for the first frame so the navigator exists before requesting the cold-start file. The preceding comment explains this timing. |
| 35–37 | `Future<void> _loadInitialPdf() async` / `_openPdf(await _channel.invokeMethod<String>('getInitialPdf'));` | Requests the activity's current intent through Kotlin and opens the returned file. |
| 38–39 | `on MissingPluginException` | Allows the app to start where this Android-only channel is unavailable. |
| 40–41 | `on PlatformException` / `_showError();` | Handles errors returned by the initial-file request. |
| 45–46 | `void _openPdf(String? path)` / `if (!mounted || path == null || path.isEmpty) return;` | Ignores calls after disposal and ignores missing or empty paths, including an ordinary launcher start. |
| 47 | `_navigatorKey.currentState?.pushAndRemoveUntil(` | Opens the incoming document and removes older viewer routes above the home screen. |
| 48 | `MaterialPageRoute(builder: (_) => PdfViewerScreen(filePath: path)),` | Reuses the existing PDF viewer with the supplied local path. |
| 49 | `(route) => route.isFirst,` | Keeps the original home route so Back can return to file selection. |
| 53–57 | `void _showError()` / `if (!mounted) return;` / `final context = _navigatorKey.currentContext;` / `if (context == null) return;` | Obtains a usable context before displaying an error dialog. |
| 58–63 | `showDialog<void>(` / `AlertDialog(` / `Text('Cannot open PDF')` / `Text('The shared PDF could not be read.')` | Displays a short message when the PDF cannot be read. |
| 64–67 | `TextButton(` / `onPressed: () => Navigator.pop(context),` / `child: const Text('OK'),` | Adds a button to dismiss the error dialog. |
| 74–77 | `void dispose()` / `_channel.setMethodCallHandler(null);` / `super.dispose();` | Unregisters the callback when the app state is disposed. |
| 81–86 | `Widget build(BuildContext context)` / `MaterialApp(` / `navigatorKey: _navigatorKey,` / `title: 'AIFile',` / `home: const FileSelectionScreen(),` | Moves the app build method into the state class and attaches the navigator key. Keeps the existing title and home screen, now constructed with `const`. |

Removed or replaced:

- Replaced `class AIFile extends StatelessWidget` with a `StatefulWidget` and `_AIFileState`, to manage channel lifecycle.
- Replaced the one-line `MaterialApp(title: 'AIFile', home: FileSelectionScreen())` with the equivalent multiline configuration plus `navigatorKey` and a const home widget.
- Removed the old introductory comments describing only navigation to file selection, since the entry point now also handles incoming PDFs.
- Preserved `main()`, the app name, and the existing selection/viewer screens.

### `MainActivity.kt`: additions and replacements

| Line(s) | Code | Brief explanation |
| --- | --- | --- |
| 3–8 | `import android.content.Intent` / `import android.net.Uri` / `import io.flutter.embedding.android.FlutterActivity` / `import io.flutter.embedding.engine.FlutterEngine` / `import io.flutter.plugin.common.MethodChannel` / `import java.io.File` | Keeps the activity/intent imports and adds URI, engine, channel, and file support. |
| 11 | `private lateinit var channel: MethodChannel` | Stores the channel for engine setup and later intent callbacks. |
| 13–14 | `override fun configureFlutterEngine(flutterEngine: FlutterEngine)` / `super.configureFlutterEngine(flutterEngine)` | Configures the channel while retaining Flutter's engine/plugin setup. |
| 15 | `channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "aifile/pdf")` | Creates the native end of the Flutter channel. |
| 16–17 | `channel.setMethodCallHandler { call, result ->` / `if (call.method == "getInitialPdf")` | Listens for Flutter's cold-start request. |
| 18–21 | `result.success(pdfPath(intent))` / `catch (e: Exception)` / `result.error("PDF_ERROR", e.message, null)` | Returns a readable path or a platform error if reading fails. |
| 23–24 | `else` / `result.notImplemented()` | Reports unsupported channel method names. |
| 30–32 | `override fun onNewIntent(intent: Intent)` / `super.onNewIntent(intent)` / `setIntent(intent)` | Retains Android's new-intent callback and saves the newest intent. |
| 33–34 | `pdfPath(intent)?.let { channel.invokeMethod("openPdf", it) }` | Replaces logging with forwarding the incoming PDF path to Flutter on hot starts. |
| 35–36 | `catch (e: Exception)` / `channel.invokeMethod("pdfError", e.message)` | Notifies Flutter if a hot-start PDF cannot be read. |
| 40–42 | `private fun pdfPath(intent: Intent?): String?` / `val uri: Uri = when (intent?.action)` / `Intent.ACTION_VIEW -> intent.data` | Extracts the document URI from an Open/View intent. |
| 43–45 | `Intent.ACTION_SEND ->` / `@Suppress("DEPRECATION")` / `intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)` | Supports the existing Share intent filter. Uses the older compatible parcelable getter and suppresses its deprecation warning locally. |
| 47–48 | `else -> null` / `} ?: return null` | Returns no document for launcher intents or missing URIs. |
| 49 | `if (uri.scheme == "file") return uri.path` | Uses a file URI's local path directly. |
| 51–52 | `val file = File.createTempFile("shared_", ".pdf", cacheDir)` | Creates a unique cached PDF for a content URI; the comment explains why a local path is needed. |
| 53–54 | `val input = contentResolver.openInputStream(uri)` / `?: throw IllegalStateException("Cannot read this PDF")` | Reads the URI through Android's content resolver or reports failure. |
| 55 | `input.use { source -> file.outputStream().use { source.copyTo(it) } }` | Copies the PDF to cache and closes both streams. |
| 56 | `return file.absolutePath` | Returns the local path expected by `PdfViewer.file`. |

Removed or replaced:

- Removed the duplicate `FlutterActivity` import.
- Removed `android.os.Bundle` and `android.util.Log`, because the revised code no longer uses them.
- Removed the `onCreate(savedInstanceState: Bundle?)` override that immediately called `handleIntent(intent)`. Flutter now requests the initial PDF after its first frame, so native code does not send the initial document before Flutter is ready to listen.
- Replaced `handleIntent(intent)` in `onNewIntent` with path extraction and `openPdf` channel delivery.
- Replaced the old `handleIntent` function, which only handled `ACTION_VIEW` and called `Log.d("PdfIntent", ...)`, with `pdfPath`, which supports VIEW and SEND and returns a readable local path.
- Replaced the inline comment beside `setIntent(intent)` with the simpler statement; saving the current intent remains unchanged.

### How the pieces connect

1. Cold start: Android holds the launch intent. Flutter renders its first frame, calls `getInitialPdf`, receives a local path, and navigates to `PdfViewerScreen`.
2. Hot start: Android delivers `onNewIntent`. Kotlin reads the PDF and invokes `openPdf`; Flutter navigates to `PdfViewerScreen`.
3. Content URI: Kotlin copies the provider's stream to the app cache before supplying its path. A file URI supplies its path directly.
4. Read failure: Kotlin returns `PDF_ERROR` for the initial request or sends `pdfError` for a new intent. Flutter shows the error dialog.

### Unchanged files and validation

- The manifest intent filters were already present and were not edited.
- `pdf_viewer_screen.dart`, `file_selection_screen.dart`, `build.gradle.kts`, dependency files, and tests were not edited for this implementation.
- Dart formatting and Flutter analysis were attempted, but neither tool was available on PATH or at the SDK path recorded in `android/local.properties` (`C:/Users/abdul/develop/flutter`). No successful analysis, Android build, or device test is recorded.
- Device verification is still needed: open a PDF with the app closed, open another while it is running, share a PDF into it, and check a normal launcher start. Restart/rebuild the app to include Kotlin changes.
- Implementation details to keep in mind: content copies use temporary cache files with no explicit cleanup added here; copying currently runs synchronously in the Android callback. These are current behavior notes, not completed improvements.

## Entry 2: Add project documentation

Recorded: **2026-10-22, 00:45:58 PKT**.

Added `PROJECT_CHANGELOG.md` with the project file overview, code-and-explanation tables, removal/replacement notes, channel flow, and actual validation status. No application code was changed in this documentation entry. The documentation timestamp was read from the clock and converted to Asia/Karachi time.
