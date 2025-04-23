import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../controllers/chat_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/constants.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());
    final screenSize = MediaQuery.of(context).size;
    final scaleFactor = (screenSize.width / 1920).clamp(0.5, 1.0);

    return Scaffold(
      body: Obx(
        () {
          if (chatController.currentUserId == null) {
            return Center(
              child: Text(
                'no_user'.tr,
                style: GoogleFonts.poppins(fontSize: 18 * scaleFactor),
              ),
            );
          }
          if (chatController.isLoadingUsers.value) {
            return Center(child: CircularProgressIndicator());
          }
          if (chatController.allUsers.isEmpty) {
            return Center(
              child: Text(
                'no_users'.tr,
                style: GoogleFonts.poppins(fontSize: 18 * scaleFactor),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16 * scaleFactor),
            itemCount: chatController.allUsers.length,
            itemBuilder: (context, index) {
              final user = chatController.allUsers[index];
              final unseenCount = chatController.getUnseenMessageCount(user['email']);
              return ListTile(
                leading: CircleAvatar(
                  radius: 24 * scaleFactor,
                  backgroundImage: user['profilePicture']?.isNotEmpty == true
                      ? NetworkImage('http://localhost:5000${user['profilePicture']}')
                      : null,
                  child: user['profilePicture']?.isEmpty != false
                      ? Text(
                          user['username'][0].toUpperCase(),
                          style: TextStyle(fontSize: 20 * scaleFactor),
                        )
                      : null,
                ),
                title: Text(
                  user['username'],
                  style: GoogleFonts.poppins(fontSize: 18 * scaleFactor),
                ),
                subtitle: Text(
                  user['online'] == true ? 'Online' : 'Offline',
                  style: GoogleFonts.poppins(fontSize: 14 * scaleFactor),
                ),
                trailing: unseenCount > 0
                    ? Badge(
                        label: Text(
                          unseenCount.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 14 * scaleFactor),
                        ),
                        backgroundColor: AppConstants.primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor),
                      )
                    : null,
                onTap: () {
                  chatController.selectReceiver(user['email']);
                  Get.toNamed(
                    AppRoutes.getChatPage(user['email'], user['username']),
                    arguments: {
                      'receiverId': user['email'],
                      'receiverUsername': user['username'],
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}