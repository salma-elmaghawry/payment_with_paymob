class IntentionResponse {
  final String id;
  final String clientSecret;
  final int intentionOrderId;
  final String specialReference;

  const IntentionResponse({
    required this.id,
    required this.clientSecret,
    required this.intentionOrderId,
    required this.specialReference,
  });

  factory IntentionResponse.fromJson(Map<String, dynamic> json) {
    return IntentionResponse(
      id: json['id'] as String,
      clientSecret: json['client_secret'] as String,
      intentionOrderId: json['intention_order_id'] as int,
      specialReference: json['special_reference'] as String,
    );
  }
}
