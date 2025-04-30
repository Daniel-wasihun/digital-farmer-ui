// chat_tab.dart
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final scaleFactor = (screenWidth / 414 * screenHeight / 896).clamp(0.8, 1.2);
        final avatarRadius = 24 * scaleFactor;
        final fontSizeLarge = 16 * scaleFactor;
        final fontSizeSmall = 14 * scaleFactor;

        return Scaffold(
          body: Column(
            children: [
              _buildSearchField(chatController, scaleFactor, fontSizeSmall, screenWidth),
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
                          scaleFactor,
                          avatarRadius,
                          fontSizeLarge,
                          fontSizeSmall,
                        ),
                      ),
                      if (chatController.isLoadingUsers.value)
                        Container(
                          color: Get.theme.colorScheme.surface.withOpacity(0.9),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                              strokeWidth: 3 * scaleFactor,
                            ),
                          ),
                        ),
                      if (chatController.errorMessage.isNotEmpty)
                        _buildErrorIndicator(chatController.errorMessage.value, scaleFactor, chatController.fetchUsers),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorIndicator(String message, double scaleFactor, VoidCallback onRetry) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16 * scaleFactor),
        margin: EdgeInsets.symmetric(horizontal: 20 * scaleFactor),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12 * scaleFactor),
          border: Border.all(color: Get.theme.colorScheme.error.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48 * scaleFactor, color: Get.theme.colorScheme.error),
            SizedBox(height: 12 * scaleFactor),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16 * scaleFactor,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16 * scaleFactor),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, size: 20 * scaleFactor),
              label: Text(
                'retry'.tr,
                style: GoogleFonts.poppins(fontSize: 14 * scaleFactor, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor, vertical: 8 * scaleFactor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * scaleFactor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(
    ChatController chatController,
    double scaleFactor,
    double fontSizeSmall,
    double screenWidth,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor, vertical: 8 * scaleFactor),
      child: Container(
        width: screenWidth * 0.95,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24 * scaleFactor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6 * scaleFactor,
              offset: Offset(0, 2 * scaleFactor),
            ),
          ],
        ),
        child: TextField(
          controller: chatController.searchController,
          style: GoogleFonts.poppins(
            fontSize: fontSizeSmall,
            color: Get.theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'search_users'.tr,
            hintStyle: GoogleFonts.poppins(
              fontSize: fontSizeSmall,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 20 * scaleFactor,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24 * scaleFactor),
              borderSide: BorderSide(color: AppConstants.primaryColor, width: 1.5 * scaleFactor),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12 * scaleFactor, horizontal: 16 * scaleFactor),
          ),
          onChanged: (_) => chatController.debounceSearch(),
        ),
      ),
    );
  }

  Widget _buildUserList(
    ChatController chatController,
    double scaleFactor,
    double avatarRadius,
    double fontSizeLarge,
    double fontSizeSmall,
  ) {
    if (chatController.currentUserId.value == null) {
      return Center(
        child: Text(
          'no_user'.tr,
          style: GoogleFonts.poppins(
            fontSize: fontSizeLarge,
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
          style: GoogleFonts.poppins(
            fontSize: fontSizeLarge,
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
          style: GoogleFonts.poppins(
            fontSize: fontSizeLarge,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor),
      itemCount: userListItems.length,
      itemBuilder: (context, index) {
        return FadeInRight(
          duration: Duration(milliseconds: 300 + (index * 50)),
          child: UserListItem(
            userData: userListItems[index],
            scaleFactor: scaleFactor,
            avatarRadius: avatarRadius,
            fontSizeLarge: fontSizeLarge,
            fontSizeSmall: fontSizeSmall,
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
  final double scaleFactor;
  final double avatarRadius;
  final double fontSizeLarge;
  final double fontSizeSmall;
  final VoidCallback onTap;

  const UserListItem({
    super.key,
    required this.userData,
    required this.scaleFactor,
    required this.avatarRadius,
    required this.fontSizeLarge,
    required this.fontSizeSmall,
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
      margin: EdgeInsets.symmetric(horizontal: 16 * scaleFactor, vertical: 6 * scaleFactor),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16 * scaleFactor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16 * scaleFactor),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor, vertical: 8 * scaleFactor),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: AppConstants.primaryColor.withOpacity(0.8),
                    backgroundImage: user['profilePicture']?.isNotEmpty == true
                        ? CachedNetworkImageProvider('http://localhost:5000${user['profilePicture']}')
                        : null,
                    child: user['profilePicture']?.isEmpty != false
                        ? Text(
                            _getFirstNameInitial(user['username']?.toString() ?? '?'),
                            style: GoogleFonts.poppins(
                              fontSize: avatarRadius * 0.65,
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
                      width: 12 * scaleFactor,
                      height: 12 * scaleFactor,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline ? Colors.green[400] : Colors.grey[400],
                        border: Border.all(
                          color: Get.theme.colorScheme.surface,
                          width: 2 * scaleFactor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12 * scaleFactor),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user['username']?.toString() ?? 'Unknown',
                            style: GoogleFonts.poppins(
                              fontSize: fontSizeLarge,
                              fontWeight: FontWeight.w600,
                              color: Get.theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTimestamp(timestamp),
                          style: GoogleFonts.poppins(
                            fontSize: fontSizeSmall * 0.8,
                            color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4 * scaleFactor),
                    Row(
                      children: [
                        if (isTyping) ...[
                          Row(
                            children: [
                              Text(
                                'typing'.tr,
                                style: GoogleFonts.poppins(
                                  fontSize: fontSizeSmall,
                                  fontStyle: FontStyle.italic,
                                  color: AppConstants.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 4 * scaleFactor),
                              _TypingDots(scaleFactor: scaleFactor),
                            ],
                          ),
                        ] else ...[
                          Expanded(
                            child: Row(
                              children: [
                                if (isSentByUser && lastMessage.isNotEmpty) ...[
                                  Icon(
                                    isDelivered || isRead ? Icons.done_all : Icons.check,
                                    size: 16 * scaleFactor,
                                    color: isRead ? Colors.blue[300] : Colors.grey[400],
                                  ),
                                  SizedBox(width: 4 * scaleFactor),
                                ],
                                Expanded(
                                  child: Text(
                                    lastMessage.isNotEmpty ? lastMessage : 'no_messages'.tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: fontSizeSmall,
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
              SizedBox(width: 12 * scaleFactor),
              if (unseenCount > 0)
                CircleAvatar(
                  radius: 10 * scaleFactor,
                  backgroundColor: AppConstants.primaryColor,
                  child: Text(
                    unseenCount > 99 ? '99+' : unseenCount.toString(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: fontSizeSmall * 0.75,
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
  final double scaleFactor;

  const _TypingDots({required this.scaleFactor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(scaleFactor: scaleFactor, delay: 0),
        SizedBox(width: 2 * scaleFactor),
        _Dot(scaleFactor: scaleFactor, delay: 200),
        SizedBox(width: 2 * scaleFactor),
        _Dot(scaleFactor: scaleFactor, delay: 400),
      ],
    );
  }
}

class _Dot extends StatefulWidget {
  final double scaleFactor;
  final int delay;

  const _Dot({required this.scaleFactor, required this.delay});

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
          width: 5 * widget.scaleFactor,
          height: 5 * widget.scaleFactor,
          decoration: const BoxDecoration(color: AppConstants.primaryColor, shape: BoxShape.circle),
        ),
      ),
    );
  }
}