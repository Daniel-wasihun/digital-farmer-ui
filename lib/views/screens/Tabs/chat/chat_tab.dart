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
    final ChatController chatController = Get.find<ChatController>();
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    // Responsive scaling factor
    final double scaleFactor = (0.9 + (screenWidth - 320) / (1200 - 320) * (1.6 - 0.9)).clamp(0.9, 1.6);
    final double adjustedScaleFactor = scaleFactor * 1.1;

    // Dynamic responsive padding
    final double padding = (8 + (screenWidth - 320) / (1200 - 320) * (32 - 8)).clamp(8.0, 32.0);

    // Font sizes
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

    // Search focus node
    final searchFocusNode = FocusNode();

    // Clear search and unfocus
    void clearSearch() {
      chatController.searchController.clear();
      chatController.debounceSearch();
      searchFocusNode.unfocus();
    }

    return GestureDetector(
      onTap: () {
        searchFocusNode.unfocus();
      },
      child: Scaffold(
        body: Column(
          children: [
            // Network status banner
            Obx(() {
              if (!chatController.hasInternet.value) {
                return FadeInDown(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: padding * 0.5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Get.theme.colorScheme.error.withOpacity(0.1),
                          Get.theme.colorScheme.error.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'no_internet'.tr,
                          style: TextStyle(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontFamilyFallback: fontFamilyFallbacks,
                            fontSize: detailFontSize,
                            color: Get.theme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8 * adjustedScaleFactor),
                        SizedBox(
                          width: 16 * adjustedScaleFactor,
                          height: 16 * adjustedScaleFactor,
                          child: CircularProgressIndicator(
                            strokeWidth: 2 * adjustedScaleFactor,
                            valueColor: AlwaysStoppedAnimation<Color>(Get.theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (!chatController.serverAvailable.value) {
                return FadeInDown(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: padding * 0.5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Get.theme.colorScheme.error.withOpacity(0.1),
                          Get.theme.colorScheme.error.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'server_unavailable'.tr,
                          style: TextStyle(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontFamilyFallback: fontFamilyFallbacks,
                            fontSize: detailFontSize,
                            color: Get.theme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8 * adjustedScaleFactor),
                        SizedBox(
                          width: 16 * adjustedScaleFactor,
                          height: 16 * adjustedScaleFactor,
                          child: CircularProgressIndicator(
                            strokeWidth: 2 * adjustedScaleFactor,
                            valueColor: AlwaysStoppedAnimation<Color>(Get.theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            // Search field
            _buildSearchField(
              chatController,
              adjustedScaleFactor,
              padding,
              detailFontSize,
              screenWidth,
              fontFamilyFallbacks,
              searchFocusNode,
              clearSearch,
            ),
            // User list
            Expanded(
              child: Obx(() {
                final userListItems = chatController.userListItems;
                final _ = chatController.unseenNotifications; // Trigger rebuild on notification changes
                print('ChatTab: Building user list with ${userListItems.length} items');
                return RefreshIndicator(
                  onRefresh: chatController.fetchUsers,
                  color: AppConstants.primaryColor,
                  backgroundColor: Get.theme.colorScheme.surface,
                  child: _buildUserList(
                    chatController,
                    userListItems,
                    adjustedScaleFactor,
                    padding,
                    subtitleFontSize,
                    detailFontSize,
                    fontFamilyFallbacks,
                  ),
                );
              }),
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
    FocusNode searchFocusNode,
    VoidCallback clearSearch,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.8),
      child: Container(
        width: screenWidth * 0.95,
        height: 40 * adjustedScaleFactor,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8 * adjustedScaleFactor,
              offset: Offset(0, 2 * adjustedScaleFactor),
            ),
          ],
        ),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: chatController.searchController,
          builder: (context, textValue, child) {
            return TextField(
              controller: chatController.searchController,
              focusNode: searchFocusNode,
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
                suffixIcon: (textValue.text.isNotEmpty || searchFocusNode.hasFocus)
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 18 * adjustedScaleFactor,
                          color: Get.theme.colorScheme.onSurface,
                        ),
                        onPressed: clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
                  borderSide: BorderSide(color: AppConstants.primaryColor, width: 1.5 * adjustedScaleFactor),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8 * adjustedScaleFactor,
                  horizontal: 12 * adjustedScaleFactor,
                ),
              ),
              onChanged: (_) => chatController.debounceSearch(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserList(
    ChatController chatController,
    List<Map<String, dynamic>> userListItems,
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
      padding: EdgeInsets.symmetric(vertical: padding * 0.5),
      itemCount: userListItems.length,
      itemBuilder: (context, index) {
        final userData = userListItems[index];
        print('ChatTab: Rendering user ${userData['user']['email']}, timestamp: ${userData['timestamp']}');
        return FadeInRight(
          duration: Duration(milliseconds: 300 + (index * 50)),
          child: UserListItem(
            userData: userData,
            adjustedScaleFactor: adjustedScaleFactor,
            padding: padding,
            subtitleFontSize: subtitleFontSize,
            detailFontSize: detailFontSize,
            fontFamilyFallbacks: fontFamilyFallbacks,
            onTap: () {
              final user = userData['user'];
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

    print('UserListItem: Rendering ${user['email']}, timestamp: $timestamp');

    return Card(
      key: ValueKey(user['email']),
      margin: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.4),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
        child: Padding(
          padding: EdgeInsets.all(padding * 0.6),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28 * adjustedScaleFactor,
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
                              fontSize: 18 * adjustedScaleFactor,
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
                  if (unseenCount > 0)
                    Positioned(
                      top: -2 * adjustedScaleFactor,
                      right: -2 * adjustedScaleFactor,
                      child: CircleAvatar(
                        radius: 10 * adjustedScaleFactor,
                        backgroundColor: AppConstants.primaryColor,
                        child: Text(
                          unseenCount > 99 ? '99+' : unseenCount.toString(),
                          style: TextStyle(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontFamilyFallback: fontFamilyFallbacks,
                            color: Colors.white,
                            fontSize: detailFontSize * 0.8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 12 * adjustedScaleFactor),
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
                            fontSize: detailFontSize * 0.85,
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
                                    isRead
                                        ? Icons.done_all
                                        : isDelivered
                                            ? Icons.done_all
                                            : Icons.check,
                                    size: 16 * adjustedScaleFactor,
                                    color: isRead
                                        ? Colors.blue[300]
                                        : isDelivered
                                            ? Colors.grey[400]
                                            : Colors.grey[400],
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
    if (timestamp.isEmpty) {
      print('UserListItem: Empty timestamp');
      return '';
    }
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      String formatted;
      if (messageDate == today) {
        formatted = DateFormat('h:mm a').format(dateTime); // e.g., 7:24 PM
      } else if (messageDate == DateTime(now.year, now.month, now.day - 1)) {
        formatted = 'yesterday'.tr; // Yesterday
      } else if (now.difference(dateTime).inDays < 7) {
        formatted = DateFormat('EEEE').format(dateTime); // e.g., Monday
      } else {
        formatted = DateFormat('dd/MM/yy').format(dateTime); // e.g., 15/05/25
      }
      print('UserListItem: Formatted timestamp $timestamp to $formatted');
      return formatted;
    } catch (e) {
      print('UserListItem: Failed to parse timestamp: $timestamp, error: $e');
      return '';
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