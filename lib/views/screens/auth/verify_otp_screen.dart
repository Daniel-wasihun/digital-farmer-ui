import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../controllers/auth/auth_controller.dart';

class VerifyOTPScreen extends StatefulWidget {
  const VerifyOTPScreen({super.key});

  @override
  _VerifyOTPScreenState createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  late List<TextEditingController> otpControllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and focus nodes for 6 OTP boxes
    otpControllers = List.generate(6, (_) => TextEditingController());
    focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes to prevent memory leaks
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Combine OTP digits into a single string
  String getOtpString() {
    return otpControllers.map((controller) => controller.text).join();
  }

  // Check if all OTP boxes are filled
  bool isOtpComplete() {
    return otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();
    final args = Get.arguments;
    final String email = args['email'];
    final String type = args['type'] ?? 'signup'; // 'signup' or 'password_reset'

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet
        ? (size.width / 720).clamp(1.0, 1.2)
        : (size.width / 360).clamp(0.8, 1.0) * (size.height / 640).clamp(0.85, 1.0);
    final maxFormWidth = isTablet ? 500.0 : 380.0;

    return WillPopScope(
      onWillPop: () async {
        return true; // Allow back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'verify_otp'.tr,
            style: theme.textTheme.titleLarge!.copyWith(
              fontSize: 18 * scaleFactor,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back,
              color: const Color(0xFF1A6B47), // Updated to lighter green
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface,
                      ]
                    : [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withOpacity(0.95),
                      ],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface,
                    ]
                  : [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withOpacity(0.95),
                    ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * (isTablet ? 0.12 : 0.06),
                      vertical: size.height * 0.03,
                    ),
                    child: Obx(
                      () => controller.isLoading.value
                          ? Center(
                              child: SpinKitFadingCube(
                                color: const Color(0xFF1A6B47), // Updated to lighter green
                                size: 32 * scaleFactor,
                              ),
                            )
                          : ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: (isTablet ? size.width * 0.75 : size.width * 0.85).clamp(280, maxFormWidth),
                              ),
                              child: Card(
                                elevation: isDarkMode ? 6.0 : 10.0,
                                color: theme.cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16 * scaleFactor),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: EdgeInsets.all((16 * scaleFactor).clamp(12.0, 24.0)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'verify_otp'.tr,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                              fontSize: (22 * scaleFactor).clamp(18.0, 24.0),
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                              shadows: isDarkMode
                                                  ? null
                                                  : [
                                                      Shadow(
                                                        blurRadius: 6.0,
                                                        color: Colors.black.withOpacity(0.2),
                                                        offset: Offset(2, 2),
                                                      ),
                                                    ],
                                            ) ??
                                            TextStyle(
                                              fontSize: (22 * scaleFactor).clamp(18.0, 24.0),
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: (14 * scaleFactor).clamp(12.0, 16.0)),
                                      Text(
                                        '${'enter_otp_sent_to'.tr} $email',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: (16 * scaleFactor).clamp(14.0, 18.0),
                                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                                            ) ??
                                            TextStyle(
                                              fontSize: (16 * scaleFactor).clamp(14.0, 18.0),
                                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                                            ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                      SizedBox(height: (14 * scaleFactor).clamp(12.0, 16.0)),
                                      AnimatedOpacity(
                                        opacity: controller.isLoading.value ? 0.5 : 1.0,
                                        duration: const Duration(milliseconds: 300),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: List.generate(6, (index) {
                                            return SizedBox(
                                              width: (40 * scaleFactor).clamp(36.0, 48.0),
                                              height: (48 * scaleFactor).clamp(44.0, 56.0),
                                              child: TextField(
                                                controller: otpControllers[index],
                                                focusNode: focusNodes[index],
                                                keyboardType: TextInputType.number,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: (18 * scaleFactor).clamp(16.0, 20.0),
                                                  color: theme.colorScheme.onSurface,
                                                ),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8 * scaleFactor),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8 * scaleFactor),
                                                    borderSide: BorderSide(
                                                      color: theme.colorScheme.primary.withOpacity(0.3),
                                                    ),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8 * scaleFactor),
                                                    borderSide: BorderSide(
                                                      color: theme.colorScheme.primary,
                                                      width: 2.0,
                                                    ),
                                                  ),
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.digitsOnly,
                                                  LengthLimitingTextInputFormatter(1),
                                                ],
                                                enabled: !controller.isLoading.value,
                                                onChanged: (value) {
                                                  if (value.isNotEmpty && index < 5) {
                                                    focusNodes[index].unfocus();
                                                    FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                                                  } else if (value.isNotEmpty && index == 5 && isOtpComplete() && !controller.isLoading.value) {
                                                    focusNodes[index].unfocus();
                                                    final otp = getOtpString();
                                                    if (type == 'password_reset') {
                                                      controller.verifyPasswordResetOTP(email, otp);
                                                    } else {
                                                      controller.verifyOTP(email, otp);
                                                    }
                                                  } else if (value.isEmpty && index > 0) {
                                                    focusNodes[index].unfocus();
                                                    FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                                                  }
                                                },
                                                textInputAction: index < 5 ? TextInputAction.next : TextInputAction.done,
                                                onSubmitted: (_) {
                                                  if (index == 5 && isOtpComplete() && !controller.isLoading.value) {
                                                    final otp = getOtpString();
                                                    if (type == 'password_reset') {
                                                      controller.verifyPasswordResetOTP(email, otp);
                                                    } else {
                                                      controller.verifyOTP(email, otp);
                                                    }
                                                  }
                                                },
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                      SizedBox(height: (14 * scaleFactor).clamp(12.0, 16.0)),
                                      TextButton(
                                        onPressed: controller.isLoading.value
                                            ? null
                                            : () {
                                                controller.resendOTP(email, type);
                                              },
                                        child: Text(
                                          'resend_otp'.tr,
                                          style: TextStyle(
                                            fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ),
                      );
                    
                  },
                ),
              ),
            ),
          ),
        ),
      );
  }
}