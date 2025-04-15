class MessOptions {
  final List<String> messNames;

  MessOptions({
    required this.messNames,
  });

  Map<String, dynamic> toJson() {
    return {
      'messNames': messNames,
    };
  }

  factory MessOptions.fromJson(Map<String, dynamic> json) {
    return MessOptions(
      messNames: List<String>.from(json['messNames'] ?? []),
    );
  }
}