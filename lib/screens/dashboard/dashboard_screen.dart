import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/staff_provider.dart';
import '../../providers/accounting_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    final accountingProvider = Provider.of<AccountingProvider>(context, listen: false);

    await Future.wait([
      studentProvider.loadStudents(),
      staffProvider.loadStaff(),
      accountingProvider.loadTransactions(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) => PopupMenuButton<String>(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      authProvider.currentUserName[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(authProvider.currentUserName),
                  const Icon(Icons.arrow_drop_down),
                  const SizedBox(width: 8),
                ],
              ),
              onSelected: (value) async {
                switch (value) {
                  case 'profile':
                    // TODO: Navigate to profile screen
                    break;
                  case 'settings':
                    context.go('/settings');
                    break;
                  case 'logout':
                    await authProvider.logout();
                    if (mounted) context.go('/login');
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(),
                const SizedBox(height: 24),

                // Stats Cards
                _buildStatsCards(isDesktop),
                const SizedBox(height: 24),

                // Charts Section
                if (isDesktop) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildFinancialChart()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStudentGenderChart()),
                    ],
                  ),
                ] else ...[
                  _buildFinancialChart(),
                  const SizedBox(height: 16),
                  _buildStudentGenderChart(),
                ],
                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActions(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(
                Icons.waving_hand,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${authProvider.currentUserName}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Here\'s what\'s happening at your madrasah today',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isDesktop) {
    return Consumer3<StudentProvider, StaffProvider, AccountingProvider>(
      builder: (context, studentProvider, staffProvider, accountingProvider, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = isDesktop ? 4 : 2;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _StatCard(
                  icon: Icons.school,
                  title: 'Total Students',
                  value: '${studentProvider.students.length}',
                  color: Colors.blue,
                  onTap: () => context.go('/students'),
                ),
                _StatCard(
                  icon: Icons.people,
                  title: 'Total Staff',
                  value: '${staffProvider.staff.length}',
                  color: Colors.green,
                  onTap: () => context.go('/staff'),
                ),
                _StatCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Monthly Income',
                  value: '\$${accountingProvider.totalIncome.toStringAsFixed(0)}',
                  color: Colors.orange,
                  onTap: () => context.go('/accounting'),
                ),
                _StatCard(
                  icon: Icons.trending_up,
                  title: 'Net Profit',
                  value: '\$${accountingProvider.netProfit.toStringAsFixed(0)}',
                  color: accountingProvider.netProfit >= 0 ? Colors.green : Colors.red,
                  onTap: () => context.go('/accounting'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFinancialChart() {
    return Consumer<AccountingProvider>(
      builder: (context, accountingProvider, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Financial Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (accountingProvider.totalIncome > accountingProvider.totalExpenses 
                        ? accountingProvider.totalIncome 
                        : accountingProvider.totalExpenses) * 1.2,
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: accountingProvider.totalIncome,
                            color: Colors.green,
                            width: 20,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: accountingProvider.totalExpenses,
                            color: Colors.red,
                            width: 20,
                          ),
                        ],
                      ),
                    ],
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text('Income');
                              case 1:
                                return const Text('Expenses');
                              default:
                                return const Text('');
                            }
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentGenderChart() {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, _) {
        final maleCount = studentProvider.students.where((s) => s.gender == 'Male').length;
        final femaleCount = studentProvider.students.where((s) => s.gender == 'Female').length;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Demographics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: maleCount.toDouble(),
                          title: 'Male\n$maleCount',
                          color: Colors.blue,
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: femaleCount.toDouble(),
                          title: 'Female\n$femaleCount',
                          color: Colors.pink,
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickActionButton(
                  icon: Icons.person_add,
                  label: 'Add Student',
                  onTap: () => context.go('/students/add'),
                ),
                _QuickActionButton(
                  icon: Icons.group_add,
                  label: 'Add Staff',
                  onTap: () => context.go('/staff/add'),
                ),
                _QuickActionButton(
                  icon: Icons.payment,
                  label: 'Record Payment',
                  onTap: () => context.go('/accounting'),
                ),
                _QuickActionButton(
                  icon: Icons.sync_alt,
                  label: 'Data Sync',
                  onTap: () => context.go('/data-sync'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.school,
                    size: 40,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Madrasah Management',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    authProvider.currentUserName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            _DrawerItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              onTap: () => context.go('/dashboard'),
            ),
            _DrawerItem(
              icon: Icons.school,
              title: 'Students',
              onTap: () => context.go('/students'),
            ),
            _DrawerItem(
              icon: Icons.people,
              title: 'Staff',
              onTap: () => context.go('/staff'),
            ),
            _DrawerItem(
              icon: Icons.payment,
              title: 'Salary Management',
              onTap: () => context.go('/salary'),
            ),
            _DrawerItem(
              icon: Icons.account_balance_wallet,
              title: 'Accounting',
              onTap: () => context.go('/accounting'),
            ),
            const Divider(),
            _DrawerItem(
              icon: Icons.sync_alt,
              title: 'Data Sync',
              onTap: () => context.go('/data-sync'),
            ),
            _DrawerItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () => context.go('/settings'),
            ),
            _DrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () async {
                await authProvider.logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Scaffold.of(context).closeDrawer();
        onTap();
      },
    );
  }
}
