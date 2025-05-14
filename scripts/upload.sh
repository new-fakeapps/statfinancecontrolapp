#!/bin/bash

sh make.sh -u --no-open
cd ../

echo "⚙️  Building"

bundle install
MATCH_PASSWORD=Testflight228! bundle exec fastlane uploadSync schemes:"FinanceManager"
