import 'package:flutter/material.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  // Demo-Daten (Frontend-only). Backend wird später ersetzt.
  final List<_RankPlayer> _leaderboard = const [
    _RankPlayer(rank: 1, name: 'Marsel Papic', progressText: '8/12', points: 65),
    _RankPlayer(rank: 2, name: 'David Iszovits', progressText: '7/12', points: 59),
    _RankPlayer(rank: 3, name: 'Fabian Erdkönig', progressText: '7/12', points: 52),
    _RankPlayer(rank: 4, name: 'Schmali', progressText: '6/12', points: 50),
    _RankPlayer(rank: 5, name: 'Lukas', progressText: '6/12', points: 49),
    _RankPlayer(rank: 6, name: 'Anna', progressText: '6/12', points: 45),
    _RankPlayer(rank: 7, name: 'Lea', progressText: '6/12', points: 41),
    _RankPlayer(rank: 8, name: 'Max', progressText: '5/12', points: 39),
    _RankPlayer(rank: 9, name: 'Noah', progressText: '5/12', points: 36),
    _RankPlayer(rank: 10, name: 'Sarah', progressText: '5/12', points: 33),
  ];

  // “Du” (wenn nicht Top 10 -> extra unten anzeigen)
  final _RankPlayer _you = const _RankPlayer(rank: 32, name: 'Du', progressText: '6/12', points: 12);

  _RankPlayer? _selected;

  void _openPlayer(_RankPlayer p) => setState(() => _selected = p);
  void _closePlayer() => setState(() => _selected = null);

  @override
  Widget build(BuildContext context) {
    return _selected == null ? _ProgressOverview(onOpenPlayer: _openPlayer, leaderboard: _leaderboard, you: _you)
        : _ProgressPlayerDetail(player: _selected!, onBack: _closePlayer, leaderboard: _leaderboard, you: _you);
  }
}

class _ProgressOverview extends StatelessWidget {
  final void Function(_RankPlayer) onOpenPlayer;
  final List<_RankPlayer> leaderboard;
  final _RankPlayer you;

  const _ProgressOverview({
    required this.onOpenPlayer,
    required this.leaderboard,
    required this.you,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Demo Stats
    const progressText = '6 / 12';
    const totalPoints = 47;
    const timeBonus = 5;
    const solved = 5;
    const skipped = 1;
    const totalTime = '30:32';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: Column(
            children: [
              const SizedBox(height: 6),
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                progressText,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 14),

              _ProgressBar(value: 0.50),

              const SizedBox(height: 16),

              _StatsBlock(
                totalPoints: totalPoints,
                timeBonus: timeBonus,
                solved: solved,
                skipped: skipped,
                totalTime: totalTime,
              ),

              const SizedBox(height: 12),

              _MiniBars(),

              const SizedBox(height: 14),

              _Leaderboard(
                scheme: scheme,
                leaderboard: leaderboard,
                you: you,
                onTap: onOpenPlayer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressPlayerDetail extends StatelessWidget {
  final _RankPlayer player;
  final VoidCallback onBack;
  final List<_RankPlayer> leaderboard;
  final _RankPlayer you;

  const _ProgressPlayerDetail({
    required this.player,
    required this.onBack,
    required this.leaderboard,
    required this.you,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Demo: Player Stats
    final p = player;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: Icon(Icons.arrow_back_ios_new, size: 18, color: scheme.onSurface),
                  ),
                  const Spacer(),
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: scheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    Text(
                      p.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Gesamtpunkte:', style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface)),
                        Text('${p.points} p', style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('+ 5 Zeitbonus', style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface)),
                        Text('5', style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Gelöste Aufgaben:', style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface)),
                        Text('5', style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Übersprungen:', style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface)),
                        Text('1', style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Gesamtzeit:', style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface)),
                        Text('30:32', style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ProgressBar(value: 0.56, labelRight: 'max Points'),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _Leaderboard(
                scheme: scheme,
                leaderboard: leaderboard,
                you: you,
                onTap: (_) {},
                disableTap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  final ColorScheme scheme;
  final List<_RankPlayer> leaderboard;
  final _RankPlayer you;
  final void Function(_RankPlayer) onTap;
  final bool disableTap;

  const _Leaderboard({
    required this.scheme,
    required this.leaderboard,
    required this.you,
    required this.onTap,
    this.disableTap = false,
  });

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor;

    final youInTop10 = leaderboard.any((p) => p.rank == you.rank);

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leaderboard.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final p = leaderboard[i];
            return _RankRow(
              player: p,
              scheme: scheme,
              onTap: disableTap ? null : () => onTap(p),
            );
          },
        ),

        if (!youInTop10) ...[
          const SizedBox(height: 10),
          Text(
            '— Dein Platz —',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface.withOpacity(0.60),
            ),
          ),
          const SizedBox(height: 10),
          _RankRow(
            player: you,
            scheme: scheme,
            onTap: disableTap ? null : () => onTap(you),
            highlight: true,
          ),
        ],

        Container(
          margin: const EdgeInsets.only(top: 12),
          height: 1,
          color: divider.withOpacity(0.0),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  final _RankPlayer player;
  final ColorScheme scheme;
  final VoidCallback? onTap;
  final bool highlight;

  const _RankRow({
    required this.player,
    required this.scheme,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = highlight ? scheme.surface : scheme.surface;
    final border = Theme.of(context).dividerColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                '${player.rank}.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface.withOpacity(0.90),
                ),
              ),
            ),
            Expanded(
              child: Text(
                player.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface.withOpacity(0.90),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              player.progressText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface.withOpacity(0.85),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 44,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${player.points} p',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: scheme.onSurface.withOpacity(0.90),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsBlock extends StatelessWidget {
  final int totalPoints;
  final int timeBonus;
  final int solved;
  final int skipped;
  final String totalTime;

  const _StatsBlock({
    required this.totalPoints,
    required this.timeBonus,
    required this.solved,
    required this.skipped,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    TextStyle left = TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: scheme.onSurface.withOpacity(0.90));
    TextStyle right = TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: scheme.onSurface.withOpacity(0.90));

    return Column(
      children: [
        Row(
          children: [
            Text('Gesamtpunkte:', style: left),
            const Spacer(),
            Text('$totalPoints p', style: right),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('+ $timeBonus Zeitbonus', style: left),
            const Spacer(),
            Text('$timeBonus', style: right),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('Gelöste Aufgaben:', style: left),
            const Spacer(),
            Text('$solved', style: right),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('Übersprungen:', style: left),
            const Spacer(),
            Text('$skipped', style: right),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('Gesamtzeit:', style: left),
            const Spacer(),
            Text(totalTime, style: right),
          ],
        ),
      ],
    );
  }
}

class _MiniBars extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: SizedBox(
        width: 54,
        height: 28,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(width: 10, height: 26, color: scheme.onSurface.withOpacity(0.85)),
            const SizedBox(width: 6),
            Container(width: 10, height: 18, color: scheme.onSurface.withOpacity(0.55)),
            const SizedBox(width: 6),
            Container(width: 10, height: 12, color: scheme.onSurface.withOpacity(0.35)),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final String? labelRight;

  const _ProgressBar({required this.value, this.labelRight});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 22,
      child: Stack(
        children: [
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: scheme.onSurface.withOpacity(0.18),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          if (labelRight != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Text(
                labelRight!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface.withOpacity(0.55),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RankPlayer {
  final int rank;
  final String name;
  final String progressText;
  final int points;

  const _RankPlayer({
    required this.rank,
    required this.name,
    required this.progressText,
    required this.points,
  });
}
