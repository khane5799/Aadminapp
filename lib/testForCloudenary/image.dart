// // file: profile_image_uploader.dart
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageUploader extends StatefulWidget {
  const ProfileImageUploader({super.key});
  @override
  State<ProfileImageUploader> createState() => _ProfileImageUploaderState();
}

class _ProfileImageUploaderState extends State<ProfileImageUploader> {
  final _picker = ImagePicker();
  final _cloudinary = CloudinaryPublic('dhpq5ao2s', 'flutter_profiles',
      cache: false); //where are these values?
  String? _imageUrl;
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80);
    if (picked == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final res = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(picked.path,
            resourceType: CloudinaryResourceType.Image, folder: 'profile_pics'),
      );
      setState(() {
        _imageUrl = res.secureUrl; // <-- store this in your DB / user profile
      });
      // Optionally: save _imageUrl to Firestore or your backend here.
    } on CloudinaryException catch (e) {
      debugPrint('Cloudinary error: ${e.message}');
      // handle error (show toast)
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: _imageUrl != null ? NetworkImage(_imageUrl!) : null,
          child: _imageUrl == null ? const Icon(Icons.person, size: 48) : null,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _pickAndUpload,
          icon: _isUploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.upload),
          label: Text(_isUploading ? 'Uploading...' : 'Pick & Upload'),
        ),
      ],
    );
  }
}
// file: cloudinary_helper.dart



// import 'dart:io';

// import 'package:cloudinary_public/cloudinary_public.dart';

// class CloudinaryHelper {
//   final CloudinaryPublic _cloudinary = CloudinaryPublic(
//     'dhpq5ao2s', // Replace with your Cloudinary cloud name
//     'flutter_profiles', // Replace with your upload preset
//     cache: false,
//   );

//   /// Upload a local image file to Cloudinary and get the URL
//   Future<String?> uploadImage(File file) async {
//     try {
//       final response = await _cloudinary.uploadFile(
//         CloudinaryFile.fromFile(
//           file.path,
//           resourceType: CloudinaryResourceType.Image,
//           folder: 'profile_pics', // optional folder
//         ),
//       );
//       return response.secureUrl;
//     } on CloudinaryException catch (e) {
//       print('Cloudinary error: ${e.message}');
//       return null;
//     } catch (e) {
//       print('Unexpected error: $e');
//       return null;
//     }
//   }
// }
