class HomeCarouselItem {
  const HomeCarouselItem({
    required this.id,
    required this.audience,
    required this.mediaUrl,
    this.caption,
    this.sortOrder = 0,
  });

  final String id;
  final String audience;
  final String mediaUrl;
  final String? caption;
  final int sortOrder;
}
