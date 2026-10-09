/**
 * 登录路由页面 - 使用 v2 装饰器
 */
import { LoginPage } from '@features/login/src/main/ets';

@Entry
@ComponentV2
struct LoginPageEntry {
  build() {
    Column() {
      LoginPage({ navigateToHome: () => {
        // 这个回调由 AppNavigation 处理
      }})
    }
    .width('100%')
    .height('100%');
  }
}
