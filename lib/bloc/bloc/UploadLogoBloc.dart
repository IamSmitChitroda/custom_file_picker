import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:photo_manager/photo_manager.dart';

part 'upload_logo_event.dart';

part 'upload_logo_state.dart';

class UploadLogoBloc extends Bloc<UploadLogoEvent, UploadLogoState> {
  UploadLogoBloc() : super(UploadLogoInitial()) {
    on<FetchImageEvent>(_fetchImages);
    on<SelectImageEvent>(_selectImage);
  }

  Future<void> _fetchImages(
    FetchImageEvent event,
    Emitter<UploadLogoState> emit,
  ) async {
    int maxSize = 40;

    emit(LoadingState());

    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();

      if (!ps.isAuth) {
        emit(
          ErrorState(error: "The permission is mandatory for uploading a logo"),
        );
        return;
      }

      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      if (albums.isEmpty) {
        emit(ErrorState(error: "No image albums found"));
        return;
      }

      final List<AssetEntity> media = await albums.first.getAssetListPaged(
        page: event.page,
        size: maxSize,
      );

      List<File> files = [];

      for (int i = 0; i < media.length; i++) {
        files.add(await media[i].file ?? File(""));
      }

      emit(
        FetchImageState(files: files, isLastPage: media.length < maxSize),
      );
    } catch (e) {
      emit(ErrorState(error: e.toString()));
    }
  }

  Future<void> _selectImage(
    SelectImageEvent event,
    Emitter<UploadLogoState> emit,
  ) async {
    emit(SelectImageState(image: event.image));
  }
}
