import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/movie_model.dart';

class DetailsScreen extends StatefulWidget {
  final Movie movie;

  DetailsScreen({required this.movie});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late WebViewController _controller;
  bool isLoading = true;
  bool isDownloading = false;
  double downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    final streamUrl = 'https://vidlink.pro/movie/${widget.movie.id}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F172A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(streamUrl));
  }

  // অ্যাপের ভেতরে ফাইল ডাউনলোড করার ফাংশন
  Future<void> downloadMovie() async {
    try {
      setState(() {
        isDownloading = true;
        downloadProgress = 0.0;
      });

      // ডাউনলোডের সোর্স লিংক (প্রয়োজনমতো পরিবর্তন করে নিতে পারো)
      final videoUrl = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
      
      Dio dio = Dio();

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      String savePath = '${directory?.path}/${widget.movie.title}.mp4';

      await dio.download(
        videoUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        isDownloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ডাউনলোড সফল হয়েছে! ফাইল সেভ হয়েছে: $savePath'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ডাউনলোড ব্যর্থ হয়েছে: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E293B),
        title: Text(
          widget.movie.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // ভিডিও প্লেয়ার সেকশন
          Container(
            height: 230,
            width: double.infinity,
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (isLoading)
                  Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  ),
              ],
            ),
          ),
          
          // ডিটেইলস ও ডাউনলোড বাটন সেকশন
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text(
                  widget.movie.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.play_circle_fill, color: Colors.redAccent, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'Auto Stream Live',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                // ইন-অ্যাপ ডাউনলোড বাটন বা প্রোগ্রেস বার
                isDownloading
                    ? Column(
                        children: [
                          LinearProgressIndicator(
                            value: downloadProgress,
                            backgroundColor: Colors.grey[800],
                            color: Colors.redAccent,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'ডাউনলোড হচ্ছে: ${(downloadProgress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: downloadMovie,
                        icon: Icon(Icons.download_rounded, size: 22),
                        label: Text(
                          'অ্যাপের ভেতর ডাউনলোড করুন',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                SizedBox(height: 20),
                Text(
                  'ওভারভিউ:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.movie.overview.isNotEmpty
                      ? widget.movie.overview
                      : 'কোনো বিবরণ পাওয়া যায়নি',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
