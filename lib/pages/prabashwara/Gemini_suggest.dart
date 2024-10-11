import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiSuggest extends StatefulWidget {
  final List<String> userPreferences;
  final List<String> matchedPreferences;
  final List<Map<String, int>> LinesWithMultiplePreferences;

  const GeminiSuggest({
    super.key,
    required this.matchedPreferences,
    required this.userPreferences,
    required this.LinesWithMultiplePreferences,
  });

  @override
  State<GeminiSuggest> createState() => _GeminiSuggestState();
}

class _GeminiSuggestState extends State<GeminiSuggest> {
  Gemini gemini = Gemini.instance;

  final ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  final ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage: "https://www.example.com/profile_image.png", // Use a valid image URL
  );

  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    debugReservedPreferences();
  }

  void debugReservedPreferences() {
    print("User Preferences: ${widget.userPreferences}");
    print("LinesWithMultiplePreferences: ${widget.LinesWithMultiplePreferences}");
    print("Matched Preferences: ${widget.matchedPreferences}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: buildUI(),
    );
  }

  Widget buildUI() {
    return Column(
      children: [
        Expanded(
          child: DashChat(
            currentUser: currentUser,
            onSend: onSend,
            messages: messages,
          ),
        ),
        buildSmartReplyButton(),
      ],
    );
  }

  Widget buildSmartReplyButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: suggestNewFoods,
        child: const Text('Suggest New Foods'),
      ),
    );
  }

  void suggestNewFoods() {
    // Create a prompt using user and matched preferences
    String prompt = "Based on the user's preferences: ${widget.userPreferences.join(', ')} "
        "and matched preferences: ${widget.matchedPreferences.join(', ')}, "
        "can you suggest some food options that are not already included in the existing suggestions?";

    // Send the prompt to Gemini
    gemini.streamGenerateContent(prompt).listen((event) {
      String? response = event.content?.parts?.fold("", (previous, current) => "$previous ${current.text}") ?? "";

      if (response != null && response.isNotEmpty) {
        // Create a response message with suggestions
        ChatMessage suggestionMessage = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: response,
        );

        setState(() {
          messages.add(suggestionMessage); // Add the suggestion message to the chat
        });
      } else {
        // Handle case where no suggestions are found
        ChatMessage noSuggestionMessage = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: "I couldn't find any new food suggestions for you.",
        );

        setState(() {
          messages.add(noSuggestionMessage);
        });
      }
    });
  }

  void onSend(ChatMessage message) {
    setState(() {
      messages.add(message);
    });

    try {
      String question = message.text;
      gemini.streamGenerateContent(question).listen((event) {
        String? response = event.content?.parts?.fold("", (previous, current) => "$previous ${current.text}") ?? "";

        if (messages.isNotEmpty && messages.last.user == geminiUser) {
          ChatMessage lastMessage = messages.removeLast();
          lastMessage.text += response;
          setState(() {
            messages.add(lastMessage);
          });
        } else {
          ChatMessage newMessage = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages.add(newMessage);
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
