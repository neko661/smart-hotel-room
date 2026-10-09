/**
 * 服务视图模型
 */
import { ServiceStateManager } from '@commons/datastore/src/main/ets/datastore_service/ServiceStateManager';

export class ServiceViewModel {
  doNotDisturb: boolean = false;
  cleanRoom: boolean = false;

  constructor() {
    ServiceStateManager.init();
  }

  toggleDoNotDisturb(): void {
    ServiceStateManager.toggleDoNotDisturb();
    this.doNotDisturb = ServiceStateManager.getDoNotDisturb();
  }

  toggleCleanRoom(): void {
    ServiceStateManager.toggleCleanRoom();
    this.cleanRoom = ServiceStateManager.getCleanRoom();
  }

  sosCall(): void {
    ServiceStateManager.sosCall();
  }
}
