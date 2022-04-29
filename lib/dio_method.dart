import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DioMethodPage extends StatefulWidget {
  const DioMethodPage({Key? key}) : super(key: key);

  @override
  State<DioMethodPage> createState() => _DioMethodPageState();
}

class _DioMethodPageState extends State<DioMethodPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Downloader")),
      body: Center(
        child: TextButton(onPressed: () => openFile(
            "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
            "certificate.pdf"
        ), child: Text("Download")),
      ),
    );
  }

  Future openFile(String url, String name) async {
    final file = await downloadFile(url, name);
    OpenFile.open(file?.path, type: "application/pdf");
  }

  Future<File?> downloadFile(String url, String name) async {
    // ------ Using Temp Dir
    // var tempDir = await getTemporaryDirectory();
    // String savePath = tempDir.path + "/${name}";

    // ------ Using Folder Data
    // final appStorage = await getApplicationDocumentsDirectory();
    // String savePath = appStorage.path + "/${name}";
    // File file = File(savePath);

    // ------ Using Folder Download
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    String savePath = "/storage/emulated/0/Download/${name}";
    File file = File(savePath);

    print(savePath);

    // ------ Download
    final response = await Dio().get(
      url,
      onReceiveProgress: showDownloadProgress,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
      ),
    );

    var raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    await raf.close();
    return file;
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

}
