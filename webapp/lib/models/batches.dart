class Batches {
  final List<String> batchNames;

  Batches({
    required this.batchNames,
  });

  Map<String, dynamic> toJson() {
    return {
      'batchNames': batchNames,
    };
  }

  factory Batches.fromJson(Map<String, dynamic> json) {
    return Batches(
      batchNames: List<String>.from(json['batchNames'] ?? []),
    );
  }
}