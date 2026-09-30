part of '../dashboard_screen.dart';

class _WorkerRecord {
  const _WorkerRecord({
    required this.id,
    required this.fullName,
    required this.workerType,
    required this.phoneNumber,
    required this.paymentType,
    required this.amount,
    required this.role,
    required this.sites,
    required this.openingAmount,
    required this.balanceType,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String workerType;
  final String phoneNumber;
  final String paymentType;
  final double amount;
  final String role;
  final List<String> sites;
  final double openingAmount;
  final String balanceType;
  final DateTime createdAt;

  bool get isSiteWorker => workerType == 'Site Worker';
  bool get isPaid => openingAmount <= 0;
  int get daysWorked => DateTime.now().difference(createdAt).inDays;
  String get initials {
    final words = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return 'W';
    }
    if (words.length == 1) {
      return words.first.characters.first.toUpperCase();
    }
    return '${words.first.characters.first}${words.last.characters.first}'
        .toUpperCase();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'workerType': workerType,
    'phoneNumber': phoneNumber,
    'paymentType': paymentType,
    'amount': amount,
    'role': role,
    'sites': sites,
    'openingAmount': openingAmount,
    'balanceType': balanceType,
    'createdAt': createdAt.toIso8601String(),
  };

  factory _WorkerRecord.fromJson(Map<String, dynamic> json) {
    return _WorkerRecord(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      workerType: json['workerType'] as String? ?? 'Site Worker',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      paymentType: json['paymentType'] as String? ?? 'Daily',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      role: json['role'] as String? ?? 'Worker',
      sites: (json['sites'] as List<dynamic>? ?? const [])
          .map((site) => site.toString())
          .toList(),
      openingAmount: (json['openingAmount'] as num?)?.toDouble() ?? 0,
      balanceType: json['balanceType'] as String? ?? 'To Pay',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class _AttendanceDayStats {
  const _AttendanceDayStats({
    required this.present,
    required this.absent,
    required this.halfDay,
    required this.unmarked,
    required this.totalPay,
  });

  final int present;
  final int absent;
  final int halfDay;
  final int unmarked;
  final double totalPay;
}

class _WorkerMonthlyAttendanceStats {
  const _WorkerMonthlyAttendanceStats({
    required this.present,
    required this.absent,
    required this.halfDay,
    required this.ot,
  });

  final int present;
  final int absent;
  final int halfDay;
  final int ot;
}

class _WorkerAdvanceTransaction {
  const _WorkerAdvanceTransaction({
    required this.id,
    required this.workerId,
    required this.type,
    required this.amount,
    required this.site,
    required this.paymentMethod,
    required this.note,
    required this.proofPath,
    required this.balanceAfter,
    required this.createdAt,
  });

  final String id;
  final String workerId;
  final String? type;
  final double amount;
  final String site;
  final String paymentMethod;
  final String note;
  final String proofPath;
  final double balanceAfter;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'workerId': workerId,
    'type': _WorkerTabController.normalizeTransactionType(type),
    'amount': amount,
    'site': site,
    'paymentMethod': paymentMethod,
    'note': note,
    'proofPath': proofPath,
    'balanceAfter': balanceAfter,
    'createdAt': createdAt.toIso8601String(),
  };

  factory _WorkerAdvanceTransaction.fromJson(Map<String, dynamic> json) {
    double readDouble(String key) {
      final value = json[key];
      if (value is num) {
        return value.toDouble();
      }
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return _WorkerAdvanceTransaction(
      id: json['id']?.toString() ?? '',
      workerId: json['workerId']?.toString() ?? '',
      type: json['type']?.toString(),
      amount: readDouble('amount'),
      site: json['site']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      proofPath: json['proofPath']?.toString() ?? '',
      balanceAfter: readDouble('balanceAfter'),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class _WorkerLedgerSummary {
  const _WorkerLedgerSummary({
    required this.totalAdvance,
    required this.advanceRecovered,
    required this.outstandingAdvance,
    required this.salaryEarned,
    required this.salaryPaid,
    required this.salaryDue,
  });

  final double totalAdvance;
  final double advanceRecovered;
  final double outstandingAdvance;
  final double salaryEarned;
  final double salaryPaid;
  final double salaryDue;

  String get salaryStatus {
    if (salaryDue <= 0 && salaryEarned > 0) {
      return 'Paid';
    }
    if (salaryPaid > 0 || advanceRecovered > 0) {
      return 'Partially Paid';
    }
    return 'Unpaid';
  }
}

class _WorkersView extends StatelessWidget {
  const _WorkersView();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<_WorkerTabController>()) {
      Get.put(_WorkerTabController(), permanent: true);
    }

    final controller = Get.find<_WorkerTabController>();

    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: controller.isAddingWorker.value
            ? _AddWorkerForm(
                key: const ValueKey('add-worker-form'),
                onClose: controller.closeForm,
              )
            : controller.workers.isEmpty
            ? _WorkerEmptyState(
                key: const ValueKey('worker-empty-state'),
                onAddWorker: controller.openForm,
              )
            : _WorkerListView(
                key: const ValueKey('worker-list'),
                controller: controller,
              ),
      ),
    );
  }
}

class _WorkerTabController extends GetxController {
  static const _storageKey = 'construction_workers';
  static const _attendanceStorageKey = 'construction_worker_attendance';
  static const _advanceStorageKey = 'construction_worker_advances';
  static const attendancePresent = 'Present';
  static const attendanceAbsent = 'Absent';
  static const attendanceHalfDay = '1/2 Day';
  static const transactionAdvanceGiven = 'Advance Given';
  static const transactionAdvanceRepaid = 'Advance Repaid';
  static const transactionAdvanceAdjusted = 'Advance Adjusted from Salary';
  static const transactionSalaryPaid = 'Salary Paid';
  static const transactionFilterAll = 'All';
  static const transactionFilterAdvance = 'Advance';
  static const transactionFilterRepayment = 'Repayment';
  static const transactionFilterSalaryAdjustment = 'Salary Adjustment';
  static const transactionFilterSalaryPayment = 'Salary Payment';

  static String normalizeTransactionType(Object? rawType) {
    final value = rawType?.toString().trim();
    if (value == null || value.isEmpty || value.toLowerCase() == 'null') {
      return transactionAdvanceGiven;
    }
    if (value == transactionAdvanceGiven ||
        value == transactionAdvanceRepaid ||
        value == transactionAdvanceAdjusted ||
        value == transactionSalaryPaid) {
      return value;
    }
    return transactionAdvanceGiven;
  }

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final wageAmountController = TextEditingController();
  final otRateController = TextEditingController();
  final openingAmountController = TextEditingController(text: '0');
  final searchController = TextEditingController();

  final isAddingWorker = false.obs;
  final workers = <_WorkerRecord>[].obs;
  final workerType = 'Site Worker'.obs;
  final paymentType = 'Daily'.obs;
  final balanceType = 'To Pay'.obs;
  final role = RxnString();
  final openingDate = DateTime.now().obs;
  final wagesOpen = true.obs;
  final workDetailsOpen = true.obs;
  final openingBalanceOpen = false.obs;
  final sites = <String>[].obs;
  final selectedWorkerTab = 'Site Workers'.obs;
  final statusFilter = 'Active'.obs;
  final sortAscending = true.obs;
  final searchQuery = ''.obs;
  final showSearch = false.obs;
  final editingWorkerId = RxnString();
  final selectedAttendanceDate = DateTime.now().obs;
  final attendance = <String, String>{}.obs;
  final advances = <_WorkerAdvanceTransaction>[].obs;
  final selectedTransactionFilter = transactionFilterAll.obs;

  static const _phoneChannel = MethodChannel('construction_site/phone');

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim();
    });
    _loadWorkers();
    _loadAttendance();
    _loadAdvances();
  }

  List<_WorkerRecord> get visibleWorkers {
    final query = searchQuery.value.toLowerCase();
    final filtered = workers.where((worker) {
      final matchesTab = selectedWorkerTab.value == 'Site Workers'
          ? worker.isSiteWorker
          : !worker.isSiteWorker;
      final matchesSearch =
          query.isEmpty ||
          worker.fullName.toLowerCase().contains(query) ||
          worker.role.toLowerCase().contains(query) ||
          worker.phoneNumber.contains(query);
      final matchesStatus =
          statusFilter.value == 'Active' ||
          statusFilter.value == 'All' ||
          (statusFilter.value == 'Settled' && worker.isPaid) ||
          (statusFilter.value == 'Due' && !worker.isPaid);

      return matchesTab && matchesSearch && matchesStatus;
    }).toList();

    filtered.sort((a, b) {
      final result = a.fullName.toLowerCase().compareTo(
        b.fullName.toLowerCase(),
      );
      return sortAscending.value ? result : -result;
    });
    return filtered;
  }

  void openForm() {
    _resetForm();
    isAddingWorker.value = true;
  }

  void closeForm() {
    isAddingWorker.value = false;
    _resetForm();
  }

  bool get isEditingWorker => editingWorkerId.value != null;

  void setWorkerType(String value) => workerType.value = value;
  void setPaymentType(String value) => paymentType.value = value;
  void setBalanceType(String value) => balanceType.value = value;
  void setRole(String? value) => role.value = value;
  void setWorkerTab(String value) => selectedWorkerTab.value = value;
  void setStatusFilter(String? value) => statusFilter.value = value ?? 'Active';
  void toggleSort() => sortAscending.toggle();
  void toggleSearch() => showSearch.toggle();
  void toggleWages() => wagesOpen.toggle();
  void toggleWorkDetails() => workDetailsOpen.toggle();
  void toggleOpeningBalance() => openingBalanceOpen.toggle();
  void removeSite(String site) => sites.remove(site);
  void setAttendanceDate(DateTime date) {
    selectedAttendanceDate.value = DateTime(date.year, date.month, date.day);
  }

  void showPreviousAttendanceMonth() {
    final date = selectedAttendanceDate.value;
    selectedAttendanceDate.value = DateTime(date.year, date.month - 1, 1);
  }

  void showNextAttendanceMonth() {
    final date = selectedAttendanceDate.value;
    selectedAttendanceDate.value = DateTime(date.year, date.month + 1, 1);
  }

  void showTodayAttendance() {
    setAttendanceDate(DateTime.now());
  }

