class StudentModel {
  final String uid;
  final String name;
  final String email;
  final String degree;
  final String entryNumber;
  final String year;
  final String url;
  final String mess;
  int refund=0;
  int monthly_refund;
  int days_of_rebate;
  int hostel_leaving_date;
  final String bank_account_number;
  final String ifsc_code;

  StudentModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.degree,
    required this.entryNumber,
    required this.year,
    required this.url,
    refund=0,
    this.monthly_refund=0,
    this.days_of_rebate=0,
    this.hostel_leaving_date=0;
    required this.bank_account_number,
    required this.ifsc_code,
    required this.mess,
  }) ;

  // Convert a UserModel into a Map for storing in Firestore or Realtime Database.
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name':name,
        'email':email,
        'degree': degree,
        'entryNumber': entryNumber,
        'year': year,
        'url':url,
        'mess': mess,
        'refund':0,
        'monthly_refund':0,
        'days_of_rebate':0,
        'hostel_leaving_days':0,
        'bank_account_number':bank_account_number,
        'ifsc_code':ifsc_code,

      };

  // Create a UserModel instance from a Map.
  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        uid: json['uid'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        degree: json['degree'] as String,
        entryNumber: json['entryNumber'] as String,
        year: json['year'] as String,
        url: json['url'] as String,
        refund: json['refund'] as int,
        monthly_refund: json['monthly_refund'] as int,
        days_of_rebate: json['days_of_rebate'] as int,
        hostel_leaving_days: json['hostel_leaving_days'] as int,
        bank_account_number: json['bank_account_number'] as String,
        ifsc_code: json['ifsc_code'] as String,
        mess:json['mess'] as String,
      );
}
