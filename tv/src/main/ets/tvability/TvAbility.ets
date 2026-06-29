import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { SerializableGameState } from 'common';

const DOMAIN = 0x0000;
const TAG = 'TvAbility';

export default class TvAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onCreate');
    
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      hilog.info(DOMAIN, TAG, 'Launched by continuation');
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
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
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onBackground');
  }

  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    hilog.info(DOMAIN, TAG, 'onContinue called');
    
    try {
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

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'onNewWant called');
    
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      if (want.parameters) {
        const gameStateStr = want.parameters['gameState'] as string;
        if (gameStateStr) {
          try {
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
