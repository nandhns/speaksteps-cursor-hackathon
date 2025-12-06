import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class PatientListSidebar extends StatelessWidget {
  final List<UserModel> patients;
  final UserModel? selectedPatient;
  final String searchQuery;
  final bool sortAscending;
  final Function(String) onSearchChanged;
  final Function(bool) onSortChanged;
  final Function(UserModel) onPatientSelected;

  const PatientListSidebar({
    super.key,
    required this.patients,
    required this.selectedPatient,
    required this.searchQuery,
    required this.sortAscending,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onPatientSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.people,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Patients',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          // Search and Sort
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search patient...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: onSearchChanged,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Sort: '),
                    const Spacer(),
                    ToggleButtons(
                      isSelected: [sortAscending, !sortAscending],
                      onPressed: (index) {
                        onSortChanged(index == 0);
                      },
                      borderRadius: BorderRadius.circular(4),
                      constraints: const BoxConstraints(
                        minHeight: 32,
                        minWidth: 60,
                      ),
                      children: const [
                        Text('A-Z'),
                        Text('Z-A'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Patient list
          Expanded(
            child: patients.isEmpty
                ? Center(
                    child: Text(
                      'No patients found',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      final isSelected = selectedPatient?.id == patient.id;
                      return InkWell(
                        onTap: () => onPatientSelected(patient),
                        child: Container(
                          color: isSelected
                              ? Colors.blue.shade50
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: isSelected
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade400,
                                child: Text(
                                  patient.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      patient.name,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.blue.shade700
                                            : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      patient.email,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
    );
  }
}

