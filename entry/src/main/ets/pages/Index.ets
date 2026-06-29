// 启动页面 - 自动跳转到游戏页面
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    // 延迟跳转，确保页面加载完成
    setTimeout(() => {
      this.navigateToGame();
    }, 100);
  }

  // 跳转到游戏页面
  private navigateToGame(): void {
    router.pushUrl({
      url: 'pages/GobangGame'
    }).catch((error: Error) => {
      console.error('Failed to navigate to game page:', error.message);
    });
  }

  build() {
    Column() {
      // 显示加载提示
      Column() {
        Text('五子棋')
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 20 });
        
        Text('加载中...')
          .fontSize(20)
          .fontColor('#666666');
        
        LoadingProgress()
          .width(50)
          .height(50)
          .margin({ top: 20 })
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
