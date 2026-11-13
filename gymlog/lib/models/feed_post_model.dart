class FeedPostModel {
  final String id;
  final String userName;
  final String routineName;
  final int duration;
  final DateTime completedAt;
  final String caption;
  final List<String> mediaUrls;
  final int exercisesCount;
  final int totalSets;
  final double totalVolume;
  int likesCount;
  bool isLikedByMe;

  FeedPostModel({
    required this.id,
    required this.userName,
    required this.routineName,
    required this.duration,
    required this.completedAt,
    required this.caption,
    required this.mediaUrls,
    required this.exercisesCount,
    required this.totalSets,
    required this.totalVolume,
    required this.likesCount,
    required this.isLikedByMe,
  });

  factory FeedPostModel.fromJson(Map<String, dynamic> json) {
    var rawMedia = json['mediaUrls'] as List? ?? [];
    List<String> mediaList = rawMedia.map((m) => m.toString()).toList();

    return FeedPostModel(
      id: (json['_id'] ?? '').toString(),
      userName: (json['user'] != null && json['user']['name'] != null)
          ? json['user']['name'].toString()
          : 'Athlete',
      routineName: json['routineName'] ?? 'Workout',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      caption: json['caption'] ?? '',
      mediaUrls: mediaList,
      exercisesCount: (json['exercisesCount'] as num?)?.toInt() ?? 0,
      totalSets: (json['totalSets'] as num?)?.toInt() ?? 0,
      totalVolume: (json['totalVolume'] as num?)?.toDouble() ?? 0.0,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      isLikedByMe: json['isLikedByMe'] == true,
    );
  }
}
