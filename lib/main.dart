import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
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
                children: const [
                  ProfilePage(),
                  AboutPage(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 34.0),
              child: PageTags(
                tags: const <String>[
                  'Profile',
                  'About',
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class ProjectPage extends StatelessWidget {
  const ProjectPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Get.size,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xfffafafa),
        ),
      ),
    );
  }
}

class AcademicPage extends StatelessWidget {
  const AcademicPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Get.size,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xff303030),
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {

  const AboutPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => FullscreenContainer(
    color: ColorPalette.contrast,
    child: Center(
      child: SizedBox.fromSize(
        size: const Size(400, 400),
        child: Container(),
      ),
    ),
  );
}

class ProfilePage extends StatelessWidget  {

  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => FullscreenContainer(
    color: ColorPalette.primary,
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
  );

}

class FullscreenContainer extends StatelessWidget {

  final Color? color;
  final Widget child;

  const FullscreenContainer({
    Key? key,
    this.color,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox.fromSize(
    size: Get.size,
    child: Container(
      decoration: BoxDecoration(
        color: color,
      ),
      child: child,
    ),
  );
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

extension IntervalOps on Interval  {

  bool contains(double value) =>  value >= begin && value <= end;

}

class IntervalAnimation<T>  {

  final Interval interval;
  final Tween<T> tween;
  final Animation<T> animation;
  final Animation<double> parent;
  final Curve curve;

  IntervalAnimation(
    {
      required this.interval,
      required this.tween,
      required this.parent,
      this.curve = Curves.linear,
    }
  ): animation = tween.animate(
    CurvedAnimation(
      parent: CurvedAnimation(parent: parent, curve: interval),
      curve: curve,
    ),
  );

  T? get value => interval.contains(parent.value) ? animation.value: null;

}

extension IntervalAnimationCompostion<T> on Iterable<IntervalAnimation<T>>  {

  T? get value => map((animation) => animation.value)
    .firstWhere(
      (value) => value != null,
      orElse: () => null,
    );

}

class PageTags extends HookWidget  {

  late final Size size;
  final List<String> tags;
  final double padding;
  final TextStyle style;

  final controller = Get.find<HomeController>();

  PageTags({Key? key,
    required this.tags,
    this.padding = 34.0,
    this.style = const TextStyle(
      fontSize: 34.0,
      fontWeight: FontWeight.normal,
    ),
  }) : super(key: key)  {
    size = _calculateSize();
  }

  Size _calculateSize()  {
    var offset = Offset.zero;
    return PageTagsPainter(
      tags: tags,
      selectionOffset: Offset.zero,
      style: style,
      padding: padding,
    ).textPainters.map(
      (textPainter)  {
        final bound = offset & textPainter.size;
        offset = bound.bottomLeft + Offset(0.0, padding);
        return bound;
      }
    ).reduce((rect1, rect2) => rect1.expandToInclude(rect2)).size;
    
  }

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
    final colorIntervals = [
      IntervalAnimation(
        interval: const Interval(0.0, 1),
        tween: ColorTween(
          begin: ColorPalette.contrast,
          end: ColorPalette.primary
        ),
        parent: animationController,
      ),
    ];
    final colorNotifier = useValueNotifier(colorIntervals.value);
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
          colorNotifier.value = colorIntervals.value;
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
      child: ValueListenableBuilder<Color?>(
        valueListenable: colorNotifier,
        builder: (context, color, _) => ValueListenableBuilder<Offset>(
          valueListenable: offsetNotifier,
          builder: (context, selectionOffset, child) => CustomPaint(
            painter: PageTagsPainter(
              tags: tags,
              selectionOffset: selectionOffset,
              tagColor: color,
              style: style,
              padding: padding,
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
  final Color? tagColor;
  final double padding;
  final TextStyle style;

  PageTagsPainter({
    required this.tags,
    required this.selectionOffset,
    required this.style,
    required this.padding,
    this.tagColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint()..color = const Color(0xfffafafa));

      // Draw Tags
      var offset = Offset.zero;
      for (var textPainter in textPainters) {
        textPainter.paint(canvas, offset);
        offset = (offset & textPainter.size).bottomLeft + Offset(0.0, padding);
      }

      canvas.drawRect(selectionOffset & Size(size.width, size.height / tags.length),
        Paint()
          ..color = const Color(0xff0094ff)
          ..blendMode = BlendMode.srcATop
      );
    canvas.restore();
  }

  Iterable<TextPainter> get textPainters => tags.map(
    (tag) => TextPainter(
      text: TextSpan(
        text: tag,
        style: style.copyWith(
          color: tagColor,
        ),
      ),
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr
    )..layout(
      minWidth: 0.0,
      maxWidth: double.infinity,
    ),
  );

  void paintTag(String text, Offset offset, Canvas canvas, Size size)  {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style.copyWith(
          color: tagColor
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
