import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:test_app/app_documents.dart';
import 'package:test_app/service_model.dart';
import 'UserProfilePage.dart';
import 'appbuttons_style.dart';
import 'cargo_type_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:test_app/ThreeDigitInputFormatter.dart';
import 'appcard_style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CargoTypeModelAdapter());
  Hive.registerAdapter(
      ServiceModelAdapter()); // ثبت TypeAdapter برای ServiceModel
  await Hive.openBox<CargoTypeModel>('cargoTypesBox');
  await Hive.openBox<ServiceModel>(
      'serviceBox'); // ایجاد Box برای ذخیره سرویس‌ها
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'افزودن سرویس حدید',
      locale: const Locale('fa', ''),
      supportedLocales: const [
        Locale('fa', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'vazir',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 14),
          bodyMedium: TextStyle(fontSize: 12),
          titleMedium: TextStyle(fontSize: 14),
          titleSmall: TextStyle(fontSize: 12),
          labelLarge: TextStyle(fontSize: 14),
        ),
        cardTheme: AppCardStyle.cardTheme,
      ),
      home: MainScreen(), // تغییر به صفحه اصلی با BottomNavigationBar
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // ایندکس صفحه کاربری (صفحه پیش‌فرض)

  // لیست صفحات
  final List<Widget> _pages = [
    DateTimePicker(), // صفحه افزودن سرویس جدید
    AddDocumentsPage(), // صفحه افزودن مدارک
    UserProfilePage(), // صفحه کاربری
  ];

  // تغییر صفحه هنگام کلیک روی آیتم‌های BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // نمایش صفحه فعلی
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        // ایندکس صفحه فعلی
        onTap: _onItemTapped,
        // تغییر صفحه هنگام کلیک
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'افزودن سرویس جدید',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'افزودن مدارک',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'صفحه کاربری',
          ),
        ],
        selectedItemColor: Colors.blue,
        // رنگ آیتم انتخاب شده
        unselectedItemColor: Colors.grey, // رنگ آیتم‌های غیرفعال
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _userNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    String userNumber = _userNumberController.text;
    String password = _passwordController.text;

    if (userNumber == '09199541276' && password == '123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DateTimePicker()),
      );
      setState(() {
        _errorMessage = '';
      });
    } else {
      setState(() {
        _errorMessage = 'شماره تماس یا رمز عبور اشتباه است.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ورود')),
      body: Center(
        // Center the card horizontally
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            // Wrapped the content with a Card
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  TextField(
                    controller: _userNumberController,
                    decoration: const InputDecoration(
                      labelText: 'شماره تماس',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'رمز عبور',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    // Ensure the parent container takes full width
                    child: ElevatedButton(
                      onPressed: () {
                        _login();
                      },
                      style: AppButtonStyle.primaryButtonStyle,
                      child: Text('ورود'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DateTimePicker extends StatefulWidget {
  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  String _button1Title = 'انتخاب زمان حرکت';
  String _button2Title = 'انتخاب زمان رسیدن به مقصد';
  String _tripDuration = 'مدت سفر محاسبه نشده است';

  Jalali? _selectedDate1;
  TimeOfDay? _selectedTime1;
  Jalali? _selectedDate2;
  TimeOfDay? _selectedTime2;

  String _origin = '';
  String _destination = '';

  String _selectedCargo = 'آجر';
  String _calculateButtonTitle = 'محاسبه هزینه حمل';
  String _shippingCost = '';
  String _finalShippingCost = '';
  final _numberFormatEnglish = NumberFormat("#,###", 'en_US');

  final List<String> _cargoTypes = ['آجر', 'ماسه', 'قند', 'چوب'];
  final String _addNewOption = 'افزودن گزینه جدید';
  String _cargoWeight = '';
  String _newCargoType = '';
  bool _showNewCargoTypeInput = false;
  String _costPerTon = '';

  final Box<CargoTypeModel> _cargoTypesBox =
      Hive.box<CargoTypeModel>('cargoTypesBox');
  final NumberFormat _numberFormat = NumberFormat.decimalPattern('fa');

  // Variables for travel costs
  String _tollCost = '';
  String _fuelCost = '';
  String _driverCost = '';
  String _disinfectionCost = '';
  String _billCost = '';
  String _highwayTollCost = '';
  String _loadingTipCost = '';
  String _unloadingTipCost = '';
  String _loadingScaleCost = '';
  String _unloadingScaleCost = '';
  String _totalCost = '';
  String _otherCost = '';
  String _finalTotalCost = ''; // New variable to store the final cost
  // Variables for receiver info
  String _receiverName = '';
  String _receiverPhone = '';

  // Variables for driver salary
  String _baseSalary = '';
  String _perDistanceSalary = '';
  String _distance = '';
  String _driverSalary = '';

  @override
  void initState() {
    super.initState();
    _loadCargoTypes();
  }

  void _loadCargoTypes() {
    final savedCargoTypes = _cargoTypesBox.values.toList();
    if (savedCargoTypes.isNotEmpty) {
      setState(() {
        _cargoTypes.addAll(savedCargoTypes.map((cargo) => cargo.name).toList());
      });
    }
  }

  void _saveCargoType(String cargoType) {
    final cargo = CargoTypeModel(cargoType);
    _cargoTypesBox.add(cargo);
  }

  bool _isCargoTypeDuplicate(String cargoType) {
    return _cargoTypes.contains(cargoType);
  }

  void _addNewCargoType() {
    if (_newCargoType.isNotEmpty) {
      if (_isCargoTypeDuplicate(_newCargoType)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('این نوع بار قبلاً اضافه شده است.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        setState(() {
          _cargoTypes.add(_newCargoType);
          _selectedCargo = _newCargoType;
          _saveCargoType(_newCargoType);
          _newCargoType = '';
          _showNewCargoTypeInput = false;
        });
      }
    }
  }

  void _calculateShippingCost() {
    if (_cargoWeight.isNotEmpty && _costPerTon.isNotEmpty) {
      double weight = double.parse(_cargoWeight);
      double cost = double.parse(_costPerTon);
      double totalCost =
          (weight * cost) / 1000; // Divide by 1000 to remove three zeros
      setState(() {
        _shippingCost = _numberFormatEnglish.format(totalCost.round());
        _calculateButtonTitle = 'هزینه حمل: $_shippingCost تومان';
        _finalShippingCost = _shippingCost;
      });
    }
  }

  void _calculateTotalCost() {
    double toll = double.tryParse(_tollCost) ?? 0;
    double fuel = double.tryParse(_fuelCost) ?? 0;
    double disinfection = double.tryParse(_disinfectionCost) ?? 0;
    double bill = double.tryParse(_billCost) ?? 0;
    double highwayToll = double.tryParse(_highwayTollCost) ?? 0;
    double loadingTip = double.tryParse(_loadingTipCost) ?? 0;
    double unloadingTip = double.tryParse(_unloadingTipCost) ?? 0;
    double loadingScale = double.tryParse(_loadingScaleCost) ?? 0;
    double unloadingScale = double.tryParse(_unloadingScaleCost) ?? 0;
    double otherCost =
        double.tryParse(_otherCost) ?? 0; // اضافه کردن سایر هزینه‌ها

    setState(() {
      _totalCost = _numberFormatEnglish.format((toll +
              fuel +
              disinfection +
              bill +
              highwayToll +
              loadingTip +
              unloadingTip +
              loadingScale +
              unloadingScale +
              otherCost) // افزودن سایر هزینه‌ها به محاسبات
          .round());
    });
  }

  void _calculateDriverSalary() {
    double perDistanceSalary = double.tryParse(_perDistanceSalary) ?? 0;
    double distance = double.tryParse(_distance) ?? 0;
    double shippingCost =
        double.tryParse(_finalShippingCost.replaceAll(',', '')) ?? 0;
    double totalCost =
        double.tryParse(_finalTotalCost.replaceAll(',', '')) ?? 0;
    double baseSalaryPercentage = double.tryParse(_baseSalary) ??
        0; // Get the percentage from _baseSalary

    double calculatedBaseSalary = 0;
    if (shippingCost - totalCost > 0) {
      calculatedBaseSalary =
          (baseSalaryPercentage / 100) * (shippingCost - totalCost);
    }

    double calculatedSalary =
        calculatedBaseSalary + (perDistanceSalary * distance);

    setState(() {
      _driverSalary = _numberFormatEnglish.format(calculatedSalary.round());
    });
  }

  void _saveToDatabase() {
    // ایجاد شیء ServiceModel با داده‌های وارد شده
    final serviceData = ServiceModel(
      origin: _origin,
      destination: _destination,
      cargoType: _selectedCargo,
      cargoWeight: _cargoWeight,
      shippingCost: _finalShippingCost,
      totalCost: _totalCost,
      receiverName: _receiverName,
      receiverPhone: _receiverPhone,
      driverSalary: _driverSalary,
      tollCost: _tollCost,
      fuelCost: _fuelCost,
      disinfectionCost: _disinfectionCost,
      billCost: _billCost,
      highwayTollCost: _highwayTollCost,
      loadingTipCost: _loadingTipCost,
      unloadingTipCost: _unloadingTipCost,
      loadingScaleCost: _loadingScaleCost,
      unloadingScaleCost: _unloadingScaleCost,
      otherCost: _otherCost,
      tripDuration: _tripDuration,
      selectedDate1: _selectedDate1?.formatFullDate() ?? '',
      selectedTime1: _selectedTime1?.format(context) ?? '',
      selectedDate2: _selectedDate2?.formatFullDate() ?? '',
      selectedTime2: _selectedTime2?.format(context) ?? '',
    );

    // ذخیره در Hive
    final serviceBox = Hive.box<ServiceModel>('serviceBox');
    serviceBox.add(serviceData);

    // نمایش پیام موفقیت
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('داده‌ها با موفقیت ذخیره شدند.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('افزودن سرویس بار جدید')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Card for selecting date and time
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ListTile(
                        title: Text(
                          'انتخاب زمان حرکت و رسیدن به مقصد',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              _showPersianDateTimePicker(context, 1),
                          style: AppButtonStyle.primaryButtonStyle,
                          child: Text(_button1Title),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              _showPersianDateTimePicker(context, 2),
                          style: AppButtonStyle.primaryButtonStyle,
                          child: Text(_button2Title),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _tripDuration,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        textDirection: ui.TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Card for add origin and destination
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ListTile(
                        title: Text(
                          'افزودن مبدا و مقصد',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'مبدا',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _origin = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'مقصد',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _destination = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Card for adding cargo details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ListTile(
                        title: Text(
                          'افزودن جزییات بار',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),

                      // Cargo Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCargo,
                        items: [
                          ..._cargoTypes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          DropdownMenuItem<String>(
                            value: _addNewOption,
                            child: Text(_addNewOption),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCargo = value!;
                            _showNewCargoTypeInput = value == _addNewOption;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'نوع بار',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input for adding new cargo type
                      Visibility(
                        visible: _showNewCargoTypeInput,
                        child: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'افزودن نوع بار جدید',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              enabled: _showNewCargoTypeInput,
                              onChanged: (value) {
                                setState(() {
                                  _newCargoType = value;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _addNewCargoType,
                                style: AppButtonStyle.primaryButtonStyle,
                                child: const Text('افزودن نوع بار'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Cargo Weight Input
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'وزن بار (کیلوگرم)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThreeDigitInputFormatter(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _cargoWeight = value.replaceAll(',', '');
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Cost per Ton Input
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'هزینه حمل هر تن بار (تومان)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThreeDigitInputFormatter(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _costPerTon = value.replaceAll(',', '');
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Calculate Shipping Cost Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _calculateShippingCost,
                          style: AppButtonStyle.primaryButtonStyle,
                          child: Text(_calculateButtonTitle),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _finalShippingCost.isEmpty
                            ? 'هزینه حمل محاسبه نشده است'
                            : 'هزینه حمل: $_finalShippingCost تومان',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // New card for travel costs
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ListTile(
                        title: Text(
                          'افزودن هزینه های سفر',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'هزینه سوخت (تومان)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThreeDigitInputFormatter(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _fuelCost = value.replaceAll(',', '');
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'هزینه ضدعفونی (تومان)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThreeDigitInputFormatter(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _disinfectionCost = value.replaceAll(',', '');
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'هزینه بارنامه (تومان)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThreeDigitInputFormatter(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _billCost = value.replaceAll(',', '');
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'عوارض آزادراهی پرداخت شده (تومان)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThreeDigitInputFormatter(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _highwayTollCost = value.replaceAll(',', '');
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'انعام بارگیری (تومان)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThreeDigitInputFormatter(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _loadingTipCost = value.replaceAll(',', '');
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'انعام زمان تخلیه (تومان)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThreeDigitInputFormatter(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _unloadingTipCost = value.replaceAll(',', '');
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'هزینه باسکول بارگیری (تومان)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThreeDigitInputFormatter(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _loadingScaleCost = value.replaceAll(',', '');
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'هزینه باسکول زمان تخلیه (تومان)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThreeDigitInputFormatter(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _unloadingScaleCost = value.replaceAll(',', '');
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'سایر هزینه‌ها (تومان)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThreeDigitInputFormatter(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _otherCost = value.replaceAll(',', '');
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _calculateTotalCost,
                          style: AppButtonStyle.primaryButtonStyle,
                          child:
                              Text('محاسبه هزینه های سفر: $_totalCost تومان'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _finalTotalCost.isEmpty
                            ? 'هزینه نهایی سفر محاسبه نشده است'
                            : 'هزینه نهایی سفر: $_finalTotalCost تومان',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // New card for receiver info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ListTile(
                        title: Text(
                          'اطلاعات تحویل گیرنده',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'نام تحویل گیرنده',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _receiverName = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'شماره تماس تحویل گیرنده',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          setState(() {
                            _receiverPhone = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // New card for driver salary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ListTile(
                        title: Text(
                          'محاسبه حقوق راننده',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'درصد حقوق پایه',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThreeDigitInputFormatter(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _baseSalary = value.replaceAll(',', '');
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'حقوق به ازای هر کیلومتر (تومان)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThreeDigitInputFormatter(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _perDistanceSalary = value.replaceAll(',', '');
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'مسافت (کیلومتر)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          setState(() {
                            _distance = value.replaceAll(',', '');
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _calculateDriverSalary,
                          style: AppButtonStyle.primaryButtonStyle,
                          child:
                              Text('محاسبه حقوق راننده: $_driverSalary تومان'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20), // فاصله از ویجت قبلی
              Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity, // عرض کامل
                  child: ElevatedButton(
                    onPressed: _saveToDatabase, // تابع ذخیره در پایگاه داده
                    style: AppButtonStyle.primaryButtonStyle, // استایل دکمه
                    child: const Text('ذخیره در پایگاه داده'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPersianDateTimePicker(BuildContext context, int buttonId) async {
    final selectedDate = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.now(),
      firstDate: Jalali(1390, 1, 1),
      lastDate: Jalali(1410, 12, 29),
    );

    if (selectedDate != null) {
      final selectedTime = await showPersianTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        if (buttonId == 2 && _selectedDate1 != null && _selectedTime1 != null) {
          final firstDateTime = DateTime(
            _selectedDate1!.toDateTime().year,
            _selectedDate1!.toDateTime().month,
            _selectedDate1!.toDateTime().day,
            _selectedTime1!.hour,
            _selectedTime1!.minute,
          );

          final secondDateTime = DateTime(
            selectedDate.toDateTime().year,
            selectedDate.toDateTime().month,
            selectedDate.toDateTime().day,
            selectedTime.hour,
            selectedTime.minute,
          );

          if (secondDateTime.isBefore(firstDateTime)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('زمان رسیدن به مقصد نمی‌تواند قبل از زمان شروع باشد.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          final duration = secondDateTime.difference(firstDateTime);
          final days = duration.inDays;
          final hours = duration.inHours.remainder(24);
          final minutes = duration.inMinutes.remainder(60);

          String durationText;
          if (days > 0) {
            durationText = 'مدت سفر: $days روز و $hours ساعت و $minutes دقیقه';
          } else {
            durationText = 'مدت سفر: $hours ساعت و $minutes دقیقه';
          }

          setState(() {
            _tripDuration = durationText;
          });
        }

        final formattedDate = selectedDate.formatFullDate();
        final formattedTime = '${selectedTime.hour}:${selectedTime.minute}';

        setState(() {
          if (buttonId == 1) {
            _button1Title = 'زمان حرکت: $formattedDate - $formattedTime';
            _selectedDate1 = selectedDate;
            _selectedTime1 = selectedTime;
          } else if (buttonId == 2) {
            _button2Title =
                'زمان رسیدن به مقصد: $formattedDate - $formattedTime';
            _selectedDate2 = selectedDate;
            _selectedTime2 = selectedTime;
          }
        });
      }
    }
  }
}
