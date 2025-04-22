import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        final scaleFactor = (screenWidth / 1920 * screenHeight / 1080).clamp(0.6, 0.95);
        final avatarRadius = 28 * scaleFactor;
        final fontSizeLarge = 16 * scaleFactor;
        final fontSizeSmall = 12 * scaleFactor;

        return Scaffold(
          body: Column(
            children: [
              _buildSearchField(chatController, scaleFactor, fontSizeSmall, screenWidth),
              Expanded(
                child: Obx(() {
                  return Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: chatController.fetchUsers, // Use the existing fetchUsers method
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
                          color: Get.theme.colorScheme.surface.withOpacity(0.7),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48 * scaleFactor, color: Colors.redAccent),
          SizedBox(height: 8 * scaleFactor),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14 * scaleFactor, color: Colors.grey[700]),
          ),
          SizedBox(height: 16 * scaleFactor),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh, size: 18 * scaleFactor),
            label: Text('retry'.tr, style: GoogleFonts.poppins(fontSize: 14 * scaleFactor)),
          ),
        ],
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
      padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor, vertical: 6 * scaleFactor),
      child: Container(
        width: screenWidth * 0.95,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(25 * scaleFactor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6 * scaleFactor,
              offset: Offset(0, 1 * scaleFactor),
            ),
          ],
        ),
        child: TextField(
          controller: chatController.searchController,
          style: GoogleFonts.poppins(
            fontSize: fontSizeSmall + 1,
            color: Get.theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'search_users'.tr,
            hintStyle: GoogleFonts.poppins(
              fontSize: fontSizeSmall + 1,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 20 * scaleFactor,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25 * scaleFactor),
              borderSide: BorderSide(color: AppConstants.primaryColor.withOpacity(0.6)),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10 * scaleFactor, horizontal: 16 * scaleFactor),
          ),
          onChanged: (_) => chatController.debounceSearch(), // Use the existing debounce method
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
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 4 * scaleFactor),
      itemCount: userListItems.length,
      itemBuilder: (context, index) {
        return UserListItem(
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
      margin: EdgeInsets.symmetric(horizontal: 6 * scaleFactor, vertical: 3 * scaleFactor),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10 * scaleFactor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10 * scaleFactor),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10 * scaleFactor, vertical: 6 * scaleFactor),
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
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: -1 * scaleFactor,
                    right: -1 * scaleFactor,
                    child: Container(
                      width: 10 * scaleFactor,
                      height: 10 * scaleFactor,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline ? Colors.green[400] : Colors.grey[400],
                        border: Border.all(
                          color: Get.theme.colorScheme.surface,
                          width: 1.5 * scaleFactor,
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
                    Text(
                      user['username']?.toString() ?? 'Unknown',
                      style: GoogleFonts.poppins(
                        fontSize: fontSizeLarge,
                        fontWeight: FontWeight.w500,
                        color: Get.theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2 * scaleFactor),
                    Text(
                      isTyping ? 'typing'.tr : lastMessage.isNotEmpty ? lastMessage : 'no_messages'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: fontSizeSmall,
                        fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
                        color: isTyping
                            ? AppConstants.primaryColor
                            : Get.theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8 * scaleFactor),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTimestamp(timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: fontSizeSmall * 0.8,
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  if (unseenCount > 0)
                    SizedBox(height: 4 * scaleFactor),
                  if (unseenCount > 0)
                    CircleAvatar(
                      radius: 10 * scaleFactor,
                      backgroundColor: AppConstants.primaryColor,
                      child: Text(
                        unseenCount.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: fontSizeSmall * 0.75,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (isSentByUser && lastMessage.isNotEmpty)
                    Icon(
                      isRead ? Icons.done_all : isDelivered ? Icons.done : Icons.schedule,
                      size: 16 * scaleFactor,
                      color: isRead ? Colors.blue[300] : Colors.grey[400],
                    ),
                ],
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