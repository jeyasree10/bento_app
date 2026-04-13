// history_page.dart — BENTO
// Reads REAL order history from Firestore for the logged-in user.
// Shows: monthly spend, order list, favourite items, total stats.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/order_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String _filter = 'All';

  static const _bg = Color(0xFF0D1B2A);
  static const _card = Color(0xFF1B263B);

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('My History'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.grey,
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Orders'),
            Tab(text: 'Monthly'),
            Tab(text: 'Favourites'),
          ],
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: OrderService().getOrders(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.orange));
          }
          if (snap.hasError) {
            return Center(
                child: Text('Error: ${snap.error}',
                    style: const TextStyle(color: Colors.white)));
          }

          final all = snap.data ?? [];
          final completed =
              all.where((o) => o['status'] == 'Completed').toList();
          final cancelled = all
              .where((o) => ['Cancelled', 'cancelled'].contains(o['status']))
              .toList();

          // Filter list for Orders tab
          List<Map<String, dynamic>> filtered;
          switch (_filter) {
            case 'Completed':
              filtered = completed;
              break;
            case 'Cancelled':
              filtered = cancelled;
              break;
            default:
              filtered = all;
          }

          // Monthly stats
          final monthlyData = _buildMonthly(all);

          // Favourite items
          final favItems = _buildFavourites(all);

          // Total stats
          final totalSpend =
              completed.fold<int>(0, (a, o) => a + (o['total'] as int? ?? 0));
          final avgSpend = completed.isNotEmpty
              ? (totalSpend / completed.length).round()
              : 0;

          return TabBarView(
            controller: _tabs,
            children: [
              // ── Tab 1: Orders ────────────────────────────
              _ordersTab(filtered, totalSpend, completed.length, avgSpend),

              // ── Tab 2: Monthly ───────────────────────────
              _monthlyTab(monthlyData, totalSpend),

              // ── Tab 3: Favourites ────────────────────────
              _favouritesTab(favItems, completed.length, totalSpend),
            ],
          );
        },
      ),
    );
  }

  // ── Tab 1: Orders ─────────────────────────────────────────
  Widget _ordersTab(List<Map<String, dynamic>> orders, int totalSpend,
      int completedCount, int avg) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Summary chips
        Row(children: [
          _chip('${orders.length}', 'Total Orders', Colors.orange),
          const SizedBox(width: 10),
          _chip('₹$totalSpend', 'Total Spent', Colors.green.shade600),
          const SizedBox(width: 10),
          _chip('₹$avg', 'Avg / Order', Colors.blue.shade400),
        ]),

        const SizedBox(height: 14),

        // Filter pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Completed', 'Cancelled'].map((f) {
              final sel = _filter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? Colors.orange : _card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(f,
                        style: TextStyle(
                            color: sel ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        if (orders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(children: [
                Text('📭', style: TextStyle(fontSize: 40)),
                SizedBox(height: 10),
                Text('No orders found',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              ]),
            ),
          )
        else
          ...orders.map((o) => _orderCard(o)),
      ]),
    );
  }

  Widget _orderCard(Map<String, dynamic> o) {
    final status = o['status'] ?? '';
    final token = o['token'] ?? '';
    final total = o['total'] ?? 0;
    final items = o['items'] as List? ?? [];
    final ts = o['createdAt'];
    String date = '–';
    if (ts is Timestamp) {
      final dt = ts.toDate();
      date =
          '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    final isOk = status == 'Completed';
    final isCanc = ['Cancelled', 'cancelled'].contains(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: isOk
                ? Colors.green
                : isCanc
                    ? Colors.red
                    : Colors.orange,
            width: 3,
          ),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('#$token',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isOk
                  ? Colors.green.withOpacity(0.15)
                  : isCanc
                      ? Colors.red.withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status,
                style: TextStyle(
                    color: isOk
                        ? Colors.green
                        : isCanc
                            ? Colors.red
                            : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
          const Spacer(),
          Text('₹$total',
              style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ]),
        const SizedBox(height: 5),
        Text(
            items.map((i) {
              final n = i is Map ? (i['name'] ?? i['n'] ?? '') : i.toString();
              final q = i is Map ? (i['qty'] ?? i['q'] ?? 1) : 1;
              return '$n ×$q';
            }).join('  •  '),
            style: const TextStyle(color: Colors.grey, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ]),
    );
  }

  // ── Tab 2: Monthly ────────────────────────────────────────
  Widget _monthlyTab(List<Map<String, dynamic>> monthly, int totalSpend) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Total spend card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFE8470A), Color(0xFFFF7043)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Total Spent (All Time)',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text('₹$totalSpend',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Track your canteen spending',
                style: TextStyle(color: Colors.white60, fontSize: 11)),
          ]),
        ),

        const SizedBox(height: 18),

        if (monthly.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Column(children: [
                Text('📊', style: TextStyle(fontSize: 36)),
                SizedBox(height: 10),
                Text('No spending data yet',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text('Complete some orders to see monthly stats!',
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
              ]),
            ),
          )
        else ...[
          const Text('Monthly Breakdown',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(height: 12),
          ...monthly.map((m) {
            final maxSpend = monthly
                .map((x) => x['spend'] as int)
                .reduce((a, b) => a > b ? a : b);
            final pct = maxSpend > 0 ? (m['spend'] as int) / maxSpend : 0.0;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(m['month'] as String,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          Text('₹${m['spend']}',
                              style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ]),
                    const SizedBox(height: 4),
                    Text('${m['count']} orders  •  Avg ₹${m['avg']}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 7,
                        backgroundColor: const Color(0xFF243447),
                        valueColor: const AlwaysStoppedAnimation(Colors.orange),
                      ),
                    ),
                  ]),
            );
          }),
        ],
      ]),
    );
  }

  // ── Tab 3: Favourites ─────────────────────────────────────
  Widget _favouritesTab(List<MapEntry<String, int>> favItems,
      int completedOrders, int totalSpend) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // User stats row
        Row(children: [
          _chip('$completedOrders', 'Completed', Colors.green.shade600),
          const SizedBox(width: 10),
          _chip('₹$totalSpend', 'Total Spent', Colors.orange),
        ]),

        const SizedBox(height: 18),

        const Text('🏆 Your Favourite Items',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        const SizedBox(height: 4),
        const Text('Based on your order history',
            style: TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 12),

        if (favItems.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Column(children: [
                Text('🍽️', style: TextStyle(fontSize: 40)),
                SizedBox(height: 10),
                Text('No favourites yet',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text('Order some food to see your favourites!',
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
              ]),
            ),
          )
        else
          ...favItems.asMap().entries.map((e) {
            final rank = e.key + 1;
            final name = e.value.key;
            final count = e.value.value;
            final maxCount = favItems.first.value;
            final pct = maxCount > 0 ? count / maxCount : 0.0;

            Color rankColor = rank == 1
                ? Colors.amber
                : rank == 2
                    ? Colors.grey.shade400
                    : rank == 3
                        ? Colors.orange.shade700
                        : Colors.grey.shade600;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(14),
                border: rank <= 3
                    ? Border.all(color: rankColor.withOpacity(0.4))
                    : null,
              ),
              child: Row(children: [
                // Rank medal
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: rankColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '#$rank',
                      style: TextStyle(
                          fontSize: rank <= 3 ? 18 : 12,
                          color: rankColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 5,
                        backgroundColor: const Color(0xFF243447),
                        valueColor: AlwaysStoppedAnimation(rankColor),
                      ),
                    ),
                  ],
                )),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('$count',
                      style: TextStyle(
                          color: rankColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const Text('orders',
                      style: TextStyle(color: Colors.grey, fontSize: 9)),
                ]),
              ]),
            );
          }),
      ]),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  Widget _chip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ]),
      ),
    );
  }

  List<Map<String, dynamic>> _buildMonthly(List<Map<String, dynamic>> orders) {
    final completed = orders.where((o) => o['status'] == 'Completed').toList();
    final Map<String, Map<String, dynamic>> byMonth = {};

    for (final o in completed) {
      final ts = o['createdAt'];
      if (ts is! Timestamp) continue;
      final dt = ts.toDate();
      final key = '${_monthName(dt.month)} ${dt.year}';
      byMonth.putIfAbsent(key, () => {'spend': 0, 'count': 0, 'month': key});
      byMonth[key]!['spend'] =
          (byMonth[key]!['spend'] as int) + (o['total'] as int? ?? 0);
      byMonth[key]!['count'] = (byMonth[key]!['count'] as int) + 1;
    }

    final result = byMonth.values.toList()
      ..sort((a, b) => b['month'].compareTo(a['month']));
    for (final m in result) {
      m['avg'] = m['count'] > 0 ? (m['spend'] / m['count']).round() : 0;
    }
    return result;
  }

  List<MapEntry<String, int>> _buildFavourites(
      List<Map<String, dynamic>> orders) {
    final completed = orders.where((o) => o['status'] == 'Completed').toList();
    final Map<String, int> counts = {};
    for (final o in completed) {
      final items = o['items'] as List? ?? [];
      for (final item in items) {
        if (item is! Map) continue;
        final name = (item['name'] ?? item['n'] ?? '').toString().trim();
        final qty = (item['qty'] ?? item['q'] ?? 1) as int;
        if (name.isNotEmpty) counts[name] = (counts[name] ?? 0) + qty;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(10).toList();
  }

  String _monthName(int m) => [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m];
}
