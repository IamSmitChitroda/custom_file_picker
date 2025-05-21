import 'dart:io';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_label/common/loading_view.dart';
import 'package:white_label/common/no_data_widget.dart';
import 'package:white_label/constant/color_constant.dart';
import 'package:white_label/constant/text_style_constant.dart';
import 'package:white_label/helpers/snack_bar_helper.dart';
import 'package:white_label/pages/upload_logo/bloc/upload_logo_bloc.dart';

class UploadLogoScreen extends StatefulWidget {
  const UploadLogoScreen({super.key});

  @override
  State<UploadLogoScreen> createState() => _UploadLogoScreenState();
}

class _UploadLogoScreenState extends State<UploadLogoScreen> {
  late final UploadLogoBloc bloc = BlocProvider.of<UploadLogoBloc>(context);
  ScrollController scrollController = ScrollController();

  bool isLoading = false;
  bool isLastPage = false;

  int page = 0;

  File? selectedImage;

  List<File> _mediaFiles = [];

  @override
  void initState() {
    bloc.add(FetchImageEvent(page: page));
    super.initState();
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (!isLastPage) {
      double position = 0.8 * scrollController.position.maxScrollExtent;
      if (scrollController.position.pixels >= position) {
        page += 1;
        bloc.add(FetchImageEvent(page: page));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return BlocConsumer<UploadLogoBloc, UploadLogoState>(
      listener: (context, state) {
        if (state is LoadingState) {
          isLoading = true;
        } else if (state is FetchImageState) {
          isLoading = false;
          isLastPage = state.isLastPage;
          page == 0
              ? _mediaFiles = state.files
              : _mediaFiles.addAll(state.files);
        } else if (state is ErrorState) {
          isLoading = false;

          SnackBarHelper.instance.errorMessage(
            context: context,
            message: state.error,
          );
        } else if (state is SelectImageState) {
          isLoading = false;
          selectedImage = state.image;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close),
            ),
            actions: [
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                  margin: EdgeInsets.fromLTRB(0, 10, 18, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: ColorConstant.instance.greyShade300,
                    ),
                  ),
                  child: Text(
                    "UPLOAD",
                    style: TextStyleConstant.instance.ts10BlackW500,
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              if (_mediaFiles.isNotEmpty)
                Column(
                  children: [
                    Container(
                      color: Colors.grey[300],
                      height: size.height * 0.45,
                      width: double.infinity,
                      child: selectedImage != null
                          ? Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(Icons.do_not_disturb_alt),
                                );
                              },
                              frameBuilder: (
                                context,
                                child,
                                frame,
                                wasSynchronouslyLoaded,
                              ) {
                                if (frame != null) return child;
                                return Container(
                                  color: Colors.white,
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                );
                              },
                            )
                          : const Center(
                              child: Text('No image selected yet'),
                            ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        try {
                          FilePickerResult? selectedFile =
                              await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                          );

                          if (selectedFile != null) {
                            File file = File(selectedFile.files.first.path!);

                            bloc.add(
                              SelectImageEvent(image: file),
                            );
                          }
                        } catch (e) {
                          SnackBarHelper.instance.errorMessage(
                            context: context,
                            message: e.toString(),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 1),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: ColorConstant.instance.white,
                          border: Border(top: BorderSide()),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Recents",
                              style: TextStyleConstant.instance.ts16BlackW600,
                            ),
                            Icon(
                              Icons.chevron_right,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        controller: scrollController,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: _mediaFiles.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              bloc.add(
                                SelectImageEvent(image: _mediaFiles[index]),
                              );
                            },
                            child: Image.file(
                              _mediaFiles[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(Icons.do_not_disturb_alt),
                                  /*Text(
                                        "",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 20,
                                        ),
                                      ),*/
                                );
                              },
                              frameBuilder: (
                                context,
                                child,
                                frame,
                                wasSynchronouslyLoaded,
                              ) {
                                if (frame != null) return child;
                                return Container(
                                  color: Colors.white,
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              if (isLoading && _mediaFiles.isEmpty) LoadingView(),
              if (!isLoading && _mediaFiles.isEmpty)
                NoDataWidget(title: "No Image", body: "No Image Here")
            ],
          ),
        );
      },
    );
  }
}
