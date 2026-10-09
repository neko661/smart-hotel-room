// Network Module - 网络请求模块
export { HttpClient, HttpRequestConfig, HttpResponse, HttpError } from './HttpClient';
export { ApiService, apiService } from '../api_service/ApiService';
export { AppConfig, Environment, ApiConfig } from '../config/AppConfig';
export { OfflineRequestManager, getOfflineRequestManager, QueuedRequest } from '../monitor_cache/OfflineRequestManager';
export { NetworkMonitor, networkMonitor, NetworkStatus } from '../monitor_cache/NetworkMonitor';

// Re-export types and classes
export type { RoomInfo, TemperatureControl, LightControl, CurtainControl, ServiceRequest } from '../api_service/ApiService';
export { FoodItem, OrderItem, OrderInfo } from '../api_service/ApiService';
export type { OrderStatusType, ServiceRequestType } from '../api_service/ApiService';
