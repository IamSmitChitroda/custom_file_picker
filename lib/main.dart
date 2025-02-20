import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const InstagramPostScreen(),
    );
  }
}

class InstagramPostScreen extends StatefulWidget {
  const InstagramPostScreen({super.key});

  @override
  State<InstagramPostScreen> createState() => _InstagramPostScreenState();
}

class _InstagramPostScreenState extends State<InstagramPostScreen> {
  List<AssetEntity> _mediaFiles = [];
  AssetEntity? _selectedMedia;

  @override
  void initState() {
    super.initState();
    _fetchMedia();
  }

  Future<void> _fetchMedia() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(type: RequestType.all);
      List<AssetEntity> media =
          await albums.first.getAssetListPaged(page: 0, size: 100);

      setState(() {
        _mediaFiles = media;
        _selectedMedia = media.isNotEmpty ? media.first : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Next',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[300],
            height: 300,
            width: double.infinity,
            child: _selectedMedia != null
                ? FutureBuilder<File?>(
                    future: _selectedMedia!.file,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.data != null) {
                        return Image.file(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                snapshot.data!.path.split('.').last,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 20,
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  )
                : const Center(child: Text('No media available')),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _mediaFiles.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      _selectedMedia = _mediaFiles[index];
                    });
                  },
                  child: FutureBuilder<File?>(
                    future: _mediaFiles[index].file,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.data != null) {
                        return Image.file(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                snapshot.data!.path.split('.').last,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 20,
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
