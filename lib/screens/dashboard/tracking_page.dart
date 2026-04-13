// tracking_page.dart  ─  BENTO
// ══════════════════════════════════════════════════════════════════════
// FLICKER FIX EXPLANATION
// ══════════════════════════════════════════════════════════════════════
// Old code: every Firestore snapshot rebuild called startTimer() again,
// which called setState every second AND caused a full widget tree
// rebuild → visible flicker.
//
// New approach:
//  • The Firestore StreamBuilder only rebuilds the STATUS TEXT and
//    the TOKEN CARD. It does NOT touch the countdown widget at all.
//  • The countdown lives in its own tiny StatefulWidget (_CountdownTimer)
//    that has its own private Timer. It never rebuilds due to Firestore.
//  • _maybeStartTimer() checks a key so it only starts once per
//    unique prepTime value — never restarts on every Firestore ping.
// ══════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/order_service.dart';

class TrackingPage extends StatefulWidget {
  final String orderId;
  const TrackingPage({super.key, required this.orderId});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage>
    with TickerProviderStateMixin {
  // ── Pulse animation for the active timeline step ──────────
  late final AnimationController _pulse;
  late final Animation<double> _pulseAnim;

  // ── "Ready" snackbar shown only once per session ──────────
  bool _readyShown = false;

  // ── Countdown state — isolated so Firestore never touches it
  String _currentPrepKey = ''; // e.g. "orderId_10"
  int _initialSeconds = 0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  // Called from StreamBuilder's postFrameCallback — only triggers once
  // per new prepTime value.
  void _maybeInitTimer(String prepStr) {
    final prepMins = int.tryParse(prepStr) ?? 0;
    final key = '${widget.orderId}_$prepStr';
    if (prepMins <= 0 || key == _currentPrepKey) return;
    setState(() {
      _currentPrepKey = key;
      _initialSeconds = prepMins * 60;
    });
  }

  static const _steps = [
    'Order Placed',
    'Accepted',
    'Preparing',
    'Ready',
    'Completed'
  ];

  int _stepIdx(String status) {
    switch (status) {
      case 'Accepted':
        return 1;
      case 'Preparing':
        return 2;
      case 'Ready':
        return 3;
      case 'Completed':
        return 4;
      default:
        return 0;
    }
  }

  static const _bg = Color(0xFF0D1B2A);
  static const _card = Color(0xFF1B263B);

  @override
  Widget build(BuildContext context) {
    if (widget.orderId == 'dummy') return _placeholder(context);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Live Tracking'),
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.orange),
                onPressed: () => Navigator.pop(context))
            : null,
      ),
      // ── StreamBuilder: only rebuilds status / token / items ──────
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: OrderService().getOrderById(widget.orderId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.orange));
          }
          if (snap.hasError || !snap.hasData || snap.data == null) {
            return _notFound(context);
          }

          final o = snap.data!;
          final status = (o['status'] ?? 'Accepted') as String;
          final token = o['token'] ?? '';
          final prepStr = (o['prepTime'] ?? '') as String;
          final items = o['items'] as List? ?? [];
          final total = o['total'] ?? 0;
          final uname = (o['userName'] ?? '') as String;

          // Init timer ONCE when prepTime arrives — no setState cascade
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _maybeInitTimer(prepStr));

          // "Ready" snackbar — once only
          if (status == 'Ready' && !_readyShown) {
            _readyShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: const Duration(seconds: 5),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                content: const Row(children: [
                  Icon(Icons.notifications_active_rounded,
                      color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('🎉 Your order is READY! Collect from counter.',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ]),
              ));
            });
          }

          final activeStep = _stepIdx(status);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(children: [
              // ── Token / name card ─────────────────────────
              _tokenCard(token, uname, status),
              const SizedBox(height: 18),

              // ── Timeline (driven by status only) ──────────
              _timeline(activeStep, status, prepStr),
              const SizedBox(height: 18),

              // ── Timer / Ready / Done cards ─────────────────
              if (status == 'Completed')
                _completedCard()
              else if (status == 'Ready')
                _readyCard()
              else if (_initialSeconds > 0)
                // ★ _CountdownTimer is a separate widget with its own Timer.
                // Firestore rebuilds DO NOT reach inside it.
                _CountdownTimer(
                  key: ValueKey(_currentPrepKey), // stable key
                  totalSeconds: _initialSeconds,
                )
              else
                _waitingCard(),

              const SizedBox(height: 18),

              // ── Order items summary ───────────────────────
              _orderSummary(items, total),
            ]),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // UI helpers
  // ─────────────────────────────────────────────────────────

  Widget _tokenCard(dynamic token, String name, String status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFE8470A), Color(0xFFFF7043)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('TOKEN',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w600)),
          Text('#$token',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  height: 1.0)),
        ]),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Icon(Icons.restaurant_rounded, color: Colors.white60, size: 28),
          const SizedBox(height: 6),
          Text(name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_statusLabel(status),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ]),
      ]),
    );
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'Accepted':
        return '✅ Accepted';
      case 'Preparing':
        return '🍳 Preparing';
      case 'Ready':
        return '🎉 Ready!';
      case 'Completed':
        return '✔ Done';
      default:
        return s;
    }
  }

  Widget _timeline(int activeStep, String status, String prepStr) {
    final icons = [
      Icons.receipt_long_rounded,
      Icons.thumb_up_alt_rounded,
      Icons.restaurant_rounded,
      Icons.notifications_active_rounded,
      Icons.check_circle_rounded,
    ];
    final subs = [
      'Your order has been received',
      'Canteen confirmed your order',
      prepStr.isNotEmpty
          ? 'Cooking — Est. $prepStr min'
          : 'Kitchen is cooking your food',
      status == 'Ready'
          ? 'Collect from the counter 🎉'
          : 'Food will be ready soon',
      status == 'Completed' ? 'Enjoy your meal! 😊' : 'Order marked as done',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF243447)),
      ),
      child: Column(
        children: List.generate(_steps.length, (i) {
          final done = i < activeStep;
          final current = i == activeStep;
          final isLast = i == _steps.length - 1;
          return Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              // Pulsing circle for active step
              ScaleTransition(
                scale: current ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? Colors.green.shade700
                        : current
                            ? Colors.orange
                            : const Color(0xFF243447),
                    boxShadow: current
                        ? [
                            BoxShadow(
                                color: Colors.orange.withOpacity(0.4),
                                blurRadius: 10)
                          ]
                        : null,
                  ),
                  child: Icon(
                    done ? Icons.check_rounded : icons[i],
                    color:
                        done || current ? Colors.white : Colors.grey.shade600,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(_steps[i],
                        style: TextStyle(
                            color: done || current
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontWeight:
                                current ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13)),
                    if (current) ...[
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.orange.withOpacity(0.4)),
                        ),
                        child: const Text('Now',
                            style: TextStyle(
                                color: Colors.orange,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ]),
                  Text(subs[i],
                      style: TextStyle(
                          color: done
                              ? Colors.green.shade400
                              : current
                                  ? Colors.orange.shade200
                                  : Colors.grey.shade700,
                          fontSize: 10)),
                ],
              )),
            ]),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.only(left: 19),
                child: Container(
                  width: 2,
                  height: 22,
                  color: i < activeStep
                      ? Colors.green.shade700
                      : const Color(0xFF243447),
                ),
              ),
          ]);
        }),
      ),
    );
  }

  Widget _waitingCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.orange.withOpacity(0.25)),
        ),
        child: const Column(children: [
          SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                  color: Colors.orange, strokeWidth: 3)),
          SizedBox(height: 12),
          Text('Kitchen is preparing your order…',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          SizedBox(height: 4),
          Text('Timer will appear when admin sets prep time',
              style: TextStyle(color: Colors.grey, fontSize: 11)),
        ]),
      );

  Widget _readyCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.green.shade800, Colors.green.shade600]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.green.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 7))
          ],
        ),
        child: const Column(children: [
          Icon(Icons.notifications_active_rounded,
              color: Colors.white, size: 48),
          SizedBox(height: 10),
          Text('Your Order is READY!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('Please collect from the counter 🎉',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
      );

  Widget _completedCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
                color: Colors.green, shape: BoxShape.circle),
            child:
                const Icon(Icons.check_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          const Text('Order Completed!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Thank you for ordering at BENTO 😊',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
      );

  Widget _orderSummary(List items, dynamic total) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF243447)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Details',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 12),
            ...items.map((item) {
              final n = item is Map
                  ? (item['name'] ?? item['n'] ?? '')
                  : item.toString();
              final q = item is Map ? (item['qty'] ?? item['q'] ?? 1) : 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(Icons.fastfood_rounded,
                        color: Colors.orange, size: 14),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                      child: Text(n.toString().trim(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12))),
                  Text('× $q',
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ]),
              );
            }),
            const Divider(color: Color(0xFF243447), height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total Paid',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('₹$total',
                  style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ]),
          ],
        ),
      );

  Widget _placeholder(BuildContext context) => Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(title: const Text('Order Tracking'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _card,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.orange.withOpacity(0.18), blurRadius: 28)
                ],
              ),
              child: const Icon(Icons.delivery_dining_rounded,
                  color: Colors.orange, size: 64),
            ),
            const SizedBox(height: 22),
            const Text('No Active Order',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Place an order to track it here',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 32),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: OrderService().getOrders(),
              builder: (ctx2, snap) {
                if (!snap.hasData || snap.data!.isEmpty)
                  return const SizedBox.shrink();
                final active = snap.data!
                    .where((o) =>
                        o['status'] != 'Completed' &&
                        o['status'] != 'Cancelled')
                    .toList();
                if (active.isEmpty) return const SizedBox.shrink();
                final latest = active.first;
                return GestureDetector(
                  onTap: () => Navigator.push(
                      ctx2,
                      MaterialPageRoute(
                          builder: (_) =>
                              TrackingPage(orderId: latest['id'] ?? 'dummy'))),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.orange.withOpacity(0.4)),
                    ),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.receipt_long_rounded,
                            color: Colors.orange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text('Token #${latest['token'] ?? ''}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Text('Status: ${latest['status'] ?? ''}',
                                style: TextStyle(
                                    color: Colors.orange.shade300,
                                    fontSize: 12)),
                          ])),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.orange, size: 14),
                    ]),
                  ),
                );
              },
            ),
          ]),
        ),
      );

  Widget _notFound(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.search_off_rounded, color: Colors.grey, size: 56),
          const SizedBox(height: 14),
          const Text('Order not found',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('It may have been cancelled',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          if (Navigator.canPop(context)) ...[
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Go Back', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ]),
      );
}

// ══════════════════════════════════════════════════════════════════════
// _CountdownTimer — completely isolated widget
// Has its OWN Timer. Firestore StreamBuilder rebuilds never reach here
// because it uses a stable ValueKey. ZERO FLICKER.
// ══════════════════════════════════════════════════════════════════════
class _CountdownTimer extends StatefulWidget {
  final int totalSeconds;
  const _CountdownTimer({super.key, required this.totalSeconds});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late int _seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _seconds = widget.totalSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final total = widget.totalSeconds;
    final pct = total > 0 ? 1.0 - (_seconds / total).clamp(0.0, 1.0) : 0.0;
    final isOver = _seconds == 0;
    final prepMin = (total / 60).ceil();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF243447)),
      ),
      child: Column(children: [
        const Text('⏱  Time Remaining',
            style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 18),
        SizedBox(
          width: 130,
          height: 130,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(
              width: 130,
              height: 130,
              child: CircularProgressIndicator(
                value: pct,
                strokeWidth: 9,
                backgroundColor: const Color(0xFF243447),
                valueColor: AlwaysStoppedAnimation(
                    isOver ? Colors.red.shade400 : Colors.orange),
              ),
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                isOver ? '00:00' : _fmt(_seconds),
                style: TextStyle(
                    color: isOver ? Colors.red.shade400 : Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                isOver ? '⚠ Delayed' : 'remaining',
                style: TextStyle(
                    color: isOver ? Colors.red.shade400 : Colors.grey,
                    fontSize: 10),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 10),
        Text('Estimated: $prepMin minutes',
            style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ]),
    );
  }
}
