@echo off
echo Copying images to frontend/images...
if not exist "frontend\images" mkdir "frontend\images"
copy /Y "images\*.png" "frontend\images\"
echo Done! Images copied to frontend/images/
pause

