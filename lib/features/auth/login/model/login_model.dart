class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class LoginResponse {
  final int? userId;
  final String? token;
  final String? error;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? idCode;

  LoginResponse({
    this.userId,
    this.token,
    this.error,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.idCode,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return LoginResponse(
      userId: json['userId'] ?? data?['userId'],
      token: json['token'],
      error: json['error'] ?? json['message'],
      firstName: data?['firstName'],
      lastName: data?['lastName'],
      email: data?['email'],
      phone: data?['fullPhoneNumber'],
      idCode: json['idCode'] ?? data?['idCode'] ?? data?['id_code'],
    );
  }
}
