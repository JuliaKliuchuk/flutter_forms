import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_forms/pages/user_info_page.dart';

import '../model/user.dart';

class RegisterFormPage extends StatefulWidget {
  const RegisterFormPage({Key? key}) : super(key: key);

  @override
  _RegisterFormPageState createState() => _RegisterFormPageState();
}

class _RegisterFormPageState extends State<RegisterFormPage> {
  bool _hidePass = true;
// TODO: - объединяем логику работы с формой(обновить, проверить на валидацию и т.д)
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _countries = ['Belarus', 'Ukraine', 'Germany', 'France'];
  String _selectedCountry = 'Belarus';

// TODO: - для получения введенных данных
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _storyController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passFocus = FocusNode();

  User newUser = User();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _storyController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();

    _nameFocus.dispose();
    _phoneFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _fieldFocusChange(
    BuildContext context,
    FocusNode currentFocus,
    FocusNode nextFocus,
  ) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Register Form'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            //Full Name
            TextFormField(
              focusNode: _nameFocus,
              autofocus: true,
              onFieldSubmitted: (_) {
                _fieldFocusChange(context, _nameFocus, _phoneFocus);
              },
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                hintText: 'ФИО',
                prefixIcon: const Icon(Icons.person),
                suffixIcon: GestureDetector(
                  onTap: () {
                    _nameController.clear();
                  },
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              ),
              validator: _validateName,
              onSaved: (value) => newUser.name = value as String,
            ),

            const SizedBox(height: 10),

            //Phone Number
            TextFormField(
              focusNode: _phoneFocus,
              onFieldSubmitted: (_) {
                _fieldFocusChange(context, _phoneFocus, _passFocus);
              },
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'Как мы можем связаться с вами?',
                helperText: 'Формат номера телефона: (XXX)XXX-XXXX',
                prefixIcon: const Icon(Icons.call),
                suffixIcon: GestureDetector(
                  onTap: () {
                    _phoneController.clear();
                  },
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                // FilteringTextInputFormatter.digitsOnly,
                FilteringTextInputFormatter(RegExp(r'^[()\d -]{1,15}$'),
                    allow: true),
              ],
              validator: (value) => _validatePhoneNumber(value!)
                  ? null
                  : 'Формат номера телефона (###)###-####',
              onSaved: (value) => newUser.phone = value as String,
            ),

            const SizedBox(height: 10),

            //Email Address
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Введите адрес электронной почты',
                icon: Icon(Icons.mail),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              onSaved: (value) => newUser.email = value!,
            ),

            const SizedBox(height: 10),

            //Country
            DropdownButtonFormField(
              decoration: const InputDecoration(
                  icon: Icon(Icons.map), labelText: 'Страна'),
              items: _countries.map((country) {
                return DropdownMenuItem(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (country) {
                setState(() {
                  _selectedCountry = country as String;
                  newUser.country = country;
                });
              },
              value: _selectedCountry,
              validator: (val) {
                return val == null ? 'Выберите страну' : null;
              },
            ),

            const SizedBox(height: 20),

            //Life Story
            TextFormField(
              controller: _storyController,
              decoration: const InputDecoration(
                labelText: 'Life Story',
                hintText: 'Расскажите нам о себе',
                helperText: 'Будьте краткими',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              inputFormatters: [
                LengthLimitingTextInputFormatter(100),
              ],
              onSaved: (value) => newUser.story = value as String,
            ),

            const SizedBox(height: 10),

            //Password
            TextFormField(
              focusNode: _passFocus,
              controller: _passController,
              obscureText: _hidePass,
              maxLength: 8,
              decoration: InputDecoration(
                labelText: 'Password *',
                hintText: 'Введите пароль',
                suffixIcon: IconButton(
                  icon:
                      Icon(_hidePass ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _hidePass = !_hidePass;
                    });
                  },
                ),
                icon: const Icon(Icons.security),
              ),
              validator: _validatePassword,
            ),

            const SizedBox(height: 10),

            //Confirm Password
            TextFormField(
              controller: _confirmPassController,
              obscureText: _hidePass,
              maxLength: 8,
              decoration: const InputDecoration(
                labelText: 'Confirm Password *',
                hintText: 'Подтвердите пароль',
                icon: Icon(Icons.border_color),
              ),
              validator: _validatePassword,
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                textStyle: const TextStyle(color: Colors.white),
              ),
              child: const Text('Submit Form'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _showDialog(name: _nameController.text);
      log('Name: ${_nameController.text}');
      log('Phone: ${_phoneController.text}');
      log('Email: ${_emailController.text}');
      log('Country: $_selectedCountry');
      log('Story: ${_storyController.text}');
    } else {
      _showMessage('Форма заполнена не корректно');
    }
  }

  String? _validateName(String? value) {
    final _nameExp = RegExp(r'^[A-Za-z ]+$');
    if (value == null) {
      return 'Обязательно для заполнения';
    } else if (!_nameExp.hasMatch(value)) {
      return 'Только буквы';
    } else {
      return null;
    }
  }

  bool _validatePhoneNumber(String input) {
    final _phoneExp = RegExp(r'^\(\d\d\d\)\d\d\d\-\d\d\d\d$');
    return _phoneExp.hasMatch(input);
  }

  String? _validateEmail(String? value) {
    if (value == null) {
      return 'Обязательно для заполнения';
    } else if (!_emailController.text.contains('@')) {
      return 'Неверный адрес электронной почты';
    } else {
      return null;
    }
  }

  String? _validatePassword(String? value) {
    if (_passController.text.length != 8) {
      return 'Необходимо ввести 8 символов';
    } else if (_confirmPassController.text != _passController.text) {
      return 'Пароль не совпадает';
    } else {
      return null;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
    ));
  }

  void _showDialog({String? name}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Регистрация прошла успешно'),
            content: Text('Пользователь $name успешно зарегистрирован'),
            actions: [
              OutlinedButton(
                  onPressed: () {
                    print('newUser  ${newUser.name}');
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserInfoPage(
                          userInfo: newUser,
                        ),
                      ),
                    );
                  },
                  child: const Text('Ок'))
            ],
          );
        });
  }
}
