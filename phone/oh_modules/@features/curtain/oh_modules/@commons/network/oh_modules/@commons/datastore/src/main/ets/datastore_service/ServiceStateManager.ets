/**
 * 全局服务状态管理器
 * 使用 AppStorageManager 实现跨组件共享状态
 */
import { promptAction } from '@kit.ArkUI';
import { AppStorageManager } from '../datastore_app/AppStorageManager';

const DO_NOT_DISTURB_KEY = 'doNotDisturb';
const CLEAN_ROOM_KEY = 'cleanRoom';
const CART_KEY = 'cart';
const ORDERS_KEY = 'orders';
const FEEDBACK_KEY = 'feedback';

export interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
  image: string;
}

export interface Order {
  id: string;
  roomNo?: string;
  items: CartItem[];
  totalPrice: number;
  totalAmount?: number;
  status: string;
  createTime: string;
  orderTime?: string;
  remark?: string;
}

export interface Feedback {
  id: string;
  category: string;
  content: string;
  createTime: string;
}

export enum FeedbackCategory {
  SERVICE = 'service',
  CLEAN = 'clean',
  FOOD = 'food',
  OTHER = 'other'
}

export enum OrderStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  DELIVERED = 'delivered',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled'
}

export class ServiceStateManager {
  static init(): void {
    if (!AppStorageManager.has(DO_NOT_DISTURB_KEY)) {
      AppStorageManager.setOrCreate(DO_NOT_DISTURB_KEY, false);
    }
    if (!AppStorageManager.has(CLEAN_ROOM_KEY)) {
      AppStorageManager.setOrCreate(CLEAN_ROOM_KEY, false);
    }
    if (!AppStorageManager.has(CART_KEY)) {
      AppStorageManager.setOrCreate(CART_KEY, [] as CartItem[]);
    }
    if (!AppStorageManager.has(ORDERS_KEY)) {
      AppStorageManager.setOrCreate(ORDERS_KEY, [] as Order[]);
    }
    if (!AppStorageManager.has(FEEDBACK_KEY)) {
      AppStorageManager.setOrCreate(FEEDBACK_KEY, [] as Feedback[]);
    }
  }

  static getDoNotDisturb(): boolean {
    ServiceStateManager.init();
    const result: boolean | undefined = AppStorageManager.get<boolean>(DO_NOT_DISTURB_KEY);
    return result || false;
  }

  static setDoNotDisturb(value: boolean): void {
    AppStorageManager.setOrCreate(DO_NOT_DISTURB_KEY, value);
  }

  static toggleDoNotDisturb(): void {
    const current = ServiceStateManager.getDoNotDisturb();
    ServiceStateManager.setDoNotDisturb(!current);
    promptAction.showToast({ message: !current ? '请勿打扰已开启' : '请勿打扰已关闭' });
  }

  static getCleanRoom(): boolean {
    ServiceStateManager.init();
    const result: boolean | undefined = AppStorageManager.get<boolean>(CLEAN_ROOM_KEY);
    return result || false;
  }

  static setCleanRoom(value: boolean): void {
    AppStorageManager.setOrCreate(CLEAN_ROOM_KEY, value);
  }

  static toggleCleanRoom(): void {
    const current = ServiceStateManager.getCleanRoom();
    ServiceStateManager.setCleanRoom(!current);
    promptAction.showToast({ message: !current ? '清理房间已请求' : '清理请求已取消' });
  }

  static getCart(): CartItem[] {
    ServiceStateManager.init();
    const result: CartItem[] | undefined = AppStorageManager.get<CartItem[]>(CART_KEY);
    return result || [];
  }

  static setCart(cart: CartItem[]): void {
    AppStorageManager.setOrCreate(CART_KEY, cart);
  }

  static addToCart(item: CartItem): void {
    const cart = ServiceStateManager.getCart();
    const existingItem = cart.find(i => i.id === item.id);
    if (existingItem) {
      existingItem.quantity += item.quantity;
    } else {
      const newItem: CartItem = {
        id: item.id,
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        image: item.image
      };
      cart.push(newItem);
    }
    ServiceStateManager.setCart(cart);
    promptAction.showToast({ message: '已添加到购物车' });
  }

