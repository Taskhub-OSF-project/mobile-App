import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write('has_seen_onboarding', 'true');
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      _OnboardingSlideData(
        title: 'Chào mừng đến với',
        description: 'Nền tảng kết nối sinh viên tìm kiếm công việc tự do và nhà tuyển dụng chất lượng một cách nhanh chóng, an toàn.',
        isFirstSlide: true,
      ),
      _OnboardingSlideData(
        title: 'Tìm việc linh hoạt',
        description: 'Dành cho Sinh viên: Khám phá hàng ngàn công việc freelance phù hợp với kỹ năng, lịch học và tăng thêm thu nhập.',
        isFirstSlide: false,
      ),
      _OnboardingSlideData(
        title: 'Tuyển dụng dễ dàng',
        description: 'Dành cho Nhà tuyển dụng: Đăng tin tuyển dụng, tiếp cận hàng ngàn sinh viên tài năng và quản lý dự án hiệu quả.',
        isFirstSlide: false,
      ),
      _OnboardingSlideData(
        title: 'Thanh toán Đảm bảo',
        description: 'Hệ thống Ký quỹ (Escrow) thông minh bảo vệ quyền lợi thanh toán của sinh viên và chất lượng công việc cho nhà tuyển dụng.',
        isFirstSlide: false,
      ),
      _OnboardingSlideData(
        title: 'Bắt đầu trải nghiệm',
        description: 'Chào mừng bạn tham gia TaskHub! Hãy lựa chọn vai trò phù hợp của bạn để tiếp tục đăng nhập.',
        isFirstSlide: false,
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A), // Slate 900
              Color(0xFF020617), // Slate 950
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Skip Button
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerRight,
                child: _currentPage < 4
                    ? TextButton(
                        onPressed: () => _completeOnboarding(context),
                        child: const Text(
                          'Bỏ qua',
                          style: TextStyle(
                            color: Color(0xFF94A3B8), // Slate 400
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
              ),
              // Swipable Slides
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: slides.length,
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (slide.isFirstSlide) ...[
                            // App logo container for Slide 1
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF059669), // Emerald 600
                                    Color(0xFF0D9488), // Teal 600
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF059669).withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.bolt,
                                size: 52,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 32),
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1.0,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Task',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: 'Hub',
                                    style: TextStyle(color: Color(0xFF34D399)), // Emerald 400
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ] else ...[
                            // Text-only layouts for slides 2-5 (simpler, cleaner UI)
                            Text(
                              slide.title,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            // Accent line separator
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 24),
                              width: 56,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF34D399), // Emerald 400
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                          Text(
                            slide.description,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFF94A3B8), // Slate 400 text
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Bottom Controls / Actions
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_currentPage < 4) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Page Indicators
                          Row(
                            children: List.generate(
                              slides.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 8),
                                height: 8,
                                width: _currentPage == index ? 24 : 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? const Color(0xFF34D399) // Emerald 400
                                      : const Color(0xFF334155), // Slate 700
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          // Next Button
                          IconButton.filled(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            },
                            icon: const Icon(Icons.arrow_forward),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(56, 56),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Action buttons on slide 5
                      ElevatedButton(
                        onPressed: () => _completeOnboarding(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Tìm công việc'),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => _completeOnboarding(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF34D399),
                          side: const BorderSide(color: Color(0xFF059669), width: 2),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Tôi là nhà tuyển dụng'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlideData {
  final String title;
  final String description;
  final bool isFirstSlide;

  _OnboardingSlideData({
    required this.title,
    required this.description,
    required this.isFirstSlide,
  });
}
