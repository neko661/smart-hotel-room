/**
 * 网络状态监测器
 * 监测网络连接状态变化，通知离线请求管理器
 */
import { connection } from '@kit.NetworkKit';
import { getOfflineRequestManager } from './OfflineRequestManager';

export enum NetworkStatus {
  UNKNOWN = 'unknown',
  NOT_CONNECTED = 'not_connected',
  CELLULAR = 'cellular',
  WIFI = 'wifi'
}

export class NetworkMonitor {
  private static instance: NetworkMonitor;
  private netCon: connection.NetConnection;
  private currentStatus: NetworkStatus = NetworkStatus.UNKNOWN;
  private listeners: Set<(status: NetworkStatus) => void> = new Set();

  private constructor() {
    this.netCon = connection.createNetConnection();
    this.init();
  }

  static getInstance(): NetworkMonitor {
    if (!NetworkMonitor.instance) {
      NetworkMonitor.instance = new NetworkMonitor();
    }
    return NetworkMonitor.instance;
  }

  private init(): void {
    this.netCon.register((error) => {
      if (error) {
        return;
      }
    });

    this.netCon.on('netAvailable', (data) => {
      this.updateStatus(NetworkStatus.WIFI);
    });

    this.netCon.on('netLost', (data) => {
      this.updateStatus(NetworkStatus.NOT_CONNECTED);
    });

    this.netCon.on('netBlockStatusChange', (data) => {
    });
  }

  /**
   * 更新网络状态
   */
  private updateStatus(status: NetworkStatus): void {
    const oldStatus = this.currentStatus;
    this.currentStatus = status;

    // 通知所有监听者
    this.listeners.forEach(listener => {
      try {
        listener(status);
      } catch {
      }
    });

    // 网络恢复时处理离线队列
    if (oldStatus === NetworkStatus.NOT_CONNECTED && status !== NetworkStatus.NOT_CONNECTED) {
      this.handleNetworkRecovery();
    }
  }

  /**
   * 网络恢复时的处理
   */
  private async handleNetworkRecovery(): Promise<void> {
    try {
      await getOfflineRequestManager().processQueue();
    } catch {
    }
  }

  /**
   * 获取当前网络状态
   */
  getCurrentStatus(): NetworkStatus {
    return this.currentStatus;
  }

  /**
   * 检查是否在线
   */
  isOnline(): boolean {
    return this.currentStatus !== NetworkStatus.NOT_CONNECTED;
  }

  /**
   * 添加状态变化监听器
   */
  addListener(listener: (status: NetworkStatus) => void): void {
    this.listeners.add(listener);
  }

  /**
   * 移除状态变化监听器
   */
  removeListener(listener: (status: NetworkStatus) => void): void {
    this.listeners.delete(listener);
  }

  /**
   * 销毁监测器
   */
  destroy(): void {
    this.netCon.unregister((error) => {
    });
    this.listeners.clear();
  }
}

export const networkMonitor = NetworkMonitor.getInstance();