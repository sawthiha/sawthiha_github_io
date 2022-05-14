part of 'main.dart';

class HomeController  extends GetxController  {

  final _scrollProgress = 0.0.obs;
  set scrollProgress(double progress)  {
    _scrollProgress.value = progress;
  }

}
