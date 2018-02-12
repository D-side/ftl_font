@echo off
echo 'Setting up tools. Hang tight, this might take a minute or so.'
call gem install bundler
call bundle install
echo 'If there are no errors above, then the setup went well.'
pause