  void openWorkerDetails(_WorkerRecord worker) {
    Get.to(() => _WorkerDetailsPage(worker: worker));
  }

  void openEditForm(_WorkerRecord worker) {
    _populateForm(worker);
    isAddingWorker.value = true;
  }

  Future<void> callWorker(_WorkerRecord worker) async {
    final phoneNumber = worker.phoneNumber.trim();
    if (phoneNumber.isEmpty) {
      Get.snackbar(
        'Phone number missing',
        '${worker.fullName} does not have a saved phone number.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
      );
      return;
    }

    try {
      final launched = await _phoneChannel.invokeMethod<bool>('openDialer', {
        'phoneNumber': phoneNumber,
      });
      if (launched != true) {
        _showCallFailed(worker);
      }
    } on PlatformException {
      _showCallFailed(worker);
    } on MissingPluginException {
      _showCallFailed(worker);
    }
  }

  void _showCallFailed(_WorkerRecord worker) {
    Get.snackbar(
      'Cannot open dialer',
      'Please call ${worker.phoneNumber} manually.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
    );
  }

  void importContact() {
    Get.snackbar(
      'Import from contacts',
      'Contact picker can be connected to the device contacts permission.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
    );
  }

  Future<void> addSite() async {
    final siteController = TextEditingController();
    final errorText = RxnString();

    final site = await Get.dialog<String>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        title: const Row(
          children: [
            Icon(Icons.apartment_rounded, color: Color(0xFF2563EB)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Add Site',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
        content: Obx(
          () => TextField(
            controller: siteController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Enter site name',
              errorText: errorText.value,
              prefixIcon: const Icon(Icons.location_city_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFDC2626)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFDC2626),
                  width: 1.5,
                ),
              ),
            ),
            textInputAction: TextInputAction.done,
            onChanged: (_) => errorText.value = null,
            onSubmitted: (_) => _submitSiteName(siteController, errorText),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<String>(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => _submitSiteName(siteController, errorText),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Site'),
          ),
        ],
      ),
    );
    siteController.dispose();

    if (site == null) {
      return;
    }
    sites.add(site);
  }

  void _submitSiteName(
    TextEditingController siteController,
    RxnString errorText,
  ) {
    final site = siteController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (site.isEmpty) {
      errorText.value = 'Enter site name';
      return;
    }

    final alreadyAdded = sites.any(
      (existing) => existing.trim().toLowerCase() == site.toLowerCase(),
    );
    if (alreadyAdded) {
      errorText.value = 'This site is already assigned';
      return;
    }

    Get.back(result: site);
  }

  Future<void> pickOpeningDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: openingDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      openingDate.value = date;
    }
  }

  Future<void> pickAttendanceDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedAttendanceDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setAttendanceDate(date);
    }
  }

  String attendanceStatusFor(_WorkerRecord worker, DateTime date) {
    return attendance[_attendanceKey(worker.id, date)] ?? '';
  }

  Future<void> markAttendance(_WorkerRecord worker, String status) async {
    attendance[_attendanceKey(worker.id, selectedAttendanceDate.value)] =
        status;
    await _persistAttendance();
  }

  double attendancePayForStatus(_WorkerRecord worker, String status) {
    if (status == attendancePresent) {
      return worker.amount;
    }
    if (status == attendanceHalfDay) {
      return worker.amount / 2;
    }
    return 0;
  }

  double attendancePayForWorkerThisMonth(_WorkerRecord worker) {
    final selectedDate = selectedAttendanceDate.value;
    return attendance.entries.fold<double>(0, (total, entry) {
      final parts = entry.key.split('|');
      if (parts.length != 2 || parts.first != worker.id) {
        return total;
      }
      final markedDate = DateTime.tryParse(parts.last);
      if (markedDate == null ||
          markedDate.year != selectedDate.year ||
          markedDate.month != selectedDate.month) {
        return total;
      }
      return total + attendancePayForStatus(worker, entry.value);
    });
  }

  double payableBalanceForWorker(_WorkerRecord worker) {
    return ledgerSummaryForWorker(worker).salaryDue;
  }

  List<_WorkerAdvanceTransaction> advancesForWorker(_WorkerRecord worker) {
    return transactionsForWorker(worker);
  }

  List<_WorkerAdvanceTransaction> transactionsForWorker(_WorkerRecord worker) {
    final items = advances
        .where((transaction) => transaction.workerId == worker.id)
        .toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  List<_WorkerAdvanceTransaction> filteredTransactionsForWorker(
    _WorkerRecord worker,
  ) {
    final filter = selectedTransactionFilter.value;
    final items = transactionsForWorker(worker);
    if (filter == transactionFilterAll) {
      return items;
    }

    return items.where((transaction) {
      final type = normalizeTransactionType(transaction.type);
      if (filter == transactionFilterAdvance) {
        return type == transactionAdvanceGiven;
      }
      if (filter == transactionFilterRepayment) {
        return type == transactionAdvanceRepaid;
      }
      if (filter == transactionFilterSalaryAdjustment) {
        return type == transactionAdvanceAdjusted;
      }
      return type == transactionSalaryPaid;
    }).toList();
  }

  double advanceTotalForWorker(_WorkerRecord worker) {
    return ledgerSummaryForWorker(worker).totalAdvance;
  }

  double salaryEarnedForWorker(_WorkerRecord worker) {
    return attendance.entries.fold<double>(0, (total, entry) {
      final parts = entry.key.split('|');
      if (parts.length != 2 || parts.first != worker.id) {
        return total;
      }
      return total + attendancePayForStatus(worker, entry.value);
    });
  }

  _WorkerLedgerSummary ledgerSummaryForWorker(_WorkerRecord worker) {
    final salaryEarned = salaryEarnedForWorker(worker);
    var totalAdvance = 0.0;
    var advanceRepaid = 0.0;
    var advanceAdjusted = 0.0;
    var salaryPaid = 0.0;

    for (final transaction in transactionsForWorker(worker)) {
      final type = normalizeTransactionType(transaction.type);
      if (type == transactionAdvanceGiven) {
        totalAdvance += transaction.amount;
      } else if (type == transactionAdvanceRepaid) {
        advanceRepaid += transaction.amount;
      } else if (type == transactionAdvanceAdjusted) {
        advanceAdjusted += transaction.amount;
      } else if (type == transactionSalaryPaid) {
        salaryPaid += transaction.amount;
      }
    }

    final recovered = advanceRepaid + advanceAdjusted;
    final outstandingAdvance = (totalAdvance - recovered).clamp(
      0.0,
      double.infinity,
    );
    final salaryDue = (salaryEarned - salaryPaid - advanceAdjusted).clamp(
      0.0,
      double.infinity,
    );

    return _WorkerLedgerSummary(
      totalAdvance: totalAdvance,
      advanceRecovered: recovered,
      outstandingAdvance: outstandingAdvance,
      salaryEarned: salaryEarned,
      salaryPaid: salaryPaid,
      salaryDue: salaryDue,
    );
  }

  void setTransactionFilter(String filter) {
    selectedTransactionFilter.value = filter;
  }

  Future<void> giveAdvance({
    required _WorkerRecord worker,
    required double amount,
    required String site,
    required String note,
  }) async {
    await recordWorkerTransaction(
      worker: worker,
      type: transactionAdvanceGiven,
      amount: amount,
      site: site,
      paymentMethod: '',
      note: note,
      proofPath: '',
      paymentDate: DateTime.now(),
    );
    Get.snackbar(
      'Advance added',
      'Rs ${_formatMoney(amount)} advance saved for ${worker.fullName}.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
    );
  }

  Future<void> recordWorkerTransaction({
    required _WorkerRecord worker,
    required String type,
    required double amount,
    required String site,
    required String paymentMethod,
    required String note,
    required String proofPath,
    required DateTime paymentDate,
  }) async {
    final transaction = _WorkerAdvanceTransaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      workerId: worker.id,
      type: type,
      amount: amount,
      site: site,
      paymentMethod: paymentMethod,
      note: note.trim(),
      proofPath: proofPath.trim(),
      balanceAfter: 0,
      createdAt: paymentDate,
    );
    advances.add(transaction);
    final summary = ledgerSummaryForWorker(worker);
    final balanceAfter = type == transactionSalaryPaid
        ? summary.salaryDue
        : summary.outstandingAdvance;
    final index = advances.indexWhere((item) => item.id == transaction.id);
    if (index != -1) {
      advances[index] = _WorkerAdvanceTransaction(
        id: transaction.id,
        workerId: transaction.workerId,
        type: normalizeTransactionType(transaction.type),
        amount: transaction.amount,
        site: transaction.site,
        paymentMethod: transaction.paymentMethod,
        note: transaction.note,
        proofPath: transaction.proofPath,
        balanceAfter: balanceAfter,
        createdAt: transaction.createdAt,
      );
    }
    await _persistAdvances();
  }

  double attendanceDaysForWorkerThisMonth(_WorkerRecord worker) {
    final selectedDate = selectedAttendanceDate.value;
    return attendance.entries.fold<double>(0, (total, entry) {
      final parts = entry.key.split('|');
      if (parts.length != 2 || parts.first != worker.id) {
        return total;
      }
      final markedDate = DateTime.tryParse(parts.last);
      if (markedDate == null ||
          markedDate.year != selectedDate.year ||
          markedDate.month != selectedDate.month) {
        return total;
      }
      if (entry.value == attendancePresent) {
        return total + 1;
      }
      if (entry.value == attendanceHalfDay) {
        return total + 0.5;
      }
      return total;
    });
  }

  _AttendanceDayStats attendanceStatsForSelectedDate() {
    var present = 0;
    var absent = 0;
    var halfDay = 0;
    var totalPay = 0.0;

    for (final worker in workers) {
      final status = attendanceStatusFor(worker, selectedAttendanceDate.value);
      if (status == attendancePresent) {
        present++;
      } else if (status == attendanceAbsent) {
        absent++;
      } else if (status == attendanceHalfDay) {
        halfDay++;
      }
      totalPay += attendancePayForStatus(worker, status);
    }

    return _AttendanceDayStats(
      present: present,
      absent: absent,
      halfDay: halfDay,
      unmarked: workers.length - present - absent - halfDay,
      totalPay: totalPay,
    );
  }

  _WorkerMonthlyAttendanceStats monthlyAttendanceStatsForWorker(
    _WorkerRecord worker,
  ) {
    final selectedDate = selectedAttendanceDate.value;
    var present = 0;
    var absent = 0;
    var halfDay = 0;

    for (final entry in attendance.entries) {
      final parts = entry.key.split('|');
      if (parts.length != 2 || parts.first != worker.id) {
        continue;
      }
      final markedDate = DateTime.tryParse(parts.last);
      if (markedDate == null ||
          markedDate.year != selectedDate.year ||
          markedDate.month != selectedDate.month) {
        continue;
      }
      if (entry.value == attendancePresent) {
        present++;
      } else if (entry.value == attendanceAbsent) {
        absent++;
      } else if (entry.value == attendanceHalfDay) {
        halfDay++;
      }
    }

    return _WorkerMonthlyAttendanceStats(
      present: present,
      absent: absent,
      halfDay: halfDay,
      ot: 0,
    );
  }

  Future<void> saveWorker() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final amount = double.parse(wageAmountController.text.trim());
    final openingAmount =
        double.tryParse(openingAmountController.text.trim()) ?? 0;
    final editingId = editingWorkerId.value;
    final existingIndex = editingId == null
        ? -1
        : workers.indexWhere((worker) => worker.id == editingId);
    final existingWorker = existingIndex == -1 ? null : workers[existingIndex];
    final worker = _WorkerRecord(
      id:
          existingWorker?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      fullName: nameController.text.trim(),
      workerType: workerType.value,
      phoneNumber: phoneController.text.trim(),
      paymentType: paymentType.value,
      amount: amount,
      role: role.value ?? 'Worker',
      sites: List<String>.from(sites),
      openingAmount: openingAmount,
      balanceType: balanceType.value,
      createdAt: existingWorker?.createdAt ?? DateTime.now(),
    );

    if (existingIndex == -1) {
      workers.add(worker);
    } else {
      workers[existingIndex] = worker;
    }
    await _persistWorkers();
    closeForm();
    selectedWorkerTab.value = worker.isSiteWorker
        ? 'Site Workers'
        : 'Office Workers';
    Get.snackbar(
      existingIndex == -1 ? 'Worker saved' : 'Worker updated',
      existingIndex == -1
          ? '${worker.fullName} has been added.'
          : '${worker.fullName} has been updated.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
    );
  }

  Future<void> removeWorker(_WorkerRecord worker) async {
    final shouldRemove = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove worker?'),
        content: Text(
          'This will remove ${worker.fullName} from your worker list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (shouldRemove != true) {
      return;
    }

    workers.removeWhere((item) => item.id == worker.id);
    attendance.removeWhere((key, value) => key.startsWith('${worker.id}|'));
    advances.removeWhere((advance) => advance.workerId == worker.id);
    await _persistWorkers();
    await _persistAttendance();
    await _persistAdvances();
    if (editingWorkerId.value == worker.id) {
      closeForm();
    }
    Get.back();
    Get.snackbar(
      'Worker removed',
      '${worker.fullName} has been removed.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
    );
  }

  Future<void> _loadWorkers() async {
    final preferences = await SharedPreferences.getInstance();
    final rawWorkers = preferences.getStringList(_storageKey) ?? const [];
    workers.assignAll(
      rawWorkers.map((raw) {
        return _WorkerRecord.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }),
    );
  }

  Future<void> _loadAttendance() async {
    final preferences = await SharedPreferences.getInstance();
    final rawAttendance =
        preferences.getStringList(_attendanceStorageKey) ?? const [];
    final loaded = <String, String>{};
    for (final raw in rawAttendance) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final key = decoded['key'] as String? ?? '';
      final status = decoded['status'] as String? ?? '';
      if (key.isNotEmpty && status.isNotEmpty) {
        loaded[key] = status;
      }
    }
    attendance.assignAll(loaded);
  }

  Future<void> _loadAdvances() async {
    final preferences = await SharedPreferences.getInstance();
    final rawAdvances =
        preferences.getStringList(_advanceStorageKey) ?? const [];
    final loaded = <_WorkerAdvanceTransaction>[];
    for (final raw in rawAdvances) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final advance = _WorkerAdvanceTransaction.fromJson(decoded);
          if (advance.id.isNotEmpty && advance.workerId.isNotEmpty) {
            loaded.add(advance);
          }
        }
      } catch (_) {
        // Ignore corrupted legacy rows so the ledger can still open.
      }
    }
    advances.assignAll(loaded);
  }

  Future<void> _persistWorkers() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      workers.map((worker) => jsonEncode(worker.toJson())).toList(),
    );
  }

  Future<void> _persistAttendance() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _attendanceStorageKey,
      attendance.entries
          .map((entry) => jsonEncode({'key': entry.key, 'status': entry.value}))
          .toList(),
    );
  }

  Future<void> _persistAdvances() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _advanceStorageKey,
      advances.map((advance) => jsonEncode(advance.toJson())).toList(),
    );
  }

  void _resetForm() {
    formKey.currentState?.reset();
    editingWorkerId.value = null;
    nameController.clear();
    phoneController.clear();
    wageAmountController.clear();
    otRateController.clear();
    openingAmountController.text = '0';
    workerType.value = 'Site Worker';
    paymentType.value = 'Daily';
    balanceType.value = 'To Pay';
    role.value = null;
    sites.clear();
    openingDate.value = DateTime.now();
    wagesOpen.value = true;
    workDetailsOpen.value = true;
    openingBalanceOpen.value = false;
  }

  void _populateForm(_WorkerRecord worker) {
    formKey.currentState?.reset();
    editingWorkerId.value = worker.id;
    nameController.text = worker.fullName;
    phoneController.text = worker.phoneNumber;
    wageAmountController.text = _formatMoney(worker.amount);
    otRateController.clear();
    openingAmountController.text = _formatMoney(worker.openingAmount);
    workerType.value = worker.workerType;
    paymentType.value = worker.paymentType;
    balanceType.value = worker.balanceType;
    role.value = worker.role;
    sites.assignAll(worker.sites);
    openingDate.value = worker.createdAt;
    wagesOpen.value = true;
    workDetailsOpen.value = true;
    openingBalanceOpen.value = worker.openingAmount > 0;
  }

  String _attendanceKey(String workerId, DateTime date) {
    return '$workerId|${_dateKey(date)}';
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    wageAmountController.dispose();
    otRateController.dispose();
    openingAmountController.dispose();
    searchController.dispose();
    super.onClose();
  }
}

