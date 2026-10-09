/**
 * 离线请求管理器
 * 用于管理离线时的请求队列和网络恢复后的重放
 */
import { PreferencesUtil } from '@commons/datastore/src/main/ets/datastore_base/PreferencesUtil';
import { HttpClient, HttpRequestConfig } from '../core_http/HttpClient';
import { SessionManager } from '@commons/datastore/src/main/ets/datastore_app/SessionManager';
import { http } from '@kit.NetworkKit';

export interface QueuedRequest {
  id: string;
  url: string;
  method: http.RequestMethod;
  headers?: Record<string, string>;
  data?: ESObject | string;
  timestamp: number;
  retryCount: number;
  maxRetries: number;
}

export class OfflineRequestManager {
  private static instance: OfflineRequestManager;
  private static readonly QUEUE_KEY = 'offline_request_queue';
  private static readonly MAX_QUEUE_SIZE = 100;
  private static readonly MAX_RETRY_COUNT = 3;
  private isProcessing: boolean = false;
  private httpClient: HttpClient;

  private constructor() {
    this.httpClient = HttpClient.getInstance();
  }

  static getInstance(): OfflineRequestManager {
    if (!OfflineRequestManager.instance) {
      OfflineRequestManager.instance = new OfflineRequestManager();
    }
    return OfflineRequestManager.instance;
  }

  /**
   * 添加请求到队列
   */
  async enqueue(config: HttpRequestConfig): Promise<void> {
    const queue = await this.getQueue();

    if (queue.length >= OfflineRequestManager.MAX_QUEUE_SIZE) {
      queue.shift();
    }

    const queuedRequest: QueuedRequest = {
      id: this.generateId(),
      url: config.url,
      method: http.RequestMethod.POST,
      headers: config.headers,
      data: config.data,
      timestamp: Date.now(),
      retryCount: 0,
      maxRetries: OfflineRequestManager.MAX_RETRY_COUNT
    };
    
    if (config.method === http.RequestMethod.GET) {
      queuedRequest.method = http.RequestMethod.GET;
    } else if (config.method === http.RequestMethod.PUT) {
      queuedRequest.method = http.RequestMethod.PUT;
    } else if (config.method === http.RequestMethod.DELETE) {
      queuedRequest.method = http.RequestMethod.DELETE;
    }

    // 过滤掉幂等的GET请求（只缓存POST/PUT/PATCH/DELETE等写操作）
    if (queuedRequest.method !== http.RequestMethod.GET) {
      queue.push(queuedRequest);
      await this.saveQueue(queue);
    }
  }

  /**
   * 处理队列中的请求
   */
  async processQueue(): Promise<void> {
    if (this.isProcessing) {
      return;
    }

    this.isProcessing = true;

    try {
      const queue = await this.getQueue();
      const failedRequests: QueuedRequest[] = [];

      for (const request of queue) {
        try {
          await this.executeRequest(request);
        } catch (error) {
          request.retryCount++;
          if (request.retryCount < request.maxRetries) {
            failedRequests.push(request);
          }
        }
      }

      await this.saveQueue(failedRequests);
    } finally {
      this.isProcessing = false;
    }
  }

  /**
   * 执行单个请求
   */
  private async executeRequest(request: QueuedRequest): Promise<void> {
    let httpMethod = http.RequestMethod.POST;
    if (request.method === http.RequestMethod.GET) {
      httpMethod = http.RequestMethod.GET;
    } else if (request.method === http.RequestMethod.PUT) {
      httpMethod = http.RequestMethod.PUT;
    } else if (request.method === http.RequestMethod.DELETE) {
      httpMethod = http.RequestMethod.DELETE;
    }
    
    await this.httpClient.request<Object>({
      url: request.url,
      method: httpMethod,
      headers: request.headers,
      data: request.data
    });
  }

  /**
   * 获取队列
   */
  private async getQueue(): Promise<QueuedRequest[]> {
    try {
      const queueData = await PreferencesUtil.get(OfflineRequestManager.QUEUE_KEY, '[]');
      return JSON.parse(queueData as string) as QueuedRequest[];
    } catch {
      return [];
    }
  }

  /**
   * 保存队列
   */
  private async saveQueue(queue: QueuedRequest[]): Promise<void> {
    try {
      await PreferencesUtil.put(OfflineRequestManager.QUEUE_KEY, JSON.stringify(queue));
    } catch {
    }
  }

  /**
   * 清空队列
   */
  async clearQueue(): Promise<void> {
    await this.saveQueue([]);
  }

  /**
   * 获取队列大小
   */
  async getQueueSize(): Promise<number> {
    const queue = await this.getQueue();
    return queue.length;
  }

  /**
   * 生成唯一ID
   */
  private generateId(): string {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }
}

// 懒加载单例，避免循环依赖问题
let offlineManagerInstance: OfflineRequestManager | null = null;

export function getOfflineRequestManager(): OfflineRequestManager {
  if (!offlineManagerInstance) {
    offlineManagerInstance = OfflineRequestManager.getInstance();
  }
  return offlineManagerInstance;
}