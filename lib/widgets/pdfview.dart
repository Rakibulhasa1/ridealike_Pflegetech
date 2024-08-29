import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ridealike/pages/common/constant_url.dart';

class PdfView extends StatefulWidget {
  final String id;
  final String title;

  const PdfView({Key? key,required this.id,required this.title}) : super(key: key);

  @override
  _PdfViewState createState() => _PdfViewState(this.id, this.title);
}

class _PdfViewState extends State<PdfView> {
  final String id;
  final String title;

  bool _isLoading = true;
  PDFDocument? document;

  _PdfViewState(this.id, this.title);

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      loadDocument();
    });
  }

  loadDocument() async {
    print("$storageServerUrl/" + id);
    document =
        await PDFDocument.fromURL("$storageServerUrl/" + id);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          title,
        ),
      ),
      body: Center(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : PDFViewer(document: document!),
      ),
    );
  }
}
