import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GiftDetailsPage extends StatefulWidget {
  final String giftName;
  final String initialStatus;

  const GiftDetailsPage({Key? key, required this.giftName, required this.initialStatus}) : super(key: key);

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
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
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
        title: Text('Gift Details'),
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
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Upload Image'),
                ),
                if (_image != null) ...[
                  const SizedBox(width: 10),
                  Text('Image selected'),
                ],
              ],
            ),
            SizedBox(height: 16),
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
