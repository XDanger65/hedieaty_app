import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GiftDetailsPage extends StatefulWidget {
  final String giftName;
  final String initialStatus;

  const GiftDetailsPage({super.key, required this.giftName, required this.initialStatus});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String status = '';
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.giftName;
    status = widget.initialStatus;
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  void _toggleStatus() {
    setState(() {
      status = (status == 'Available') ? 'Pledged' : 'Available';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Gift Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Upload Image'),
                ),
                if (_image != null) ...[
                  const SizedBox(width: 10),
                  const Text('Image selected'),
                ],
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _toggleStatus,
              child: Text('Status: $status'),
            ),
          ],
        ),
      ),
    );
  }
}
