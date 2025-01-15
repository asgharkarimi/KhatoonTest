import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test_app/app_card_view_styles.dart';
import 'package:test_app/appbuttons_style.dart';
import 'package:test_app/service_model.dart';
import 'package:intl/intl.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  List<ServiceModel> _services = []; // لیست سرویس‌ها
  bool _showIncomeCard = false; // State برای نمایش یا پنهان کردن Card
  double _totalDriverIncome = 0; // State برای ذخیره مجموع درآمد

  @override
  void initState() {
    super.initState();
    _loadServices(); // بارگذاری سرویس‌ها از Hive
    _addTestServices();
  }

  void _loadServices() {
    final serviceBox = Hive.box<ServiceModel>('serviceBox');
    setState(() {
      _services = serviceBox.values.toList();
    });

    // Debug: Print all services and their driverSalary
    for (var service in _services) {
      print(
          'Service: ${service.origin} -> ${service.destination}, Driver Salary: ${service.driverSalary}');
    }
  }

  double _parseDriverSalary(String salary) {
    // Remove any non-numeric characters (like commas or currency symbols)
    String cleanedSalary = salary.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleanedSalary) ?? 0;
  }

  void _deleteService(ServiceModel service) {
    final serviceBox = Hive.box<ServiceModel>('serviceBox');

    // پیدا کردن key مربوط به service
    final key = serviceBox.keyAt(serviceBox.values.toList().indexOf(service));

    // حذف سرویس از Hive
    serviceBox.delete(key);

    // بارگذاری مجدد لیست سرویس‌ها
    _loadServices();
  }

  void _addTestServices() {
    final serviceBox = Hive.box<ServiceModel>('serviceBox');

    // لیست شهرهای ایران برای مبدا و مقصد
    final List<String> iranCities = [
      'تهران',
      'مشهد',
      'اصفهان',
      'شیراز',
      'تبریز',
      'اهواز',
      'کرج',
      'قم',
      'کرمانشاه',
      'ارومیه',
    ];

    // ایجاد ۵ سرویس تستی
    for (int i = 0; i < 5; i++) {
      final origin = iranCities[i % iranCities.length]; // انتخاب شهر مبدا
      final destination =
          iranCities[(i + 1) % iranCities.length]; // انتخاب شهر مقصد
      final selectedDate1 = '1402/01/${10 + i}'; // تاریخ حرکت
      final selectedTime1 = '${10 + i}:00'; // زمان حرکت

      // بررسی وجود سرویس تکراری
      final isDuplicate = serviceBox.values.any((service) =>
          service.origin == origin &&
          service.destination == destination &&
          service.selectedDate1 == selectedDate1 &&
          service.selectedTime1 == selectedTime1);

      // اگر سرویس تکراری وجود نداشت، آن را اضافه کنید
      if (!isDuplicate) {
        final service = ServiceModel(
          origin: origin,
          destination: destination,
          cargoType: 'نوع بار ${i + 1}',
          shippingCost: '${(i + 1) * 100000}',
          // هزینه حمل
          driverSalary: '${(i + 1) * 50000}',
          // حقوق راننده
          selectedDate1: selectedDate1,
          // تاریخ حرکت
          selectedTime1: selectedTime1,
          // زمان حرکت
          selectedDate2: '1402/01/${12 + i}',
          // تاریخ رسیدن
          selectedTime2: '${12 + i}:00',
          // زمان رسیدن
          cargoWeight: '',
          totalCost: '',
          receiverName: '',
          receiverPhone: '',
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
        );
        serviceBox.add(service); // افزودن سرویس به دیتابیس
      }
    }

    _loadServices(); // بارگذاری مجدد لیست سرویس‌ها
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text('صفحه کاربری راننده اصغر کریمی'),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Button for Income Report
        Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity, // Makes the button span the full width
            child: ElevatedButton(
              style: AppButtonStyle.primaryButtonStyle,
              // Your custom button style
              onPressed: () {
                // Add your logic for generating income report here
                _generateIncomeReport();
              },
              child: Text(
                'گزارش گیری درامد راننده ',
                style: TextStyle(fontSize: 14), // Optional: Add text stylin`g
              ),
            ),
          ),
        ),
        // نمایش Card برای مجموع درآمد
        Visibility(
          visible: _showIncomeCard, // نمایش یا پنهان کردن Card
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: AppCard(
                child: Column(
                  children: [
                    SizedBox(height: 8),
                    Text(
                      'کل درآمد راننده: ${NumberFormat('#,###').format(_totalDriverIncome)} تومان',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // List of Services
        Expanded(
          child: _services.isEmpty
              ? Center(
                  child: Text(
                    'هیچ سرویسی یافت نشد.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return _buildServiceCard(service);
                  },
                ),
        ),
      ],
    );
  }

  void _generateIncomeReport() {
    if (_showIncomeCard) {
      setState(() {
        _showIncomeCard = false;
      });
      return; // از ادامه اجرای متد جلوگیری کنید
    }
    // Convert driverSalary from String to double and calculate total income
    _totalDriverIncome = _services.fold(0, (sum, service) {
      // Parse the driverSalary string to a double using the helper function
      double salary = _parseDriverSalary(service.driverSalary);
      return sum + salary;
    });

    // Debug: Print total driver income
    print('Total Driver Income: $_totalDriverIncome');

    // نمایش Card
    setState(() {
      _showIncomeCard = true;
    });
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Card(
      margin: EdgeInsets.all(4), // Reduced margin
      elevation: 2, // سایه برای کارت
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // گوشه‌های گرد
      ),
      child: Padding(
        padding: EdgeInsets.all(12), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            // Reduced space
            // نمایش مبدا و مقصد به صورت "سرویس بار از مبدا origin به مقصد destination"
            Text(
              'سرویس بار از مبدا ${service.origin} به مقصد ${service.destination}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            // Reduced space
            // جزئیات سرویس (بدون مبدا و مقصد)
            ListTile(
              contentPadding: EdgeInsets.zero,
              // Remove default padding
              leading:
                  Icon(Icons.local_shipping, color: Colors.orange, size: 20),
              // Smaller icon
              title: Text(
                'نوع بار',
                style: TextStyle(fontSize: 14), // Smaller font size
              ),
              subtitle: Text(
                service.cargoType,
                style: TextStyle(fontSize: 12), // Smaller font size
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              // Remove default padding
              leading:
                  Icon(Icons.monetization_on, color: Colors.purple, size: 20),
              // Smaller icon
              title: Text(
                'هزینه حمل',
                style: TextStyle(fontSize: 14), // Smaller font size
              ),
              subtitle: Text(
                '${NumberFormat('#,###').format(double.tryParse(service.shippingCost) ?? 0)} تومان',
                style: TextStyle(fontSize: 12), // Smaller font size
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              // Remove default padding
              leading: Icon(Icons.attach_money, color: Colors.green, size: 20),
              // Smaller icon
              title: Text(
                'حقوق راننده',
                style: TextStyle(fontSize: 14), // Smaller font size
              ),
              subtitle: Text(
                '${NumberFormat('#,###').format(double.tryParse(service.driverSalary) ?? 0)} تومان',
                style: TextStyle(fontSize: 12), // Smaller font size
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              // Remove default padding
              leading: Icon(Icons.access_time, color: Colors.teal, size: 20),
              // Smaller icon
              title: Text(
                'زمان حرکت',
                style: TextStyle(fontSize: 14), // Smaller font size
              ),
              subtitle: Text(
                '${service.selectedDate1} - ${service.selectedTime1}',
                style: TextStyle(fontSize: 12), // Smaller font size
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              // Remove default padding
              leading: Icon(Icons.access_time, color: Colors.teal, size: 20),
              // Smaller icon
              title: Text(
                'زمان رسیدن',
                style: TextStyle(fontSize: 14), // Smaller font size
              ),
              subtitle: Text(
                '${service.selectedDate2} - ${service.selectedTime2}',
                style: TextStyle(fontSize: 12), // Smaller font size
              ),
            ),
            // دکمه حذف
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: AppButtonStyle.primaryButtonStyle,
                onPressed: () {
                  _deleteService(service); // Call the delete function
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'حذف از لیست',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white, // Text color
                      fontSize: 14, // Text size
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
