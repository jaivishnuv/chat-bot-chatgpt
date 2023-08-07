import 'dart:convert';

import 'package:ai_chat_bot_app/response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController promptController;
  String responseTxt = '';
  late ResponseModel _responseModel;

  @override
  void initState() {
    promptController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff343541),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'F',
              style: GoogleFonts.acme(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            ),
            Text('lutter',
                style: GoogleFonts.akayaKanadaka(
                  color: Colors.white,
                  fontSize: 30,
                )),
            const SizedBox(width: 5),
            Text('G',
                style: GoogleFonts.acme(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold)),
            Text('pt',
                style: GoogleFonts.akayaKanadaka(
                  color: Colors.white,
                  fontSize: 30,
                )),
          ],
        ),
        backgroundColor: const Color(0xff343541),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(children: [
            Expanded(child: PromptBldr(responseTxt: responseTxt)),
            TextFormFieldBldr(
              promptController: promptController,
              btnFun: completionFun,
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> completionFun() async {
    setState(() => responseTxt = 'Loading...');

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.env['token']}'
      },
      body: jsonEncode({
        "model": "text-davinci-003",
        "prompt": promptController.text,
        "max_tokens": 250,
        "temperature": 0,
        "top_p": 1,
      }),
    );

    final responseBody = jsonDecode(response.body);
    print('Response Body: $responseBody');

    final responseModel = ResponseModel.fromJson(responseBody);
    print('Response Model: $responseModel');

    setState(() {
      _responseModel = responseModel;
      responseTxt = _responseModel.text;
      debugPrint(responseTxt);
    });
  }
}

class PromptBldr extends StatelessWidget {
  const PromptBldr({Key? key, required this.responseTxt}) : super(key: key);

  final String responseTxt;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3.5,
      color: const Color(0xff444653),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Text(
              responseTxt,
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 25, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class TextFormFieldBldr extends StatelessWidget {
  const TextFormFieldBldr(
      {Key? key, required this.promptController, required this.btnFun})
      : super(key: key);

  final TextEditingController promptController;
  final Function btnFun;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(left: 2, right: 2, bottom: 50, top: 10),
        child: Row(
          children: [
            Flexible(
              child: TextFormField(
                cursorColor: Colors.white,
                controller: promptController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xff444653),
                    ),
                    borderRadius: BorderRadius.circular(5.5),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xff444653),
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xff444653),
                  hintText: 'Ask me anything!',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Container(
              color: const Color(0xff19bc99),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton(
                  onPressed: () {
                    btnFun();
                  },
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
