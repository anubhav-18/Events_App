import 'package:cu_events/src/UI/User_UI/home/home_sections/menu_page_section.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/models/user_model.dart';
import 'package:cu_events/src/reusable_widget/custom_button.dart';
import 'package:cu_events/src/reusable_widget/custom_dropdown.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/reusable_widget/custom_textfiled.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _isLoading = true;
  UserModel? _userModel;
  bool _isEdited = false;

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
                TextEditingController(text: userModel.firstName)
                  ..addListener(_checkIfEdited);
            _lastNameController =
                TextEditingController(text: userModel.lastName)
                  ..addListener(_checkIfEdited);
            _emailController = TextEditingController(text: userModel.email)
              ..addListener(_checkIfEdited);
            _phoneController =
                TextEditingController(text: userModel.phoneNo ?? "")
                  ..addListener(_checkIfEdited);
            _selectedGender = userModel.gender;
            _dobController = TextEditingController(
                text: userModel.dateOfBirth != null
                    ? DateFormat('yyyy-MM-dd').format(userModel.dateOfBirth!)
                    : '');
            _isLoading = false; // Data loaded, stop the loading state
          });
        }
      }
    } catch (e) {
      // Handle errors here (e.g., show error message)
      print('Error fetching user data: $e');
    }
  }

  void _checkIfEdited() {
    bool isEdited = _firstNameController.text != _userModel?.firstName ||
        _lastNameController.text != _userModel?.lastName ||
        _emailController.text != _userModel?.email ||
        _phoneController.text != _userModel?.phoneNo ||
        _selectedGender != _userModel?.gender ||
        _dobController.text !=
            (_userModel?.dateOfBirth != null
                ? DateFormat('yyyy-MM-dd').format(_userModel!.dateOfBirth!)
                : '');
    if (isEdited != _isEdited) {
      setState(() {
        _isEdited = isEdited;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserModel? latestUserData =
            await _firestoreService.getUserDetails(_userModel!.id);

        UserModel updatedUser = UserModel(
          id: _userModel!.id,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          phoneNo: _phoneController.text,
          gender: _selectedGender,
          dateOfBirth: _selectedDateOfBirth ?? latestUserData?.dateOfBirth,
          interests: [],
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
        showCustomSnackBar(context, 'Failed to update profile');
        print(e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Profile Picture (CircleAvatar)
          CircleAvatar(
            radius: 60,
            backgroundColor: primaryBckgnd,
            child: Text(
              _firstNameController.text.isNotEmpty
                  ? _firstNameController.text[0].toUpperCase()
                  : '',
              style: GoogleFonts.montserrat(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
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
                                    isPrefixIcon: true,
                                    prefixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            '+91',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ),
                                        const VerticalDivider(
                                          color: Colors.black,
                                          thickness: 1,
                                          width: 20,
                                        ),
                                      ],
                                    ),
                                    wantValidator: true,
                                    boolValidator: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return null; // Allows empty input
                                      } else if (!RegExp(r'^[6-9]\d{9}$')
                                          .hasMatch(value)) {
                                        return 'Please enter a valid Phone Number';
                                      }
                                      return null; // Valid input
                                    },
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
                                        _checkIfEdited();
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
                                      final DateTime? picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: _selectedDateOfBirth ??
                                            DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              colorScheme:
                                                  const ColorScheme.light(
                                                primary:
                                                    primaryBckgnd, // Head color
                                                onPrimary: Colors.white,
                                                onSurface: Colors.black, // Ear
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _selectedDateOfBirth = picked;
                                          _dobController.text =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(picked);
                                          _checkIfEdited();
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: greyColor,
                        padding: const EdgeInsets.all(16.0),
                        child: CustomElevatedButton(
                          onPressed: _isEdited ? _updateProfile : null,
                          title: 'Save Changes',
                          widget: true,
                          width: double.infinity,
                          isColor: true,
                          backgroundColor:
                              _isEdited ? primaryBckgnd : Colors.grey,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : Text(
                                  'Save Changes',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: _isEdited
                                            ? whiteColor
                                            : Colors.black.withOpacity(0.5),
                                      ),
                                ),
                        ),
                      ),
                    ],
                  ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
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
