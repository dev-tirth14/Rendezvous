import 'package:Event_Finder_App/msc/theme.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroScreen extends StatefulWidget {
  Function callback;
  IntroScreen({this.callback, Key key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();
  void _onIntroEnd() {
    widget.callback();
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    PageDecoration pageDecoration =  PageDecoration(
      boxDecoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: light),
      titleTextStyle: TextStyle(
        color: dark,
        fontSize: 28.0, 
        fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      contentPadding: EdgeInsets.all(0),
    
      imagePadding: EdgeInsets.zero,
    );

    return Center(
      child: Container(
        
        padding: EdgeInsets.only(top:70,bottom: 70,right: 30,left: 30),
        decoration: BoxDecoration(
          color: dark,),
        child: IntroductionScreen(
          globalBackgroundColor: dark,
          
          key: introKey,
          pages: [
            PageViewModel(
              title: "Welcome",
              bodyWidget: Container(
                height: MediaQuery.of(context).size.height*0.6,
                child: new Image(
                  image: AssetImage("assets/img/IntroHome.png"),
                  fit: BoxFit.contain,
                ),
              ),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Welcome",
              bodyWidget: Container(
                height: MediaQuery.of(context).size.height*0.6,
                child: new Image(
                  image: AssetImage("assets/img/IntroMoreInfo.png"),
                  fit: BoxFit.contain,
                ),
              ),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Welcome",
              bodyWidget: Container(
                height: MediaQuery.of(context).size.height*0.6,
                child: new Image(
                  image: AssetImage("assets/img/IntroMyEvents.png"),
                  fit: BoxFit.contain,
                ),
              ),
              decoration: pageDecoration,
            ),
            
          ],
          onDone: () => _onIntroEnd(),
          //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
          showSkipButton: true,
          skipFlex: 0,
          nextFlex: 0,
          skip: const Text('Skip'),
          next: const Icon(Icons.arrow_forward),
          done:
              const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
          dotsDecorator: DotsDecorator(
            size: Size(10.0, 10.0),
            color: lighterRed,
            activeSize: Size(22.0, 10.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
        ),
      ),
    );
    
  }
}
