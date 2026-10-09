/**
 * 应用导航 - 基于 Navigation + NavPathStack 的路由容器
 */
import { LoginPage } from '@features/login/src/main/ets';
import { HomePage as HomeFeaturePage } from '@features/home/src/main/ets';
import { LightControlPage } from '@features/light/src/main/ets';
import { CurtainControlPage } from '@features/curtain/src/main/ets';
import { ServiceControlPage } from '@features/service/src/main/ets';
import { SessionManager } from '@commons/datastore/src/main/ets/datastore_app/SessionManager';

// Tab条目信息
interface TabItem {
  name: string;
  icon: Resource;
  iconSelected: Resource;
  routeName: RouteName;
}

type RouteName = 'LoginPage' | 'HomePage' | 'LightControlPage' | 'CurtainControlPage' | 'ServiceControlPage';

const LOGIN_ROUTE: RouteName = 'LoginPage';
const HOME_ROUTE: RouteName = 'HomePage';

const TAB_ITEMS: TabItem[] = [
  {
    name: '首页',
    icon: $r('app.media.tabs_icon_home_unselect'),
    iconSelected: $r('app.media.tabs_icon_home_select'),
    routeName: HOME_ROUTE
  },
  {
    name: '灯光',
    icon: $r('app.media.tabs_icon_light_unselect'),
    iconSelected: $r('app.media.tabs_icon_light_select'),
    routeName: 'LightControlPage'
  },
  {
    name: '窗帘',
    icon: $r('app.media.tabs_icon_curtain_unselect'),
    iconSelected: $r('app.media.tabs_icon_curtain_select'),
    routeName: 'CurtainControlPage'
  },
  {
    name: '服务',
    icon: $r('app.media.tabs_icon_service_unselect'),
    iconSelected: $r('app.media.tabs_icon_service_select'),
    routeName: 'ServiceControlPage'
  }
];

@ComponentV2
struct LoginRoutePage {
  @Event onLoginSuccess: () => void = () => {};

  build() {
    LoginPage({
      navigateToHome: (): void => {
        this.onLoginSuccess();
      }
    })
  }
}

@ComponentV2
struct ServiceRoutePage {
  @Event onLogoutSuccess: () => void = () => {};

  build() {
    ServiceControlPage({
      onLogout: (): void => {
        this.onLogoutSuccess();
      }
    })
  }
}

@Entry
@ComponentV2
struct AppNavigation {
  private pathStack: NavPathStack = new NavPathStack();
  @Local currentRoute: RouteName = LOGIN_ROUTE;

  aboutToAppear(): void {
    this.syncInitialRoute();
  }

  private syncInitialRoute(): void {
    const targetRoute: RouteName = SessionManager.getSession() !== null ? HOME_ROUTE : LOGIN_ROUTE;
    this.currentRoute = targetRoute;
    if (this.pathStack.size() === 0) {
      this.pathStack.pushPath({ name: targetRoute });
      return;
    }
    this.pathStack.replacePath({ name: targetRoute });
  }

  private navigateToRoute(routeName: RouteName): void {
    if (this.currentRoute === routeName && this.pathStack.size() > 0) {
      return;
    }
    this.currentRoute = routeName;
    if (this.pathStack.size() === 0) {
      this.pathStack.pushPath({ name: routeName });
      return;
    }
    this.pathStack.replacePath({ name: routeName });
  }

  private getCurrentTabIndex(): number {
    const currentIndex = TAB_ITEMS.findIndex(item => item.routeName === this.currentRoute);
    return currentIndex >= 0 ? currentIndex : 0;
  }

  @Builder
  private routeMap(name: string) {
    if (name === LOGIN_ROUTE) {
      NavDestination() {
        LoginRoutePage({
          onLoginSuccess: (): void => {
            this.navigateToRoute(HOME_ROUTE);
          }
        })
      }
      .hideTitleBar(true)
      .hideBackButton(true);
    } else if (name === HOME_ROUTE) {
      NavDestination() {
        HomeFeaturePage()
      }
      .hideTitleBar(true)
      .hideBackButton(true);
    } else if (name === 'LightControlPage') {
      NavDestination() {
        LightControlPage()
      }
      .hideTitleBar(true)
      .hideBackButton(true);
    } else if (name === 'CurtainControlPage') {
      NavDestination() {
        CurtainControlPage()
      }
      .hideTitleBar(true)
      .hideBackButton(true);
    } else if (name === 'ServiceControlPage') {
      NavDestination() {
        ServiceRoutePage({
          onLogoutSuccess: (): void => {
            this.navigateToRoute(LOGIN_ROUTE);
          }
        })
      }
      .hideTitleBar(true)
      .hideBackButton(true);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Navigation(this.pathStack) {
      }
      .hideNavBar(true)
      .mode(NavigationMode.Stack)
      .navDestination(this.routeMap)
      .width('100%')
      .height('100%');

      if (this.currentRoute !== LOGIN_ROUTE) {
        this.buildCustomTabBar()
      }
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  buildCustomTabBar() {
    Row({ space: 0 }) {
      ForEach(TAB_ITEMS, (item: TabItem, index: number) => {
        Button() {
          Column({ space: 3 }) {
            Image(this.getCurrentTabIndex() === index ? item.iconSelected : item.icon)
              .width(28)
              .height(28);
            Text(item.name)
              .fontSize(11)
              .fontColor(this.getCurrentTabIndex() === index ? '#D4AF37' : '#FFFFFF');
          }
          .width('100%')
          .height(65)
          .justifyContent(FlexAlign.Center);
        }
        .width('25%')
        .height(65)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.navigateToRoute(item.routeName);
        });
      })
    }
    .width('95%')
    .height(65)
    .backgroundColor('rgba(0, 0, 0, 0.70)')
    .borderRadius(32)
    .margin({ bottom: 10, left: '2.5%', right: '2.5%' });
  }
}

// 路由表入口函数
@Builder
export function LoginPageBuilder() {
  NavDestination() {
    LoginRoutePage()
  }
  .hideTitleBar(true)
  .hideBackButton(true);
}

@Builder
export function HomePageBuilder() {
  NavDestination() {
    HomeFeaturePage()
  }
  .hideTitleBar(true)
  .hideBackButton(true);
}

@Builder
export function LightControlPageBuilder() {
  NavDestination() {
    LightControlPage()
  }
  .hideTitleBar(true)
  .hideBackButton(true);
}

@Builder
export function CurtainControlPageBuilder() {
  NavDestination() {
    CurtainControlPage()
  }
  .hideTitleBar(true)
  .hideBackButton(true);
}

@Builder
export function ServiceControlPageBuilder() {
  NavDestination() {
    ServiceRoutePage()
  }
  .hideTitleBar(true)
  .hideBackButton(true);
}
