class BillingData {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  const BillingData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone_number': phoneNumber,
  };
}
