/**
 * 全局窗帘状态管理器
 * 使用 AppStorageManager 实现跨组件共享状态，支持动画效果
 */
import { promptAction } from '@kit.ArkUI';
import { AppStorageManager } from '../datastore_app/AppStorageManager';

const CURTAIN_POSITION_KEY = 'curtainPosition';
const CURTAIN_STATE_KEY = 'curtainState';
const SCREEN_POSITION_KEY = 'screenPosition';
const SCREEN_STATE_KEY = 'screenState';

export class CurtainState {
  opening: boolean = false;
  closing: boolean = false;
  paused: boolean = false;

  constructor(opening: boolean = false, closing: boolean = false, paused: boolean = false) {
    this.opening = opening;
    this.closing = closing;
    this.paused = paused;
  }
}

export class CurtainStateManager {
  private static curtainTimer: number = 0;
  private static screenTimer: number = 0;

  static init(): void {
    if (!AppStorageManager.has(CURTAIN_POSITION_KEY)) {
      AppStorageManager.setOrCreate(CURTAIN_POSITION_KEY, 0);
    }
    if (!AppStorageManager.has(CURTAIN_STATE_KEY)) {
      const defaultState = new CurtainState();
      AppStorageManager.setOrCreate(CURTAIN_STATE_KEY, defaultState);
    }
    if (!AppStorageManager.has(SCREEN_POSITION_KEY)) {
      AppStorageManager.setOrCreate(SCREEN_POSITION_KEY, 0);
    }
    if (!AppStorageManager.has(SCREEN_STATE_KEY)) {
      const defaultState = new CurtainState();
      AppStorageManager.setOrCreate(SCREEN_STATE_KEY, defaultState);
    }
  }

  static getCurtainPosition(): number {
    CurtainStateManager.init();
    const result: number | undefined = AppStorageManager.get<number>(CURTAIN_POSITION_KEY);
    return result || 0;
  }

  static setCurtainPosition(position: number): void {
    const clamped = Math.max(0, Math.min(100, position));
    AppStorageManager.setOrCreate(CURTAIN_POSITION_KEY, clamped);
  }

  static getCurtainState(): CurtainState {
    CurtainStateManager.init();
    const state: CurtainState | undefined = AppStorageManager.get<CurtainState>(CURTAIN_STATE_KEY);
    if (state) {
      return state;
    }
    const defaultState = new CurtainState();
    return defaultState;
  }

  static setCurtainState(state: CurtainState): void {
    AppStorageManager.setOrCreate(CURTAIN_STATE_KEY, state);
  }

  static getScreenPosition(): number {
    CurtainStateManager.init();
    const result: number | undefined = AppStorageManager.get<number>(SCREEN_POSITION_KEY);
    return result || 0;
  }

  static setScreenPosition(position: number): void {
    const clamped = Math.max(0, Math.min(100, position));
    AppStorageManager.setOrCreate(SCREEN_POSITION_KEY, clamped);
  }

  static getScreenState(): CurtainState {
    CurtainStateManager.init();
    const state: CurtainState | undefined = AppStorageManager.get<CurtainState>(SCREEN_STATE_KEY);
    if (state) {
      return state;
    }
    const defaultState = new CurtainState();
    return defaultState;
  }

  static setScreenState(state: CurtainState): void {
    AppStorageManager.setOrCreate(SCREEN_STATE_KEY, state);
  }

  static openAll(): void {
    CurtainStateManager.openCurtain();
    CurtainStateManager.openScreen();
  }

  static closeAll(): void {
    CurtainStateManager.closeCurtain();
    CurtainStateManager.closeScreen();
  }

  static openCurtain(): void {
    CurtainStateManager.stopCurtainAnimation();
    const newState = new CurtainState(true, false, false);
    CurtainStateManager.setCurtainState(newState);
    CurtainStateManager.startCurtainAnimation(true);
  }

  static closeCurtain(): void {
    CurtainStateManager.stopCurtainAnimation();
    const newState = new CurtainState(false, true, false);
    CurtainStateManager.setCurtainState(newState);
    CurtainStateManager.startCurtainAnimation(false);
  }

