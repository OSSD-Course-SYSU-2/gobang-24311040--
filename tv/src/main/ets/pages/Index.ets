// 启动页面 - TV端
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    setTimeout(() => {
      this.navigateToGame();
    }, 100);
  }

  private navigateToGame(): void {
    router.pushUrl({
      url: 'pages/GobangGameTV'
    }).catch((error: Error) => {
      console.error('Failed to navigate to game page:', error.message);
    });
  }

  build() {
    Column() {
      Column() {
        Text('五子棋')
          .fontSize(64)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 30 });
        
        Text('智慧屏版本')
          .fontSize(32)
          .fontColor('#666666')
          .margin({ bottom: 40 });
        
        LoadingProgress()
          .width(80)
          .height(80)
          .color('#4CAF50');
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
