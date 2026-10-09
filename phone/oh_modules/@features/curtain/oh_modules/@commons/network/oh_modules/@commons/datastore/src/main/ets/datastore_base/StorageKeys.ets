/**
 * 存储键常量
 */
interface AppStorageKeySet {
  USER_INFO: string;
  THEME_CONFIG: string;
  LANGUAGE: string;
  ROOM_NO: string;
  USER_NAME: string;
  REMEMBER_ME: string;
}

interface PersistenceKeySet {
  USER_TOKEN: string;
  USER_DATA: string;
  SETTINGS: string;
  CACHE: string;
}

interface StorageKeyConfig {
  APP_STORAGE: AppStorageKeySet;
  PERSISTENCE: PersistenceKeySet;
}

export const AppStorageKeys: StorageKeyConfig = {
  APP_STORAGE: {
    USER_INFO: 'app_storage_user_info',
    THEME_CONFIG: 'app_storage_theme_config',
    LANGUAGE: 'app_storage_language',
    ROOM_NO: 'app_storage_room_no',
    USER_NAME: 'app_storage_user_name',
    REMEMBER_ME: 'app_storage_remember_me'
  },

  PERSISTENCE: {
    USER_TOKEN: 'persistence_user_token',
    USER_DATA: 'persistence_user_data',
    SETTINGS: 'persistence_settings',
    CACHE: 'persistence_cache'
  }
};

interface SimpleStorageKeys {
  IS_LOGGED_IN: string;
  ROOM_NO: string;
  USER_NAME: string;
  REMEMBER_ME: string;
}

export const StorageKeys: SimpleStorageKeys = {
  IS_LOGGED_IN: 'isLoggedIn',
  ROOM_NO: 'roomNo',
  USER_NAME: 'userName',
  REMEMBER_ME: 'rememberMe'
};
