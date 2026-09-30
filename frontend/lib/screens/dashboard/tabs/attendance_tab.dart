part of '../dashboard_screen.dart';

class _AttendanceView extends StatelessWidget {
  const _AttendanceView();

  static const _blue = Color(0xFF2563EB);
  static const _green = Color(0xFF059669);
  static const _red = Color(0xFFDC2626);
  static const _amber = Color(0xFFD97706);
  static const _dark = Color(0xFF111827);
  static const _muted = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<_WorkerTabController>()) {
      Get.put(_WorkerTabController(), permanent: true);
    }

    final controller = Get.find<_WorkerTabController>();

    return SafeArea(
      top: false,
      child: Obx(() {
        final workers = controller.workers.toList();
        final stats = controller.attendanceStatsForSelectedDate();

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Attendance',
                            style: TextStyle(
                              color: _dark,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        _DateSelector(
                          date: controller.selectedAttendanceDate.value,
                          onPressed: () =>
                              controller.pickAttendanceDate(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _AttendancePayCard(stats: stats),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _AttendanceStatCard(
                            label: 'Present',
                            value: stats.present.toString(),
                            icon: Icons.check_circle_rounded,
                            color: _green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _AttendanceStatCard(
                            label: 'Absent',
                            value: stats.absent.toString(),
                            icon: Icons.cancel_rounded,
                            color: _red,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _AttendanceStatCard(
                            label: 'Half Day',
                            value: stats.halfDay.toString(),
                            icon: Icons.timelapse_rounded,
                            color: _amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Workers',
                      style: TextStyle(
                        color: _dark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            if (workers.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
                  child: _AttendanceEmptyState(
                    onAddWorker: () =>
                        Get.find<DashboardController>().changeTab(1),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 132),
                sliver: SliverList.separated(
                  itemCount: workers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final worker = workers[index];
                    final status = controller.attendanceStatusFor(
                      worker,
                      controller.selectedAttendanceDate.value,
                    );

                    return _AttendanceWorkerCard(
                      worker: worker,
                      status: status,
                      pay: controller.attendancePayForStatus(worker, status),
                      onSelected: (value) =>
                          controller.markAttendance(worker, value),
                    );
                  },
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.date, required this.onPressed});

  final DateTime date;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _AttendanceView._border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 17,
                color: _AttendanceView._blue,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(date),
                style: const TextStyle(
                  color: _AttendanceView._dark,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttendancePayCard extends StatelessWidget {
  const _AttendancePayCard({required this.stats});

  final _AttendanceDayStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today payable wages',
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${_formatMoney(stats.totalPay)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${stats.unmarked} unmarked',
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceStatCard extends StatelessWidget {
  const _AttendanceStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AttendanceView._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: _AttendanceView._dark,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _AttendanceView._muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceWorkerCard extends StatelessWidget {
  const _AttendanceWorkerCard({
    required this.worker,
    required this.status,
    required this.pay,
    required this.onSelected,
  });

  final _WorkerRecord worker;
  final String status;
  final double pay;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AttendanceView._border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  worker.initials,
                  style: const TextStyle(
                    color: _AttendanceView._dark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _AttendanceView._dark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${worker.role} - ${worker.paymentType} Rs ${_formatMoney(worker.amount)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _AttendanceView._muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Rs ${_formatMoney(pay)}',
                style: const TextStyle(
                  color: _AttendanceView._dark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _AttendanceChoiceButton(
                  label: 'Present',
                  icon: Icons.check_rounded,
                  selected: status == _WorkerTabController.attendancePresent,
                  color: _AttendanceView._green,
                  onPressed: () =>
                      onSelected(_WorkerTabController.attendancePresent),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AttendanceChoiceButton(
                  label: 'Absent',
                  icon: Icons.close_rounded,
                  selected: status == _WorkerTabController.attendanceAbsent,
                  color: _AttendanceView._red,
                  onPressed: () =>
                      onSelected(_WorkerTabController.attendanceAbsent),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AttendanceChoiceButton(
                  label: '1/2 Day',
                  icon: Icons.schedule_rounded,
                  selected: status == _WorkerTabController.attendanceHalfDay,
                  color: _AttendanceView._amber,
                  onPressed: () =>
                      onSelected(_WorkerTabController.attendanceHalfDay),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceChoiceButton extends StatelessWidget {
  const _AttendanceChoiceButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? color : color.withValues(alpha: 0.08),
        foregroundColor: selected ? Colors.white : color,
        side: BorderSide(
          color: selected ? color : color.withValues(alpha: 0.22),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _AttendanceEmptyState extends StatelessWidget {
  const _AttendanceEmptyState({required this.onAddWorker});

  final VoidCallback onAddWorker;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.groups_2_rounded,
            color: _AttendanceView._blue,
            size: 34,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'No workers added',
          style: TextStyle(
            color: _AttendanceView._dark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add workers first, then mark daily attendance here.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _AttendanceView._muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: onAddWorker,
          icon: const Icon(Icons.group_add_rounded),
          label: const Text('Go to Workers'),
          style: FilledButton.styleFrom(
            backgroundColor: _AttendanceView._blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}
