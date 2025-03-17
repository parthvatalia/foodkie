// presentation/common_widgets/image_picker_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/core/utils/image_utils.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';

class ImagePickerWidget extends StatefulWidget {
  final String? imageUrl;
  final File? imageFile;
  final Function(File?) onImagePicked;
  final double height;
  final double width;
  final BoxShape shape;
  final String placeholder;
  final bool showBorder;

  const ImagePickerWidget({
    Key? key,
    this.imageUrl,
    this.imageFile,
    required this.onImagePicked,
    this.height = 200,
    this.width = double.infinity,
    this.shape = BoxShape.rectangle,
    this.placeholder = 'Select Image',
    this.showBorder = true,
  }) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _imageFile = widget.imageFile;
  }

  void _pickImage(ImageSource source) async {
    final pickedFile = await ImageUtils.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      widget.onImagePicked(pickedFile);
    }
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text(StringConstants.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text(StringConstants.chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPickerOptions(context),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: widget.shape,
          borderRadius: widget.shape == BoxShape.rectangle
              ? BorderRadius.circular(12)
              : null,
          border: widget.showBorder
              ? Border.all(
            color: AppTheme.primaryColor.withOpacity(0.5),
            width: 2,
          )
              : null,
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // If there's a selected image file
    if (_imageFile != null) {
      return _buildImagePreview(
        imageProvider: FileImage(_imageFile!),
        isFile: true,
      );
    }

    // If there's a remote image URL
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return _buildImagePreview(
        imageProvider: NetworkImage(widget.imageUrl!),
        isFile: false,
      );
    }

    // Otherwise show the placeholder
    return _buildPlaceholder();
  }

  Widget _buildImagePreview({
    required ImageProvider imageProvider,
    required bool isFile,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // The image
        ClipRRect(
          borderRadius: widget.shape == BoxShape.rectangle
              ? BorderRadius.circular(12)
              : BorderRadius.circular(widget.height),
          child: Image(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),

        // Overlay with edit icon
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: widget.shape == BoxShape.circle
                  ? BoxShape.circle
                  : BoxShape.rectangle,
              borderRadius: widget.shape == BoxShape.rectangle
                  ? const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              )
                  : null,
            ),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.add_a_photo,
          size: 40,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 8),
        Text(
          widget.placeholder,
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}