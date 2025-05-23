class MinioAccount {
  final String name;
  final String endpoint;
  final String accessKey;
  final String secretKey;
  final bool useSSL;

  MinioAccount({
    required this.name,
    required this.endpoint,
    required this.accessKey,
    required this.secretKey,
    this.useSSL = true,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'endpoint': endpoint,
        'accessKey': accessKey,
        'secretKey': secretKey,
        'useSSL': useSSL,
      };

  factory MinioAccount.fromJson(Map<String, dynamic> json) => MinioAccount(
        name: json['name'] as String,
        endpoint: json['endpoint'] as String,
        accessKey: json['accessKey'] as String,
        secretKey: json['secretKey'] as String,
        useSSL: json['useSSL'] as bool? ?? true,
      );
} 