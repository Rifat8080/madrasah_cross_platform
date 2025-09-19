import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_sync_service.dart';
import '../../providers/student_provider.dart';
import '../../providers/staff_provider.dart';
import '../../providers/salary_provider.dart';
import '../../providers/accounting_provider.dart';

class DataSyncScreen extends StatefulWidget {
  const DataSyncScreen({super.key});

  @override
  State<DataSyncScreen> createState() => _DataSyncScreenState();
}

class _DataSyncScreenState extends State<DataSyncScreen> {
  final DataSyncService _syncService = DataSyncService.instance;
  bool _isExporting = false;
  bool _isImporting = false;
  String? _lastExportPath;
  Map<String, dynamic>? _lastBackupInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Synchronization'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.sync_alt,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data Synchronization',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Export and import data between devices to keep your madrasah management system synchronized.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Export Section
            _buildExportSection(),
            const SizedBox(height: 24),

            // Import Section
            _buildImportSection(),
            const SizedBox(height: 24),

            // Backup Info Section
            if (_lastBackupInfo != null) _buildBackupInfoSection(),
            const SizedBox(height: 24),

            // Instructions
            _buildInstructionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.upload,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Export Data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Create a backup file containing all your madrasah data. This file can be imported on another device to synchronize data.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            
            // Export buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: _isExporting ? null : _exportAllData,
                  icon: _isExporting 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.backup),
                  label: const Text('Export All Data'),
                ),
                OutlinedButton.icon(
                  onPressed: _isExporting ? null : _exportStudentsOnly,
                  icon: const Icon(Icons.school),
                  label: const Text('Students Only'),
                ),
                OutlinedButton.icon(
                  onPressed: _isExporting ? null : _exportStaffOnly,
                  icon: const Icon(Icons.people),
                  label: const Text('Staff Only'),
                ),
                OutlinedButton.icon(
                  onPressed: _isExporting ? null : _exportAccountingOnly,
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('Accounting Only'),
                ),
              ],
            ),
            
            if (_lastExportPath != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Last export: $_lastExportPath',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.download,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Import Data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Import a backup file to update your local data. This will merge data from another device.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            
            FilledButton.icon(
              onPressed: _isImporting ? null : _importData,
              icon: _isImporting 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.restore),
              label: const Text('Select & Import Backup File'),
            ),
            
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Warning: Importing data will merge with existing records. Duplicate records will be updated based on timestamps.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Backup Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow('Version', _lastBackupInfo!['version'] ?? 'Unknown'),
            _InfoRow('Exported By', _lastBackupInfo!['exported_by'] ?? 'Unknown'),
            _InfoRow('Export Date', _formatDateTime(_lastBackupInfo!['exported_at'])),
            _InfoRow('Platform', _lastBackupInfo!['platform'] ?? 'Unknown'),
            _InfoRow('Total Records', '${_lastBackupInfo!['total_records'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to Synchronize Data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _InstructionStep(
              step: '1',
              title: 'Export from Source Device',
              description: 'Use "Export All Data" to create a backup file on the device with your latest data.',
            ),
            _InstructionStep(
              step: '2',
              title: 'Transfer the File',
              description: 'Copy the exported JSON file to your target device using USB, email, cloud storage, etc.',
            ),
            _InstructionStep(
              step: '3',
              title: 'Import on Target Device',
              description: 'Use "Select & Import Backup File" to merge the data into your target device.',
            ),
            _InstructionStep(
              step: '4',
              title: 'Verify Data',
              description: 'Check that all your students, staff, and financial records have been synchronized correctly.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _InfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _InstructionStep({
    required String step,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAllData() async {
    setState(() => _isExporting = true);
    
    try {
      final exportPath = await _syncService.exportData();
      
      if (exportPath != null) {
        setState(() => _lastExportPath = exportPath);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Data exported successfully to: $exportPath'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to export data'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() => _isExporting = false);
  }

  Future<void> _exportStudentsOnly() async {
    setState(() => _isExporting = true);
    
    try {
      final exportPath = await _syncService.exportTableData('students');
      
      if (exportPath != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Students data exported to: $exportPath'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting students: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() => _isExporting = false);
  }

  Future<void> _exportStaffOnly() async {
    setState(() => _isExporting = true);
    
    try {
      final exportPath = await _syncService.exportTableData('staff');
      
      if (exportPath != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Staff data exported to: $exportPath'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting staff: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() => _isExporting = false);
  }

  Future<void> _exportAccountingOnly() async {
    setState(() => _isExporting = true);
    
    try {
      final exportPath = await _syncService.exportTableData('accounting_transactions');
      
      if (exportPath != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Accounting data exported to: $exportPath'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting accounting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() => _isExporting = false);
  }

  Future<void> _importData() async {
    setState(() => _isImporting = true);
    
    try {
      final success = await _syncService.importData(null);
      
      if (success) {
        // Refresh all providers
        if (mounted) {
          await _refreshAllProviders();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data imported successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to import data or operation cancelled'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() => _isImporting = false);
  }

  Future<void> _refreshAllProviders() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    final salaryProvider = Provider.of<SalaryProvider>(context, listen: false);
    final accountingProvider = Provider.of<AccountingProvider>(context, listen: false);

    await Future.wait([
      studentProvider.loadStudents(),
      staffProvider.loadStaff(),
      salaryProvider.loadSalaryPayments(),
      accountingProvider.loadTransactions(),
    ]);
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'Unknown';
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }
}
