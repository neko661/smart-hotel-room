/**
 * 灯光数据模型 - 使用 v2 装饰器
 */
@ObservedV2
export class LightData {
  @Trace lightSwitches: boolean[] = [false, false, false, false, false, false, false, false, false];

  constructor() {
  }

  toggleLight(index: number): void {
    if (index >= 0 && index < this.lightSwitches.length) {
      this.lightSwitches[index] = !this.lightSwitches[index];
    }
  }

  setAllLights(on: boolean): void {
    this.lightSwitches = this.lightSwitches.map(() => on);
  }

  get isAllOn(): boolean {
    return this.lightSwitches.every(switched => switched);
  }

  get isAllOff(): boolean {
    return this.lightSwitches.every(switched => !switched);
  }

  get onLightCount(): number {
    return this.lightSwitches.filter(switched => switched).length;
  }
}
