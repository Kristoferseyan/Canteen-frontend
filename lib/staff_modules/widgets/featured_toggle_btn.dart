

import 'package:final_canteen/model/menu_item_model.dart';
import 'package:final_canteen/services/item_services.dart';
import 'package:final_canteen/utils/colors.dart';
import 'package:flutter/material.dart';

class FeaturedToggleButton extends StatefulWidget {
  final ItemByCategory item;
  final Function(bool) onToggle;

  const FeaturedToggleButton({
    Key? key,
    required this.item,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<FeaturedToggleButton> createState() => _FeaturedToggleButtonState();
}

class _FeaturedToggleButtonState extends State<FeaturedToggleButton> {
  bool _isLoading = false;
  int _selectedDurationHours = 24; 

  @override
  Widget build(BuildContext context) {
    return _buildToggleButton();
  }

  Widget _buildToggleButton() {
    final isFeatured = widget.item.isFeatured;
    
    return _isLoading
        ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          )
        : IconButton(
            icon: Icon(
              isFeatured ? Icons.star : Icons.star_border,
              color: isFeatured ? Colors.amber : Colors.grey[600],
            ),
            onPressed: () => isFeatured 
                ? _showRemoveConfirmationDialog() 
                : _showFeaturedDialog(),
            tooltip: isFeatured ? "Remove from featured" : "Add to featured",
          );
  }

  Future<void> _showRemoveConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 10),
              Text('Remove Featured Status'),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to remove "${widget.item.itemName}" from featured items?'),
                SizedBox(height: 12),
                if (widget.item.featuredEndTime != null)
                  Text(
                    'Current featured period ends: ${_formatDateTime(widget.item.featuredEndTime!)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
              ),
              child: Text('Remove', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _removeFeaturedStatus();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFeaturedDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  SizedBox(width: 10),
                  Text('Feature This Item'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How long should "${widget.item.itemName}" be featured?'),
                    SizedBox(height: 24),
                    
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() {
                              if (_selectedDurationHours > 1) {
                                _selectedDurationHours--;
                              }
                            });
                          },
                        ),
                        Text(
                          "$_selectedDurationHours hours",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() {
                              if (_selectedDurationHours < 168) { 
                                _selectedDurationHours++;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPresetButton("1 hour", 1, setState),
                        _buildPresetButton("4 hours", 4, setState),
                        _buildPresetButton("12 hours", 12, setState),
                        _buildPresetButton("1 day", 24, setState),
                        _buildPresetButton("2 days", 48, setState),
                        _buildPresetButton("1 week", 168, setState),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withOpacity(0.5))
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Feature Preview:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[800],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'From: ${_formatDateTime(DateTime.now())}',
                            style: TextStyle(fontSize: 13),
                          ),
                          Text(
                            'Until: ${_formatDateTime(DateTime.now().add(Duration(hours: _selectedDurationHours)))}',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text('Feature Item', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _confirmFeature();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Widget _buildPresetButton(String label, int hours, StateSetter setState) {
    final isSelected = _selectedDurationHours == hours;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedDurationHours = hours;
          });
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.grey[800],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Future<void> _removeFeaturedStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ItemService itemService = ItemService();
      final success = await itemService.removeFeaturedStatus(widget.item.id);
      
      if (success && mounted) {
        widget.onToggle(false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Item removed from featured"),
            backgroundColor: AppColors.primary,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to remove featured status"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmFeature() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ItemService itemService = ItemService();
      final now = DateTime.now();
      final endTime = now.add(Duration(hours: _selectedDurationHours));
      
      final success = await itemService.setItemAsFeatured(
        widget.item.id,
        now,
        endTime
      );
      
      if (success && mounted) {
        widget.onToggle(true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Item featured for $_selectedDurationHours hours"),
            backgroundColor: AppColors.primary,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to feature item"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)} ${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}';
  }
  
  
  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}