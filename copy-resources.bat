@echo off
echo 正在复制资源文件...

xcopy "E:\MyApplication3\product\default\src\main\resources\base\media\*" "E:\MyApplication3\phone\src\main\resources\base\media\" /E /Y

copy "E:\MyApplication3\product\default\src\main\resources\base\media\startIcon.png" "E:\MyApplication3\phone\src\main\resources\base\media\app_icon.png" /Y

echo 资源文件复制完成！
pause
