import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../utils/app_colors.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WorkoutProvider>(context, listen: false).fetchFeed();
    });
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final hrs = mins ~/ 60;
    final remainingMins = mins % 60;
    if (hrs > 0) return '${hrs}h ${remainingMins}m';
    return '${mins}m';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);
    final feed = provider.feed;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Community Feed',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.card,
        onRefresh: () => provider.fetchFeed(),
        child: provider.isFeedLoading && feed.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : feed.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.public,
                            size: 64,
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Community Posts Yet',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'When finishing a workout, toggle "Share to Community Feed" to publish your workout and photos here!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: feed.length,
                    itemBuilder: (context, index) {
                      final post = feed[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Post Header: Avatar, Name, Routine, Date
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.15),
                                    child: Text(
                                      post.userName.isNotEmpty
                                          ? post.userName[0].toUpperCase()
                                          : 'A',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.userName,
                                          style: const TextStyle(
                                            color: AppColors.text,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          '${post.routineName} • ${_formatDate(post.completedAt)}',
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Post Caption
                            if (post.caption.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                                child: Text(
                                  post.caption,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                            // Attached Media / Photo
                            if (post.mediaUrls.isNotEmpty)
                              Container(
                                width: double.infinity,
                                height: 240,
                                decoration: const BoxDecoration(
                                  color: AppColors.surface,
                                ),
                                child: Image.network(
                                  post.mediaUrls.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Icon(Icons.fitness_center,
                                        color: AppColors.primary, size: 48),
                                  ),
                                ),
                              ),

                            // Workout Metrics Chip Row
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  _buildMetricPill(
                                    Icons.timer_outlined,
                                    _formatDuration(post.duration),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildMetricPill(
                                    Icons.fitness_center,
                                    '${post.totalVolume.toInt()} kg',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildMetricPill(
                                    Icons.repeat,
                                    '${post.totalSets} sets',
                                  ),
                                ],
                              ),
                            ),

                            const Divider(color: AppColors.border, height: 1),

                            // Post Actions: Fist Bump / Like Button
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () =>
                                        provider.toggleLike(post.id),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 6),
                                      child: Row(
                                        children: [
                                          Icon(
                                            post.isLikedByMe
                                                ? Icons.thumb_up
                                                : Icons.thumb_up_alt_outlined,
                                            size: 18,
                                            color: post.isLikedByMe
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            post.likesCount > 0
                                                ? '${post.likesCount} Fist Bumps'
                                                : 'Fist Bump',
                                            style: TextStyle(
                                              color: post.isLikedByMe
                                                  ? AppColors.primary
                                                  : AppColors.textSecondary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildMetricPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
