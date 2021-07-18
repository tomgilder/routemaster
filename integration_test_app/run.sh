cd "$(dirname "$0")"
killall chromedriver
chromedriver --port=4444 &
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/navigation_hash_test.dart -d web-server || { kill $!; exit 1;}
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/navigation_path_test.dart -d web-server || { kill $!; exit 1;}