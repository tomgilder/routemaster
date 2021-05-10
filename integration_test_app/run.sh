chromedriver --port=4444 &
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/replace_hash_test.dart -d web-server || { kill $!; exit 1;}
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/replace_path_test.dart -d web-server || { kill $!; exit 1;}