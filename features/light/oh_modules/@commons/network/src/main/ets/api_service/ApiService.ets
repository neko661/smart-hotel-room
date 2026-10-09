/**
 * API服务 - 智慧客房接口封装
 */
import { HttpClient } from '../core_http/HttpClient';

// ============ 数据模型 ============

export interface RoomInfo {
  roomId: string;
  roomNumber: string;
  guestName: string;
  checkInDate: string;
  checkOutDate: string;
  status: 'occupied' | 'vacant' | 'cleaning';
}

export interface TemperatureControl {
  currentTemp: number;
  targetTemp: number;
  mode: 'cool' | 'heat' | 'auto' | 'fan';
  fanSpeed: number;
  isOn: boolean;
}

export interface LightControl {
  id: string;
  name: string;
  isOn: boolean;
  brightness: number;
  color?: string;
}

export interface CurtainControl {
  id: string;
  name: string;
  position: number;
  isOpen: boolean;
}

export class FoodItem {
  id: string = '';
  name: string = '';
  price: number = 0;
  category: string = '';
  description: string = '';
  image: string = '';

  constructor(id: string, name: string, price: number, category: string, description?: string, image?: string) {
    this.id = id;
    this.name = name;
    this.price = price;
    this.category = category;
    this.description = description || '';
    this.image = image || '';
  }
}

export class OrderItem {
  id: string = '';
  foodId: string = '';
  name: string = '';
  price: number = 0;
  quantity: number = 0;

  constructor(id: string, foodId: string, name: string, price: number, quantity: number) {
    this.id = id;
    this.foodId = foodId;
    this.name = name;
    this.price = price;
    this.quantity = quantity;
  }
}

export type OrderStatusType = 'pending' | 'preparing' | 'delivering' | 'completed' | 'cancelled';

export class OrderInfo {
  orderId: string = '';
  roomId: string = '';
  items: OrderItem[] = [];
  totalAmount: number = 0;
  status: OrderStatusType = 'pending';
  createTime: string = '';
  estimatedDeliveryTime?: string = '';

  constructor(orderId: string, roomId: string, items: OrderItem[], totalAmount: number, status: OrderStatusType, createTime: string) {
    this.orderId = orderId;
    this.roomId = roomId;
    this.items = items;
    this.totalAmount = totalAmount;
    this.status = status;
    this.createTime = createTime;
  }
}

export type ServiceRequestType = 'cleaning' | 'laundry' | 'roomService' | 'maintenance';

export interface ServiceRequest {
  id: string;
  type: ServiceRequestType;
  status: 'pending' | 'processing' | 'completed';
  createTime: string;
  description?: string;
}

// 用于API错误的自定义错误类
export class ApiError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ApiError';
  }
}

// 成功响应类
export class SuccessResponse {
  success: boolean = false;

  constructor(success: boolean) {
    this.success = success;
  }
}

// ============ API服务类 ============

export class ApiService {
  private httpClient: HttpClient;

  constructor() {
    this.httpClient = HttpClient.getInstance();
    this.configureBaseUrl();
  }

  private configureBaseUrl(): void {
    this.httpClient.setBaseUrl('https://api.hotel.com/v1');
  }

  // ============ 房间信息 ============

  async getRoomInfo(): Promise<RoomInfo> {
    try {
      const response = await this.httpClient.get<RoomInfo>('/room/info');
      return response;
    } catch {
      throw new ApiError('获取房间信息失败');
    }
  }

  // ============ 温度控制 ============

  async getTemperatureControl(): Promise<TemperatureControl> {
    try {
      const response = await this.httpClient.get<TemperatureControl>('/room/temperature');
      return response;
    } catch {
      throw new ApiError('获取温度控制信息失败');
    }
  }

  async setTemperature(temp: number): Promise<TemperatureControl> {
    try {
      const response = await this.httpClient.put<TemperatureControl>('/room/temperature', { targetTemp: temp });
      return response;
    } catch {
      throw new ApiError('设置温度失败');
    }
  }

  async toggleAirConditioner(isOn: boolean): Promise<TemperatureControl> {
    try {
      const response = await this.httpClient.put<TemperatureControl>('/room/airconditioner', { isOn });
      return response;
    } catch {
      throw new ApiError('切换空调状态失败');
    }
  }

  // ============ 灯光控制 ============

