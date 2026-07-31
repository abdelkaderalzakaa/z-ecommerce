class BusinessVisitModel {
  final String id;             // المعرّف الفريد لسجل الزيارة
  final String businessId;     // معرّف النشاط التجاري (المتجر/المطعم) الذي تمت زيارته
  final String? userId;        // معرّف المستخدم (null إذا كان الزائر غير مسجل/Guest)
  final String? deviceId;      // معرّف الجهاز (لإحصاء الزيارات الفريدة للزوار غير المسجلين)
  
  final DateTime visitDate;    // توقيت الزيارة
  final int? durationInSeconds;// مدة البقاء في صفحة المتجر بالثواني (اختياري للإحصائيات العميقة)
  final String? source;        // مصدر الزيارة (مثلاً: 'search', 'direct_link', 'facebook_ad')

  BusinessVisitModel({
    required this.id,
    required this.businessId,
    this.userId,
    this.deviceId,
    required this.visitDate,
    this.durationInSeconds,
    this.source,
  });

  /// تحويل البيانات من قاعدة البيانات (JSON/Map) إلى كلاس Dart
  factory BusinessVisitModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BusinessVisitModel(
      id: documentId,
      businessId: map['businessId'] ?? '',
      userId: map['userId'],
      deviceId: map['deviceId'],
      visitDate: map['visitDate'] != null 
          ? DateTime.parse(map['visitDate']) 
          : DateTime.now(),
      durationInSeconds: map['durationInSeconds'],
      source: map['source'],
    );
  }

  /// تحويل كلاس Dart إلى Map لحفظه في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'businessId': businessId,
      'userId': userId,
      'deviceId': deviceId,
      'visitDate': visitDate.toIso8601String(),
      'durationInSeconds': durationInSeconds,
      'source': source,
    };
  }

  /// إنشاء كائن BusinessVisitModel فارغ بقيم افتراضية
  factory BusinessVisitModel.empty() {
    return BusinessVisitModel(
      id: '',
      businessId: '',
      visitDate: DateTime.now(),
    );
  }
}