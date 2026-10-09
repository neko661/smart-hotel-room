# 复制资源文件脚本
$sourceDir = "E:\MyApplication3\product\default\src\main\resources\base\media"
$targetDir = "E:\MyApplication3\phone\src\main\resources\base\media"

# 确保目标目录存在
if (!(Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force
}

# 复制 startIcon.png 为 app_icon.png
Copy-Item "$sourceDir\startIcon.png" "$targetDir\app_icon.png" -Force

# 复制所有其他资源文件
Get-ChildItem -Path $sourceDir -Filter "*.png" | ForEach-Object {
    Copy-Item $_.FullName "$targetDir\$($_.Name)" -Force
}

Get-ChildItem -Path $sourceDir -Filter "*.jpg" | ForEach-Object {
    Copy-Item $_.FullName "$targetDir\$($_.Name)" -Force
}

Get-ChildItem -Path $sourceDir -Filter "*.webp" | ForEach-Object {
    Copy-Item $_.FullName "$targetDir\$($_.Name)" -Force
}

Write-Host "资源文件复制完成！" -ForegroundColor Green
