import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_text.dart';

class ProgressTab extends StatelessWidget {
  const ProgressTab({super.key});

  static const int _totalStations = 12;
  static const double _maxPoints = 120.0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('Users').snapshots(),
      builder: (context, snapshot) {
        final scheme = Theme.of(context).colorScheme;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              tr('Ranking konnte nicht geladen werden.',
                  'Ranking could not be loaded.'),
              style: TextStyle(color: scheme.onSurface),
            ),
          );
        }

        final currentUid = FirebaseAuth.instance.currentUser?.uid;
        final players = (snapshot.data?.docs ?? const [])
            .map((d) => _Player.fromDoc(d.id, d.data()))
            .toList();

        players.sort((a, b) {
          final byPoints = b.points.compareTo(a.points);
          if (byPoints != 0) return byPoints;
          return b.solved.compareTo(a.solved);
        });

        for (var i = 0; i < players.length; i++) {
          players[i] = players[i].copyWith(rank: i + 1);
        }

        _Player? currentPlayer;
        if (currentUid != null) {
          for (final p in players) {
            if (p.uid == currentUid) {
              currentPlayer = p;
              break;
            }
          }
        }

        final top = players.take(10).toList();
        final ownPlayer = currentPlayer;
        final showOwnRow =
            ownPlayer != null && !top.any((p) => p.uid == ownPlayer.uid);

        final progressSolved =
            (currentPlayer?.solved ?? 0).clamp(0, _totalStations);
        final progressRatio =
            ((currentPlayer?.points ?? 0) / _maxPoints).clamp(0.0, 1.0);

        void openDetails(_Player player) {
          showDialog<void>(
            context: context,
            builder: (_) => _PlayerDetailsDialog(player: player),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  Text(
                    tr('Fortschritt', 'Progress'),
                    style: TextStyle(
                      fontSize: 58,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    '$progressSolved / $_totalStations',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      letterSpacing: -1.0,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ProgressBar(value: progressRatio),
                  const SizedBox(height: 16),
                  _StatsText(
                    points: currentPlayer?.points ?? 0,
                    timeBonus: currentPlayer?.timeBonusPoints ?? 0,
                    solved: progressSolved,
                    totalTime: currentPlayer?.totalTimeText ?? '0:00',
                  ),
                  const SizedBox(height: 10),
                  _MiniBars(color: scheme.onSurface),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: top.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (_, i) => _RankRow(
                        player: top[i],
                        totalStations: _totalStations,
                        onTap: () => openDetails(top[i]),
                      ),
                    ),
                  ),
                  if (showOwnRow) ...[
                    const SizedBox(height: 8),
                    Divider(color: scheme.onSurface, height: 1, thickness: 2),
                    const SizedBox(height: 8),
                    _RankRow(
                      player: ownPlayer,
                      totalStations: _totalStations,
                      highlight: true,
                      onTap: () => openDetails(ownPlayer),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatsText extends StatelessWidget {
  final double points;
  final double timeBonus;
  final int solved;
  final String totalTime;

  const _StatsText({
    required this.points,
    required this.timeBonus,
    required this.solved,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    TextStyle s() => TextStyle(
          fontSize: 44 / 3,
          fontWeight: FontWeight.w800,
          height: 1.35,
          color: scheme.onSurface,
        );

    return Column(
      children: [
        _StatRow(
            label: tr('Gesamtpunkte:', 'Total points:'),
            value: '${_fmtPoints(points)} p',
            style: s()),
        _StatRow(
            label: tr('+ ${_fmtPoints(timeBonus)} Zeitbonus',
                '+ ${_fmtPoints(timeBonus)} time bonus'),
            value: '',
            style: s()),
        _StatRow(
            label: tr('Gelöste Aufgaben:', 'Solved tasks:'),
            value: '$solved',
            style: s()),
        _StatRow(
            label: tr('Gesamtzeit:', 'Total time:'),
            value: totalTime,
            style: s()),
      ],
    );
  }

  String _fmtPoints(double value) {
    final n = double.parse(value.toStringAsFixed(1));
    if (n % 1 == 0) return n.toInt().toString();
    return n.toStringAsFixed(1);
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle style;

  const _StatRow({
    required this.label,
    required this.value,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        if (value.isNotEmpty) Text(value, style: style),
      ],
    );
  }
}

class _MiniBars extends StatelessWidget {
  final Color color;
  const _MiniBars({required this.color});

  @override
  Widget build(BuildContext context) {
    Widget bar(double h, double alpha) {
      return Container(
        width: 22,
        height: h,
        decoration: BoxDecoration(
          color: color.withValues(alpha: alpha),
          borderRadius: BorderRadius.circular(3),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        bar(58, 1.0),
        const SizedBox(width: 4),
        bar(38, 0.6),
        const SizedBox(width: 4),
        bar(22, 0.25),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 28,
        color: const Color(0xFFD3D3D6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: v,
            child: Container(color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final _Player player;
  final int totalStations;
  final bool highlight;
  final VoidCallback onTap;

  const _RankRow({
    required this.player,
    required this.totalStations,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFD3D3D6),
          borderRadius: BorderRadius.circular(9),
          border:
              highlight ? Border.all(color: Colors.black, width: 1.2) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${player.rank}. ${player.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 32 / 2.15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${player.solved}/$totalStations',
              style: const TextStyle(
                fontSize: 32 / 2.15,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 62,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_fmtPoints(player.points)} p',
                  style: const TextStyle(
                    fontSize: 32 / 2.15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtPoints(double value) {
    final n = double.parse(value.toStringAsFixed(1));
    if (n % 1 == 0) return n.toInt().toString();
    return n.toStringAsFixed(1);
  }
}

class _PlayerDetailsDialog extends StatelessWidget {
  final _Player player;
  const _PlayerDetailsDialog({required this.player});

  @override
  Widget build(BuildContext context) {
    const totalStations = 12;
    const maxPoints = 120.0;
    final solved = player.solved.clamp(0, totalStations);
    final ratio = (player.points / maxPoints).clamp(0.0, 1.0);
    final percent = (ratio * 100).round();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              player.name,
              style: const TextStyle(
                fontSize: 50 / 2.15,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            _DialogStatRow(
              label: tr('Gesamtpunkte:', 'Total points:'),
              value: '${_fmtPoints(player.points)} p',
            ),
            _DialogStatRow(
              label: tr(
                '+ ${_fmtPoints(player.timeBonusPoints)} Zeitbonus',
                '+ ${_fmtPoints(player.timeBonusPoints)} time bonus',
              ),
              value: '',
            ),
            _DialogStatRow(
                label: tr('Gelöste Aufgaben:', 'Solved tasks:'),
                value: '$solved'),
            _DialogStatRow(
                label: tr('Gesamtzeit:', 'Total time:'),
                value: player.totalTimeText),
            const SizedBox(height: 10),
            Text(
              '$percent%',
              style: const TextStyle(
                fontSize: 46 / 2.2,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 30,
                    color: const Color(0xFFD3D3D6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: ratio.clamp(0.0, 1.0),
                        child: Container(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  right: 8,
                  top: 3,
                  child: Text(
                    'max 120 p',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmtPoints(double value) {
    final n = double.parse(value.toStringAsFixed(1));
    if (n % 1 == 0) return n.toInt().toString();
    return n.toStringAsFixed(1);
  }
}

class _DialogStatRow extends StatelessWidget {
  final String label;
  final String value;
  const _DialogStatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 47 / 2.2,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(
                fontSize: 47 / 2.2,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}

class _Player {
  final String uid;
  final String name;
  final int rank;
  final double points;
  final double timeBonusPoints;
  final int solved;
  final String totalTimeText;

  const _Player({
    required this.uid,
    required this.name,
    required this.rank,
    required this.points,
    required this.timeBonusPoints,
    required this.solved,
    required this.totalTimeText,
  });

  factory _Player.fromDoc(String uid, Map<String, dynamic> data) {
    final points = (data['Points'] as num?)?.toDouble() ??
        (data['points'] as num?)?.toDouble() ??
        (data['score'] as num?)?.toDouble() ??
        (data['Score'] as num?)?.toDouble() ??
        0.0;
    final timeBonusPoints =
        (data['TimeBonusPoints'] as num?)?.toDouble() ?? 0.0;

    final completedRaw = (data['CompletedStadions'] as List?) ?? const [];
    final completedCount = completedRaw.whereType<num>().length;
    final solved = (data['SolvedCount'] as num?)?.toInt() ?? completedCount;
    final totalTimeText = _readTotalTimeText(data);

    final username = (data['Username'] as String?)?.trim();
    final email = (data['Email'] as String?)?.trim();
    final fallback = email != null && email.contains('@')
        ? email.split('@').first
        : 'Player';

    return _Player(
      uid: uid,
      name: (username != null && username.isNotEmpty) ? username : fallback,
      rank: 0,
      points: points,
      timeBonusPoints: timeBonusPoints,
      solved: solved,
      totalTimeText: totalTimeText,
    );
  }

  static String _readTotalTimeText(Map<String, dynamic> data) {
    final raw = data['TotalTimeText'] ?? data['Gesamtzeit'];
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();

    final seconds = (data['TotalTimeSeconds'] as num?)?.toInt() ??
        (data['totalTimeSeconds'] as num?)?.toInt();
    if (seconds == null || seconds <= 0) return '0:00';

    final m = (seconds ~/ 60).toString();
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  _Player copyWith({
    String? uid,
    String? name,
    int? rank,
    double? points,
    double? timeBonusPoints,
    int? solved,
    String? totalTimeText,
  }) {
    return _Player(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      rank: rank ?? this.rank,
      points: points ?? this.points,
      timeBonusPoints: timeBonusPoints ?? this.timeBonusPoints,
      solved: solved ?? this.solved,
      totalTimeText: totalTimeText ?? this.totalTimeText,
    );
  }
}
