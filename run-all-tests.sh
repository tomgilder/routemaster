#!/bin/bash
set -e

flutter test
flutter test --platform chrome
integration_test_app/run.sh

cd example/book_store
flutter test

cd ../..
cd example/mobile_app
flutter test