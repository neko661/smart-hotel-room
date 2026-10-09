# 智慧客房项目架构说明

## 项目结构

```
E:\MyApplication3/
├── products/phone/              # 手机端产品配置
├── commons/                     # 公共能力层（全局通用底座）
│   ├── datastore/              # 数据持久化模块
│   │   ├── src/main/ets/
│   │   │   ├── AppStorageManager.ets    # AppStorage管理器
│   │   │   ├── PersistenceV2Manager.ets # 持久化存储管理器
│   │   │   ├── PreferencesUtil.ets      # 首选项工具
│   │   │   ├── SessionManager.ets       # 会话管理器
│   │   │   └── StorageKeys.ets          # 存储键常量
│   │   └── oh-package.json5
│   ├── network/                # 网络请求模块
│   │   ├── src/main/ets/
│   │   │   ├── HttpClient.ets           # HTTP客户端
│   │   │   ├── ApiService.ets           # API服务封装
│   │   │   └── AppConfig.ets            # 应用配置
│   │   └── oh-package.json5
│   ├── uicomponents/           # 基础UI组件模块
│   │   ├── src/main/ets/
│   │   │   ├── AppButton.ets            # 按钮组件
│   │   │   ├── AppLoading.ets           # 加载组件
│   │   │   ├── AppTextInput.ets         # 输入框组件
│   │   │   ├── AppTitleBar.ets          # 标题栏组件
│   │   │   └── ResponsiveLayout.ets     # 响应式布局
│   │   └── oh-package.json5
│   └── utils/                  # 通用工具函数模块
│       ├── src/main/ets/
│       │   ├── DateUtil.ets             # 日期工具
│       │   ├── DeviceUtil.ets           # 设备工具
│       │   ├── Logger.ets               # 日志工具
│       │   ├── ResponsiveUtil.ets       # 响应式工具
│       │   ├── StringUtil.ets           # 字符串工具
│       │   └── ValidationUtil.ets        # 验证工具
│       └── oh-package.json5
├── features/                    # 业务功能模块
│   ├── login/                  # 登录模块
│   │   ├── src/main/ets/
│   │   │   ├── model/AuthData.ets
│   │   │   ├── viewmodel/AuthViewModel.ets
│   │   │   └── view/LoginPage.ets
│   │   └── oh-package.json5
│   ├── home/                   # 首页模块
│   │   ├── src/main/ets/
│   │   │   ├── model/HomeData.ets
│   │   │   ├── viewmodel/HomeViewModel.ets
│   │   │   ├── view/HomePage.ets
│   │   │   └── view/components/
│   │   │       ├── AirConditionerPanel.ets
│   │   │       ├── SceneModePanel.ets
│   │   │       └── NightModePanel.ets
│   │   └── oh-package.json5
│   ├── light/                  # 灯光控制模块
│   │   ├── src/main/ets/
│   │   │   ├── model/LightData.ets
│   │   │   ├── viewmodel/LightViewModel.ets
│   │   │   └── view/LightControlPage.ets
│   │   └── oh-package.json5
│   ├── curtain/                # 窗帘控制模块
│   │   ├── src/main/ets/
│   │   │   ├── model/CurtainData.ets
│   │   │   ├── viewmodel/CurtainViewModel.ets
│   │   │   └── view/CurtainControlPage.ets
│   │   └── oh-package.json5
│   └── service/                # 客房服务模块
│       ├── src/main/ets/
│       │   ├── model/ServiceData.ets
│       │   ├── viewmodel/ServiceViewModel.ets
│       │   └── view/ServiceControlPage.ets
│       └── oh-package.json5
└── phone/                       # 手机端主运行入口
    ├── src/main/ets/
    │   ├── entryability/EntryAbility.ets    # 应用启动入口
    │   └── pages/AppNavigation.ets          # 全局路由导航
    ├── build-profile.json5
    └── oh-package.json5
```

## 架构设计原则

1. **分层清晰**
   - 公共能力层（commons）：全局通用底座，无业务依赖
   - 业务功能层（features）：独立的功能模块，高内聚低耦合
   - 产品入口层（phone）：主运行入口，负责路由和生命周期

2. **模块独立**
   - 每个功能模块（login/home/light/curtain/service）独立开发、测试
   - 模块间通过依赖注入通信，降低耦合

3. **代码复用**
   - 公共组件、工具函数统一管理在commons层
   - 避免重复代码，提高开发效率

## 依赖关系

```
phone (主入口)
  ├─→ commons/datastore
  ├─→ commons/utils
  ├─→ commons/uicomponents
  ├─→ features/login
  ├─→ features/home
  ├─→ features/light
  ├─→ features/curtain
  └─→ features/service

features/* (业务模块)
  ├─→ commons/datastore
  ├─→ commons/utils
  ├─→ commons/uicomponents
  └─→ commons/network

commons/network
  └─→ commons/datastore

commons/uicomponents
  └─→ commons/utils
```

## 迁移说明

原项目结构已重构为新架构，主要变化：

1. `common/` → `commons/` 拆分为多个子模块
2. `feature/` → `features/` 按业务功能独立拆分
3. `entry/` → `phone/` 作为主入口模块
4. 新增 `products/phone/` 作为产品配置目录

所有原有功能保持不变，仅调整了代码组织结构。
