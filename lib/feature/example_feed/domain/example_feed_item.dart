class ExampleFeedItem {
  const ExampleFeedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
  });

  factory ExampleFeedItem.fromJson(Map<String, dynamic> json) {
    return ExampleFeedItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final String category;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category,
    };
  }
}
