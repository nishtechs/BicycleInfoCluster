import 'package:deepseek_api/deepseek_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';


//OpenAI Key
//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
//OpenAI Key


class Deepseek extends StatelessWidget {
  const Deepseek({super.key});

  @override
  Widget build(BuildContext context) {
    return const BicycleComputerScreen();
  }
}

class BicycleComputerScreen extends StatefulWidget {
  const BicycleComputerScreen({super.key});

  @override
  _BicycleComputerScreenState createState() => _BicycleComputerScreenState();
}

class _BicycleComputerScreenState extends State<BicycleComputerScreen> {
  final TextEditingController _textController = TextEditingController();
  String _displayText = '';

  @override
  void initState() {
    super.initState();
  }

  String resp = "";

  final deepseek = DeepSeekAPI(
    apiKey: 'sk-a33aab42c73244e6afc5ca2e3cb1dbb7',
    // Optional: baseUrl: 'https://api.deepseek.com/v1' (default)
  );

  callDeepseek(String query) async {
    final response = await deepseek.createChatCompletion(
      ChatCompletionRequest(
        model: 'deepseek-chat',
        messages: [ChatMessage(role: 'user', content: query)],
        temperature: 0.7,
        maxTokens: 100,
      ),
    );

    setState(() {
      resp = response.choices.first.message.content;
    });
    // print(response.choices.first.message.content);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void submitText() {
      setState(() {
        _displayText = _textController.text;
      });
      callDeepseek(_displayText);
    }

    return Scaffold(
      backgroundColor: Colors.blueAccent[100],
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Deepseek Page',
          style: GoogleFonts.poppins(fontSize: 25.sp, fontWeight: FontWeight.w600, fontFeatures: [const FontFeature.alternativeFractions()], color: Colors.black),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: resp,
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: submitText,
                  child: const Text('Submit'),
                ),
                SizedBox(height: 20.h),
                Text(
                  _displayText,
                  style: TextStyle(fontSize: 18.sp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
