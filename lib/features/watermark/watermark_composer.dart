import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

class WatermarkComposer {
  static Future<File> compose({
    required String sourcePath,
    required String outputPath,
    required DateTime takenAt,
    required double latitude,
    required double longitude,
    required double accuracy,
    required String officer,
  }) async {
    final sourceBytes = await File(sourcePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(sourceBytes);
    final frame = await codec.getNextFrame();
    final source = frame.image;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(source.width.toDouble(), source.height.toDouble());
    canvas.drawImage(
      source,
      Offset.zero,
      Paint()..filterQuality = FilterQuality.high,
    );

    final scale = (size.width / 1200).clamp(.65, 3.5);
    final padding = 24 * scale;
    final logoData = await rootBundle.load(
      'assets/images/telkom_akses_logo.png',
    );
    final logoCodec = await ui.instantiateImageCodec(
      logoData.buffer.asUint8List(),
    );
    final logo = (await logoCodec.getNextFrame()).image;
    final logoHeight = 68 * scale;
    final logoWidth = logo.width * logoHeight / logo.height;
    final textLeft = padding + logoWidth + 22 * scale;
    final maxTextWidth = size.width - textLeft - padding;
    final timestamp = _dateTime(takenAt);
    final lines = <String>[
      'XiuMark  •  Telkom Akses',
      timestamp,
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}  •  ±${accuracy.toStringAsFixed(1)} m',
      if (officer.trim().isNotEmpty) 'Petugas: ${officer.trim()}',
      'Lokasi administratif tidak tersedia (data offline belum dipasang)',
    ];
    final fontSize = 19 * scale;
    final lineHeight = 26 * scale;
    final panelHeight = padding * 2 + lines.length * lineHeight;
    final panelTop = size.height - panelHeight;
    canvas.drawRect(
      Rect.fromLTWH(0, panelTop, size.width, panelHeight),
      Paint()..color = const Color(0xD9001725),
    );
    final logoRect = Rect.fromLTWH(
      padding,
      panelTop + (panelHeight - logoHeight) / 2,
      logoWidth,
      logoHeight,
    );
    canvas.drawImageRect(
      logo,
      Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
      logoRect,
      Paint()..filterQuality = FilterQuality.high,
    );
    for (var i = 0; i < lines.length; i++) {
      final painter = TextPainter(
        text: TextSpan(
          text: lines[i],
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: maxTextWidth);
      painter.paint(
        canvas,
        Offset(textLeft, panelTop + padding + i * lineHeight),
      );
    }

    final picture = recorder.endRecording();
    final output = await picture.toImage(source.width, source.height);
    final png = await output.toByteData(format: ui.ImageByteFormat.png);
    if (png == null) throw StateError('Gagal membuat gambar watermark.');
    final file = File(p.setExtension(outputPath, '.png'));
    await file.writeAsBytes(png.buffer.asUint8List(), flush: true);
    source.dispose();
    logo.dispose();
    output.dispose();
    picture.dispose();
    codec.dispose();
    logoCodec.dispose();
    return file;
  }

  static String _dateTime(DateTime value) {
    final local = value.toLocal();
    final offset = local.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}:${two(local.second)} UTC$sign$hours:$minutes';
  }
}
