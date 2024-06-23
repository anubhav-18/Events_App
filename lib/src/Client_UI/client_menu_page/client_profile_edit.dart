import 'package:cu_events/src/Client_UI/client_menu_page.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/models/client_model.dart';
import 'package:cu_events/src/reusable_widget/custom_button.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/reusable_widget/custom_textfiled.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditClientProfilePage extends StatefulWidget {
  const EditClientProfilePage({Key? key}) : super(key: key);

  @override
  _EditClientProfilePageState createState() => _EditClientProfilePageState();
}

class _EditClientProfilePageState extends State<EditClientProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _desginationController;
  String? _selectedCategory;
  DateTime? _selectedDateOfBirth;
  bool _isLoading = true;
  ClientModel? _clientModel;
  bool _isEdited = false;

  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchClientData();
  }

  Future<void> _fetchClientData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        ClientModel? clientModel =
            await _firestoreService.getClientDetails(user.uid);
        if (clientModel != null) {
          setState(() {
            _clientModel = clientModel;
            _nameController = TextEditingController(text: clientModel.name)
              ..addListener(_checkIfEdited);
            _emailController = TextEditingController(text: clientModel.email)
              ..addListener(_checkIfEdited);
            _phoneController = TextEditingController(text: clientModel.phoneNo)
              ..addListener(_checkIfEdited);
            _desginationController =
                TextEditingController(text: clientModel.designation)
                  ..addListener(_checkIfEdited);
            _isLoading = false; // Data loaded, stop the loading state
          });
        }
      }
    } catch (e) {
      // Handle errors here (e.g., show error message)
      print('Error fetching client data: $e');
    }
  }

  void _checkIfEdited() {
    bool isEdited = _nameController.text != _clientModel?.name ||
        _emailController.text != _clientModel?.email ||
        _phoneController.text != _clientModel?.phoneNo ||
        _desginationController.text != _clientModel?.designation;
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

        ClientModel updatedClient = ClientModel(
            id: _clientModel!.id,
            name: _nameController.text,
            email: _emailController.text,
            phoneNo: _phoneController.text,
            designation: _desginationController.text,
            role: 'client');

        await _firestoreService.updateClientDetails(updatedClient);

        showCustomSnackBar(context, 'Profile updated successfully');
        Navigator.pop(context, updatedClient);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ClientMenuPage(
              updatedUser: updatedClient,
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
              _nameController.text.isNotEmpty
                  ? _nameController.text[0].toUpperCase()
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
                                  // Name
                                  CustomTextField(
                                    labelText: 'Name',
                                    controller: _nameController,
                                  ),
                                  const SizedBox(height: 20),
                                  // Email (non-editable)
                                  CustomTextField(
                                    labelText: 'Email',
                                    controller: _emailController,
                                    readOnly: true,
                                  ),
                                  const SizedBox(height: 20),
                                  CustomTextField(
                                    labelText: 'Desgination',
                                    controller: _desginationController,
                                    readOnly: false,
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
}
