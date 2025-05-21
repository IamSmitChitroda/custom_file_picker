part of 'upload_logo_bloc.dart';

@immutable
sealed class UploadLogoEvent {}

class FetchImageEvent extends UploadLogoEvent {
  final int page;

  FetchImageEvent({required this.page});
}

class SelectImageEvent extends UploadLogoEvent {
  final File image;

  SelectImageEvent({required this.image});
}
