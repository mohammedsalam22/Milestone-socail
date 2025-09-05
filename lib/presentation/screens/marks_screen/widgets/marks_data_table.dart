import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/model/mark_model.dart';
import '../../../../data/model/exam_type.dart';

class MarksDataTable extends StatefulWidget {
  final List<MarkModel> marks;
  final String studentName;

  const MarksDataTable({
    super.key,
    required this.marks,
    required this.studentName,
  });

  @override
  State<MarksDataTable> createState() => _MarksDataTableState();
}

class _MarksDataTableState extends State<MarksDataTable> {
  List<MarkModel> _filteredMarks = [];
  ExamType? _selectedExamType;
  String _searchQuery = '';
  bool _sortAscending = true;
  int _sortColumnIndex = 0; // Default sort by date

  @override
  void initState() {
    super.initState();
    _filteredMarks = List.from(widget.marks);
    _sortMarks();
  }

  @override
  void didUpdateWidget(MarksDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.marks != widget.marks) {
      _filteredMarks = List.from(widget.marks);
      _applyFilters();
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredMarks = widget.marks.where((mark) {
        // Filter by exam type
        if (_selectedExamType != null && mark.examType != _selectedExamType) {
          return false;
        }

        // Filter by search query (subject name)
        if (_searchQuery.isNotEmpty) {
          if (!mark.subjectName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          )) {
            return false;
          }
        }

        return true;
      }).toList();

      _sortMarks();
    });
  }

  void _sortMarks() {
    _filteredMarks.sort((a, b) {
      int comparison = 0;
      switch (_sortColumnIndex) {
        case 0: // Date
          comparison = a.date.compareTo(b.date);
          break;
        case 1: // Subject
          comparison = a.subjectName.compareTo(b.subjectName);
          break;
        case 2: // Exam Type
          comparison = a.examType.displayName.compareTo(b.examType.displayName);
          break;
        case 3: // Mark
          comparison = a.mark.compareTo(b.mark);
          break;
        case 4: // Grade
          comparison = a.grade.compareTo(b.grade);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
  }

  void _onSort(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
      _sortMarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Filter and Search Controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by subject name...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _applyFilters();
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _applyFilters();
                  });
                },
              ),
              const SizedBox(height: 16),
              // Exam Type Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', null),
                    const SizedBox(width: 8),
                    ...ExamType.values.map(
                      (type) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(type.displayName, type),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Data Table
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      theme.colorScheme.primary.withOpacity(0.1),
                    ),
                    columns: [
                      _buildDataColumn('Date', 0, Icons.calendar_today),
                      _buildDataColumn('Subject', 1, Icons.book),
                      _buildDataColumn('Exam Type', 2, Icons.quiz),
                      _buildDataColumn('Mark', 3, Icons.grade),
                      _buildDataColumn('Grade', 4, Icons.star),
                      _buildDataColumn('Status', 5, Icons.check_circle),
                    ],
                    rows: _filteredMarks.map((mark) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              DateFormat('MMM dd, yyyy').format(mark.date),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          DataCell(
                            Text(
                              mark.subjectName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getExamTypeColor(
                                  mark.examType,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getExamTypeColor(
                                    mark.examType,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                mark.examType.displayName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _getExamTypeColor(mark.examType),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${mark.mark}/${mark.topMark}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${mark.percentage.toStringAsFixed(1)}%)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: mark.gradeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: mark.gradeColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                mark.grade,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: mark.gradeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  mark.isPassed
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: mark.isPassed
                                      ? Colors.green
                                      : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  mark.isPassed ? 'Passed' : 'Failed',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: mark.isPassed
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Summary Statistics
        if (_filteredMarks.isNotEmpty) _buildSummaryStats(theme),
      ],
    );
  }

  DataColumn _buildDataColumn(String label, int columnIndex, IconData icon) {
    final theme = Theme.of(context);
    final isSorted = _sortColumnIndex == columnIndex;

    return DataColumn(
      label: InkWell(
        onTap: () => _onSort(columnIndex),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            if (isSorted)
              Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, ExamType? examType) {
    final isSelected = _selectedExamType == examType;
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedExamType = selected ? examType : null;
          _applyFilters();
        });
      },
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildSummaryStats(ThemeData theme) {
    final totalMarks = _filteredMarks.length;
    final passedMarks = _filteredMarks.where((m) => m.isPassed).length;
    final averagePercentage =
        _filteredMarks.map((m) => m.percentage).reduce((a, b) => a + b) /
        totalMarks;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Marks',
              totalMarks.toString(),
              Icons.assignment,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Passed',
              passedMarks.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Average',
              '${averagePercentage.toStringAsFixed(1)}%',
              Icons.trending_up,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getExamTypeColor(ExamType examType) {
    switch (examType) {
      case ExamType.exam1:
        return Colors.blue;
      case ExamType.exam2:
        return Colors.green;
      case ExamType.exam3:
        return Colors.orange;
      case ExamType.exam4:
        return Colors.purple;
      case ExamType.oralTest:
        return Colors.teal;
      case ExamType.writtenTest:
        return Colors.indigo;
    }
  }
}
