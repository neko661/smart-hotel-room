/**
 * 应用配置
 */
export enum Environment {
  DEV = 'dev',
  TEST = 'test',
  PROD = 'prod'
}

export interface ApiConfig {
  baseUrl: string;
  timeout: number;
  enableMock: boolean;
}

export class AppConfig {
  private static currentEnvironment: Environment = Environment.DEV;

  private static configs: Record<Environment, ApiConfig> = {
    [Environment.DEV]: {
      baseUrl: 'https://dev-api.hotel.com',
      timeout: 30000,
      enableMock: false
    },
    [Environment.TEST]: {
      baseUrl: 'http://test-api.hotel.com',
      timeout: 30000,
      enableMock: false
    },
    [Environment.PROD]: {
      baseUrl: 'https://api.hotel.com',
      timeout: 30000,
      enableMock: false
    }
  };

  static setEnvironment(env: Environment): void {
    AppConfig.currentEnvironment = env;
  }

  static getEnvironment(): Environment {
    return AppConfig.currentEnvironment;
  }

  static getConfig(): ApiConfig {
    return AppConfig.configs[AppConfig.currentEnvironment];
  }

  static getBaseUrl(): string {
    return AppConfig.configs[AppConfig.currentEnvironment].baseUrl;
  }

  static getTimeout(): number {
    return AppConfig.configs[AppConfig.currentEnvironment].timeout;
  }

  static isMockEnabled(): boolean {
    return AppConfig.configs[AppConfig.currentEnvironment].enableMock;
  }
}