  static updateCartItemQuantity(itemId: string, quantity: number): void {
    const cart = ServiceStateManager.getCart();
    const item = cart.find(i => i.id === itemId);
    if (item) {
      if (quantity <= 0) {
        ServiceStateManager.removeFromCart(itemId);
      } else {
        item.quantity = quantity;
        ServiceStateManager.setCart(cart);
      }
    }
  }

  static removeFromCart(itemId: string): void {
    const cart = ServiceStateManager.getCart();
    const filtered = cart.filter(item => item.id !== itemId);
    ServiceStateManager.setCart(filtered);
    promptAction.showToast({ message: '已从购物车移除' });
  }

  static clearCart(): void {
    ServiceStateManager.setCart([]);
  }

  static getCartTotal(): number {
    const cart = ServiceStateManager.getCart();
    return cart.reduce((total, item) => total + item.price * item.quantity, 0);
  }

  static getCartCount(): number {
    const cart = ServiceStateManager.getCart();
    return cart.reduce((count, item) => count + item.quantity, 0);
  }

  static getOrders(): Order[] {
    ServiceStateManager.init();
    const result: Order[] | undefined = AppStorageManager.get<Order[]>(ORDERS_KEY);
    return result || [];
  }

  static setOrders(orders: Order[]): void {
    AppStorageManager.setOrCreate(ORDERS_KEY, orders);
  }

  static createOrder(roomNo?: string, remark?: string): Order | null {
    const cart = ServiceStateManager.getCart();
    if (cart.length === 0) {
      promptAction.showToast({ message: '购物车为空' });
      return null;
    }

    const totalPrice = ServiceStateManager.getCartTotal();
    const now = new Date();
    const orderItems: CartItem[] = [];
    for (let i = 0; i < cart.length; i++) {
      const item = cart[i];
      const orderItem: CartItem = {
        id: item.id,
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        image: item.image
      };
      orderItems.push(orderItem);
    }

    const order: Order = {
      id: Date.now().toString(),
      roomNo: roomNo,
      items: orderItems,
      totalPrice,
      totalAmount: totalPrice,
      status: OrderStatus.PENDING,
      createTime: now.toLocaleString(),
      orderTime: now.toLocaleString(),
      remark: remark
    };

    const orders = ServiceStateManager.getOrders();
    orders.unshift(order);
    ServiceStateManager.setOrders(orders);
    ServiceStateManager.clearCart();
    promptAction.showToast({ message: '订单已提交' });
    return order;
  }

  static cancelOrder(orderId: string): void {
    const orders = ServiceStateManager.getOrders();
    const updatedOrders: Order[] = [];
    for (let i = 0; i < orders.length; i++) {
      const order = orders[i];
      if (order.id === orderId) {
        const cancelledOrder: Order = {
          id: order.id,
          roomNo: order.roomNo,
          items: order.items,
          totalPrice: order.totalPrice,
          totalAmount: order.totalAmount,
          status: OrderStatus.CANCELLED,
          createTime: order.createTime,
          orderTime: order.orderTime,
          remark: order.remark
        };
        updatedOrders.push(cancelledOrder);
      } else {
        updatedOrders.push(order);
      }
    }
    ServiceStateManager.setOrders(updatedOrders);
  }

  static logout(): void {
    ServiceStateManager.setDoNotDisturb(false);
    ServiceStateManager.setCleanRoom(false);
    ServiceStateManager.clearCart();
  }

  static sosCall(): void {
    promptAction.showToast({ message: 'SOS紧急呼叫已发送，工作人员将尽快到达' });
  }

  static addFeedback(category: string, content: string): void {
    const feedback: Feedback = {
      id: Date.now().toString(),
      category: category,
      content: content,
      createTime: new Date().toLocaleString()
    };
    const feedbacks: Feedback[] | undefined = AppStorageManager.get<Feedback[]>(FEEDBACK_KEY);
    const feedbackArray = feedbacks || [];
    feedbackArray.unshift(feedback);
    AppStorageManager.setOrCreate(FEEDBACK_KEY, feedbackArray);
    promptAction.showToast({ message: '反馈已提交' });
  }

  static getFeedbacks(): Feedback[] {
    const result: Feedback[] | undefined = AppStorageManager.get<Feedback[]>(FEEDBACK_KEY);
    return result || [];
  }
}