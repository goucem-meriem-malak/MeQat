import 'package:flutter/material.dart';
import 'package:meqat/Data.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HajjTutorialPage extends StatefulWidget {
  @override
  _HajjTutorialPageState createState() => _HajjTutorialPageState();
}

class _HajjTutorialPageState extends State<HajjTutorialPage> {
  final PageController _controller = PageController();
  bool onLastPage = false;
  final List<Map<String, String>> hajjSteps = Other.hajjSteps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: hajjSteps.length,
            onPageChanged: (index) {
              setState(() => onLastPage = index == hajjSteps.length - 1);
            },
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(24),
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hajjSteps[index]['title']!,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    Text(
                      hajjSteps[index]['description']!,
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          // Indicator + Done button
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: hajjSteps.length,
                  effect: WormEffect(dotHeight: 12, dotWidth: 12),
                ),
                SizedBox(height: 20),
                if (onLastPage)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // or move to another page
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
