import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'Data.dart';

class UmrahTutorialPage extends StatefulWidget {
  @override
  _UmrahTutorialPageState createState() => _UmrahTutorialPageState();
}

class _UmrahTutorialPageState extends State<UmrahTutorialPage> {
  final PageController _controller = PageController();
  bool onLastPage = false;
  final List<Map<String, String>> umrahSteps = Other.umrahSteps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: umrahSteps.length,
            onPageChanged: (index) {
              setState(() => onLastPage = index == umrahSteps.length - 1);
            },
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(24),
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      umrahSteps[index]['title']!,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    Text(
                      umrahSteps[index]['description']!,
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: umrahSteps.length,
                  effect: WormEffect(dotHeight: 12, dotWidth: 12),
                ),
                SizedBox(height: 20),
                if (onLastPage)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // or navigate somewhere else
                    },
                    child: Text('Done'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
