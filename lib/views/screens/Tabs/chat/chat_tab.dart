import 'package:agri/services/api/base_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../controllers/chat/chat_controller.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../utils/constants.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    // Responsive scaling factor based on screen width (same as CropTipsTab)
    final double scaleFactor = (0.9 + (screenWidth - 320) / (1200 - 320) * (1.6 - 0.9)).clamp(0.9, 1.6);
    final double adjustedScaleFactor = scaleFactor * 1.1;

    // Dynamic responsive padding (same as CropTipsTab)
    final double padding = (8 + (screenWidth - 320) / (1200 - 320) * (32 - 8)).clamp(8.0, 32.0);

    // Font sizes (aligned with CropTipsTab)
    const double baseHeaderFontSize = 32.0;
    const double baseTitleFontSize = 20.0;
    const double baseSubtitleFontSize = 16.0;
    const double baseDetailFontSize = 14.0;

    final double headerFontSize = (baseHeaderFontSize * adjustedScaleFactor).clamp(22.0, 38.0);
    final double titleFontSize = (baseTitleFontSize * adjustedScaleFactor).clamp(16.0, 28.0);
    final double subtitleFontSize = (baseSubtitleFontSize * adjustedScaleFactor * 0.9).clamp(12.0, 20.0);
    final double detailFontSize = (baseDetailFontSize * adjustedScaleFactor * 0.9).clamp(10.0, 18.0);

    // Font fallbacks for Amharic
    const List<String> fontFamilyFallbacks = ['NotoSansEthiopic', 'AbyssinicaSIL'];

    return Scaffold(
      body: Column(
        children: [
          _buildSearchField(
            chatController,
            adjustedScaleFactor,
            padding,
            detailFontSize,
            screenWidth,
            fontFamilyFallbacks,
          ),
          Expanded(
            child: Obx(() {
              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: chatController.fetchUsers,
                    color: AppConstants.primaryColor,
                    backgroundColor: Get.theme.colorScheme.surface,
                    child: _buildUserList(
                      chatController,
                      adjustedScaleFactor,
                      padding,
                      subtitleFontSize,
                      detailFontSize,
                      fontFamilyFallbacks,
                    ),
                  ),
                  if (chatController.isLoadingUsers.value)
                    Container(
                      color: Get.theme.colorScheme.surface.withOpacity(0.9),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                          strokeWidth: 3 * adjustedScaleFactor,
                        ),
                      ),
                    ),
                  if (chatController.errorMessage.isNotEmpty)
                    _buildErrorIndicator(
                      chatController.errorMessage.value,
                      adjustedScaleFactor,
                      padding,
                      subtitleFontSize,
                      detailFontSize,
                      chatController.fetchUsers,
                      fontFamilyFallbacks,
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorIndicator(
    String message,
    double adjustedScaleFactor,
    double padding,
    double subtitleFontSize,
    double detailFontSize,
    VoidCallback onRetry,
    List<String> fontFamilyFallbacks,
  ) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(padding),
        margin: EdgeInsets.symmetric(horizontal: padding * 1.25),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
          border: Border.all(color: Get.theme.colorScheme.error.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48 * adjustedScaleFactor,
              color: Get.theme.colorScheme.error,
            ),
            SizedBox(height: 8 * adjustedScaleFactor),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontFamilyFallback: fontFamilyFallbacks,
                fontSize: subtitleFontSize,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12 * adjustedScaleFactor),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, size: 18 * adjustedScaleFactor),
              label: Text(
                'retry'.tr,
                style: TextStyle(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontFamilyFallback: fontFamilyFallbacks,
                  fontSize: detailFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * adjustedScaleFactor,
                  vertical: 6 * adjustedScaleFactor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * adjustedScaleFactor),
                ),
                elevation: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(
    ChatController chatController,
    double adjustedScaleFactor,
    double padding,
    double detailFontSize,
    double screenWidth,
    List<String> fontFamilyFallbacks,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.8),
      child: Container(
        width: screenWidth * 0.95,
        height: 36 * adjustedScaleFactor,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8 * adjustedScaleFactor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6 * adjustedScaleFactor,
              offset: Offset(0, 2 * adjustedScaleFactor),
            ),
          ],
        ),
        child: TextField(
          controller: chatController.searchController,
          style: TextStyle(
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontFamilyFallback: fontFamilyFallbacks,
            fontSize: detailFontSize,
            color: Get.theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'search_users'.tr,
            hintStyle: TextStyle(
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontFamilyFallback: fontFamilyFallbacks,
              fontSize: detailFontSize,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 18 * adjustedScaleFactor,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8 * adjustedScaleFactor),
              borderSide: BorderSide(color: Colors.grey, width: 1 * adjustedScaleFactor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8 * adjustedScaleFactor),
              borderSide: BorderSide(color: Colors.grey, width: 1 * adjustedScaleFactor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8 * adjustedScaleFactor),
              borderSide: BorderSide(color: AppConstants.primaryColor, width: 1.5 * adjustedScaleFactor),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 8 * adjustedScaleFactor,
              horizontal: 10 * adjustedScaleFactor,
            ),
          ),
          onChanged: (_) => chatController.debounceSearch(),
        ),
      ),
    );
  }

  Widget _buildUserList(
    ChatController chatController,
    double adjustedScaleFactor,
    double padding,
    double subtitleFontSize,
    double detailFontSize,
    List<String> fontFamilyFallbacks,
  ) {
    if (chatController.currentUserId.value == null) {
      return Center(
        child: Text(
          'no_user'.tr,
          style: TextStyle(
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontFamilyFallback: fontFamilyFallbacks,
            fontSize: subtitleFontSize,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    final List<Map<String, dynamic>> userListItems = chatController.userListItems;
    if (userListItems.isEmpty && chatController.searchController.text.isEmpty) {
      return Center(
        child: Text(
          'no_users'.tr,
          style: TextStyle(
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontFamilyFallback: fontFamilyFallbacks,
            fontSize: subtitleFontSize,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    if (userListItems.isEmpty) {
      return Center(
        child: Text(
          'no_results'.tr,
          style: TextStyle(
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontFamilyFallback: fontFamilyFallbacks,
            fontSize: subtitleFontSize,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: padding * 0.8),
      itemCount: userListItems.length,
      itemBuilder: (context, index) {
        return FadeInRight(
          duration: Duration(milliseconds: 300 + (index * 50)),
          child: UserListItem(
            userData: userListItems[index],
            adjustedScaleFactor: adjustedScaleFactor,
            padding: padding,
            subtitleFontSize: subtitleFontSize,
            detailFontSize: detailFontSize,
            fontFamilyFallbacks: fontFamilyFallbacks,
            onTap: () {
              final user = userListItems[index]['user'];
              chatController.selectReceiver(user['email']);
              Get.toNamed(
                AppRoutes.getChatPage(user['email'], user['username'] ?? 'Unknown'),
                arguments: {
                  'receiverId': user['email'],
                  'receiverUsername': user['username'] ?? 'Unknown',
                },
              );
            },
          ),
        );
      },
    );
  }
}

class UserListItem extends StatelessWidget {
  final Map<String, dynamic> userData;
  final double adjustedScaleFactor;
  final double padding;
  final double subtitleFontSize;
  final double detailFontSize;
  final List<String> fontFamilyFallbacks;
  final VoidCallback onTap;

  const UserListItem({
    super.key,
    required this.userData,
    required this.adjustedScaleFactor,
    required this.padding,
    required this.subtitleFontSize,
    required this.detailFontSize,
    required this.fontFamilyFallbacks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = userData['user'] as Map<String, dynamic>;
    final unseenCount = userData['unseenCount'] as int;
    final isTyping = userData['isTyping'] as bool;
    final lastMessage = userData['lastMessage'] as String;
    final timestamp = userData['timestamp'] as String;
    final isSentByUser = userData['isSentByUser'] as bool;
    final isDelivered = userData['isDelivered'] as bool;
    final isRead = userData['isRead'] as bool;
    final isOnline = user['online'] == true;

    return Card(
      key: ValueKey(user['email']),
      margin: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.75),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
        child: Padding(
          padding: EdgeInsets.all(padding * 0.8),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 32 * adjustedScaleFactor / 2,
                    backgroundColor: AppConstants.primaryColor.withOpacity(0.8),
                    backgroundImage: user['profilePicture']?.isNotEmpty == true
                        ? CachedNetworkImageProvider('${BaseApi.imageBaseUrl}${user['profilePicture']}')
                        : null,
                    child: user['profilePicture']?.isEmpty != false
                        ? Text(
                            _getFirstNameInitial(user['username']?.toString() ?? '?'),
                            style: TextStyle(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontFamilyFallback: fontFamilyFallbacks,
                              fontSize: (32 * adjustedScaleFactor / 2) * 0.65,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12 * adjustedScaleFactor,
                      height: 12 * adjustedScaleFactor,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline ? Colors.green[400] : Colors.grey[400],
                        border: Border.all(
                          color: Get.theme.colorScheme.surface,
                          width: 2 * adjustedScaleFactor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8 * adjustedScaleFactor),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user['username']?.toString() ?? 'Unknown',
                            style: TextStyle(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontFamilyFallback: fontFamilyFallbacks,
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w600,
                              color: Get.theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTimestamp(timestamp),
                          style: TextStyle(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontFamilyFallback: fontFamilyFallbacks,
                            fontSize: detailFontSize * 0.8,
                            color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4 * adjustedScaleFactor),
                    Row(
                      children: [
                        if (isTyping) ...[
                          Row(
                            children: [
                              Text(
                                'typing'.tr,
                                style: TextStyle(
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                  fontFamilyFallback: fontFamilyFallbacks,
                                  fontSize: detailFontSize,
                                  fontStyle: FontStyle.italic,
                                  color: AppConstants.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 4 * adjustedScaleFactor),
                              _TypingDots(adjustedScaleFactor: adjustedScaleFactor),
                            ],
                          ),
                        ] else ...[
                          Expanded(
                            child: Row(
                              children: [
                                if (isSentByUser && lastMessage.isNotEmpty) ...[
                                  Icon(
                                    isDelivered || isRead ? Icons.done_all : Icons.check,
                                    size: 18 * adjustedScaleFactor,
                                    color: isRead ? Colors.blue[300] : Colors.grey[400],
                                  ),
                                  SizedBox(width: 4 * adjustedScaleFactor),
                                ],
                                Expanded(
                                  child: Text(
                                    lastMessage.isNotEmpty ? lastMessage : 'no_messages'.tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.poppins().fontFamily,
                                      fontFamilyFallback: fontFamilyFallbacks,
                                      fontSize: detailFontSize,
                                      color: unseenCount > 0
                                          ? Get.theme.colorScheme.onSurface
                                          : Get.theme.colorScheme.onSurface.withOpacity(0.6),
                                      fontWeight: unseenCount > 0 ? FontWeight.w500 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8 * adjustedScaleFactor),
              if (unseenCount > 0)
                CircleAvatar(
                  radius: 10 * adjustedScaleFactor,
                  backgroundColor: AppConstants.primaryColor,
                  child: Text(
                    unseenCount > 99 ? '99+' : unseenCount.toString(),
                    style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontFamilyFallback: fontFamilyFallbacks,
                      color: Colors.white,
                      fontSize: detailFontSize * 0.75,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFirstNameInitial(String username) {
    if (username.isEmpty) return '?';
    final firstName = username.split(' ').first;
    return firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
  }

  String _formatTimestamp(String timestamp) {
    if (timestamp.isEmpty) return '';
    final dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (messageDate == yesterday) {
      return 'yesterday'.tr;
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    } else {
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }
}

class _TypingDots extends StatelessWidget {
  final double adjustedScaleFactor;

  const _TypingDots({required this.adjustedScaleFactor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(adjustedScaleFactor: adjustedScaleFactor, delay: 0),
        SizedBox(width: 2 * adjustedScaleFactor),
        _Dot(adjustedScaleFactor: adjustedScaleFactor, delay: 200),
        SizedBox(width: 2 * adjustedScaleFactor),
        _Dot(adjustedScaleFactor: adjustedScaleFactor, delay: 400),
      ],
    );
  }
}

class _Dot extends StatefulWidget {
  final double adjustedScaleFactor;
  final int delay;

  const _Dot({required this.adjustedScaleFactor, required this.delay});

  @override
  _DotState createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(widget.delay / 1000, (widget.delay + 330) / 1000, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Opacity(
        opacity: _animation.value,
        child: Container(
          width: 5 * widget.adjustedScaleFactor,
          height: 5 * widget.adjustedScaleFactor,
          decoration: const BoxDecoration(
            color: AppConstants.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}