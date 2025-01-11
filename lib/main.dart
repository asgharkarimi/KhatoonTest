import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'appbuttons_style.dart';
import 'cargo_type_model.dart'; // Import the Hive model
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  await Hive.initFlutter(); // Initialize Hive
  Hive.registerAdapter(CargoTypeModelAdapter()); // Register the Hive adapter
  await Hive.openBox<CargoTypeModel>(
      'cargoTypesBox'); // Open a Hive box for cargo types
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
        Locale('fa', ''), // Persian
        Locale('en', ''), // English (optional)
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
      ),
      home: DateTimePicker(),
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

  // Variables for origin and destination
  String _origin = '';
  String _destination = '';

  // Variables for cargo details
  String _selectedCargo = 'آجر';
  final List<String> _cargoTypes = [
    'آجر',
    'ماسه',
    'قند',
    'چوب'
  ]; // Main cargo types
  final String _addNewOption =
      'افزودن گزینه جدید'; // Constant for "افزودن گزینه جدید"
  String _cargoWeight = '';
  String _newCargoType = ''; // For user to add new cargo type
  bool _showNewCargoTypeInput =
      false; // Controls visibility of the new cargo type input
  String _costPerTon = ''; // Variable to store the cost per ton of cargo

  final Box<CargoTypeModel> _cargoTypesBox =
      Hive.box<CargoTypeModel>('cargoTypesBox'); // Hive box for cargo types
  final NumberFormat _numberFormat =
      NumberFormat.decimalPattern('fa'); // برای فرمت‌بندی اعداد فارسی

  @override
  void initState() {
    super.initState();
    _loadCargoTypes(); // Load cargo types when the app starts
  }

  void _loadCargoTypes() {
    // Load cargo types from Hive
    final savedCargoTypes = _cargoTypesBox.values.toList();
    if (savedCargoTypes.isNotEmpty) {
      setState(() {
        _cargoTypes.addAll(savedCargoTypes.map((cargo) => cargo.name).toList());
      });
    }
  }

  void _saveCargoType(String cargoType) {
    // Save cargo type to Hive
    final cargo = CargoTypeModel(cargoType);
    _cargoTypesBox.add(cargo);
  }

  bool _isCargoTypeDuplicate(String cargoType) {
    return _cargoTypes.contains(cargoType); // Check if the item already exists
  }

  void _addNewCargoType() {
    if (_newCargoType.isNotEmpty) {
      if (_isCargoTypeDuplicate(_newCargoType)) {
        // Show a warning if the item already exists
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('این نوع بار قبلاً اضافه شده است.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        setState(() {
          _cargoTypes.add(_newCargoType); // Add the new item to the main list
          _selectedCargo = _newCargoType; // Select the new item
          _saveCargoType(_newCargoType); // Save to Hive
          _newCargoType = ''; // Clear the input field
          _showNewCargoTypeInput = false; // Hide the input field
        });
      }
    }
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: Color(0x80BDBDBD),
                    width: 1,
                  ),
                ),
                elevation: 0,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: Color(0x80BDBDBD),
                    width: 1,
                  ),
                ),
                elevation: 0,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: Color(0x80BDBDBD),
                    width: 1,
                  ),
                ),
                elevation: 0,
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
                            _showNewCargoTypeInput = value ==
                                _addNewOption; // Show input only if "افزودن گزینه جدید" is selected
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

                      // Input for adding new cargo type (visible only when "افزودن گزینه جدید" is selected)
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
                              // Enable only if visible
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
                        controller: TextEditingController(
                          text: _cargoWeight.isNotEmpty
                              ? _numberFormat.format(
                                  int.parse(_cargoWeight.replaceAll(',', '')))
                              : '',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _cargoWeight = value.replaceAll(
                                ',', ''); // حذف جداکننده‌ها برای ذخیره‌سازی
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Cost per Ton Input
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'هزینه حمل هر تن بار (ریال)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: _costPerTon.isNotEmpty
                              ? _numberFormat.format(
                                  int.parse(_costPerTon.replaceAll(',', '')))
                              : '',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _costPerTon = value.replaceAll(
                                ',', ''); // حذف جداکننده‌ها برای ذخیره‌سازی
                          });
                        },
                      ),
                    ],
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

        // Variables for cargo details
        String _selectedCargo = 'آجر';
        final List<String> _cargoTypes = ['آجر', 'ماسه', 'قند', 'چوب'];
        String _cargoWeight = '';
        String _newCargoType = ''; // For user to add new cargo type

        final Box<CargoTypeModel> _cargoTypesBox = Hive.box<CargoTypeModel>(
            'cargoTypesBox'); // Hive box for cargo types

        void _loadCargoTypes() {
          // Load cargo types from Hive
          final savedCargoTypes = _cargoTypesBox.values.toList();
          if (savedCargoTypes.isNotEmpty) {
            setState(() {
              _cargoTypes
                  .addAll(savedCargoTypes.map((cargo) => cargo.name).toList());
            });
          }
        }

        @override
        void initState() {
          super.initState();
          _loadCargoTypes(); // Load cargo types when the app starts
        }

        void _saveCargoType(String cargoType) {
          // Save cargo type to Hive
          final cargo = CargoTypeModel(cargoType);
          _cargoTypesBox.put(cargoType, cargo);
        }

        void _updateSelectionCount(String cargoType) {
          final cargo = _cargoTypesBox.values.firstWhere(
            (cargo) => cargo.name == cargoType,
            orElse: () => CargoTypeModel(cargoType),
          );

          cargo.selectionCount++; // Increment selection count
          _cargoTypesBox.put(cargoType, cargo); // Save to Hive
        }

        List<String> _getSortedCargoTypes() {
          final savedCargoTypes = _cargoTypesBox.values.toList();
          savedCargoTypes.sort((a, b) => b.selectionCount
              .compareTo(a.selectionCount)); // Sort by selection count
          return savedCargoTypes.map((cargo) => cargo.name).toList();
        }

        @override
        Widget build(BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Center(child: Text('افزودن سرویس بار جدید')),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // ... (other widgets)

                  // Card for adding cargo details
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(
                        color: Color(0x80BDBDBD),
                        width: 1,
                      ),
                    ),
                    elevation: 0,
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
                            items: _getSortedCargoTypes().map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCargo = value!;
                                _updateSelectionCount(
                                    value); // Update selection count
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

                          // ... (other widgets)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }
  }
}
