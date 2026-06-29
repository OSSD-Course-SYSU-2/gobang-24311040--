// 数据持久化工具类
import { GameStats, GameSettings } from '../model/GameConstants';
import preferences from '@ohos.data.preferences';

const STATS_KEY = 'gobang_stats';
const SETTINGS_KEY = 'gobang_settings';

export class DataStorage {
  private static instance: DataStorage;
  private preferences: preferences.Preferences | null = null;
  
  private constructor() {}
  
  // 获取单例
  static getInstance(): DataStorage {
    if (!DataStorage.instance) {
      DataStorage.instance = new DataStorage();
    }
    return DataStorage.instance;
  }
  
  // 初始化
  async init(context: Context): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(context, 'gobang_data');
    } catch (error) {
      console.error('Failed to init preferences:', error);
    }
  }
  
  // 保存游戏统计
  async saveStats(stats: GameStats): Promise<void> {
    if (!this.preferences) return;
    
    try {
      await this.preferences.put(STATS_KEY, JSON.stringify(stats));
      await this.preferences.flush();
    } catch (error) {
      console.error('Failed to save stats:', error);
    }
  }
  
  // 加载游戏统计
  async loadStats(): Promise<GameStats> {
    const defaultStats: GameStats = {
      blackWins: 0,
      whiteWins: 0,
      draws: 0,
      totalGames: 0
    };
    
    if (!this.preferences) return defaultStats;
    
    try {
      const data = await this.preferences.get(STATS_KEY, '');
      if (data) {
        return JSON.parse(data as string) as GameStats;
      }
    } catch (error) {
      console.error('Failed to load stats:', error);
    }
    
    return defaultStats;
  }
  
  // 保存游戏设置
  async saveSettings(settings: GameSettings): Promise<void> {
    if (!this.preferences) return;
    
    try {
      await this.preferences.put(SETTINGS_KEY, JSON.stringify(settings));
      await this.preferences.flush();
    } catch (error) {
      console.error('Failed to save settings:', error);
    }
  }
  
  // 加载游戏设置
  async loadSettings(): Promise<GameSettings> {
    const defaultSettings: GameSettings = {
      mode: 'pvp',
      firstPlayer: 1,
      soundEnabled: true
    };
    
    if (!this.preferences) return defaultSettings;
    
    try {
      const data = await this.preferences.get(SETTINGS_KEY, '');
      if (data) {
        return JSON.parse(data as string) as GameSettings;
      }
    } catch (error) {
      console.error('Failed to load settings:', error);
    }
    
    return defaultSettings;
  }
  
  // 清空所有数据
  async clearAll(): Promise<void> {
    if (!this.preferences) return;
    
    try {
      await this.preferences.clear();
      await this.preferences.flush();
    } catch (error) {
      console.error('Failed to clear data:', error);
    }
  }
}
