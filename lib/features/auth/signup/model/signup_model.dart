class SignupRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String fullPhoneNumber;
  final String password;
  //final String idCode;

  SignupRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.fullPhoneNumber,
    required this.password,
    //required this.idCode,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'fullPhoneNumber': fullPhoneNumber,
    'password': password,
    //'idCode': idCode,
  };
}

class SignupResponse {
  final int? id;
  final String? token;
  final String? error;
  final String? idCode;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;

  SignupResponse({
    this.id,
    this.token,
    this.error,
    this.idCode,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return SignupResponse(
      id: json['id'] ?? data?['userId'],
      token: json['token'],
      error: json['error'] ?? json['message'],
      idCode: json['idCode'] ?? data?['idCode'] ?? data?['id_code'],
      firstName: data?['firstName'],
      lastName: data?['lastName'],
      email: data?['email'],
      phone: data?['fullPhoneNumber'] ?? data?['phone'],
    );
  }
}