class _WorkerListView extends StatelessWidget {
  const _WorkerListView({super.key, required this.controller});

  final _WorkerTabController controller;

  static const _blue = Color(0xFF2563EB);
  static const _dark = Color(0xFF111827);
  static const _border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Stack(
        children: [
          CustomScrollView(
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
                              'Workers',
                              style: TextStyle(
                                color: _dark,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Menu',
                            onPressed: () {},
                            icon: const Icon(
                              Icons.menu_rounded,
                              size: 30,
                              color: _dark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => _FilterPill(
                                label:
                                    'Status: ${controller.statusFilter.value}',
                                values: const [
                                  'Active',
                                  'All',
                                  'Settled',
                                  'Due',
                                ],
                                onSelected: controller.setStatusFilter,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Obx(
                              () => _FilterPill(
                                label: controller.sortAscending.value
                                    ? 'Sort: Name A-Z'
                                    : 'Sort: Name Z-A',
                                values: const ['Name A-Z', 'Name Z-A'],
                                onSelected: (value) {
                                  final shouldAsc = value == 'Name A-Z';
                                  if (controller.sortAscending.value !=
                                      shouldAsc) {
                                    controller.toggleSort();
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            tooltip: 'Search workers',
                            onPressed: controller.toggleSearch,
                            icon: const Icon(
                              Icons.search_rounded,
                              color: _dark,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => AnimatedCrossFade(
                          firstChild: Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: TextField(
                              controller: controller.searchController,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Search workers',
                                prefixIcon: const Icon(Icons.search_rounded),
                                suffixIcon:
                                    controller.searchController.text.isEmpty
                                    ? null
                                    : IconButton(
                                        onPressed: () =>
                                            controller.searchController.clear(),
                                        icon: const Icon(Icons.close_rounded),
                                      ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: _border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: _border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: _blue,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          secondChild: const SizedBox.shrink(),
                          crossFadeState: controller.showSearch.value
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 180),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _WorkerTabsHeader(controller: controller),
              ),
              Obx(() {
                final workers = controller.visibleWorkers;
                if (workers.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 118),
                      child: _InlineEmptyWorkers(
                        onAddWorker: controller.openForm,
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 132),
                  sliver: SliverList.separated(
                    itemCount: workers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return _WorkerCard(
                        worker: workers[index],
                        onTap: () =>
                            controller.openWorkerDetails(workers[index]),
                        onCall: () => controller.callWorker(workers[index]),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 102,
            child: FloatingActionButton.extended(
              heroTag: 'add-worker-fab',
              onPressed: controller.openForm,
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              icon: const Icon(Icons.group_add_rounded),
              label: const Text(
                'Add Worker',
                style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkerTabsHeader extends SliverPersistentHeaderDelegate {
  _WorkerTabsHeader({required this.controller});

  final _WorkerTabController controller;

  @override
  double get minExtent => 54;

  @override
  double get maxExtent => 54;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border.symmetric(
            horizontal: BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        child: Obx(() {
          final siteCount = controller.workers
              .where((worker) => worker.isSiteWorker)
              .length;
          final officeCount = controller.workers.length - siteCount;
          return Row(
            children: [
              _WorkerCountTab(
                label: 'Site Workers ($siteCount)',
                selected: controller.selectedWorkerTab.value == 'Site Workers',
                onTap: () => controller.setWorkerTab('Site Workers'),
              ),
              _WorkerCountTab(
                label: 'Office Workers ($officeCount)',
                selected:
                    controller.selectedWorkerTab.value == 'Office Workers',
                onTap: () => controller.setWorkerTab('Office Workers'),
              ),
            ],
          );
        }),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _WorkerTabsHeader oldDelegate) =>
      oldDelegate.controller != controller;
}

class _WorkerCountTab extends StatelessWidget {
  const _WorkerCountTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF111827),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 3,
              width: selected ? 166 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.values,
    required this.onSelected,
  });

  final String label;
  final List<String> values;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => values
          .map((value) => PopupMenuItem(value: value, child: Text(value)))
          .toList(),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  const _WorkerCard({
    required this.worker,
    required this.onTap,
    required this.onCall,
  });

  final _WorkerRecord worker;
  final VoidCallback onTap;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            color: Colors.white,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  worker.initials,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          worker.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      worker.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: worker.isPaid
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  worker.isPaid ? 'Settled' : 'Due',
                  style: TextStyle(
                    color: worker.isPaid
                        ? const Color(0xFF047857)
                        : const Color(0xFFB45309),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Call worker',
                onPressed: onCall,
                icon: const Icon(
                  Icons.call_outlined,
                  color: Color(0xFF2563EB),
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineEmptyWorkers extends StatelessWidget {
  const _InlineEmptyWorkers({required this.onAddWorker});

  final VoidCallback onAddWorker;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.groups_2_outlined, size: 58, color: Color(0xFF1F63BF)),
        const SizedBox(height: 14),
        const Text(
          'No workers match your filters',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onAddWorker,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Worker'),
        ),
      ],
    );
  }
}

class _WorkerEmptyState extends StatelessWidget {
  const _WorkerEmptyState({super.key, required this.onAddWorker});

  final VoidCallback onAddWorker;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 118),
        child: Column(
          children: [
            const SizedBox(height: 42),
            const _WorkerEmptyIllustration(),
            const SizedBox(height: 28),
            const Text(
              'No workers',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1D2433),
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Workers you add will show up here.',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF1D2433),
                fontSize: 16,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                height: 1.22,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: onAddWorker,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Worker'),
                style: ElevatedButton.styleFrom(
                  elevation: 7,
                  shadowColor: const Color(0xFF0B5BB8).withValues(alpha: 0.24),
                  backgroundColor: const Color(0xFF1F63BF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
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

class _AddWorkerForm extends GetView<_WorkerTabController> {
  const _AddWorkerForm({super.key, required this.onClose});

  final VoidCallback onClose;

  static const _blue = Color(0xFF1F63BF);
  static const _dark = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _border = Color(0xFFD9DCE2);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Form(
        key: controller.formKey,
        child: CustomScrollView(
          key: const PageStorageKey('add-worker-scroll'),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 14, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => Text(
                          controller.isEditingWorker
                              ? 'Edit Worker'
                              : 'Add Worker',
                          style: const TextStyle(
                            color: _dark,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: onClose,
                      icon: const Icon(Icons.close_rounded, size: 28),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 124),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _FormCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ContactImportButton(
                          onPressed: controller.importContact,
                        ),
                        const SizedBox(height: 22),
                        const _Label('Full Name', requiredMark: true),
                        const SizedBox(height: 8),
                        _AppTextField(
                          controller: controller.nameController,
                          hint: "Enter worker's full name",
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter worker name';
                            }
                            if (value.trim().length < 2) {
                              return 'Name is too short';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        const _Label('Worker Type', requiredMark: true),
                        const SizedBox(height: 8),
                        Obx(
                          () => _SegmentedChoice(
                            values: const ['Site Worker', 'Office Worker'],
                            selected: controller.workerType.value,
                            onChanged: controller.setWorkerType,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _Label('Phone Number', requiredMark: true),
                        const SizedBox(height: 8),
                        _AppTextField(
                          controller: controller.phoneController,
                          hint: 'Enter phone number',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final phone = value?.trim() ?? '';
                            if (phone.isEmpty) {
                              return 'Enter phone number';
                            }
                            if (phone.replaceAll(RegExp(r'\D'), '').length <
                                7) {
                              return 'Enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => _ExpandableFormCard(
                      title: 'Wages & Payment',
                      isOpen: controller.wagesOpen.value,
                      onToggle: controller.toggleWages,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _Label('Payment Type', requiredMark: true),
                          const SizedBox(height: 8),
                          _SegmentedChoice(
                            values: const ['Daily', 'Weekly', 'Monthly'],
                            selected: controller.paymentType.value,
                            onChanged: controller.setPaymentType,
                          ),
                          const SizedBox(height: 18),
                          const _Label('Amount', requiredMark: true),
                          const SizedBox(height: 8),
                          _MoneyField(
                            controller: controller.wageAmountController,
                            hint: 'e.g., 800',
                            validator: (value) {
                              final amount = double.tryParse(
                                value?.trim() ?? '',
                              );
                              if (amount == null || amount <= 0) {
                                return 'Enter a valid amount';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          const _Label('OT rate per hour (Optional)'),
                          const SizedBox(height: 8),
                          _MoneyField(
                            controller: controller.otRateController,
                            hint: 'e.g., 100',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => _ExpandableFormCard(
                      title: 'Work Details',
                      isOpen: controller.workDetailsOpen.value,
                      onToggle: controller.toggleWorkDetails,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _Label('Role'),
                          const SizedBox(height: 8),
                          _RoleDropdown(
                            value: controller.role.value,
                            onChanged: controller.setRole,
                          ),
                          const SizedBox(height: 18),
                          const _Label('Assigned Sites'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...controller.sites.map(
                                (site) => InputChip(
                                  label: Text(site),
                                  onDeleted: () => controller.removeSite(site),
                                  deleteIcon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                  ),
                                  backgroundColor: const Color(0xFFEAF2FF),
                                  side: const BorderSide(color: _border),
                                  labelStyle: const TextStyle(
                                    color: _dark,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              _AddSiteButton(onPressed: controller.addSite),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => _ExpandableFormCard(
                      title: 'Opening Balance',
                      isOpen: controller.openingBalanceOpen.value,
                      onToggle: controller.toggleOpeningBalance,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _Label('Balance type'),
                          const SizedBox(height: 8),
                          _SegmentedChoice(
                            values: const ['To Pay', 'To Receive'],
                            selected: controller.balanceType.value,
                            onChanged: controller.setBalanceType,
                          ),
                          const SizedBox(height: 18),
                          const _Label('Enter amount'),
                          const SizedBox(height: 8),
                          _MoneyField(
                            controller: controller.openingAmountController,
                            hint: '0',
                          ),
                          const SizedBox(height: 18),
                          const _Label('As of Date'),
                          const SizedBox(height: 8),
                          _DateButton(
                            date: controller.openingDate.value,
                            onPressed: () =>
                                controller.pickOpeningDate(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: controller.saveWorker,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        elevation: 7,
                        shadowColor: _blue.withValues(alpha: 0.24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Obx(
                        () => Text(
                          controller.isEditingWorker
                              ? 'Update Worker'
                              : 'Save Worker',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkerDetailsPage extends StatelessWidget {
  const _WorkerDetailsPage({required this.worker});

  final _WorkerRecord worker;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<_WorkerTabController>();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111827),
          elevation: 0,
          leading: IconButton(
            tooltip: 'Back',
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_rounded, size: 28),
          ),
          titleSpacing: 0,
          title: Text(
            worker.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                controller.openEditForm(worker);
                Get.back();
              },
              icon: const Icon(Icons.edit_square, color: Color(0xFF2563EB)),
              label: const Text(
                'Edit',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0,
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'More',
              icon: const Icon(Icons.more_vert_rounded, size: 26),
              onSelected: (value) {
                if (value == 'remove') {
                  controller.removeWorker(worker);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFDC2626),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Remove Worker',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(52),
            child: _WorkerDetailsTabs(),
          ),
        ),
        body: TabBarView(
          children: [
            _WorkerOverviewTab(worker: worker),
            _WorkerAttendanceDetailsTab(worker: worker),
            _WorkerTransactionsTab(worker: worker),
            _SimpleWorkerTab(
              title: 'Tasks',
              rows: [
                _DetailRowData(
                  'Active Tasks',
                  worker.sites.isEmpty
                      ? 'No active tasks'
                      : '${worker.sites.length} active site task(s)',
                ),
                _DetailRowData(
                  'Current Work',
                  worker.sites.isEmpty
                      ? '${worker.role} assignment pending'
                      : '${worker.role} at ${worker.sites.first}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkerDetailsTabs extends StatelessWidget {
  const _WorkerDetailsTabs();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: TabBar(
        isScrollable: false,
        labelColor: const Color(0xFF2563EB),
        unselectedLabelColor: const Color(0xFF111827),
        indicatorColor: const Color(0xFF2563EB),
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: EdgeInsets.zero,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Attendance'),
          Tab(text: 'Transactions'),
          Tab(text: 'Tasks'),
        ],
      ),
    );
  }
}

class _WorkerOverviewTab extends StatelessWidget {
  const _WorkerOverviewTab({required this.worker});

  final _WorkerRecord worker;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 132),
      children: [
        _WorkerOverviewHero(worker: worker),
        const SizedBox(height: 14),
        _WorkerSummaryCard(worker: worker),
        const SizedBox(height: 14),
        _ProfilePanel(
          title: 'Personal Information',
          icon: Icons.badge_rounded,
          accentColor: const Color(0xFF2563EB),
          children: [
            _PlainInfoRow(
              label: 'Phone Number',
              value: worker.phoneNumber,
              icon: Icons.phone_rounded,
              trailing: IconButton(
                tooltip: 'Call worker',
                onPressed: () =>
                    Get.find<_WorkerTabController>().callWorker(worker),
                icon: const Icon(
                  Icons.call_outlined,
                  color: Color(0xFF2563EB),
                  size: 28,
                ),
              ),
            ),
            _PlainInfoRow(
              label: 'Role',
              value: worker.role,
              icon: Icons.engineering_rounded,
            ),
            _PlainInfoRow(
              label: 'Join Date',
              value: _formatNumericDate(worker.createdAt),
              icon: Icons.event_available_rounded,
              showDivider: false,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ExpandableDetailsCard(
          title: 'Assigned Sites',
          icon: Icons.apartment_rounded,
          count: worker.sites.length,
          initiallyExpanded: true,
          children: worker.sites.isEmpty
              ? const [_ArrowRow(title: 'No sites assigned', showArrow: false)]
              : worker.sites.map((site) => _ArrowRow(title: site)).toList(),
        ),
        const SizedBox(height: 14),
        _ExpandableDetailsCard(
          title: 'Active Tasks',
          icon: Icons.task_alt_rounded,
          initiallyExpanded: false,
          children: [
            _ArrowRow(
              title: worker.sites.isEmpty
                  ? '${worker.role} assignment pending'
                  : '${worker.role} at ${worker.sites.first}',
              showArrow: false,
            ),
          ],
        ),
      ],
    );
  }
}

class _WorkerSummaryCard extends StatelessWidget {
  const _WorkerSummaryCard({required this.worker});

  final _WorkerRecord worker;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<_WorkerTabController>();

    return Obx(() {
      final payable = controller.payableBalanceForWorker(worker);
      final days = controller.attendanceDaysForWorkerThisMonth(worker);
      final monthPay = controller.attendancePayForWorkerThisMonth(worker);

      return Row(
        children: [
          Expanded(
            child: _OverviewMetricCard(
              label: 'Payable',
              value: 'Rs ${_formatMoney(payable)}',
              icon: Icons.account_balance_wallet_rounded,
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _OverviewMetricCard(
              label: 'Attendance Pay',
              value: 'Rs ${_formatMoney(monthPay)}',
              icon: Icons.payments_rounded,
              color: const Color(0xFF059669),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _OverviewMetricCard(
              label: 'Paid Days',
              value: _formatAttendanceDays(days),
              icon: Icons.fact_check_rounded,
              color: const Color(0xFFD97706),
            ),
          ),
        ],
      );
    });
  }
}

class _WorkerOverviewHero extends StatelessWidget {
  const _WorkerOverviewHero({required this.worker});

  final _WorkerRecord worker;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Text(
              worker.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worker.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _OverviewBadge(
                      icon: Icons.engineering_rounded,
                      label: worker.role,
                    ),
                    _OverviewBadge(
                      icon: Icons.schedule_rounded,
                      label: worker.paymentType,
                    ),
                    _OverviewBadge(
                      icon: Icons.business_rounded,
                      label: worker.workerType,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewBadge extends StatelessWidget {
  const _OverviewBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFBFDBFE), size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
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

class _OverviewMetricCard extends StatelessWidget {
  const _OverviewMetricCard({
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
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              height: 1.15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkerAttendanceDetailsTab extends StatelessWidget {
  const _WorkerAttendanceDetailsTab({required this.worker});

  final _WorkerRecord worker;

  static const _blue = Color(0xFF2563EB);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFDC2626);
  static const _amber = Color(0xFFE58A00);
  static const _dark = Color(0xFF111827);
  static const _muted = Color(0xFF9CA3AF);
  static const _border = Color(0xFFD7D7D7);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<_WorkerTabController>();

    return Obx(() {
      final selectedDate = controller.selectedAttendanceDate.value;
      final status = controller.attendanceStatusFor(worker, selectedDate);
      final monthStats = controller.monthlyAttendanceStatsForWorker(worker);

      return Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 88),
            children: [
              _WorkerAttendanceStatsStrip(stats: monthStats),
              const SizedBox(height: 12),
              _WorkerAttendanceCalendarCard(
                worker: worker,
                selectedDate: selectedDate,
                onPreviousMonth: controller.showPreviousAttendanceMonth,
                onNextMonth: controller.showNextAttendanceMonth,
                onSelectDate: controller.setAttendanceDate,
              ),
              const SizedBox(height: 14),
              _SelectedAttendanceStatusCard(
                date: selectedDate,
                status: status,
                pay: controller.attendancePayForStatus(worker, status),
              ),
            ],
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 10,
            child: SafeArea(
              top: false,
              child: _UpdateTodayAttendanceButton(
                onPressed: () => _showTodayAttendanceSheet(context, worker),
              ),
            ),
          ),
        ],
      );
    });
  }

  void _showTodayAttendanceSheet(BuildContext context, _WorkerRecord worker) {
    final controller = Get.find<_WorkerTabController>();
    controller.showTodayAttendance();

    Get.bottomSheet(
      Obx(() {
        final today = controller.selectedAttendanceDate.value;
        final status = controller.attendanceStatusFor(worker, today);

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Update Today's Attendance",
                        style: TextStyle(
                          color: _dark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: Get.back,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _AttendanceWorkerCard(
                  worker: worker,
                  status: status,
                  pay: controller.attendancePayForStatus(worker, status),
                  onSelected: (value) async {
                    await controller.markAttendance(worker, value);
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        );
      }),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _WorkerAttendanceStatsStrip extends StatelessWidget {
  const _WorkerAttendanceStatsStrip({required this.stats});

  final _WorkerMonthlyAttendanceStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _WorkerAttendanceDetailsTab._border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _WorkerAttendanceStat(
              value: stats.present.toString(),
              label: 'Present',
              color: _WorkerAttendanceDetailsTab._dark,
            ),
          ),
          Expanded(
            child: _WorkerAttendanceStat(
              value: stats.halfDay.toString(),
              label: 'Half Day',
              color: _WorkerAttendanceDetailsTab._amber,
            ),
          ),
          Expanded(
            child: _WorkerAttendanceStat(
              value: stats.absent.toString(),
              label: 'Absent',
              color: _WorkerAttendanceDetailsTab._dark,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkerAttendanceStat extends StatelessWidget {
  const _WorkerAttendanceStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            height: 1,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _WorkerAttendanceDetailsTab._dark,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _WorkerAttendanceCalendarCard extends StatelessWidget {
  const _WorkerAttendanceCalendarCard({
    required this.worker,
    required this.selectedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
  });

  final _WorkerRecord worker;
  final DateTime selectedDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(selectedDate.year, selectedDate.month);
    final daysInMonth = DateUtils.getDaysInMonth(
      selectedDate.year,
      selectedDate.month,
    );
    final leadingEmptyDays = firstDay.weekday - DateTime.monday;
    final cells = leadingEmptyDays + daysInMonth;
    final rowCount = (cells / DateTime.daysPerWeek).ceil();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _WorkerAttendanceDetailsTab._border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _CalendarIconButton(
                icon: Icons.chevron_left_rounded,
                tooltip: 'Previous month',
                onPressed: onPreviousMonth,
              ),
              Expanded(
                child: Text(
                  _formatMonthYear(selectedDate),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _WorkerAttendanceDetailsTab._dark,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0,
                  ),
                ),
              ),
              _CalendarIconButton(
                icon: Icons.chevron_right_rounded,
                tooltip: 'Next month',
                onPressed: onNextMonth,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              _WeekdayLabel('Mon'),
              _WeekdayLabel('Tue'),
              _WeekdayLabel('Wed'),
              _WeekdayLabel('Thu'),
              _WeekdayLabel('Fri'),
              _WeekdayLabel('Sat'),
              _WeekdayLabel('Sun'),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: List.generate(rowCount, (rowIndex) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: rowIndex == rowCount - 1 ? 0 : 4,
                ),
                child: Row(
                  children: List.generate(DateTime.daysPerWeek, (weekdayIndex) {
                    final cellIndex =
                        (rowIndex * DateTime.daysPerWeek) + weekdayIndex;
                    final day = cellIndex - leadingEmptyDays + 1;
                    if (day < 1 || day > daysInMonth) {
                      return const Expanded(child: SizedBox(height: 42));
                    }

                    final date = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      day,
                    );

                    return Expanded(
                      child: _AttendanceCalendarDay(
                        worker: worker,
                        date: date,
                        selected: DateUtils.isSameDay(date, selectedDate),
                        onTap: () => onSelectDate(date),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE4E4E4)),
          const SizedBox(height: 10),
          const _AttendanceLegend(),
        ],
      ),
    );
  }
}

class _CalendarIconButton extends StatelessWidget {
  const _CalendarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints.tightFor(width: 42, height: 42),
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 30, color: _WorkerAttendanceDetailsTab._dark),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _WorkerAttendanceDetailsTab._dark,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _AttendanceCalendarDay extends StatelessWidget {
  const _AttendanceCalendarDay({
    required this.worker,
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final _WorkerRecord worker;
  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<_WorkerTabController>();
    final status = controller.attendanceStatusFor(worker, date);
    final statusColor = _statusColor(status);
    final today = DateTime.now();
    final isFuture = date.isAfter(DateTime(today.year, today.month, today.day));
    final textColor =
        statusColor ??
        (isFuture
            ? _WorkerAttendanceDetailsTab._muted
            : _WorkerAttendanceDetailsTab._dark);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(2),
        onTap: onTap,
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? _WorkerAttendanceDetailsTab._amber.withValues(alpha: 0.14)
                : Colors.transparent,
            border: selected
                ? Border.all(color: _WorkerAttendanceDetailsTab._blue, width: 3)
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                date.day.toString(),
                style: TextStyle(
                  color: selected
                      ? _WorkerAttendanceDetailsTab._amber
                      : textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0,
                ),
              ),
              if (statusColor != null)
                Positioned(
                  bottom: 3,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color? _statusColor(String status) {
    if (status == _WorkerTabController.attendancePresent) {
      return _WorkerAttendanceDetailsTab._green;
    }
    if (status == _WorkerTabController.attendanceAbsent) {
      return _WorkerAttendanceDetailsTab._red;
    }
    if (status == _WorkerTabController.attendanceHalfDay) {
      return _WorkerAttendanceDetailsTab._amber;
    }
    return null;
  }
}

class _AttendanceLegend extends StatelessWidget {
  const _AttendanceLegend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        _LegendItem('Present', _WorkerAttendanceDetailsTab._green),
        _LegendItem('Half Day', _WorkerAttendanceDetailsTab._amber),
        _LegendItem('Absent', _WorkerAttendanceDetailsTab._red),
        _OvertimeLegendItem(),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: _WorkerAttendanceDetailsTab._dark,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _OvertimeLegendItem extends StatelessWidget {
  const _OvertimeLegendItem();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 19,
          height: 15,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 1,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: const BoxDecoration(
                    color: _WorkerAttendanceDetailsTab._green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _WorkerAttendanceDetailsTab._blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 7),
        const Text(
          'OT',
          style: TextStyle(
            color: _WorkerAttendanceDetailsTab._dark,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _SelectedAttendanceStatusCard extends StatelessWidget {
  const _SelectedAttendanceStatusCard({
    required this.date,
    required this.status,
    required this.pay,
  });

  final DateTime date;
  final String status;
  final double pay;

  @override
  Widget build(BuildContext context) {
    final displayStatus = status.isEmpty ? 'Not marked' : status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _WorkerAttendanceDetailsTab._border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.fact_check_rounded,
            color: _WorkerAttendanceDetailsTab._blue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${_formatDate(date)} - $displayStatus',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _WorkerAttendanceDetailsTab._dark,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: 0,
              ),
            ),
          ),
          Text(
            'Rs ${_formatMoney(pay)}',
            style: const TextStyle(
              color: _WorkerAttendanceDetailsTab._dark,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateTodayAttendanceButton extends StatelessWidget {
  const _UpdateTodayAttendanceButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.how_to_reg_rounded, size: 22),
      label: const Text("Update Today's Attendance"),
      style: FilledButton.styleFrom(
        backgroundColor: _WorkerAttendanceDetailsTab._blue,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.24),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _WorkerTransactionsTab extends StatelessWidget {
  const _WorkerTransactionsTab({required this.worker});

  final _WorkerRecord worker;

  static const _blue = Color(0xFF2563EB);
  static const _dark = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _border = Color(0xFFE2E8F0);
  static const _surface = Color(0xFFFFFFFF);
  static const _softBg = Color(0xFFF8FAFC);
  static const _success = Color(0xFF059669);
  static const _danger = Color(0xFFDC2626);
  static const _warning = Color(0xFFD97706);
  static const _purple = Color(0xFF7C3AED);

  static List<BoxShadow> get _cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 10),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<_WorkerTabController>();

    return Obx(() {
      final summary = controller.ledgerSummaryForWorker(worker);
      final transactions = controller.filteredTransactionsForWorker(worker);

      return ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 132),
        children: [
          _GiveAdvanceButton(
            onPressed: () => _openGiveAdvanceSheet(context, worker),
          ),
          const SizedBox(height: 14),
          _TransactionHeroCard(summary: summary),
          const SizedBox(height: 14),
          _TransactionActionGrid(worker: worker),
          const SizedBox(height: 14),
          _TransactionSummaryPanel(summary: summary),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Transaction History',
                  style: TextStyle(
                    color: _dark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Text(
                summary.salaryStatus,
                style: const TextStyle(
                  color: _blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _TransactionFilterBar(),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            _NoAdvanceState(
              onPressed: () => _openGiveAdvanceSheet(context, worker),
            )
          else
            ...transactions.map(
              (transaction) => _AdvanceTransactionTile(transaction),
            ),
        ],
      );
    });
  }

  void _openGiveAdvanceSheet(BuildContext context, _WorkerRecord worker) {
    Get.bottomSheet(
      _GiveAdvanceSheet(worker: worker),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _TransactionActionGrid extends StatelessWidget {
  const _TransactionActionGrid({required this.worker});

  final _WorkerRecord worker;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CompactTransactionAction(
            label: 'Repay',
            icon: Icons.keyboard_return_rounded,
            onPressed: () => _openSheet(
              _LedgerTransactionSheet(
                worker: worker,
                type: _WorkerTabController.transactionAdvanceRepaid,
                title: 'Advance Repaid',
                amountLabel: 'Repayment Amount (Rs)',
                submitLabel: 'Save Repayment',
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CompactTransactionAction(
            label: 'Adjust',
            icon: Icons.sync_alt_rounded,
            onPressed: () => _openSheet(
              _LedgerTransactionSheet(
                worker: worker,
                type: _WorkerTabController.transactionAdvanceAdjusted,
                title: 'Adjust From Salary',
                amountLabel: 'Adjustment Amount (Rs)',
                submitLabel: 'Adjust Advance',
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CompactTransactionAction(
            label: 'Pay Salary',
            icon: Icons.account_balance_wallet_rounded,
            onPressed: () => _openSheet(
              _LedgerTransactionSheet(
                worker: worker,
                type: _WorkerTabController.transactionSalaryPaid,
                title: 'Pay Salary',
                amountLabel: 'Salary Amount (Rs)',
                submitLabel: 'Pay Salary',
                showPaymentFields: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openSheet(Widget sheet) {
    Get.bottomSheet(
      sheet,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _TransactionHeroCard extends StatelessWidget {
  const _TransactionHeroCard({required this.summary});

  final _WorkerLedgerSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), _WorkerTransactionsTab._blue],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _WorkerTransactionsTab._blue.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    summary.salaryStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Salary Due',
                  style: TextStyle(
                    color: Color(0xFFBFDBFE),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Rs ${_formatMoney(summary.salaryDue)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Advance Left',
                  style: TextStyle(
                    color: Color(0xFFBFDBFE),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Rs ${_formatMoney(summary.outstandingAdvance)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactTransactionAction extends StatelessWidget {
  const _CompactTransactionAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: _WorkerTransactionsTab._dark,
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFD9E2F1)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _GiveAdvanceButton extends StatelessWidget {
  const _GiveAdvanceButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: _WorkerTransactionsTab._blue,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _WorkerTransactionsTab._blue.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payments_rounded, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                'Give Advance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
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

class _TransactionSummaryPanel extends StatelessWidget {
  const _TransactionSummaryPanel({required this.summary});

  final _WorkerLedgerSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _WorkerTransactionsTab._surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _WorkerTransactionsTab._border),
        boxShadow: _WorkerTransactionsTab._cardShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 10) / 2;

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _TransactionSummaryMetric(
                width: itemWidth,
                label: 'Total Advance',
                value: 'Rs ${_formatMoney(summary.totalAdvance)}',
                color: _WorkerTransactionsTab._danger,
              ),
              _TransactionSummaryMetric(
                width: itemWidth,
                label: 'Repaid/Adjusted',
                value: 'Rs ${_formatMoney(summary.advanceRecovered)}',
                color: _WorkerTransactionsTab._warning,
              ),
              _TransactionSummaryMetric(
                width: itemWidth,
                label: 'Outstanding',
                value: 'Rs ${_formatMoney(summary.outstandingAdvance)}',
                color: _WorkerTransactionsTab._blue,
              ),
              _TransactionSummaryMetric(
                width: itemWidth,
                label: 'Salary Earned',
                value: 'Rs ${_formatMoney(summary.salaryEarned)}',
                color: _WorkerTransactionsTab._success,
              ),
              _TransactionSummaryMetric(
                width: itemWidth,
                label: 'Salary Paid',
                value: 'Rs ${_formatMoney(summary.salaryPaid)}',
                color: _WorkerTransactionsTab._purple,
              ),
              _TransactionSummaryMetric(
                width: itemWidth,
                label: 'Salary Due',
                value: 'Rs ${_formatMoney(summary.salaryDue)}',
                color: _WorkerTransactionsTab._dark,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TransactionSummaryMetric extends StatelessWidget {
  const _TransactionSummaryMetric({
    required this.width,
    required this.label,
    required this.value,
    required this.color,
  });

  final double width;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_metricIcon(label), color: color, size: 16),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _WorkerTransactionsTab._muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  IconData _metricIcon(String label) {
    if (label.contains('Advance')) {
      return Icons.payments_rounded;
    }
    if (label.contains('Repaid') || label.contains('Adjusted')) {
      return Icons.sync_alt_rounded;
    }
    if (label.contains('Outstanding')) {
      return Icons.warning_amber_rounded;
    }
    if (label.contains('Earned')) {
      return Icons.fact_check_rounded;
    }
    if (label.contains('Paid')) {
      return Icons.verified_rounded;
    }
    return Icons.account_balance_wallet_rounded;
  }
}

class _NoAdvanceState extends StatelessWidget {
  const _NoAdvanceState({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _WorkerTransactionsTab._border),
        boxShadow: _WorkerTransactionsTab._cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: _WorkerTransactionsTab._blue,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No transactions yet',
            style: TextStyle(
              color: _WorkerTransactionsTab._dark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use Give Advance, Repay, Adjust, or Pay Salary to build this worker ledger.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _WorkerTransactionsTab._muted,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Give Advance'),
          ),
        ],
      ),
    );
  }
}

class _AdvanceTransactionTile extends StatelessWidget {
  const _AdvanceTransactionTile(this.advance);

  final _WorkerAdvanceTransaction advance;

  @override
  Widget build(BuildContext context) {
    final type = _WorkerTabController.normalizeTransactionType(advance.type);
    final color = _transactionColor(type);
    final balanceLabel = type == _WorkerTabController.transactionSalaryPaid
        ? 'Salary due after'
        : 'Advance balance after';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _WorkerTransactionsTab._border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 4, color: color),
          const SizedBox(width: 10),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_transactionIcon(type), color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _WorkerTransactionsTab._dark,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      _formatDate(advance.createdAt),
                      if (advance.paymentMethod.isNotEmpty)
                        advance.paymentMethod,
                      if (advance.site.isNotEmpty) advance.site,
                      if (advance.note.isNotEmpty) advance.note,
                    ].join(' - '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _WorkerTransactionsTab._muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _WorkerTransactionsTab._softBg,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '$balanceLabel: Rs ${_formatMoney(advance.balanceAfter)}',
                          style: const TextStyle(
                            color: _WorkerTransactionsTab._muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (advance.proofPath.isNotEmpty)
                        InkWell(
                          onTap: () => _showReceipt(advance),
                          borderRadius: BorderRadius.circular(99),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _WorkerTransactionsTab._blue.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              'View receipt',
                              style: TextStyle(
                                color: _WorkerTransactionsTab._blue,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${_amountPrefix(type)}Rs ${_formatMoney(advance.amount)}',
                    maxLines: 1,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _amountPrefix(String type) {
    if (type == _WorkerTabController.transactionAdvanceGiven) {
      return '+ ';
    }
    return '- ';
  }

  IconData _transactionIcon(String type) {
    if (type == _WorkerTabController.transactionAdvanceGiven) {
      return Icons.call_made_rounded;
    }
    if (type == _WorkerTabController.transactionAdvanceRepaid) {
      return Icons.keyboard_return_rounded;
    }
    if (type == _WorkerTabController.transactionAdvanceAdjusted) {
      return Icons.sync_alt_rounded;
    }
    return Icons.account_balance_wallet_rounded;
  }

  Color _transactionColor(String type) {
    if (type == _WorkerTabController.transactionAdvanceGiven) {
      return const Color(0xFFDC2626);
    }
    if (type == _WorkerTabController.transactionAdvanceRepaid) {
      return const Color(0xFF059669);
    }
    if (type == _WorkerTabController.transactionAdvanceAdjusted) {
      return const Color(0xFFD97706);
    }
    return _WorkerTransactionsTab._blue;
  }

  void _showReceipt(_WorkerAdvanceTransaction transaction) {
    final proof = transaction.proofPath.trim();
    final isImageUrl =
        proof.startsWith('http://') || proof.startsWith('https://');

    Get.dialog(
      AlertDialog(
        title: const Text('Payment proof'),
        content: isImageUrl
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: Image.network(proof, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(proof),
                ],
              )
            : SelectableText(proof),
        actions: [TextButton(onPressed: Get.back, child: const Text('Close'))],
      ),
    );
  }
}

class _TransactionFilterBar extends GetView<_WorkerTabController> {
  const _TransactionFilterBar();

  static const _filters = [
    _WorkerTabController.transactionFilterAll,
    _WorkerTabController.transactionFilterAdvance,
    _WorkerTabController.transactionFilterRepayment,
    _WorkerTabController.transactionFilterSalaryAdjustment,
    _WorkerTabController.transactionFilterSalaryPayment,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(
        () => Row(
          children: _filters.map((filter) {
            final selected =
                controller.selectedTransactionFilter.value == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter),
                selected: selected,
                onSelected: (_) => controller.setTransactionFilter(filter),
                selectedColor: _WorkerTransactionsTab._blue,
                backgroundColor: Colors.white,
                side: const BorderSide(color: _WorkerTransactionsTab._border),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : _WorkerTransactionsTab._dark,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _GiveAdvanceSheet extends StatefulWidget {
  const _GiveAdvanceSheet({required this.worker});

  final _WorkerRecord worker;

  @override
  State<_GiveAdvanceSheet> createState() => _GiveAdvanceSheetState();
}

class _GiveAdvanceSheetState extends State<_GiveAdvanceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late String _selectedSite;

  static const _quickAmounts = [1000, 2000, 3000, 5000, 10000, 15000, 20000];

  @override
  void initState() {
    super.initState();
    _selectedSite = _siteOptions.first;
  }

  List<String> get _siteOptions =>
      widget.worker.sites.isEmpty ? const ['General'] : widget.worker.sites;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Give Advance',
                          style: TextStyle(
                            color: _WorkerTransactionsTab._dark,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: Get.back,
                        icon: const Icon(Icons.close_rounded, size: 32),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  const Text(
                    'To Worker',
                    style: TextStyle(
                      color: _WorkerTransactionsTab._dark,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.worker.fullName,
                    style: const TextStyle(
                      color: _WorkerTransactionsTab._dark,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _AdvanceFormLabel('Advance Amount (Rs)'),
                  const SizedBox(height: 10),
                  _AdvanceAmountField(controller: _amountController),
                  const SizedBox(height: 20),
                  const _AdvanceFormLabel('Quick Amount'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _quickAmounts.map((amount) {
                      return _QuickAmountChip(
                        amount: amount,
                        onPressed: () {
                          _amountController.text = amount.toString();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  const _AdvanceFormLabel('Site'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _siteOptions.map((site) {
                      final selected = site == _selectedSite;
                      return ChoiceChip(
                        label: Text(site),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _selectedSite = site);
                        },
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : _WorkerTransactionsTab._dark,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                        ),
                        selectedColor: _WorkerTransactionsTab._blue,
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: _WorkerTransactionsTab._border,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  const _AdvanceFormLabel('Note (Optional)'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _noteController,
                    minLines: 3,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      color: _WorkerTransactionsTab._dark,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Reason for advance...',
                      hintStyle: const TextStyle(
                        color: _WorkerTransactionsTab._muted,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: _WorkerTransactionsTab._border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: _WorkerTransactionsTab._blue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: _WorkerTransactionsTab._blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Give Advance'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final amount =
        double.tryParse(_amountController.text.trim().replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      return;
    }

    await Get.find<_WorkerTabController>().giveAdvance(
      worker: widget.worker,
      amount: amount,
      site: _selectedSite,
      note: _noteController.text,
    );
    Get.back();
  }
}

class _LedgerTransactionSheet extends StatefulWidget {
  const _LedgerTransactionSheet({
    required this.worker,
    required this.type,
    required this.title,
    required this.amountLabel,
    required this.submitLabel,
    this.showPaymentFields = false,
  });

  final _WorkerRecord worker;
  final String type;
  final String title;
  final String amountLabel;
  final String submitLabel;
  final bool showPaymentFields;

  @override
  State<_LedgerTransactionSheet> createState() =>
      _LedgerTransactionSheetState();
}

class _LedgerTransactionSheetState extends State<_LedgerTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _proofController = TextEditingController();
  var _paymentDate = DateTime.now();
  var _paymentMethod = 'Cash';

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _proofController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<_WorkerTabController>();
    final summary = controller.ledgerSummaryForWorker(widget.worker);

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: widget.showPaymentFields ? 0.82 : 0.68,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: _WorkerTransactionsTab._dark,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: Get.back,
                        icon: const Icon(Icons.close_rounded, size: 30),
                      ),
                    ],
                  ),
                  const Divider(height: 26),
                  _LedgerLimitPanel(summary: summary, type: widget.type),
                  const SizedBox(height: 18),
                  _AdvanceFormLabel(widget.amountLabel),
                  const SizedBox(height: 10),
                  _AdvanceAmountField(controller: _amountController),
                  const SizedBox(height: 18),
                  const _AdvanceFormLabel('Payment Date'),
                  const SizedBox(height: 10),
                  _LedgerDateButton(
                    date: _paymentDate,
                    onPressed: _pickPaymentDate,
                  ),
                  if (widget.showPaymentFields) ...[
                    const SizedBox(height: 18),
                    const _AdvanceFormLabel('Payment Method'),
                    const SizedBox(height: 10),
                    _PaymentMethodSelector(
                      selected: _paymentMethod,
                      onChanged: (value) {
                        setState(() => _paymentMethod = value);
                      },
                    ),
                    const SizedBox(height: 18),
                    const _AdvanceFormLabel('Proof / Receipt Image'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _proofController,
                      textInputAction: TextInputAction.next,
                      decoration: _ledgerInputDecoration(
                        'Receipt image path or reference (optional)',
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  const _AdvanceFormLabel('Note (Optional)'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _noteController,
                    minLines: 3,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _ledgerInputDecoration('Add note...'),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: _WorkerTransactionsTab._blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(54),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(widget.submitLabel),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _ledgerInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: _WorkerTransactionsTab._muted,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _WorkerTransactionsTab._border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _WorkerTransactionsTab._blue,
          width: 2,
        ),
      ),
    );
  }

  Future<void> _pickPaymentDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _paymentDate = date);
    }
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final amount =
        double.tryParse(_amountController.text.trim().replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      return;
    }

    final controller = Get.find<_WorkerTabController>();
    final summary = controller.ledgerSummaryForWorker(widget.worker);
    final limit = _limitFor(summary);
    if (limit <= 0 || amount > limit) {
      Get.snackbar(
        limit <= 0 ? 'Nothing available' : 'Amount too high',
        limit <= 0
            ? 'There is no available balance for this transaction.'
            : 'Maximum allowed is Rs ${_formatMoney(limit)}.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
      );
      return;
    }

    await controller.recordWorkerTransaction(
      worker: widget.worker,
      type: widget.type,
      amount: amount,
      site: '',
      paymentMethod: widget.showPaymentFields ? _paymentMethod : '',
      note: _noteController.text,
      proofPath: widget.showPaymentFields ? _proofController.text : '',
      paymentDate: _paymentDate,
    );
    Get.back();
  }

  double _limitFor(_WorkerLedgerSummary summary) {
    if (widget.type == _WorkerTabController.transactionAdvanceRepaid) {
      return summary.outstandingAdvance;
    }
    if (widget.type == _WorkerTabController.transactionAdvanceAdjusted) {
      return summary.outstandingAdvance < summary.salaryDue
          ? summary.outstandingAdvance
          : summary.salaryDue;
    }
    if (widget.type == _WorkerTabController.transactionSalaryPaid) {
      return summary.salaryDue;
    }
    return 0;
  }
}

class _LedgerLimitPanel extends StatelessWidget {
  const _LedgerLimitPanel({required this.summary, required this.type});

  final _WorkerLedgerSummary summary;
  final String type;

  @override
  Widget build(BuildContext context) {
    final label = type == _WorkerTabController.transactionSalaryPaid
        ? 'Salary due'
        : type == _WorkerTabController.transactionAdvanceAdjusted
        ? 'Adjustable amount'
        : 'Outstanding advance';
    final value = type == _WorkerTabController.transactionSalaryPaid
        ? summary.salaryDue
        : type == _WorkerTabController.transactionAdvanceAdjusted
        ? (summary.outstandingAdvance < summary.salaryDue
              ? summary.outstandingAdvance
              : summary.salaryDue)
        : summary.outstandingAdvance;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _WorkerTransactionsTab._border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _WorkerTransactionsTab._muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            'Rs ${_formatMoney(value)}',
            style: const TextStyle(
              color: _WorkerTransactionsTab._dark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerDateButton extends StatelessWidget {
  const _LedgerDateButton({required this.date, required this.onPressed});

  final DateTime date;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _WorkerTransactionsTab._border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: _WorkerTransactionsTab._blue,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              _formatDate(date),
              style: const TextStyle(
                color: _WorkerTransactionsTab._dark,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  const _PaymentMethodSelector({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['Cash', 'UPI', 'Bank'].map((method) {
        final isSelected = selected == method;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Center(child: Text(method)),
              selected: isSelected,
              onSelected: (_) => onChanged(method),
              selectedColor: _WorkerTransactionsTab._blue,
              backgroundColor: Colors.white,
              side: const BorderSide(color: _WorkerTransactionsTab._border),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : _WorkerTransactionsTab._dark,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AdvanceFormLabel extends StatelessWidget {
  const _AdvanceFormLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF374151),
        fontSize: 18,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        letterSpacing: 0,
      ),
    );
  }
}

class _AdvanceAmountField extends StatelessWidget {
  const _AdvanceAmountField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      textAlign: TextAlign.right,
      validator: (value) {
        final amount =
            double.tryParse((value ?? '').trim().replaceAll(',', '')) ?? 0;
        if (amount <= 0) {
          return 'Enter advance amount';
        }
        return null;
      },
      style: const TextStyle(
        color: _WorkerTransactionsTab._dark,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ),
      decoration: InputDecoration(
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 18, right: 8),
          child: Align(
            widthFactor: 1,
            alignment: Alignment.centerLeft,
            child: Text(
              'Rs',
              style: TextStyle(
                color: _WorkerTransactionsTab._blue,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        hintText: 'Enter amount',
        hintStyle: const TextStyle(
          color: _WorkerTransactionsTab._muted,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: _WorkerTransactionsTab._blue,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: _WorkerTransactionsTab._blue,
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
      ),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  const _QuickAmountChip({required this.amount, required this.onPressed});

  final int amount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _WorkerTransactionsTab._dark,
        side: const BorderSide(color: Color(0xFFD4D4D4), width: 1.4),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text('Rs ${_formatMoney(amount.toDouble())}'),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({
    required this.title,
    required this.children,
    this.icon,
    this.accentColor = const Color(0xFF2563EB),
  });

  final String title;
  final List<Widget> children;
  final IconData? icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 19),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ...children,
        ],
      ),
    );
  }
}

class _PlainInfoRow extends StatelessWidget {
  const _PlainInfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.trailing,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Widget? trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 19, color: const Color(0xFF2563EB)),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 18),
        ] else
          const SizedBox(height: 18),
      ],
    );
  }
}

class _ExpandableDetailsCard extends StatefulWidget {
  const _ExpandableDetailsCard({
    required this.title,
    required this.children,
    this.icon,
    this.count,
    this.initiallyExpanded = false,
  });

  final String title;
  final IconData? icon;
  final int? count;
  final bool initiallyExpanded;
  final List<Widget> children;

  @override
  State<_ExpandableDetailsCard> createState() => _ExpandableDetailsCardState();
}

class _ExpandableDetailsCardState extends State<_ExpandableDetailsCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: const Color(0xFF2563EB),
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                if (widget.count != null) ...[
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFDADDE3)),
                    ),
                    child: Text(
                      widget.count.toString(),
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 28,
                  color: const Color(0xFF111827),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(children: widget.children),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }
}

class _ArrowRow extends StatelessWidget {
  const _ArrowRow({required this.title, this.showArrow = true});

  final String title;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          if (showArrow)
            const Icon(
              Icons.chevron_right_rounded,
              size: 26,
              color: Color(0xFF475569),
            ),
        ],
      ),
    );
  }
}

class _DetailRowData {
  const _DetailRowData(this.label, this.value);

  final String label;
  final String value;
}

class _SimpleWorkerTab extends StatelessWidget {
  const _SimpleWorkerTab({required this.title, required this.rows});

  final String title;
  final List<_DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      children: [
        _ProfilePanel(
          title: title,
          children: rows
              .map(
                (row) => _PlainInfoRow(
                  label: row.label,
                  value: row.value,
                  showDivider: row != rows.last,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E4E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 13,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ExpandableFormCard extends StatelessWidget {
  const _ExpandableFormCard({
    required this.title,
    required this.isOpen,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final bool isOpen;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onToggle,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: _AddWorkerForm._dark,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isOpen ? 0 : 0.5,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(Icons.keyboard_arrow_up_rounded, size: 28),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: child,
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isOpen
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 190),
          ),
        ],
      ),
    );
  }
}

class _ContactImportButton extends StatelessWidget {
  const _ContactImportButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPressed,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(
              Icons.person_outline_rounded,
              color: _AddWorkerForm._blue,
              size: 28,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Import from contacts',
                style: TextStyle(
                  color: _AddWorkerForm._blue,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: _AddWorkerForm._blue,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.requiredMark = false});

  final String text;
  final bool requiredMark;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 14,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
        children: [
          if (requiredMark)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
        ],
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.textInputAction,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: const TextStyle(
        color: _AddWorkerForm._dark,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: _AddWorkerForm._muted,
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _AddWorkerForm._border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _AddWorkerForm._blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
      ),
    );
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField({
    required this.controller,
    required this.hint,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      textAlign: TextAlign.right,
      validator: validator,
      style: const TextStyle(
        color: _AddWorkerForm._dark,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ),
      decoration: InputDecoration(
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 18, right: 8),
          child: Align(
            widthFactor: 1,
            alignment: Alignment.centerLeft,
            child: Text(
              'Rs',
              style: TextStyle(
                color: _AddWorkerForm._muted,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        hintText: hint,
        hintStyle: const TextStyle(
          color: _AddWorkerForm._muted,
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _AddWorkerForm._border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _AddWorkerForm._blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
      ),
    );
  }
}

class _SegmentedChoice extends StatelessWidget {
  const _SegmentedChoice({
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  final List<String> values;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        border: Border.all(color: _AddWorkerForm._border),
        borderRadius: BorderRadius.circular(9),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: values.map((value) {
          final isSelected = value == selected;

          return Expanded(
            child: Material(
              color: isSelected
                  ? _AddWorkerForm._blue
                  : const Color(0xFFF3F4F7),
              child: InkWell(
                onTap: () => onChanged(value),
                child: Center(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.white : _AddWorkerForm._dark,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  const _RoleDropdown({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      hint: const Text('Select Role'),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _AddWorkerForm._border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _AddWorkerForm._blue),
        ),
      ),
      style: const TextStyle(
        color: _AddWorkerForm._dark,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
      ),
      items: const [
        DropdownMenuItem(value: 'Worker', child: Text('Worker')),
        DropdownMenuItem(value: 'Mason', child: Text('Mason')),
        DropdownMenuItem(value: 'Carpenter', child: Text('Carpenter')),
        DropdownMenuItem(value: 'Electrician', child: Text('Electrician')),
        DropdownMenuItem(value: 'Plumber', child: Text('Plumber')),
        DropdownMenuItem(value: 'Supervisor', child: Text('Supervisor')),
        DropdownMenuItem(value: 'Helper', child: Text('Helper')),
        DropdownMenuItem(value: 'Accountant', child: Text('Accountant')),
        DropdownMenuItem(value: 'Manager', child: Text('Manager')),
      ],
      onChanged: onChanged,
    );
  }
}

class _AddSiteButton extends StatelessWidget {
  const _AddSiteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded, size: 26),
      label: const Text('Add Site'),
      style: OutlinedButton.styleFrom(
        foregroundColor: _AddWorkerForm._dark,
        side: const BorderSide(color: _AddWorkerForm._border),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({required this.date, required this.onPressed});

  final DateTime date;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onPressed,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: _AddWorkerForm._border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: _AddWorkerForm._muted,
            ),
            const SizedBox(width: 12),
            Text(
              _formatDate(date),
              style: const TextStyle(
                color: _AddWorkerForm._dark,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkerEmptyIllustration extends StatelessWidget {
  const _WorkerEmptyIllustration();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 180,
      height: 184,
      child: CustomPaint(painter: _WorkerEmptyPainter()),
    );
  }
}

class _WorkerEmptyPainter extends CustomPainter {
  const _WorkerEmptyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 180;
    final sy = size.height / 184;
    canvas.save();
    canvas.scale(sx, sy);

    final shadow = Paint()
      ..color = const Color(0xFFE8F0FA)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(22, 166, 136, 10),
        const Radius.circular(99),
      ),
      shadow,
    );

    final boardShadow = Paint()
      ..color = const Color(0xFFD4E1F3)
      ..style = PaintingStyle.fill;
    final board = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = const Color(0xFFBFD2EC)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(48, 42, 108, 126),
        const Radius.circular(15),
      ),
      boardShadow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(40, 36, 108, 126),
        const Radius.circular(15),
      ),
      board,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(40, 36, 108, 126),
        const Radius.circular(15),
      ),
      border,
    );

    final blue = Paint()
      ..color = const Color(0xFF2E69BD)
      ..style = PaintingStyle.fill;
    final paleBlue = Paint()
      ..color = const Color(0xFFBFD2EC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final light = Paint()
      ..color = const Color(0xFFE7EEF8)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(66, 62, 72, 7),
        const Radius.circular(99),
      ),
      blue,
    );
    canvas.drawRect(const Rect.fromLTWH(40, 84, 108, 2), light);

    for (var i = 0; i < 3; i++) {
      final y = 106.0 + (i * 26);
      canvas.drawCircle(Offset(62, y), 9, paleBlue);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(84, y - 7, i == 2 ? 38 : 48, 4),
          const Radius.circular(99),
        ),
        light,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(84, y + 4, i == 2 ? 26 : 42, 4),
          const Radius.circular(99),
        ),
        light,
      );
      canvas.drawCircle(Offset(136, y - 3), 7, light);
    }

    final helmet = Paint()
      ..color = const Color(0xFF1F63BF)
      ..style = PaintingStyle.fill;
    final helmetDark = Paint()
      ..color = const Color(0xFF1557AF)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      const Rect.fromLTWH(72, 6, 36, 30),
      3.14,
      3.14,
      true,
      helmet,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(68, 27, 48, 11),
        const Radius.circular(3),
      ),
      helmet,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(78, 40, 42, 12),
        const Radius.circular(99),
      ),
      helmetDark,
    );

    final gear = Paint()
      ..color = const Color(0xFF1F63BF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(const Offset(121, 9), 5, gear);
    canvas.drawCircle(const Offset(125, 25), 4, gear);

    canvas.save();
    canvas.translate(128, 154);
    canvas.rotate(-0.23);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 58, 11),
        const Radius.circular(99),
      ),
      helmetDark,
    );
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _formatDate(DateTime date) {
  const months = [
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
    'Dec',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatMonthYear(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${months[date.month - 1]} ${date.year}';
}

String _formatNumericDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}

String _dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _formatAttendanceDays(double days) {
  if (days == 0) {
    return '-';
  }
  if (days == days.roundToDouble()) {
    return days.toStringAsFixed(0);
  }
  return days.toStringAsFixed(1);
}

String _formatMoney(double amount) {
  if (amount == amount.roundToDouble()) {
    return amount.toStringAsFixed(0);
  }
  return amount.toStringAsFixed(2);
}
