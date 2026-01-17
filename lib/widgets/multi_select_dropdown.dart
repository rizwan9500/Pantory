import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

/// Multi-select searchable dropdown widget for selecting multiple items
class MultiSelectDropdown extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> items;
  final List<String> selectedValues;
  final Function(List<String>) onChanged;
  final IconData icon;
  final Color? highlightColor; // For allergens (red)
  final List<String>? popularItems;
  
  const MultiSelectDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.selectedValues,
    required this.onChanged,
    this.icon = Icons.checklist,
    this.highlightColor,
    this.popularItems,
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];
  List<String> _tempSelectedValues = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _tempSelectedValues = List.from(widget.selectedValues);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(lowerQuery))
            .toList();
      }
    });
  }

  void _toggleItem(String item) {
    setState(() {
      if (_tempSelectedValues.contains(item)) {
        _tempSelectedValues.remove(item);
      } else {
        _tempSelectedValues.add(item);
      }
    });
  }

  void _showDropdown() {
    _searchController.clear();
    _filteredItems = widget.items;
    _tempSelectedValues = List.from(widget.selectedValues);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => GlassContainer(
            blur: 20,
            opacity: 0.3,
            borderRadius: 24,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(widget.icon, color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_tempSelectedValues.isNotEmpty)
                                  Text(
                                    '${_tempSelectedValues.length} selected',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search box
                      TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      _searchController.clear();
                                      _filterItems('');
                                    });
                                  },
                                  child: const Icon(Icons.clear, color: Colors.white70),
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          setModalState(() => _filterItems(value));
                        },
                      ),
                      if (_searchController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${_filteredItems.length} results found',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Popular items (if provided and no search)
                if (widget.popularItems != null && _searchController.text.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Common Choices',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.popularItems!.map((item) {
                            final isSelected = _tempSelectedValues.contains(item);
                            return GestureDetector(
                              onTap: () {
                                setModalState(() => _toggleItem(item));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (widget.highlightColor?.withOpacity(0.4) ?? Colors.white.withOpacity(0.3))
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? (widget.highlightColor ?? Colors.white)
                                        : Colors.white.withOpacity(0.3),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected)
                                      const Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    Text(
                                      item,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white30),
                        const SizedBox(height: 8),
                        Text(
                          'All Options',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // List
                Expanded(
                  child: _filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.search_off,
                                color: Colors.white54,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No results found',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final isSelected = _tempSelectedValues.contains(item);
                            
                            return GestureDetector(
                              onTap: () {
                                setModalState(() => _toggleItem(item));
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (widget.highlightColor?.withOpacity(0.4) ?? Colors.white.withOpacity(0.3))
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? (widget.highlightColor ?? Colors.white)
                                        : Colors.white30,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                
                // Action buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_tempSelectedValues.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setModalState(() => _tempSelectedValues.clear());
                          },
                          child: const Text(
                            'Clear All',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          widget.onChanged(_tempSelectedValues);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          foregroundColor: Colors.purple.shade900,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Done (${_tempSelectedValues.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showDropdown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30),
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.selectedValues.isEmpty
                        ? widget.hint
                        : '${widget.selectedValues.length} selected',
                    style: TextStyle(
                      color: widget.selectedValues.isNotEmpty
                          ? Colors.white
                          : Colors.white54,
                      fontSize: 15,
                      fontWeight: widget.selectedValues.isNotEmpty
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
