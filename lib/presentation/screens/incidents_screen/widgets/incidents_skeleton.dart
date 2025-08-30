import 'package:flutter/material.dart';

class IncidentsSkeleton extends StatefulWidget {
  const IncidentsSkeleton({super.key});

  @override
  State<IncidentsSkeleton> createState() => _IncidentsSkeletonState();
}

class _IncidentsSkeletonState extends State<IncidentsSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: _buildShimmerText(theme, 120, 24),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [_buildShimmerIcon(theme, 24)],
      ),
      body: Column(
        children: [
          // Section Filter Skeleton
          Container(
            padding: const EdgeInsets.all(16),
            child: _buildShimmerContainer(
              theme,
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _buildShimmerText(theme, 100, 16),
                    const Spacer(),
                    _buildShimmerIcon(theme, 20),
                  ],
                ),
              ),
            ),
          ),

          // Incidents List Skeleton
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3, // Show 3 skeleton cards
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildIncidentCardSkeleton(theme),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildShimmerFAB(theme),
    );
  }

  Widget _buildIncidentCardSkeleton(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient background skeleton
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Incident icon skeleton
                  _buildShimmerContainer(
                    theme,
                    width: 48,
                    height: 48,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 16),

                  // Title and date skeleton
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmerText(theme, 200, 20),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildShimmerIcon(theme, 16),
                            const SizedBox(width: 6),
                            _buildShimmerText(theme, 120, 14),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Delete button skeleton
                  _buildShimmerContainer(
                    theme,
                    width: 44,
                    height: 44,
                    borderRadius: 12,
                  ),
                ],
              ),
            ),

            // Content skeleton
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Students involved skeleton
                  Row(
                    children: [
                      _buildShimmerIcon(theme, 20),
                      const SizedBox(width: 8),
                      _buildShimmerText(theme, 120, 16),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Student chips skeleton
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      2,
                      (index) => _buildShimmerContainer(
                        theme,
                        width: 80 + (index * 20),
                        height: 32,
                        borderRadius: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Procedure skeleton
                  _buildInfoSectionSkeleton(
                    theme,
                    'Procedure',
                    Icons.assignment_rounded,
                    theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),

                  // Note skeleton
                  _buildInfoSectionSkeleton(
                    theme,
                    'Note',
                    Icons.note_rounded,
                    theme.colorScheme.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSectionSkeleton(
    ThemeData theme,
    String title,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildShimmerIcon(theme, 20),
              const SizedBox(width: 8),
              _buildShimmerText(theme, 80, 16),
            ],
          ),
          const SizedBox(height: 8),
          _buildShimmerText(theme, 250, 14),
          const SizedBox(height: 4),
          _buildShimmerText(theme, 180, 14),
        ],
      ),
    );
  }

  Widget _buildShimmerContainer(
    ThemeData theme, {
    double? width,
    double? height,
    double borderRadius = 8,
    Widget? child,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                theme.colorScheme.surfaceVariant.withOpacity(0.3),
                theme.colorScheme.surfaceVariant.withOpacity(0.5),
                theme.colorScheme.surfaceVariant.withOpacity(0.3),
              ],
              stops: [0.0, _animation.value, 1.0],
            ),
          ),
          child: child,
        );
      },
    );
  }

  Widget _buildShimmerText(ThemeData theme, double width, double height) {
    return _buildShimmerContainer(
      theme,
      width: width,
      height: height,
      borderRadius: height / 2,
    );
  }

  Widget _buildShimmerIcon(ThemeData theme, double size) {
    return _buildShimmerContainer(
      theme,
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }

  Widget _buildShimmerFAB(ThemeData theme) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.3),
                theme.colorScheme.primary.withOpacity(0.5),
                theme.colorScheme.primary.withOpacity(0.3),
              ],
              stops: [0.0, _animation.value, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        );
      },
    );
  }
}
