import 'package:flutter/material.dart';

import '../models/session.dart';
import '../theme/tokens.dart';
import '../utils/format.dart';
import 'app_buttons.dart';

/// "Delete this session?" Returns true when the user confirms.
Future<bool?> showDeleteSessionDialog(BuildContext context, Session s) => showConfirmDialog(
      context,
      title: 'Delete this session?',
      body: '${sessionTitle(s.date)} and its ${plural(s.exercises.length, 'exercise')} will be removed.',
      confirm: 'Delete',
    );

/// A flat dialog with "Keep" and a primary [confirm] action. Returns true on confirm.
Future<bool?> showConfirmDialog(BuildContext context, {required String title, required String body, required String confirm}) =>
    showDialog<bool>(
      context: context,
      barrierColor: AppColors.scrim,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(Space.s4),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.h3),
                const SizedBox(height: 8),
                Text(body, style: AppText.body.copyWith(color: AppColors.muted)),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(label: 'Keep', variant: BtnVariant.ghost, foreground: AppColors.ink, onPressed: () => Navigator.of(context).pop(false)),
                    const SizedBox(width: 8),
                    AppButton(label: confirm, variant: BtnVariant.danger, onPressed: () => Navigator.of(context).pop(true)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
