import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
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
  await Hive.openBox<CargoTypeModel>('cargoTypesBox');
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

  //Travel expenses costs
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

  // Variables for driver salary
  String _baseSalary = '';
  String _perDistanceSalary = '';
  String _distance = '';
  String _driverSalary = '';

  //origin and destination variables
  String _origin = '';
  String _destination = '';

  // Variables for receiver info
  String _receiverName = '';
  String _receiverPhone = '';

  String _selectedCargo = 'آجر';
  String _calculateButtonTitle = 'محاسبه هزینه حمل';
  String _shippingCost = '';
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
      setState(() {
        _shippingCost = _numberFormatEnglish.format((weight * cost).round());
        _calculateButtonTitle = 'هزینه حمل: $_shippingCost تومان';
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

    setState(() {
      _totalCost = _numberFormatEnglish.format((toll +
              fuel +
              disinfection +
              bill +
              highwayToll +
              loadingTip +
              unloadingTip +
              loadingScale +
              unloadingScale)
          .round());
    });
  }

  void _calculateDriverSalary() {
    double baseSalary = double.tryParse(_baseSalary) ?? 0;
    double perDistanceSalary = double.tryParse(_perDistanceSalary) ?? 0;
    double distance = double.tryParse(_distance) ?? 0;

    setState(() {
      _driverSalary = _numberFormatEnglish
          .format((baseSalary + (perDistanceSalary * distance)).round());
    });
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
                        labelText: 'هزینه عوارض (تومان)',
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
                          _tollCost = value.replaceAll(',', '');
                        });
                      },
                    ),
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
                        labelText: 'عوارض آزادراهی (تومان)',
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
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _calculateTotalCost,
                        style: AppButtonStyle.primaryButtonStyle,
                        child: Text('محاسبه هزینه های سفر: $_totalCost تومان'),
                      ),
                    ),
                  ],
                ),
              )),
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
              //new card for dirver salary
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
                          labelText: 'حقوق پایه (تومان)',
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
              )
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
