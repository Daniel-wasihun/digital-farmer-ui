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
        final scaleFactor = (screenWidth / 1920 * screenHeight / 1080).clamp(0.5, 1.0);
        final avatarRadius = 32 * scaleFactor;
        final fontSizeLarge = 18 * scaleFactor;
        final fontSizeSmall = 14 * scaleFactor;

        return Scaffold(
          body: Column(
            children: [
              _buildSearchField(chatController, scaleFactor, fontSizeSmall, screenWidth),
              Expanded(
                child: Obx(() {
                  return Stack(
                    children: [
                      _buildUserList(
                        chatController,
                        scaleFactor,
                        avatarRadius,
                        fontSizeLarge,
                        fontSizeSmall,
                      ),
                      if (chatController.isLoadingUsers.value)
                        Container(
                          color: Colors.black.withOpacity(0.1),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
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

  Widget _buildSearchField(
    ChatController chatController,
    double scaleFactor,
    double fontSizeSmall,
    double screenWidth,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor, vertical: 8 * scaleFactor),
      child: Container(
        width: screenWidth,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(30 * scaleFactor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8 * scaleFactor,
              offset: Offset(0, 2 * scaleFactor),
            ),
          ],
        ),
        child: TextField(
          controller: chatController.searchController,
          style: GoogleFonts.poppins(
            fontSize: fontSizeSmall + 2,
            color: Get.theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'search_users'.tr,
            hintStyle: GoogleFonts.poppins(
              fontSize: fontSizeSmall + 2,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 24 * scaleFactor,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30 * scaleFactor),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12 * scaleFactor),
          ),
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
    if (chatController.currentUserId == null) {
      return Center(
        child: Text(
          'no_user'.tr,
          style: GoogleFonts.poppins(
            fontSize: fontSizeLarge,
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
      );
    }
    final userListItems = chatController.userListItems;
    if (userListItems.isEmpty && chatController.searchController.text.isEmpty) {
      return Center(
        child: Text(
          'no_users'.tr,
          style: GoogleFonts.poppins(
            fontSize: fontSizeLarge,
            color: Get.theme.colorScheme.onSurface,
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
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
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
      margin: EdgeInsets.symmetric(horizontal: 8 * scaleFactor, vertical: 4 * scaleFactor),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12 * scaleFactor),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor, vertical: 4 * scaleFactor),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Get.theme.colorScheme.primary,
              backgroundImage: user['profilePicture']?.isNotEmpty == true
                  ? CachedNetworkImageProvider('http://localhost:5000${user['profilePicture']}')
                  : null,
              child: user['profilePicture']?.isEmpty != false
                  ? Text(
                      _getFirstNameInitial(user['username']?.toString() ?? '?'),
                      style: GoogleFonts.poppins(
                        fontSize: avatarRadius * 0.75,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: -2 * scaleFactor,
              right: -2 * scaleFactor,
              child: Container(
                width: 12 * scaleFactor,
                height: 12 * scaleFactor,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? Colors.green : Colors.grey,
                  border: Border.all(
                    color: Get.theme.colorScheme.surface,
                    width: 2 * scaleFactor,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isTyping ? 'typing'.tr : lastMessage.isNotEmpty ? lastMessage : 'no_messages'.tr,
                style: GoogleFonts.poppins(
                  fontSize: fontSizeSmall,
                  fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
                  color: isTyping
                      ? Get.theme.colorScheme.primary
                      : Get.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSentByUser && lastMessage.isNotEmpty)
              Text(
                isRead ? 'Read' : 'Delivered',
                style: GoogleFonts.poppins(
                  fontSize: fontSizeSmall * 0.8,
                  color: isRead ? Colors.blue : Colors.grey,
                ),
              ),
          ],
        ),
        trailing: unseenCount > 0
            ? CircleAvatar(
                radius: 12 * scaleFactor,
                backgroundColor: AppConstants.primaryColor,
                child: Text(
                  unseenCount.toString(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: fontSizeSmall * 0.85,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12 * scaleFactor),
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
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}