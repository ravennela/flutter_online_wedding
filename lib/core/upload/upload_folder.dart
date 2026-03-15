/// Folder names for catalog upload. Used to segregate files in Cloudinary.
/// Use when calling [FileUploadDataSource.upload] so the backend stores under the right path.
enum UploadFolder {
  events('event-booking/events'),
  decorations('event-booking/decorations');

  final String value;
  const UploadFolder(this.value);
}
