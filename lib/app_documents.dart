import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test_app/service_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
  await Hive.initFlutter(); // Initialize Hive
  Hive.registerAdapter(ServiceModelAdapter()); // Register the adapter
  print('Initializing Hive...');
  try {
    await Hive.openBox<ServiceModel>(
        'serviceBox'); // Open the box for ServiceModel
    print('Box "serviceBox" opened successfully.');
  } catch (e) {
    print('Error opening box: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AddDocumentsPage(),
    );
  }
}

class AddDocumentsPage extends StatefulWidget {
  @override
  _AddDocumentsPageState createState() => _AddDocumentsPageState();
}

class _AddDocumentsPageState extends State<AddDocumentsPage> {
  List<File> _imageFiles = [];
  final ImagePickerHelper _imagePickerHelper = ImagePickerHelper();

  List<String> _services = []; // لیست گزینه‌های سرویس
  String? _selectedService; // سرویس انتخاب شده

  String origin = '';
  String destination = '';
  String selectedDate1 = ''; // متغیر برای ذخیره selectedDate1
  String selectedTime1 = ''; // متغیر برای ذخیره selectedTime1

  @override
  void initState() {
    super.initState();
    _loadAllServices(); // بارگیری تمام سرویس‌ها از Hive
  }

  // تابع برای بارگیری تمام سرویس‌ها از Hive
  void _loadAllServices() async {
    if (!Hive.isBoxOpen('serviceBox')) {
      await Hive.openBox<ServiceModel>(
          'serviceBox'); // باز کردن جعبه اگر باز نشده باشد
    }
    final serviceBox = Hive.box<ServiceModel>('serviceBox');

    // Fetch all ServiceModel objects from the box
    final List<ServiceModel> services = serviceBox.values.toList();

    // Update the _services list with the loaded origin, destination, selectedDate1, and selectedTime1
    setState(() {
      _services = services.map((service) {
        return ' از ${service.origin} به ${service.destination} (تاریخ: ${service.selectedDate1} - زمان: ${service.selectedTime1})';
      }).toList();

      // Set default origin, destination, selectedDate1, and selectedTime1 (optional)
      if (services.isNotEmpty) {
        origin = services.first.origin;
        destination = services.first.destination;
        selectedDate1 =
            services.first.selectedDate1; // Set default selectedDate1
        selectedTime1 =
            services.first.selectedTime1; // Set default selectedTime1
      } else {
        origin = 'مبدا پیش‌فرض';
        destination = 'مقصد پیش‌فرض';
        selectedDate1 = 'تاریخ پیش‌فرض';
        selectedTime1 = 'زمان پیش‌فرض';
      }
    });
  }

  // تابع برای ذخیره origin و destination در Hive
  void _saveOriginAndDestination(String origin, String destination) {
    final settingsBox = Hive.box('settings');
    settingsBox.put('origin', origin);
    settingsBox.put('destination', destination);
  }

