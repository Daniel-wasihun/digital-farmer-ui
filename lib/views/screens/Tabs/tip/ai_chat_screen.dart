import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/chat/ai_chat_controller.dart';

class AIChatScreen extends GetView<AIChatController> {
  const AIChatScreen({super.key});

  // Render text with bold headers and properly aligned bullet points
  Widget _buildMessageText(String text, bool isRich, double scaleFactor) {
    if (!isRich) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 14 * scaleFactor,
          fontFamily: 'NotoSansEthiopic',
          color: Colors.black87,
        ),
      );
    }

    final lines = text.split('\n');
    final children = <Widget>[];

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.startsWith('**') && line.endsWith('**')) {
        children.add(
          Text(
            line.replaceAll('**', '').trim(),
            style: TextStyle(
              fontSize: 16 * scaleFactor,
              fontFamily: 'NotoSansEthiopic',
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        );
      } else if (line.startsWith('• ')) {
        children.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  fontSize: 14 * scaleFactor,
                  fontFamily: 'NotoSansEthiopic',
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 8 * scaleFactor),
              Expanded(
                child: Text(
                  line.replaceFirst('• ', '').trim(),
                  style: TextStyle(
                    fontSize: 14 * scaleFactor,
                    fontFamily: 'NotoSansEthiopic',
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        children.add(
          Text(
            line.trim(),
            style: TextStyle(
              fontSize: 14 * scaleFactor,
              fontFamily: 'NotoSansEthiopic',
              color: Colors.black87,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(AIChatController());
    final scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'agriculture_ai_chat'.tr,
          style: TextStyle(fontSize: 18 * scaleFactor),
        ),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green[700]!,
                Colors.green[500]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.white,
              Colors.green[50]!,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Obx(() => ListView.builder(
                    controller: controller.scrollController,
                    padding: EdgeInsets.all(12 * scaleFactor),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      final isUser = message['sender'] == 'user';
                      final isError = message['isError'] == true;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: FadeTransition(
                          opacity: CurvedAnimation(
                            parent: ModalRoute.of(context)!.animation!,
                            curve: Curves.easeIn,
                          ),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(isUser ? 1 : -1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: ModalRoute.of(context)!.animation!,
                              curve: Curves.easeOut,
                            )),
                            child: Align(
                              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isUser)
                                    Padding(
                                      padding: EdgeInsets.only(right: 8 * scaleFactor),
                                      child: CircleAvatar(
                                        radius: 16 * scaleFactor,
                                        backgroundColor: Colors.green[100],
                                        child: Icon(
                                          Icons.smart_toy,
                                          size: 20 * scaleFactor,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                  Flexible(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: 6 * scaleFactor,
                                        horizontal: 12 * scaleFactor,
                                      ),
                                      padding: EdgeInsets.all(14 * scaleFactor),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isUser
                                              ? [
                                                  Colors.green[400]!,
                                                  Colors.green[300]!,
                                                ]
                                              : [
                                                  Colors.grey[300]!,
                                                  Colors.grey[200]!,
                                                ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20 * scaleFactor)
                                            .copyWith(
                                          bottomRight:
                                              isUser ? Radius.zero : Radius.circular(20 * scaleFactor),
                                          bottomLeft:
                                              isUser ? Radius.circular(20 * scaleFactor) : Radius.zero,
                                          topLeft: Radius.circular(20 * scaleFactor),
                                          topRight: Radius.circular(20 * scaleFactor),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.15),
                                            blurRadius: 8 * scaleFactor,
                                            offset: Offset(0, 3 * scaleFactor),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildMessageText(
                                              message['text'], message['isRich'], scaleFactor),
                                          if (isError) ...[
                                            SizedBox(height: 8 * scaleFactor),
                                            TextButton.icon(
                                              onPressed: () =>
                                                  controller.retryMessage(message['query']),
                                              icon: Icon(
                                                Icons.refresh,
                                                size: 14 * scaleFactor,
                                              ),
                                              label: Text(
                                                'retry'.tr,
                                                style: TextStyle(fontSize: 12 * scaleFactor),
                                              ),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red[400],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isUser)
                                    Padding(
                                      padding: EdgeInsets.only(left: 8 * scaleFactor),
                                      child: CircleAvatar(
                                        radius: 16 * scaleFactor,
                                        backgroundColor: Colors.green[100],
                                        child: Icon(
                                          Icons.person,
                                          size: 20 * scaleFactor,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )),
            ),
            Obx(() => controller.isLoading.value
                ? Padding(
                    padding: EdgeInsets.all(10 * scaleFactor),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                    ),
                  )
                : const SizedBox.shrink()),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green[50]!,
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8 * scaleFactor,
                    offset: Offset(0, -2 * scaleFactor),
                  ),
                ],
              ),
              padding: EdgeInsets.all(12 * scaleFactor),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green[50]!,
                            Colors.grey[100]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30 * scaleFactor),
                        border: Border.all(
                          color: Colors.green[300]!,
                          width: 1.5 * scaleFactor,
                        ),
                      ),
                      child: TextField(
                        controller: controller.textController,
                        decoration: InputDecoration(
                          hintText: 'ask_about_agriculture'.tr,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20 * scaleFactor,
                            vertical: 15 * scaleFactor,
                          ),
                          prefixIcon: Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.green[600],
                            size: 20 * scaleFactor,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey,
                              size: 20 * scaleFactor,
                            ),
                            onPressed: () => controller.textController.clear(),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14 * scaleFactor,
                          fontFamily: 'NotoSansEthiopic',
                        ),
                        onSubmitted: (value) => controller.sendMessage(value),
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * scaleFactor),
                  FloatingActionButton(
                    onPressed: () => controller.sendMessage(controller.textController.text),
                    backgroundColor: Colors.green[600],
                    mini: true,
                    elevation: 2,
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 24 * scaleFactor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}