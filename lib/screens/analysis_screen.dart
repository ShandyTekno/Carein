import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import 'processing_screen.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _bytes;

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => _bytes = bytes);
    } catch (_) {
      if (!mounted) return;
      final name = source == ImageSource.camera ? 'camera' : 'gallery';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open the $name on this device.')),
      );
    }
  }

  void _clearPhoto() {
    setState(() => _bytes = null);
  }

  void _start() {
    // Prototype flow: transition to processing screen
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProcessingScreen(imageBytes: _bytes)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewHeight = MediaQuery.of(context).size.height * 0.36;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analyze Your Skin',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Take a clear photo of your face for AI analysis',
              style: TextStyle(fontSize: 14, color: AppColors.grey),
            ),
            const SizedBox(height: 20),
            _buildPreview(previewHeight),
            const SizedBox(height: 16),
            if (_bytes == null) ...[
              AppButton(
                label: 'Take Photo',
                icon: Icons.photo_camera_outlined,
                outlined: true,
                onPressed: () => _pick(ImageSource.camera),
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Choose from Gallery',
                icon: Icons.photo_library_outlined,
                outlined: true,
                onPressed: () => _pick(ImageSource.gallery),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      label: const Text('Retake'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: _clearPhoto,
                    tooltip: 'Remove photo',
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.card(),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'For the best result',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 12),
                  _Tip('Use natural, bright lighting'),
                  _Tip('Face directly toward the camera'),
                  _Tip('Avoid makeup, filters, or glasses'),
                  _Tip('Keep entire facial area visible'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Start AI Analysis',
              icon: Icons.auto_awesome,
              onPressed: _start,
            ),
            if (_bytes == null) ...[
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'No photo selected. Sample face analysis will be demonstrated.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(double height) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.softBlue, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: _bytes != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(_bytes!, fit: BoxFit.cover),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                        SizedBox(width: 6),
                        Text(
                          'Photo Ready',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                // Oval face guide outline
                Container(
                  width: 140,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(90),
                    border: Border.all(
                      color: AppColors.blue.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        size: 30,
                        color: AppColors.blue,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Position face in frame',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Take a photo or choose from gallery',
                      style: TextStyle(fontSize: 12.5, color: AppColors.grey),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 13.5)),
        ],
      ),
    );
  }
}
