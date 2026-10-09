/**
 * 应用入口 - EntryAbility
 */
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { PreferencesUtil } from '@commons/datastore/src/main/ets/datastore_base/PreferencesUtil';
import { PersistenceV2Manager } from '@commons/datastore/src/main/ets/datastore_base/PersistenceV2Manager';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'EntryAbility', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'EntryAbility', 'onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'EntryAbility', 'onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'EntryAbility', 'onWindowStageCreate');
    void this.startApp(windowStage);
  }

  private async startApp(windowStage: window.WindowStage): Promise<void> {
    await this.initAsync();
    windowStage.loadContent('pages/navigation/AppNavigation', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'EntryAbility', 'Failed to load. Code: %{public}d, msg: %{public}s', err.code, err.message);
        return;
      }
      hilog.info(DOMAIN, 'EntryAbility', 'Succeeded in loading the content.');
    });
  }

  private async initAsync(): Promise<void> {
    try {
      await PreferencesUtil.init(this.context);
      hilog.info(DOMAIN, 'EntryAbility', 'PreferencesUtil initialized');
    } catch (err) {
      hilog.error(DOMAIN, 'EntryAbility', 'PreferencesUtil init failed: %{public}s', JSON.stringify(err));
    }

    try {
      await PersistenceV2Manager.init(this.context);
      hilog.info(DOMAIN, 'EntryAbility', 'PersistenceV2Manager initialized');
    } catch (err) {
      hilog.error(DOMAIN, 'EntryAbility', 'PersistenceV2Manager init failed: %{public}s', JSON.stringify(err));
    }
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'EntryAbility', 'onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'EntryAbility', 'onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'EntryAbility', 'onBackground');
  }
}
