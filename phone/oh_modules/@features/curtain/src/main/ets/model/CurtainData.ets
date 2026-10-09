/**
 * 窗帘数据模型 - 使用 v2 装饰器
 */
@ObservedV2
export class CurtainData {
  @Trace curtainPosition: number = 0;
  @Trace curtainOpening: boolean = false;
  @Trace curtainClosing: boolean = false;
  @Trace curtainPaused: boolean = false;

  @Trace screenPosition: number = 0;
  @Trace screenOpening: boolean = false;
  @Trace screenClosing: boolean = false;
  @Trace screenPaused: boolean = false;

  openCurtain(): void {
    this.curtainOpening = true;
    this.curtainClosing = false;
    this.curtainPaused = false;
  }

  closeCurtain(): void {
    this.curtainClosing = true;
    this.curtainOpening = false;
    this.curtainPaused = false;
  }

  pauseCurtain(): void {
    this.curtainPaused = !this.curtainPaused;
  }

  openScreen(): void {
    this.screenOpening = true;
    this.screenClosing = false;
    this.screenPaused = false;
  }

  closeScreen(): void {
    this.screenClosing = true;
    this.screenOpening = false;
    this.screenPaused = false;
  }

  pauseScreen(): void {
    this.screenPaused = !this.screenPaused;
  }

  openAll(): void {
    this.openCurtain();
    this.openScreen();
  }

  closeAll(): void {
    this.closeCurtain();
    this.closeScreen();
  }
}
