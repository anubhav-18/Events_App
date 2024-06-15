import 'dart:io';
import 'package:cu_events/src/UI/home/home_sections/menu_page_section.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/models/user_model.dart';
import 'package:cu_events/src/reusable_widget/custom_button.dart';
import 'package:cu_events/src/reusable_widget/custom_dropdown.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/reusable_widget/custom_textfiled.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  File? _image;
  bool _isLoading = true;
  String? _imageUrl;
  UserModel? _userModel;

  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _dobController = TextEditingController();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        UserModel? userModel = await _firestoreService.getUserDetails(user.uid);
        if (userModel != null) {
          setState(() {
            _userModel = userModel;
            _firstNameController =
                TextEditingController(text: userModel.firstName);
            _lastNameController =
                TextEditingController(text: userModel.lastName);
            _emailController = TextEditingController(text: userModel.email);
            _phoneController =
                TextEditingController(text: userModel.phoneNo ?? "");
            _selectedGender = userModel.gender;
            _dobController = TextEditingController(
                text: userModel.dateOfBirth != null
                    ? DateFormat('yyyy-MM-dd').format(userModel.dateOfBirth!)
                    : '');
            _imageUrl = userModel.profilePicture;
            _isLoading = false; // Data loaded, stop the loading state
          });
        }
      }
    } catch (e) {
      // Handle errors here (e.g., show error message)
      print('Error fetching user data: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? imageUrl = _imageUrl;
        if (_image != null) {
          imageUrl = await _uploadImageToFirebase(_image!);
        }

        UserModel updatedUser = UserModel(
          id: _userModel!.id,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          phoneNo: _phoneController.text,
          gender: _selectedGender,
          dateOfBirth: _selectedDateOfBirth,
          profilePicture: imageUrl,
        );

        await _firestoreService.updateUserDetails(updatedUser);

        showCustomSnackBar(context, 'Profile updated successfully');
        Navigator.pop(context, updatedUser);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MenuPage(
              updatedUser: updatedUser,
            ),
          ),
        );
      } catch (e) {
        showCustomSnackBar(context, 'Failed to update profile: $e');
        print(e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');
      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Function to build the profile picture section
  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Profile Picture (CircleAvatar)
          CircleAvatar(
            radius: 60,
            backgroundColor: primaryBckgnd,
            backgroundImage: _image != null
                ? FileImage(_image!) as ImageProvider
                : (_imageUrl != null ? NetworkImage(_imageUrl!) : null),
            child: (_image == null && _imageUrl == null)
                ? Text(
                    _firstNameController.text.isNotEmpty
                        ? _firstNameController.text[0].toUpperCase()
                        : '',
                    style: GoogleFonts.montserrat(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          // Edit Icon with BottomSheet
          Card(
            elevation: 4,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext bc) {
                    return _buildBottomSheet(context);
                  },
                );
              },
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: SvgPicture.asset(
                  'assets/icons/categories/edit.svg',
                  width: 17,
                  height: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BottomSheet Content
  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      // height: 170, // Adjust height as needed
      decoration: const BoxDecoration(
        color: backgndColor, // Use your background color
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Wrap(
        children: [
          const SizedBox(
            height: 10,
          ),
          ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.grey.withOpacity(0.2),
              child: SvgPicture.asset(
                'assets/icons/categories/change_picture.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6), BlendMode.srcIn),
              ),
            ),
            title: Text(
              'Change Picture',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              _selectImage();
            },
          ),
          const Divider(
            thickness: 1,
            color: Colors.black,
          ),
          ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.grey.withOpacity(0.2),
              child: SvgPicture.asset(
                'assets/icons/categories/delete.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6), BlendMode.srcIn),
              ),
            ),
            title: Text(
              'Delete Picture',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              setState(() {
                _image = null;
                _imageUrl = null;
              });
            },
          ),
          const Divider(
            thickness: 1,
            color: Colors.black,
          ),
          ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.grey.withOpacity(0.2),
              child: SvgPicture.asset(
                'assets/icons/categories/cancel.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6), BlendMode.srcIn),
              ),
            ),
            title: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 22,
          ),
        ),
        title: Text(
          'Your Profile',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        elevation: 0,
        backgroundColor: greyColor,
      ),
      backgroundColor: backgndColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildProfilePicture(), // Profile Picture
                      const SizedBox(height: 20),
                      // First Name
                      CustomTextField(
                        labelText: 'First Name',
                        controller: _firstNameController,
                      ),
                      const SizedBox(height: 20),
                      // Last Name
                      CustomTextField(
                        labelText: 'Last Name',
                        controller: _lastNameController,
                      ),
                      const SizedBox(height: 20),
                      // Email (non-editable)
                      CustomTextField(
                        labelText: 'Email',
                        controller: _emailController,
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      // Phone Number
                      CustomTextField(
                        labelText: 'Phone Number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: true,
                        wantValidator: false,
                      ),
                      const SizedBox(height: 20),
                      // Gender Dropdown (optional)
                      CustomDropdown(
                        labelText: 'Gender',
                        value: _selectedGender,
                        items: [
                          customDropdownItem('Male'),
                          customDropdownItem('Female'),
                          customDropdownItem('Other'),
                          customDropdownItem('Rather not say'),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        labelText: 'Date Of Birth',
                        controller: _dobController,
                        wantValidator: false,
                        readOnly: true,
                        isDateField: true,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDateOfBirth ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDateOfBirth = picked;
                              _dobController.text =
                                  DateFormat('yyyy-MM-dd').format(picked);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      // Save Changes Button
                      CustomElevatedButton(
                        onPressed: _updateProfile,
                        title: 'Save Changes',
                        widget: true,
                        width: double.infinity,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : Text(
                                'Save Changes',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: whiteColor),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  DropdownMenuItem<String> customDropdownItem(String value) => DropdownMenuItem(
        value: value,
        child: Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.w600),
        ),
      );
}
