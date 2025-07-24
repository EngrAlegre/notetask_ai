import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/ai_service.dart';
import './widgets/ai_response_widget.dart';
import './widgets/command_selector_widget.dart';
import './widgets/model_selector_widget.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({Key? key}) : super(key: key);

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiService _aiService = AiService();

  String _selectedCommand = 'summarize';
  String _selectedModel = 'sonar-pro';
  String? _response;
  bool _isLoading = false;

  final Map<String, String> _commands = {
    'summarize': 'Summarize',
    'grammar': 'Grammar Check',
    'rewrite': 'Rewrite',
    'ideas': 'Generate Ideas',
  };

  final List<String> _models = [
    'sonar',
    'sonar-pro',
    'sonar-deep-research',
    'sonar-reasoning',
    'sonar-reasoning-pro',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _processText() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter some text to process',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    if (!_aiService.isAvailable) {
      Fluttertoast.showToast(
        msg: 'AI service is not available. Please configure your API key.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _response = null;
    });

    try {
      final result = await _aiService.askQuestion(
        question: 'Command: $_selectedCommand\nText:\n"""\n$input\n"""',
      );

      setState(() {
        _response = result;
      });

      // Scroll to response
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });

      HapticFeedback.lightImpact();
    } catch (e) {
      setState(() {
        _response = 'Sorry, I encountered an error. Please try again later.';
      });

      Fluttertoast.showToast(
        msg: 'AI processing failed: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearAll() {
    setState(() {
      _inputController.clear();
      _response = null;
    });
  }

  void _copyResponse() {
    if (_response != null) {
      Clipboard.setData(ClipboardData(text: _response!));
      Fluttertoast.showToast(
        msg: 'Response copied to clipboard',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'AI Assistant',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        actions: [
          if (_response != null)
            IconButton(
              onPressed: _copyResponse,
              icon: CustomIconWidget(
                iconName: 'content_copy',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
            ),
          IconButton(
            onPressed: _clearAll,
            icon: CustomIconWidget(
              iconName: 'clear_all',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 5.w,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Service Status
                    if (!_aiService.isAvailable)
                      Container(
                        padding: EdgeInsets.all(3.w),
                        margin: EdgeInsets.only(bottom: 3.h),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'warning',
                              color: Colors.orange,
                              size: 5.w,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                'AI service is not configured. Please add your Perplexity API key to enable AI features.',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Command Selector
                    CommandSelectorWidget(
                      selectedCommand: _selectedCommand,
                      commands: _commands,
                      onCommandChanged: (command) {
                        setState(() {
                          _selectedCommand = command;
                        });
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Model Selector
                    ModelSelectorWidget(
                      selectedModel: _selectedModel,
                      models: _models,
                      onModelChanged: (model) {
                        setState(() {
                          _selectedModel = model;
                        });
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Text Input
                    Text(
                      'Text to Process',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _inputController,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          hintText: 'Enter text here...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Process Button
                    SizedBox(
                      width: double.infinity,
                      height: 6.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _processText,
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 4.w,
                                    height: 4.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  const Text('Processing...'),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'auto_awesome',
                                    color: Colors.white,
                                    size: 5.w,
                                  ),
                                  SizedBox(width: 2.w),
                                  const Text('Process Text'),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // AI Response
                    if (_response != null)
                      AiResponseWidget(
                        response: _response!,
                        onCopy: _copyResponse,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}