  // تابع برای انتخاب تصویر از گالری
  Future<void> _pickImageFromGallery() async {
    final File? image = await _imagePickerHelper.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _imageFiles.add(image); // اضافه کردن تصویر انتخاب شده به لیست
      });
    }
  }

  // تابع برای گرفتن عکس با دوربین
  Future<void> _takePhotoWithCamera() async {
    final File? image = await _imagePickerHelper.takePhotoWithCamera();
    if (image != null) {
      setState(() {
        _imageFiles.add(image); // اضافه کردن تصویر گرفته شده به لیست
      });
    }
  }

  // تابع برای حذف عکس از لیست
  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index); // حذف عکس از لیست
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('افزودن مستندات بار')),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'انتخاب سرویس برای بارگزاری مستندات',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _selectedService,
                items: _services.map((String service) {
                  return DropdownMenuItem<String>(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedService = newValue; // به‌روزرسانی سرویس انتخاب شده

                    // Extract origin, destination, selectedDate1, and selectedTime1 from the selected service
                    if (newValue != null) {
                      final serviceBox = Hive.box<ServiceModel>('serviceBox');
                      final services = serviceBox.values.toList();
                      final selectedService = services.firstWhere(
                            (service) =>
                        'سرویس از ${service.origin} به ${service.destination} (تاریخ: ${service.selectedDate1} - زمان: ${service.selectedTime1})' ==
                            newValue,
                        orElse: () => ServiceModel(
                          origin: '',
                          destination: '',
                          cargoType: '',
                          cargoWeight: '',
                          shippingCost: '',
                          totalCost: '',
                          receiverName: '',
                          receiverPhone: '',
                          driverSalary: '',
                          tollCost: '',
                          fuelCost: '',
                          disinfectionCost: '',
                          billCost: '',
                          highwayTollCost: '',
                          loadingTipCost: '',
                          unloadingTipCost: '',
                          loadingScaleCost: '',
                          unloadingScaleCost: '',
                          otherCost: '',
                          tripDuration: '',
                          selectedDate1: '',
                          selectedTime1: '',
                          selectedDate2: '',
                          selectedTime2: '',
                        ),
                      );

                      origin = selectedService.origin;
                      destination = selectedService.destination;
                      selectedDate1 =
                          selectedService.selectedDate1; // Update selectedDate1
                      selectedTime1 =
                          selectedService.selectedTime1; // Update selectedTime1
                    }
                  });
                },
              ),
            ),
            // کارت‌ویو برای افزودن عکس
            AppCardView(
              backgroundColor: Colors.grey.shade100.withOpacity(0.8),
              title: 'افزودن عکس بارنامه',
              child: Column(
                children: [
                  // نمایش origin، destination، selectedDate1 و selectedTime1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _pickImageFromGallery,
                        child: Text('انتخاب از گالری'),
                      ),
                      ElevatedButton(
                        onPressed: _takePhotoWithCamera,
                        child: Text('دوربین'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // لیست برای نمایش تصاویر انتخاب شده یا گرفته شده
                  _imageFiles.isEmpty
                      ? Center(
                    child: Text('هیچ تصویری انتخاب نشده است.'),
                  )
                      : GridView.builder(
                    shrinkWrap: true,
                    // Ensure the GridView takes only the required space
                    physics: NeverScrollableScrollPhysics(),
                    // Disable scrolling
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // نمایش ۳ تصویر در هر ردیف
                      crossAxisSpacing: 8, // فاصله بین تصاویر در عرض
                      mainAxisSpacing: 8, // فاصله بین تصاویر در ارتفاع
                      childAspectRatio: 1, // نسبت عرض به ارتفاع تصاویر
                    ),
                    itemCount: _imageFiles.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          // نمایش عکس
                          ClipRRect( // ADDED THIS
                            borderRadius: BorderRadius.circular(14.0), // ADDED THIS
                            child:  Image.file(
                              _imageFiles[index],
                              fit:
                              BoxFit.cover, // نمایش کامل تصویر بدون برش
                            ),
                          ),
                          // آیکون ضربدر برای حذف عکس
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              // حذف عکس با لمس آیکون
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red, // رنگ پس‌زمینه آیکون
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white, // رنگ آیکون
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImagePickerHelper {
  final ImagePicker _imagePicker = ImagePicker();

  // انتخاب تصویر از گالری
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // کیفیت تصویر (۰ تا ۱۰۰)
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint("خطا در انتخاب تصویر از گالری: $e");
    }
    return null;
  }

  // گرفتن عکس با دوربین
  Future<File?> takePhotoWithCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // کیفیت تصویر (۰ تا ۱۰۰)
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint("خطا در گرفتن عکس با دوربین: $e");
    }
    return null;
  }
}

class AppCardView extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? backgroundColor;

  const AppCardView({
    Key? key,
    required this.title,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFFFAFAFA).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ),
    );
  }
}