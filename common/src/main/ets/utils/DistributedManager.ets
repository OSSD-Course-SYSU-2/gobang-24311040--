// 分布式流转管理器 - Common模块
import deviceManager from '@ohos.distributedDeviceManager';
import { BusinessError } from '@ohos.base';
import { SerializableGameState } from '../model/SerializableGameState';
import { GameBoard } from '../model/GameBoard';

// 设备信息接口
export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: string;
  isOnline: boolean;
}

// 流转回调接口
export interface DistributedCallback {
  onDeviceFound?: (devices: DeviceInfo[]) => void;
  onStateChanged?: (state: string) => void;
  onError?: (error: string) => void;
}

// 订阅信息接口
interface SubscribeInfo {
  subscribeId: number;
  mode: string;
  frequency: string;
  isSameAccount: boolean;
  isWakeRemote: boolean;
  capability: string[];
}

// 扩展DeviceManager接口，添加发现设备方法
interface DeviceManagerWithDiscovery extends deviceManager.DeviceManager {
  startDeviceDiscovery: (subscribeInfo: SubscribeInfo) => void;
  stopDeviceDiscovery: (subscribeId: number) => void;
}

export class DistributedManager {
  private deviceManager: deviceManager.DeviceManager | null = null;
  private callback: DistributedCallback | null = null;
  private currentDeviceId: string = '';
  private targetDeviceId: string = '';

  constructor() {
    this.initDeviceManager();
  }

  // 初始化设备管理器
  private initDeviceManager(): void {
    try {
      // 创建设备管理器
      const dmInstance = deviceManager.createDeviceManager('com.example.gobang');
      this.deviceManager = dmInstance;
      
      // 获取当前设备ID
      this.currentDeviceId = this.getLocalDeviceId();
      
      console.info('DistributedManager initialized successfully');
    } catch (error) {
      const err = error as BusinessError;
      console.error('Failed to init device manager:', err.message);
    }
  }

  // 获取本地设备ID
  private getLocalDeviceId(): string {
    try {
      if (this.deviceManager) {
        const deviceInfo = this.deviceManager.getLocalDeviceNetworkId();
        return deviceInfo;
      }
    } catch (error) {
      console.error('Failed to get local device id:', error);
    }
    return '';
  }

  // 设置回调
  setCallback(callback: DistributedCallback): void {
    this.callback = callback;
  }

  // 发现设备
  discoverDevices(): void {
    if (!this.deviceManager) {
      console.error('Device manager not initialized');
      return;
    }

    try {
      // 注册设备状态回调
      this.deviceManager.on('serviceDie', (data: any) => {
        console.info('Device state changed:', data.deviceName);
        if (this.callback && this.callback.onDeviceFound) {
          this.getOnlineDevices().then(devices => {
            if (this.callback && this.callback.onDeviceFound) {
              this.callback.onDeviceFound(devices);
            }
          });
        }
      });

      // 发现设备
      const subscribeInfo: SubscribeInfo = {
        subscribeId: 12345,
        mode: 'DISCOVER_MODE_ACTIVE',
        frequency: 'MID',
        isSameAccount: true,
        isWakeRemote: true,
        capability: []
      };

      (this.deviceManager as DeviceManagerWithDiscovery).startDeviceDiscovery(subscribeInfo);
      
      if (this.callback && this.callback.onStateChanged) {
        this.callback.onStateChanged('discovering');
      }
      
      console.info('Device discovery started');
    } catch (error) {
      const err = error as BusinessError;
      console.error('Failed to discover devices:', err.message);
      if (this.callback && this.callback.onError) {
        this.callback.onError('Failed to discover devices: ' + err.message);
      }
    }
  }

  // 停止发现设备
  stopDiscovery(): void {
    if (!this.deviceManager) {
      return;
    }

    try {
      (this.deviceManager as DeviceManagerWithDiscovery).stopDeviceDiscovery(12345);
      console.info('Device discovery stopped');
    } catch (error) {
      console.error('Failed to stop discovery:', error);
    }
  }

  // 获取在线设备列表
  async getOnlineDevices(): Promise<DeviceInfo[]> {
    const devices: DeviceInfo[] = [];
    
    if (!this.deviceManager) {
      return devices;
    }

    try {
      const deviceInfos: deviceManager.DeviceBasicInfo[] = await this.deviceManager.getAvailableDeviceList();
      for (let i = 0; i < deviceInfos.length; i++) {
        const info = deviceInfos[i];
        const device: DeviceInfo = {
          deviceId: info.networkId || '',
          deviceName: info.deviceName || '',
          deviceType: info.deviceType || '',
          isOnline: true
        };
        devices.push(device);
      }
    } catch (error) {
      console.error('Failed to get online devices:', error);
    }

    return devices;
  }

  // 迁移游戏状态到目标设备
  migrateGameState(gameBoard: GameBoard, targetDeviceId: string): boolean {
    if (!this.deviceManager) {
      console.error('Device manager not initialized');
      return false;
    }

    try {
      // 序列化游戏状态
      const state = gameBoard.toSerializableState(this.currentDeviceId);
      const stateJson = state.serialize();
      
      // 这里需要通过分布式软总线发送数据
      // 实际实现需要使用分布式数据管理或分布式框架API
      console.info('Migrating game state to device:', targetDeviceId);
      console.info('State data:', stateJson);
      
      this.targetDeviceId = targetDeviceId;
      
      // 模拟迁移成功
      if (this.callback && this.callback.onStateChanged) {
        this.callback.onStateChanged('migrated');
      }
      
      return true;
    } catch (error) {
      console.error('Failed to migrate game state:', error);
      if (this.callback && this.callback.onError) {
        this.callback.onError('Failed to migrate game state');
      }
      return false;
    }
  }

  // 从源设备恢复游戏状态
  restoreGameState(stateJson: string): GameBoard | null {
    try {
      const state = SerializableGameState.deserialize(stateJson);
      const gameBoard = new GameBoard();
      gameBoard.fromSerializableState(state);
      
      console.info('Game state restored from device:', state.deviceId);
      
      return gameBoard;
    } catch (error) {
      console.error('Failed to restore game state:', error);
      return null;
    }
  }

  // 获取当前设备ID
  getCurrentDeviceId(): string {
    return this.currentDeviceId;
  }

  // 获取目标设备ID
  getTargetDeviceId(): string {
    return this.targetDeviceId;
  }

  // 检查是否支持分布式
  isDistributedSupported(): boolean {
    return this.deviceManager !== null;
  }

  // 释放资源
  release(): void {
    this.stopDiscovery();
    
    if (this.deviceManager) {
      try {
        deviceManager.releaseDeviceManager(this.deviceManager);
        this.deviceManager = null;
        console.info('Device manager released');
      } catch (error) {
        console.error('Failed to release device manager:', error);
      }
    }
  }
}
