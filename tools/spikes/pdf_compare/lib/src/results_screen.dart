import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config.dart';
import 'engines.dart';
import 'memory.dart';
import 'pdfrx_engine.dart';
import 'pdfx_engine.dart';
import 'runner.dart';

/// Size of FX-PDF-05 as listed in app/test/fixtures/large_files_manifest.json.
const int _expectedLargePdfBytes = 144657028;

/// Runs the harness on launch (unless AUTORUN=false), shows each step as it
/// finishes, then the result JSON, and writes the same JSON to a file.
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({
    super.key,
    required this.config,
    required this.uncaught,
  });

  final HarnessConfig config;
  final List<Map<String, Object?>> uncaught;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final List<String> _lines = <String>[];
  final Map<String, ui.Image> _previews = <String, ui.Image>{};
  String _status = 'Not started';
  String _json = '';
  String _jsonPath = '';
  bool _running = false;

  @override
  void initState() {
    super.initState();
    if (widget.config.autorun) {
      _run();
    }
  }

  @override
  void dispose() {
    for (final image in _previews.values) {
      image.dispose();
    }
    super.dispose();
  }

  void _log(String line) {
    debugPrint('PDFCMP $line');
    if (mounted) {
      setState(() => _lines.add(line));
    }
  }

  Future<void> _run() async {
    if (_running) {
      return;
    }
    final config = widget.config;
    setState(() {
      _running = true;
      _status = 'Running: ${config.libs.join(', ')}';
      _lines.clear();
      _json = '';
    });
    try {
      final inputs = await _prepareInputs(config);
      final engines = <PdfEngine>[
        for (final name in config.libs)
          if (name == 'pdfrx') PdfrxEngine() else PdfxEngine(),
      ];
      final outDir = Directory(
        config.outDir.isEmpty
            ? '${Directory.systemTemp.path}/pdf_compare_out'
            : config.outDir,
      )..createSync(recursive: true);
      final jsonFile = File(
        '${outDir.path}/results_${config.libs.join('+')}.json',
      );
      final runner = HarnessRunner(
        config: config,
        engines: engines,
        inputs: inputs,
        sampler: RssSampler(),
        environment: _environment(config, inputs),
        log: _log,
        uncaughtErrors: widget.uncaught,
        onSnapshot: (snapshot) {
          jsonFile.writeAsStringSync(
            const JsonEncoder.withIndent('  ').convert(snapshot),
            flush: true,
          );
        },
      );
      final result = await runner.run();
      await _renderPreviews(engines, inputs);
      final json = const JsonEncoder.withIndent('  ').convert(result);
      _jsonPath = jsonFile.path;
      debugPrint('PDFCMP_DONE ${jsonFile.path}');
      if (mounted) {
        setState(() {
          _json = json;
          _status = 'Finished. Results written to ${jsonFile.path}';
        });
      }
    } on Object catch (error, stack) {
      debugPrint('PDFCMP_FAILED $error\n$stack');
      if (mounted) {
        setState(() => _status = 'The harness itself failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _running = false);
      }
    }
    if (config.exitWhenDone) {
      await Future<void>.delayed(const Duration(seconds: 2));
      exit(0);
    }
  }

  /// Small first-page images, so a person can see the libraries drew the page.
  Future<void> _renderPreviews(
    List<PdfEngine> engines,
    List<PdfInput> inputs,
  ) async {
    for (final engine in engines) {
      for (final input in inputs) {
        if (input.skipReason != null || input.expectError) {
          continue;
        }
        EngineDocument? document;
        try {
          document = await engine.open(input.path);
          final page = await document.render(1, widthPx: 360);
          final image = page.image;
          if (image != null) {
            _previews['${engine.name} ${input.id}']?.dispose();
            _previews['${engine.name} ${input.id}'] = image.clone();
          }
          page.dispose();
        } on Object catch (error) {
          _log('preview ${engine.name} ${input.id} failed: $error');
        } finally {
          await document?.close();
        }
      }
    }
  }

  Future<List<PdfInput>> _prepareInputs(HarnessConfig config) async {
    final folder = Directory('${Directory.systemTemp.path}/pdf_compare_inputs')
      ..createSync(recursive: true);
    Future<String> unpack(String name) async {
      final data = await rootBundle.load('assets/pdf/$name');
      final file = File('${folder.path}/$name');
      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
      return file.path;
    }

    final large = config.largePdf;
    String? largeSkip;
    if (large.isEmpty) {
      largeSkip = 'LARGE_PDF was not given';
    } else if (!File(large).existsSync()) {
      largeSkip = 'LARGE_PDF does not exist on this device';
    }
    return <PdfInput>[
      PdfInput(
        id: 'FX-PDF-01',
        path: await unpack('fx_pdf_01.pdf'),
        expectError: false,
        fullScenarios: true,
      ),
      PdfInput(
        id: 'FX-PDF-05',
        path: large,
        expectError: false,
        fullScenarios: true,
        skipReason: largeSkip,
      ),
      PdfInput(
        id: 'FX-PDF-10',
        path: await unpack('fx_pdf_10.pdf'),
        expectError: true,
        fullScenarios: false,
      ),
      PdfInput(
        id: 'FX-PDF-11',
        path: await unpack('fx_pdf_11.pdf'),
        expectError: true,
        fullScenarios: false,
      ),
    ];
  }

  Map<String, Object?> _environment(
    HarnessConfig config,
    List<PdfInput> inputs,
  ) {
    final large = inputs.firstWhere((input) => input.id == 'FX-PDF-05');
    final largeBytes = large.skipReason == null
        ? File(large.path).lengthSync()
        : null;
    return <String, Object?>{
      'os': Platform.operatingSystem,
      'osVersion': Platform.operatingSystemVersion,
      'dart': Platform.version.split(' ').first,
      'buildMode': kReleaseMode
          ? 'release'
          : kProfileMode
          ? 'profile'
          : 'debug',
      'processors': Platform.numberOfProcessors,
      'simulatorName': Platform.environment['SIMULATOR_DEVICE_NAME'],
      'deviceLabel': config.deviceLabel,
      'memorySource':
          'dart:io ProcessInfo.currentRss read every 20 ms during a step; '
          'the process peak is ProcessInfo.maxRss',
      'largePdfBytes': largeBytes,
      'largePdfBytesInManifest': _expectedLargePdfBytes,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('PDF compare (spike, WB-05)')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(_status, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                FilledButton(
                  onPressed: _running ? null : _run,
                  child: const Text('Run'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _json.isEmpty
                      ? null
                      : () => Clipboard.setData(ClipboardData(text: _json)),
                  child: const Text('Copy JSON'),
                ),
              ],
            ),
            if (_previews.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  for (final entry in _previews.entries)
                    SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(entry.key, style: theme.textTheme.labelSmall),
                          RawImage(image: entry.value, fit: BoxFit.contain),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            for (final line in _lines)
              Text(line, style: theme.textTheme.bodySmall),
            if (_json.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                'Result JSON ($_jsonPath)',
                style: theme.textTheme.titleSmall,
              ),
              SelectableText(
                _json,
                style: const TextStyle(fontFamily: 'Courier', fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
