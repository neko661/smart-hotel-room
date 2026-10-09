/**
 * HTTP客户端
 */
import { http } from '@kit.NetworkKit';
import { AppConfig } from '../config/AppConfig';
import { SessionManager } from '@commons/datastore/src/main/ets/datastore_app/SessionManager';
import { getOfflineRequestManager } from '../monitor_cache/OfflineRequestManager';
import { networkMonitor, NetworkStatus } from '../monitor_cache/NetworkMonitor';

export interface HttpRequestConfig {
  url: string;
  method?: http.RequestMethod;
  headers?: Record<string, string>;
  data?: ESObject | string | ArrayBuffer;
  expectDataType?: http.HttpDataType;
  connectTimeout?: number;
  readTimeout?: number;
  retryCount?: number;
  maxRetries?: number;
  enableOfflineQueue?: boolean;
}

export interface HttpResponse<T = Object> {
  data: T;
  statusCode: number;
  headers: Record<string, string>;
}

export class HttpError extends Error {
  statusCode: number | undefined;
  data: Object | undefined;

  constructor(message: string, statusCode?: number, data?: Object) {
    super(message);
    this.name = 'HttpError';
    this.statusCode = statusCode;
    this.data = data;
  }
}

export class HttpClient {
  private static instance: HttpClient;
  private httpRequest: http.HttpRequest;
  baseUrl: string = '';
  timeout: number = 0;
  private static readonly DEFAULT_MAX_RETRIES = 3;
  private static readonly RETRY_DELAY = 1000;

  private constructor() {
    this.httpRequest = http.createHttp();
    this.baseUrl = AppConfig.getBaseUrl();
    this.timeout = AppConfig.getTimeout();
  }

  static getInstance(): HttpClient {
    if (!HttpClient.instance) {
      HttpClient.instance = new HttpClient();
    }
    return HttpClient.instance;
  }

  refreshConfig(): void {
    this.baseUrl = AppConfig.getBaseUrl();
    this.timeout = AppConfig.getTimeout();
  }

  async request<T>(config: HttpRequestConfig): Promise<T> {
    const maxRetries = config.maxRetries ?? HttpClient.DEFAULT_MAX_RETRIES;
    let retryCount = config.retryCount ?? 0;
    let lastError: HttpError | null = null;

    if (!networkMonitor.isOnline() && config.enableOfflineQueue !== false) {
      const method = config.method !== undefined ? config.method : http.RequestMethod.GET;
      if (method !== http.RequestMethod.GET) {
        await getOfflineRequestManager().enqueue(config);
        throw new HttpError('Network offline, request queued', 0);
      }
    }

    while (retryCount <= maxRetries) {
      try {
        return await this.executeRequest<T>(config);
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        lastError = error instanceof HttpError ? error : new HttpError(message);

        const shouldRetry = await this.shouldRetry(lastError, retryCount, maxRetries);

        if (!shouldRetry) {
          break;
        }

        retryCount++;
        if (retryCount <= maxRetries) {
          await this.delay(HttpClient.RETRY_DELAY * retryCount);
        }
      }
    }

    if (lastError) {
      throw lastError;
    } else {
      throw new HttpError('Request failed');
    }
  }

  private async executeRequest<T>(config: HttpRequestConfig): Promise<T> {
    const fullUrl = config.url.startsWith('http') ? config.url : `${this.baseUrl}${config.url}`;

    const defaultHeaders: Record<string, string> = {
      'Content-Type': 'application/json'
    };

    if (config.headers) {
      Object.keys(config.headers).forEach(key => {
        defaultHeaders[key] = config.headers![key];
      });
    }

    const token = SessionManager.getToken();
    if (token) {
      defaultHeaders['Authorization'] = `Bearer ${token}`;
    }

    const requestMethod = config.method !== undefined ? config.method : http.RequestMethod.GET;
    const response = await this.httpRequest.request(fullUrl, {
      method: requestMethod,
      header: defaultHeaders,
      extraData: config.data,
      expectDataType: config.expectDataType || http.HttpDataType.STRING,
      connectTimeout: config.connectTimeout || this.timeout,
      readTimeout: config.readTimeout || this.timeout,
    });

    const responseData: string = response.result as string;
    let parsedData: Object = responseData;
    if (typeof responseData === 'string') {
      parsedData = JSON.parse(responseData);
    }

    const httpResponse: HttpResponse = {
      data: parsedData,
      statusCode: response.responseCode,
      headers: response.header as Record<string, string>
    };

    if (response.responseCode >= 400) {
      throw new HttpError(
        `HTTP Error: ${response.responseCode}`,
        response.responseCode,
        parsedData
      );
    }

    return parsedData as T;
  }

  private async shouldRetry(error: HttpError, retryCount: number, maxRetries: number): Promise<boolean> {
    if (retryCount >= maxRetries) {
      return false;
    }

    if (error.statusCode) {
      if (error.statusCode >= 500 && error.statusCode < 600) {
        return true;
      }
      if (error.statusCode === 429) {
        return true;
      }
      if (error.statusCode === 408) {
        return true;
      }
    }

    if (error.message.includes('network') || error.message.includes('timeout')) {
      return true;
    }

    return false;
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  async get<T>(url: string, params?: Record<string, string>): Promise<T> {    
    let fullUrl = url;
    if (params && Object.keys(params).length > 0) {
      const keys = Object.keys(params);
      const queryParts: string[] = [];
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        queryParts.push(`${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`);
      }
      fullUrl += `?${queryParts.join('&')}`;
    }
    return this.request<T>({ url: fullUrl, method: http.RequestMethod.GET });
  }

  async post<T>(url: string, data?: ESObject): Promise<T> {
    return this.request<T>({ url, method: http.RequestMethod.POST, data });
  }

  async put<T>(url: string, data?: ESObject): Promise<T> {
    return this.request<T>({ url, method: http.RequestMethod.PUT, data });
  }

  async delete<T>(url: string): Promise<T> {
    return this.request<T>({ url, method: http.RequestMethod.DELETE });
  }

  async patch<T>(url: string, data?: ESObject): Promise<T> {
    return this.request<T>({ url, method: http.RequestMethod.POST, data });
  }

  setBaseUrl(url: string): void {
    this.baseUrl = url;
  }
}