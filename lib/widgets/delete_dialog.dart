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
            padding: const EdgeInsets.all(Space.s4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.cardTitle),
                const SizedBox(height: 12),
                Opacity(opacity: 0.85, child: Text(body, style: AppText.body.copyWith(fontSize: 14))),
                const SizedBox(height: 20), // 12 gap + 8 margin
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(label: 'Keep', onPressed: () => Navigator.of(context).pop(false)),
                    const SizedBox(width: 8),
                    AppButton(label: confirm, variant: BtnVariant.primary, onPressed: () => Navigator.of(context).pop(true)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
