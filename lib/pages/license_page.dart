import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ios_club_app/widgets/club_app_bar.dart';
import 'dart:async' show Future;

class LicensePage extends StatefulWidget {
  const LicensePage({super.key});

  @override
  State<LicensePage> createState() => _LicensePageState();
}

class _LicensePageState extends State<LicensePage> {
  String _licenseText = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLicense();
  }

  Future<void> _loadLicense() async {
    try {
      final licenseContent = await rootBundle.loadString('LICENSE');
      setState(() {
        _licenseText = licenseContent;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _licenseText = '无法加载许可证文件';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClubAppBar(title: '开源许可证'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: SelectableText(_licenseText),
            ),
    );
  }
}
