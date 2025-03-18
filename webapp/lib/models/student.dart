class StudentModel {
  final String uid;
  final String degree;
  final String password;
  final String entryNumber;
  final int year;
  int refund=0;
  int monthly_refund;
  int days_of_rebate;
  int bank_account_number;
  String ifsc_code;

  StudentModel({
    required this.uid,
    required this.degree,
    required this.entryNumber,
    required this.year,
    required this.password,
    refund=0,
    this.monthly_refund=0,
    this.days_of_rebate=0,
    this.bank_account_number=0,
    this.ifsc_code=""
  }) ;

  // Convert a UserModel into a Map for storing in Firestore or Realtime Database.
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'degree': degree,
        'entryNumber': entryNumber,
        'year': year,
        'password': password,
        'refund':0,
        'monthly_refund':0,
        'days_of_rebate':0,
        'bank_account_number':0,
        'ifsc_code':""
      };

  // Create a UserModel instance from a Map.
  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        uid: json['uid'] as String,
        degree: json['degree'] as String,
        entryNumber: json['entryNumber'] as String,
        year: json['year'] as int,
        password: json['password'] as String,
        refund: json['refund'] as int,
        monthly_refund: json['monthly_refund'] as int,
        days_of_rebate: json['days_of_rebate'] as int,
        bank_account_number: json['bank_account_number'] as int,
        ifsc_code: json['ifsc_code'] as String
      );
}
