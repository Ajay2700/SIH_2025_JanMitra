import 'package:get/get.dart';

class CitizenMainController extends GetxController {
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    print('CitizenMainController initialized');
  }

  void changePage(int index) {
    print('Changing page to index: $index');
    currentIndex.value = index;
  }
}
