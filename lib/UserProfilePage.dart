import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:test_app/service_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  List<ServiceModel> _services = []; // لیست سرویس‌ها

  @override
  void initState() {
    super.initState();
    _loadServices(); // بارگذاری سرویس‌ها از Hive
  }

  void _loadServices() {
    final serviceBox = Hive.box<ServiceModel>('serviceBox');
    setState(() {
      _services = serviceBox.values.toList(); // تبدیل داده‌ها به لیست
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('صفحه کاربری'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_services.isEmpty) {
      return Center(
        child: Text(
          'هیچ سرویسی یافت نشد.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return _buildServiceCard(service);
      },
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 4, // سایه برای کارت
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // گوشه‌های گرد
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان سرویس
            Text(
              'سرویس باربری',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 8),
            // جزئیات سرویس
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.green),
              // آیکون مبدا
              title: Text('مبدا'),
              subtitle: Text(service.origin),
            ),
            ListTile(
              leading: Icon(Icons.location_off, color: Colors.red),
              // آیکون مقصد
              title: Text('مقصد'),
              subtitle: Text(service.destination),
            ),
            ListTile(
              leading: Icon(Icons.local_shipping, color: Colors.orange),
              // آیکون نوع بار
              title: Text('نوع بار'),
              subtitle: Text(service.cargoType),
            ),
            ListTile(
              leading: Icon(Icons.monetization_on, color: Colors.purple),
              // آیکون هزینه
              title: Text('هزینه حمل'),
              subtitle: Text('${service.shippingCost} تومان'),
            ),
            ListTile(
              leading: Icon(Icons.access_time, color: Colors.teal),
              // آیکون زمان
              title: Text('زمان حرکت'),
              subtitle:
                  Text('${service.selectedDate1} - ${service.selectedTime1}'),
            ),
            ListTile(
              leading: Icon(Icons.access_time, color: Colors.teal),
              // آیکون زمان
              title: Text('زمان رسیدن'),
              subtitle:
                  Text('${service.selectedDate2} - ${service.selectedTime2}'),
            ),
            // دکمه حذف
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _deleteService(service);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
