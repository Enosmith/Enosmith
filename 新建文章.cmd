@echo off
set /p filename=请输入文章名称：
hexo new post %filename%
echo 新建文章成功
pause
