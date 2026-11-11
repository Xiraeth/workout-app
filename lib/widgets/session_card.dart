import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/session.dart';
import '../theme/tokens.dart';
import '../utils/format.dart';
import 'common.dart';

/// A session on the selected day.
class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.session, required this.today, required this.onTap});

  final Session session;
  final DateTime today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: AppColors.neutral300,
        hoverColor: AppColors.neutral300,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(sessionMeta(session).toUpperCase(), style: AppText.caps(10, em: 0.1, color: AppColors.accent700)),
                  ),
                  const SizedBox(width: 8),
                  StatusTag(session.status(today)),
                ],
              ),
              const SizedBox(height: 8),
              Text(sessionDisplayTitle(session), style: AppText.cardTitle),
              const SizedBox(height: 8),
              Opacity(
                opacity: 0.8,
                child: Text(sessionExerciseList(session), style: AppText.body.copyWith(fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row in "Coming up": short date | title + meta | chevron.
class UpcomingRow extends StatelessWidget {
  const UpcomingRow({super.key, required this.session, required this.onTap});

  final Session session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RuledRow(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(width: 64, child: Text(dayShort(session.date).toUpperCase(), style: AppText.caps(12, em: 0.06))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sessionDisplayTitle(session),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body.copyWith(fontSize: 15, fontWeight: FontWeight.w800, height: 1.4)),
                Text(sessionMeta(session), style: AppText.muted12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.ink),
        ],
      ),
    );
  }
}
