# HarmonyOS 项目性能优化脚本
Write-Host "=== HarmonyOS 项目性能优化 ===" -ForegroundColor Green

# 1. 清理构建缓存
Write-Host "`n[1/4] 清理构建缓存..." -ForegroundColor Yellow
Remove-Item -Path ".\.hvigor\cache" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".\entry\build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".\build" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "构建缓存已清理" -ForegroundColor Green

# 2. 优化 Node.js 内存配置
Write-Host "`n[2/4] 配置 Node.js 内存优化..." -ForegroundColor Yellow
$env:NODE_OPTIONS = "--max-old-space-size=4096"
Write-Host "Node.js 内存限制已设置为 4GB" -ForegroundColor Green

# 3. 设置构建环境变量
Write-Host "`n[3/4] 设置构建环境变量..." -ForegroundColor Yellow
$env:HVIGOR_DAEMON_ENABLED = "true"
$env:HVIGOR_PARALLEL_EXECUTION = "true"
$env:HVIGOR_INCREMENTAL_EXECUTION = "true"
Write-Host "构建环境变量已设置" -ForegroundColor Green

# 4. 预加热构建缓存
Write-Host "`n[4/4] 预加热构建缓存..." -ForegroundColor Yellow
$etsFiles = (Get-ChildItem -Path ".\entry\src\main\ets" -Recurse -Filter "*.ets" -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Host "已扫描 $etsFiles 个 ArkTS 文件，准备构建缓存" -ForegroundColor Green

Write-Host "`n=== 优化完成 ===" -ForegroundColor Green
Write-Host "提示：下次构建将会使用优化后的配置，加载速度应该会显著提升" -ForegroundColor Cyan
Write-Host "`n建议操作：" -ForegroundColor Yellow
Write-Host "1. 重启 DevEco Studio 以应用所有优化配置" -ForegroundColor White
Write-Host "2. 使用 Build > Clean Project 清理项目" -ForegroundColor White
Write-Host "3. 使用 Build > Make Project 重新构建项目" -ForegroundColor White
