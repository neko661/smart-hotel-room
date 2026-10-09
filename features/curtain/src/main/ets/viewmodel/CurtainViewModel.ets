/**
 * 窗帘视图模型
 */
import { CurtainStateManager } from '@commons/datastore/src/main/ets/datastore_feature_device/CurtainStateManager';

export class CurtainViewModel {
  curtainPosition: number = 0;
  curtainOpening: boolean = false;
  curtainClosing: boolean = false;
  curtainPaused: boolean = false;

  screenPosition: number = 0;
  screenOpening: boolean = false;
  screenClosing: boolean = false;
  screenPaused: boolean = false;

  constructor() {
    CurtainStateManager.init();
  }

  openAll(): void {
    CurtainStateManager.openAll();
  }

  closeAll(): void {
    CurtainStateManager.closeAll();
  }

  openCurtain(): void {
    CurtainStateManager.openCurtain();
  }

  closeCurtain(): void {
    CurtainStateManager.closeCurtain();
  }

  pauseCurtain(): void {
    CurtainStateManager.pauseCurtain();
  }

  openScreen(): void {
    CurtainStateManager.openScreen();
  }

  closeScreen(): void {
    CurtainStateManager.closeScreen();
  }

  pauseScreen(): void {
    CurtainStateManager.pauseScreen();
  }
}