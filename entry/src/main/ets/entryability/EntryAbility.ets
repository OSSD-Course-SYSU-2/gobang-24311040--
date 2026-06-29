import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { SerializableGameState, GameBoard } from 'common';

const DOMAIN = 0x0000;
const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  // 存储游戏状态
  private gameState: SerializableGameState | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onCreate');
    
    // 检查是否从其他设备迁移过来
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      hilog.info(DOMAIN, TAG, 'Launched by continuation');
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onBackground');
  }

  // 分布式流转 - 保存状态
  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    hilog.info(DOMAIN, TAG, 'onContinue called');
    
    try {
      // 从全局存储获取游戏状态
      const gameStateStr = AppStorage.get<string>('gameState');
      if (gameStateStr) {
        wantParam['gameState'] = gameStateStr;
        hilog.info(DOMAIN, TAG, 'Game state saved for continuation');
        return AbilityConstant.OnContinueResult.AGREE;
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to save game state: %{public}s', JSON.stringify(error));
    }
    
    return AbilityConstant.OnContinueResult.REJECT;
  }

  // 分布式流转 - 恢复状态
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'onNewWant called');
    
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      // 从want参数中获取迁移的游戏状态
      if (want.parameters) {
        const gameStateStr = want.parameters['gameState'] as string;
        if (gameStateStr) {
          try {
            // 恢复游戏状态
            const state = SerializableGameState.deserialize(gameStateStr);
            AppStorage.setOrCreate<string>('gameState', gameStateStr);
            hilog.info(DOMAIN, TAG, 'Game state restored from continuation');
          } catch (error) {
            hilog.error(DOMAIN, TAG, 'Failed to restore game state: %{public}s', JSON.stringify(error));
          }
        }
      }
    }
  }
}
