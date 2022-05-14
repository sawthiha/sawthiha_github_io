import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'config.dart';
part 'bindings.dart';
part 'controller.dart';
part 'theme.dart';

void main() {
  HomeBindings().dependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Saw\'s Website',
      theme: themeData,
      home: Home(),
    );
  }
}

class Home extends HookWidget  {

  final controller = Get.find<HomeController>();

  Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    useEffect(
      ()  {
        void onScrollUpdated()  {
          controller.scrollProgress = scrollController.position.extentBefore / (scrollController.position.extentBefore + scrollController.position.extentAfter);
        }
        scrollController.addListener(onScrollUpdated);
        return ()  {
          scrollController.removeListener(onScrollUpdated);
        };
      }
    );
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: Get.size.height,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  SizedBox.fromSize(
                    size: Get.size,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xff303030),
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Wrap(
                              direction: Axis.vertical,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const CircleAvatar(
                                  backgroundImage: AssetImage('assets/profile.jpg'),
                                  radius: 125,
                                ),
                                const Padding(padding: EdgeInsets.only(top: 21.0)),
                                const Text('Saw Thiha',
                                  style: TextStyle(
                                    fontSize: 69,
                                    color: ColorPalette.contrast,
                                  ),
                                ),
                                const Text('Software Engineer',
                                  style: TextStyle(
                                    fontSize: 34,
                                    color: ColorPalette.contrast,
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.only(top: 27.0)),
                                Wrap(
                                  direction: Axis.horizontal,
                                  spacing: 21.0,
                                  children: [
                                    for(var entry in Config.socialMediaLinks.entries)
                                      SocialMediaLinkIcon(
                                        iconAsset: entry.value,
                                        link: entry.key,
                                      ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox.fromSize(
                    size: Get.size,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xfffafafa),
                      ),
                      child: Center(
                        child: SizedBox.fromSize(
                          size: const Size(400, 400),
                          child: Container(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox.fromSize(
                    size: Get.size,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xff303030),
                      ),
                    ),
                  ),
                  SizedBox.fromSize(
                    size: Get.size,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xfffafafa),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 34.0),
              child: PageTags(),
            ),
          ),
        ],
      ),
    );
  }

}

class SocialMediaLinkIcon extends StatelessWidget {

  final String iconAsset;
  final String link;

  const SocialMediaLinkIcon({
    Key? key,
    required this.iconAsset,
    required this.link,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrlString(link),
      child: SizedBox.fromSize(
        size: const Size(34.0, 34.0),
        child: Image.asset(iconAsset),
      ),
    );
  }
}

class PageTags extends HookWidget  {

  static const size = Size(160, 266);
  static const tags = <String>['Profile', 'About', 'Academic', 'Projects'];

  final controller = Get.find<HomeController>();

  PageTags({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(
        seconds: 1,
      )
    );
    final selectionAnimation = Tween(
      begin: Offset.zero,
      end: Offset(0.0, (tags.length - 1) * size.height / tags.length)
    ).animate(
     animationController,
    );
    final colorAnimations = [
      ColorTween(
        begin: const Color(0xfffafafa),
        end: const Color(0xff303030),
      ).animate(
        CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.0, 0.33),
        ),
      ),
      ColorTween(
        begin: const Color(0xff303030),
        end: const Color(0xfffafafa),
      ).animate(
        CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.33, 0.66),
        ),
      ),
      ColorTween(
        begin: const Color(0xfffafafa),
        end: const Color(0xff303030),
      ).animate(
        CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.66, 1),
        ),
      ),
    ];
    final colorNotifier = useValueNotifier(const Color(0xfffafafa));
    final offsetNotifier = useValueNotifier(Offset.zero);
    useEffect(
      ()  {
        final sub = controller._scrollProgress.listen(
          (progress)  {
            animationController.value = progress;
          }
        );
        void onSelectionAnimation()  {
          offsetNotifier.value = selectionAnimation.value;
          colorNotifier.value = animationController.value < 0.33 ? colorAnimations[0].value!
            : animationController.value < 0.66 ? colorAnimations[1].value!
            : colorAnimations[2].value!;
        }
        animationController.addListener(onSelectionAnimation);
        return ()  {
          animationController.removeListener(onSelectionAnimation);
          sub.cancel();
        };
      }
    );
    return SizedBox.fromSize(
      size: size,
      child: ValueListenableBuilder<Color>(
        valueListenable: colorNotifier,
        builder: (context, color, _) => ValueListenableBuilder<Offset>(
          valueListenable: offsetNotifier,
          builder: (context, selectionOffset, child) => CustomPaint(
            painter: PageTagsPainter(
              tags: tags,
              selectionOffset: selectionOffset,
              tagColor: color,
            ),
            child: Container(),
            willChange: true,
          ),
        ),
      ),
    );
  }

}

class PageTagsPainter extends CustomPainter  {

  final List<String> tags;
  final Offset selectionOffset;
  final Color tagColor;

  PageTagsPainter({
    required this.tags,
    required this.selectionOffset,
    required this.tagColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = size.height / tags.length;
    canvas.saveLayer(Offset.zero & size, Paint()..color = const Color(0xfffafafa));

      // Draw Tags
      for (var i = 0; i < tags.length; i++) {
        paintTag(tags[i], Offset(0, i * padding), canvas, size);
      }

      canvas.drawRect(selectionOffset & Size(size.width, size.height / tags.length),
        Paint()
          ..color = const Color(0xff0094ff)
          ..blendMode = BlendMode.srcATop
      );
    canvas.restore();
  }

  void paintTag(String text, Offset offset, Canvas canvas, Size size)  {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: tagColor,
          fontSize: 34,
          fontWeight: FontWeight.normal,
        ),
      ),
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr
    )..layout(maxWidth: size.width);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

}
