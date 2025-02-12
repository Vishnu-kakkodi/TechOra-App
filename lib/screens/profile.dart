import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  String name = "";
  String email = "";
  String mobile = "";
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name") ?? "";
      email = prefs.getString("email") ?? "";
      mobile = prefs.getString("mobile") ?? "+91 9876543210";
      imageUrl = prefs.getString("profilePhoto");
    });
    print('Imagepathhhhhhhhhhhhhhhhhhh,$imageUrl');
  }

  /// Pick an image from the gallery and save its path
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text("Take Photo"),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromSource(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromSource(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  /// Function to handle image picking from a given source
  Future<void> _pickImageFromSource(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("profileImage", pickedFile.path);
      setState(() {
        imageUrl = pickedFile.path;
      });
    }
  }

  Future<void> editProfileImage() async {
    TextEditingController imageController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Profile Picture"),
        content: TextField(
          controller: imageController,
          decoration: const InputDecoration(
            hintText: "Enter new image URL",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              String newImageUrl = imageController.text.trim();
              if (newImageUrl.isNotEmpty) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString("profileImage", newImageUrl);

                setState(() {
                  imageUrl = newImageUrl;
                });

                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// Edit a field and save it to SharedPreferences
Future<void> _editField(String field, String currentValue) async {
  TextEditingController controller = TextEditingController(text: currentValue);

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Edit $field"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter new $field"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              String newValue = controller.text.trim();
              if (newValue.isNotEmpty) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                
                // Store the updated value in SharedPreferences
                await prefs.setString(field, newValue);

                // 🔥 Call setState to refresh the UI
                setState(() {
                  if (field == "userName") {
                    name = newValue;
                  } else if (field == "phoneNumber") {
                    mobile = newValue;
                  }
                });

                // 🔥 Call API to update profile
                bool success = await ApiService.updateProfile(field, newValue);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$field updated successfully!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to update $field")),
                  );
                }

                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.brown,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                          "https://techora-aws-s3-bucket1.s3.ap-south-1.amazonaws.com/user_photo/2025/1736753167980_WhatsApp_Image_2025-01-13_at_10.15.49_341a8a0d.jpg")
                      as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed:
                          _pickImage, // Now shows camera & gallery options
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Profile Fields with Edit Button
            _buildProfileField("Name", name, () => _editField("userName", name)),
            _buildProfileField(
                "Email", email, () => _editField("email", email)),
            _buildProfileField(
                "Mobile", mobile, () => _editField("phoneNumber", mobile)),
          ],
        ),
      ),
    );
  }

  /// Helper Widget to Build Profile Fields with Edit Buttons
  Widget _buildProfileField(String label, String value, VoidCallback onEdit) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        trailing: label == "Email"
          ? null // Hide edit button for Email
          : IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
      ),
    );
  }
}
