import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toko/models/message.dart';
import 'package:toko/viewmodels/auth_viewmodel.dart';
import 'package:toko/viewmodels/message_viewmodel.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF4285F4);
  final messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask((){
      final authVM = Provider.of<AuthViewmodel>(context, listen: false);
      final messageVM = Provider.of<MessageViewmodel>(context, listen: false);
      authVM.initwebsocket();
      messageVM.fetchChatRoom();
      messageVM.fetchMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageVM = Provider.of<MessageViewmodel>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xff2563EB),
                const Color(0xff3B82F6),
                const Color(0xff60A5FA),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SafeArea(
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              titleSpacing: 0,

              title: Row(
                children: [

                  Hero(
                    tag: "kwanza_avatar",
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(.5),
                          width: 2,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          "https://avatars.githubusercontent.com/u/144583426?v=4",
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [

                        const Text(
                          "Kwanza AI",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 3),

                        messageVM.isTyping
                        ? const TypingStatus()
                        : Row(
                            children: [

                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),

                              const SizedBox(width: 6),

                              Text(
                                "Online",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(.9),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              actions: [

                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(.15),
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              Colors.white.withOpacity(.2),
                        ),
                      ),
                      child: const Row(
                        children: [

                          Icon(
                            Icons.memory,
                            size: 14,
                            color: Colors.white,
                          ),

                          SizedBox(width: 6),

                          Text(
                            "qwen2.5",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                PopupMenuButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  itemBuilder: (context) => [

                    const PopupMenuItem(
                      value: "clear",
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline),
                          SizedBox(width: 8),
                          Text("Clear Chat"),
                        ],
                      ),
                    ),

                    const PopupMenuItem(
                      value: "model",
                      child: Row(
                        children: [
                          Icon(Icons.tune),
                          SizedBox(width: 8),
                          Text("Model Settings"),
                        ],
                      ),
                    ),

                    const PopupMenuItem(
                      value: "about",
                      child: Row(
                        children: [
                          Icon(Icons.info_outline),
                          SizedBox(width: 8),
                          Text("About"),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xffF8FAFC),
        child: SafeArea(
          child: Column(
            children: [

              // ==========================
              // HEADER USER
              // ==========================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff2563EB),
                      Color(0xff3B82F6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [

                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Text(
                        (messageVM.currentUser?.name ?? "G")
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2563EB),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      messageVM.currentUser?.name ?? "Guest",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      messageVM.currentUser?.email ?? "",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==========================
              // NEW CHAT BUTTON
              // ==========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xff2563EB),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      messageVM.selectedRoom(null);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "New Chat",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==========================
              // TITLE
              // ==========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Recent Chats",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ==========================
              // CHAT LIST
              // ==========================
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: messageVM.chatRoomList.length,
                  itemBuilder: (context, index) {

                    final room =
                        messageVM.chatRoomList[index];

                    final isSelected =
                        room.id == messageVM.chatRoomId;

                    return Container(
                      margin:
                          const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: isSelected
                            ? const Color(0xffDBEAFE)
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(14),
                        elevation: isSelected ? 2 : 0,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(14),
                          onTap: () async {

                            Navigator.pop(context);

                            await messageVM
                                .selectedRoom(room.id);
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.all(12),
                            child: Row(
                              children: [

                                Container(
                                  padding:
                                      const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(
                                            0xffEFF6FF),
                                    borderRadius:
                                        BorderRadius.circular(
                                            12),
                                  ),
                                  child: Icon(
                                    Icons.chat_bubble_outline,
                                    color: isSelected
                                        ? const Color(
                                            0xff2563EB)
                                        : Colors.blueGrey,
                                    size: 18,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [

                                      Text(
                                        room.chatName,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight.w600,
                                          color: isSelected
                                              ? const Color(
                                                  0xff1E3A8A)
                                              : Colors.black87,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "Tap to continue",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors
                                              .grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xff2563EB),
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ==========================
              // FOOTER
              // ==========================
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [

                    Icon(
                      Icons.smart_toy_outlined,
                      color: Colors.grey.shade600,
                    ),

                    const SizedBox(width: 10),

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Kwanza AI",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "qwen2.5-coder:3b",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 90),
              Expanded(
                child: messageVM.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric( horizontal: 12, vertical: 16),
                        itemCount: messageVM.messageList.length,
                        itemBuilder: (context, index) {
                          final msg = messageVM.messageList[index];
                          final isMe = msg.role == "user";
                          return AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: 1,
                            child: Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: _ChatBubble(
                                messages: msg,
                                isMe: isMe,
                                color: primaryColor,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              _buildInputField(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    final messageVM = Provider.of<MessageViewmodel>(context, listen: false);
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: primaryColor),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: const InputDecoration(
                    hintText: "Send message...",
                    border: InputBorder.none,
                    isDense: true),
                onSubmitted: messageVM.isAction
                ? null
                : (message) {
                  if(message.isNotEmpty){
                    messageVM.sendMessage(message);
                    setState(() {
                      messageController.clear();
                    });
                  }
                },
              ),
            ),
            IconButton(
              icon: messageVM.isAction
              ? Center(child: CircularProgressIndicator(),)
              : Icon(Icons.send_rounded, color: primaryColor),
              onPressed: messageVM.isAction
              ? null
              : (){
                if(messageController.text.isNotEmpty){
                  messageVM.sendMessage(messageController.text);
                  setState(() {
                    messageController.clear();
                  });
                }
              },
            ),
          ],
        ),
      );
  }
}

class _ChatBubble extends StatefulWidget {
  final Message messages;
  final bool isMe;
  final Color color;

  const _ChatBubble({
    required this.messages,
    required this.isMe,
    required this.color,
  });

  @override
  State<_ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<_ChatBubble>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    // final maxWidth = MediaQuery.of(context).size.width * .78;
    final maxWidth = MediaQuery.of(context).size.width * .65;

    final bubbleColor = widget.isMe
        ? null
        : Colors.white;

    final textColor = widget.isMe
        ? Colors.white
        : Colors.black87;

    final time = widget.messages.createAt != null
        ? DateFormat("HH:mm").format(widget.messages.createAt!)
        : "";

    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween(
          begin: Offset(
            widget.isMe ? .25 : -.25,
            0,
          ),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOut,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          child: Row(
            mainAxisAlignment: widget.isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              if (!widget.isMe)
                Padding(
                  padding: const EdgeInsets.only(
                    right: 8,
                  ),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: const NetworkImage(
                      "https://avatars.githubusercontent.com/u/144583426?v=4",
                    ),
                  ),
                ),

              Flexible(
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: widget.isMe
                        ? const LinearGradient(
                            colors: [
                              Color(0xff2563EB),
                              Color(0xff3B82F6),
                            ],
                          )
                        : null,
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft:
                          Radius.circular(widget.isMe ? 24 : 8),
                      topRight:
                          Radius.circular(widget.isMe ? 8 : 24),
                      bottomLeft:
                          const Radius.circular(24),
                      bottomRight:
                          const Radius.circular(24),
                    ),
                    border: widget.isMe
                        ? null
                        : Border.all(
                            color: Colors.grey.shade200,
                          ),
                    boxShadow: [

                      if (!widget.isMe)
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),

                      if (widget.messages.isStreaming)
                        BoxShadow(
                          color: Colors.blue.withOpacity(.25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      SelectableText(
                        widget.messages.message,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),

                      if (widget.messages.isStreaming)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                          ),
                          child: Row(
                            children: [

                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),

                              const SizedBox(width: 6),

                              Text(
                                "Generating...",
                                style: TextStyle(
                                  color: textColor.withOpacity(.7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.isMe
                                ? Colors.white70
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class TypingStatus extends StatefulWidget {
  const TypingStatus({super.key});

  @override
  State<TypingStatus> createState() => _TypingStatusState();
}

class _TypingStatusState extends State<TypingStatus> {
  bool showCursor = true;

  @override
  void initState() {
    super.initState();

    Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          showCursor = !showCursor;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.edit_note_rounded,
          color: Colors.orangeAccent,
          size: 14,
        ),

        const SizedBox(width: 4),

        Flexible(
          child: Text(
            "Thinking...",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),

        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: showCursor ? 1 : 0,
          child: const Text(
            "▌",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}