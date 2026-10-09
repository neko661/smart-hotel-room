/**
 * 服务数据模型
 */

export class ServiceOption {
  name: string = '';
  icon: string = '';
  enabled: boolean = false;

  constructor(name: string = '', icon: string = '', enabled: boolean = false) {
    this.name = name;
    this.icon = icon;
    this.enabled = enabled;
  }
}

export class ServiceData {
  static serviceOptions: ServiceOption[] = [
    new ServiceOption('请勿打扰', 'service_icon_do_not_disturb', false),
    new ServiceOption('清理房间', 'service_icon_clean_room', false),
    new ServiceOption('客房服务', 'order', false),
    new ServiceOption('扫码评价', 'washcloth', false)
  ];
}
