// 启动页面 - Widget模块
import { router } from '@kit.ArkUI';
import { Want } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    // 跳转到主应用
    setTimeout(() => {
      this.openMainApp();
    }, 100);
  }

  private openMainApp(): void {
    // 启动主应用
    const want: Want = {
      bundleName: 'com.example.gobang',
      abilityName: 'EntryAbility'
    };
    
    // 由于widget模块独立，这里提示用户打开主应用
    console.info('Please open main application');
  }

  build() {
    Column() {
      Column() {
        Text('五子棋')
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 20 });
        
        Text('请打开主应用开始游戏')
          .fontSize(20)
          .fontColor('#666666');
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}