  async getLights(): Promise<LightControl[]> {
    try {
      const response = await this.httpClient.get<LightControl[]>('/room/lights');
      return response;
    } catch {
      throw new ApiError('获取灯光列表失败');
    }
  }

  async toggleLight(lightId: string, isOn: boolean): Promise<LightControl> {
    try {
      const response = await this.httpClient.put<LightControl>(`/room/lights/${lightId}`, { isOn });
      return response;
    } catch {
      throw new ApiError('切换灯光状态失败');
    }
  }

  async setLightBrightness(lightId: string, brightness: number): Promise<LightControl> {
    try {
      const response = await this.httpClient.put<LightControl>(`/room/lights/${lightId}/brightness`, { brightness });
      return response;
    } catch {
      throw new ApiError('设置灯光亮度失败');
    }
  }

  async setLightScene(sceneId: string): Promise<SuccessResponse> {
    try {
      const response = await this.httpClient.post<SuccessResponse>('/room/lights/scene', { sceneId });
      return response;
    } catch {
      throw new ApiError('设置灯光场景失败');
    }
  }

  // ============ 窗帘控制 ============

  async getCurtains(): Promise<CurtainControl[]> {
    try {
      const response = await this.httpClient.get<CurtainControl[]>('/room/curtains');
      return response;
    } catch {
      throw new ApiError('获取窗帘列表失败');
    }
  }

  async setCurtainPosition(curtainId: string, position: number): Promise<CurtainControl> {
    try {
      const response = await this.httpClient.put<CurtainControl>(`/room/curtains/${curtainId}`, { position });
      return response;
    } catch {
      throw new ApiError('设置窗帘位置失败');
    }
  }

  async toggleCurtain(curtainId: string, isOpen: boolean): Promise<CurtainControl> {
    try {
      const response = await this.httpClient.put<CurtainControl>(`/room/curtains/${curtainId}/toggle`, { isOpen });
      return response;
    } catch {
      throw new ApiError('切换窗帘状态失败');
    }
  }

  // ============ 餐饮服务 ============

  async getFoodMenu(): Promise<FoodItem[]> {
    try {
      const response = await this.httpClient.get<FoodItem[]>('/dining/menu');
      return response;
    } catch {
      throw new ApiError('获取菜单失败');
    }
  }

  async createOrder(items: OrderItem[]): Promise<OrderInfo> {
    try {
      const response = await this.httpClient.post<OrderInfo>('/dining/order', { items });
      return response;
    } catch {
      throw new ApiError('创建订单失败');
    }
  }

  async getOrders(): Promise<OrderInfo[]> {
    try {
      const response = await this.httpClient.get<OrderInfo[]>('/dining/orders');
      return response;
    } catch {
      throw new ApiError('获取订单列表失败');
    }
  }

  async getOrderById(orderId: string): Promise<OrderInfo> {
    try {
      const response = await this.httpClient.get<OrderInfo>(`/dining/orders/${orderId}`);
      return response;
    } catch {
      throw new ApiError('获取订单详情失败');
    }
  }

  // ============ 客房服务 ============

  async requestService(type: ServiceRequestType, description?: string): Promise<ServiceRequest> {
    try {
      const response = await this.httpClient.post<ServiceRequest>('/services/request', { type, description });
      return response;
    } catch {
      throw new ApiError('提交服务请求失败');
    }
  }

  async getServiceRequests(): Promise<ServiceRequest[]> {
    try {
      const response = await this.httpClient.get<ServiceRequest[]>('/services/requests');
      return response;
    } catch {
      throw new ApiError('获取服务请求列表失败');
    }
  }

  // ============ 其他功能 ============

  async getQRCode(): Promise<string> {
    try {
      interface QRCodeResponse {
        qrCode: string;
      }
      const response = await this.httpClient.get<QRCodeResponse>('/room/qrcode');
      return response.qrCode;
    } catch {
      throw new ApiError('获取二维码失败');
    }
  }

  async setDoNotDisturb(isEnabled: boolean): Promise<SuccessResponse> {
    try {
      const response = await this.httpClient.put<SuccessResponse>('/room/do-not-disturb', { isEnabled });
      return response;
    } catch {
      throw new ApiError('设置请勿打扰失败');
    }
  }
}

// 单例导出
export const apiService = new ApiService();