  static pauseCurtain(): void {
    CurtainStateManager.stopCurtainAnimation();
    const currentState = CurtainStateManager.getCurtainState();
    const newState = new CurtainState(currentState.opening, currentState.closing, true);
    CurtainStateManager.setCurtainState(newState);
    promptAction.showToast({ message: '窗帘已暂停' });
  }

  static resumeCurtain(): void {
    const currentState = CurtainStateManager.getCurtainState();
    if (currentState.paused) {
      const newState = new CurtainState(currentState.opening, currentState.closing, false);
      CurtainStateManager.setCurtainState(newState);
      CurtainStateManager.startCurtainAnimation(currentState.opening);
    }
  }

  static openScreen(): void {
    CurtainStateManager.stopScreenAnimation();
    const newState = new CurtainState(true, false, false);
    CurtainStateManager.setScreenState(newState);
    CurtainStateManager.startScreenAnimation(true);
  }

  static closeScreen(): void {
    CurtainStateManager.stopScreenAnimation();
    const newState = new CurtainState(false, true, false);
    CurtainStateManager.setScreenState(newState);
    CurtainStateManager.startScreenAnimation(false);
  }

  static pauseScreen(): void {
    CurtainStateManager.stopScreenAnimation();
    const currentState = CurtainStateManager.getScreenState();
    const newState = new CurtainState(currentState.opening, currentState.closing, true);
    CurtainStateManager.setScreenState(newState);
    promptAction.showToast({ message: '纱帘已暂停' });
  }

  static resumeScreen(): void {
    const currentState = CurtainStateManager.getScreenState();
    if (currentState.paused) {
      const newState = new CurtainState(currentState.opening, currentState.closing, false);
      CurtainStateManager.setScreenState(newState);
      CurtainStateManager.startScreenAnimation(currentState.opening);
    }
  }

  private static startCurtainAnimation(opening: boolean): void {
    const step = opening ? 2 : -2;
    CurtainStateManager.curtainTimer = setInterval(() => {
      const current = CurtainStateManager.getCurtainPosition();
      let next = current + step;

      if (next >= 100) {
        next = 100;
        CurtainStateManager.stopCurtainAnimation();
        const state = new CurtainState();
        CurtainStateManager.setCurtainState(state);
        promptAction.showToast({ message: '窗帘已完全打开' });
      } else if (next <= 0) {
        next = 0;
        CurtainStateManager.stopCurtainAnimation();
        const state = new CurtainState();
        CurtainStateManager.setCurtainState(state);
        promptAction.showToast({ message: '窗帘已完全关闭' });
      }

      CurtainStateManager.setCurtainPosition(next);
    }, 50);
  }

  private static stopCurtainAnimation(): void {
    if (CurtainStateManager.curtainTimer !== 0) {
      clearInterval(CurtainStateManager.curtainTimer);
      CurtainStateManager.curtainTimer = 0;
    }
  }

  private static startScreenAnimation(opening: boolean): void {
    const step = opening ? 2 : -2;
    CurtainStateManager.screenTimer = setInterval(() => {
      const current = CurtainStateManager.getScreenPosition();
      let next = current + step;

      if (next >= 100) {
        next = 100;
        CurtainStateManager.stopScreenAnimation();
        const state = new CurtainState();
        CurtainStateManager.setScreenState(state);
        promptAction.showToast({ message: '纱帘已完全打开' });
      } else if (next <= 0) {
        next = 0;
        CurtainStateManager.stopScreenAnimation();
        const state = new CurtainState();
        CurtainStateManager.setScreenState(state);
        promptAction.showToast({ message: '纱帘已完全关闭' });
      }

      CurtainStateManager.setScreenPosition(next);
    }, 50);
  }

  private static stopScreenAnimation(): void {
    if (CurtainStateManager.screenTimer !== 0) {
      clearInterval(CurtainStateManager.screenTimer);
      CurtainStateManager.screenTimer = 0;
    }
  }
}