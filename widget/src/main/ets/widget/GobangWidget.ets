// 五子棋桌面卡片
import { FormExtension, formProvider, formBindingData } from '@kit.ArkUI';
import { ChessType, GameMode, GameState } from 'common';

interface FormData {
  title: string;
  status: string;
  mode: string;
  blackWins: number;
  whiteWins: number;
  totalGames: number;
}

export default class GobangWidget extends FormExtension {
  onCreate(formId: string): formBindingData.FormBindingData {
    console.info('GobangWidget onCreate');
    
    // 创建卡片数据
    const formData: FormData = {
      title: '五子棋',
      status: '黑方回合',
      mode: '双人对战',
      blackWins: 0,
      whiteWins: 0,
      totalGames: 0
    };
    
    return formBindingData.createFormBindingData(formData);
  }

  onUpdate(formId: string): void {
    console.info('GobangWidget onUpdate');
    
    // 更新卡片数据
    const formData: FormData = {
      title: '五子棋',
      status: '黑方回合',
      mode: '双人对战',
      blackWins: 0,
      whiteWins: 0,
      totalGames: 0
    };
    
    formProvider.updateForm(formId, formBindingData.createFormBindingData(formData)).catch((error: Error) => {
      console.error('Failed to update form:', error.message);
    });
  }

  onDestroy(formId: string): void {
    console.info('GobangWidget onDestroy');
  }
}

// 卡片UI组件
@Entry
@Component
struct WidgetCard {
  @LocalStorageProp('title') title: string = '五子棋';
  @LocalStorageProp('status') status: string = '黑方回合';
  @LocalStorageProp('mode') mode: string = '双人对战';
  @LocalStorageProp('blackWins') blackWins: number = 0;
  @LocalStorageProp('whiteWins') whiteWins: number = 0;
  @LocalStorageProp('totalGames') totalGames: number = 0;

  build() {
    Column() {
      // 标题
      Row() {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333');
        
        Blank();
        
        // 快捷操作按钮
        Button('开始')
          .fontSize(12)
          .height(24)
          .backgroundColor('#4CAF50')
          .onClick(() => {
            // 点击卡片打开应用
            postCardAction(this, {
              action: 'router',
              abilityName: 'FormAbility',
              params: {
                targetPage: 'pages/Index'
              }
            });
          });
      }
      .width('100%')
      .margin({ bottom: 10 });
      
      Divider();
      
      // 游戏状态
      Column() {
        Row() {
          Text('当前：')
            .fontSize(12);
          
          Text(this.status)
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF0000');
        }
        .width('100%')
        .margin({ top: 8, bottom: 8 });
        
        Row() {
          Text(`模式：${this.mode}`)
            .fontSize(12);
        }
        .width('100%')
        .margin({ bottom: 8 });
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);
      
      Divider();
      
      // 统计信息
      Row() {
        Text(`黑${this.blackWins}胜`)
          .fontSize(10);
        
        Text(`白${this.whiteWins}胜`)
          .fontSize(10);
        
        Text(`共${this.totalGames}局`)
          .fontSize(10);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 8 });
    }
    .width('100%')
    .height('100%')
    .padding(10)
    .backgroundColor('#FFFFFF')
    .borderRadius(8);
  }
}
