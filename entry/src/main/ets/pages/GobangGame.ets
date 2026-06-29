// 五子棋游戏主页面 - 手机端（支持分布式流转）
import { 
  ChessType, 
  GameMode, 
  GameState,
  GameBoard,
  WinChecker,
  AIPlayer,
  BoardDrawer,
  DrawParams,
  DistributedManager,
  DeviceInfo,
  SerializableGameState
} from 'common';

@Entry
@Component
struct GobangGame {
  // 游戏状态
  @State private gameBoard: GameBoard = new GameBoard();
  @State private gameMode: string = GameMode.PVP;
  @State private winLine: WinLine | null = null;
  @State private lastMoveX: number = -1;
  @State private lastMoveY: number = -1;
  @State private isAIThinking: boolean = false;
  
  // 统计信息
  @State private blackWins: number = 0;
  @State private whiteWins: number = 0;
  @State private draws: number = 0;
  @State private totalGames: number = 0;
  
  // 分布式流转
  @State private showDeviceList: boolean = false;
  @State private deviceList: DeviceInfo[] = [];
  @State private isMigrating: boolean = false;
  private distributedManager: DistributedManager = new DistributedManager();
  
  // 画布相关
  private boardDrawer: BoardDrawer = new BoardDrawer();
  private settings2D: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings2D);
  private canvasWidth: number = 0;
  private canvasHeight: number = 0;
  private isCanvasReady: boolean = false;

  aboutToAppear(): void {
    // 初始化游戏
    this.initGame();
    
    // 初始化分布式管理器
    this.initDistributed();
  }

  aboutToDisappear(): void {
    // 释放分布式管理器
    this.distributedManager.release();
  }

  // 初始化游戏
  private initGame(): void {
    this.gameBoard = new GameBoard();
    this.winLine = null;
    this.lastMoveX = -1;
    this.lastMoveY = -1;
    this.isAIThinking = false;
  }

  // 初始化分布式管理器
  private initDistributed(): void {
    this.distributedManager.setCallback({
      onDeviceFound: (devices: DeviceInfo[]) => {
        this.deviceList = devices;
      },
      onStateChanged: (state: string) => {
        console.info('Distributed state changed:', state);
        if (state === 'migrated') {
          this.isMigrating = false;
        }
      },
      onError: (error: string) => {
        console.error('Distributed error:', error);
        this.isMigrating = false;
      }
    });
  }

  build() {
    Column() {
      // 标题栏
      this.TitleBar();
      
      // 状态栏
      this.StatusBar();
      
      // 棋盘画布
      this.BoardCanvas();
      
      // 控制面板
      this.ControlPanel();
      
      // 统计信息
      this.StatsPanel();
      
      // 设备列表弹窗
      if (this.showDeviceList) {
        this.DeviceListDialog();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }

  // 标题栏
  @Builder
  TitleBar() {
    Row() {
      Text('五子棋')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333');
      
      Blank();
      
      // 分布式流转按钮
      if (this.distributedManager.isDistributedSupported()) {
        Button('流转')
          .fontSize(14)
          .height(32)
          .backgroundColor('#9C27B0')
          .fontColor('#FFFFFF')
          .enabled(!this.isMigrating && !this.isGameOver())
          .onClick(() => {
            this.showDeviceList = true;
            this.distributedManager.discoverDevices();
          });
      }
    }
    .width('100%')
    .height(50)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 2, color: '#CCCCCC', offsetY: 2 });
  }

  // 状态栏
  @Builder
  StatusBar() {
    Row() {
      // 当前玩家
      Text(this.getCurrentPlayerText())
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentPlayerColor());
      
      Blank();
      
      // 游戏模式
      Text(this.gameMode === GameMode.PVP ? '双人对战' : '人机对战')
        .fontSize(14)
        .fontColor('#666666');
    }
    .width('90%')
    .height(40)
    .justifyContent(FlexAlign.SpaceBetween);
  }

  // 棋盘画布
  @Builder
  BoardCanvas() {
    Column() {
      Canvas(this.context)
        .width('90%')
        .aspectRatio(1)
        .backgroundColor('#DEB887')
        .border({ width: 2, color: '#8B4513' })
        .onReady(() => {
          this.onCanvasReady();
        })
        .onClick((event: ClickEvent) => {
          this.onCanvasClick(event.x, event.y);
        });
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({ top: 10, bottom: 10 });
  }

  // 控制面板
  @Builder
  ControlPanel() {
    Column() {
      Row() {
        // 悔棋按钮
        Button('悔棋')
          .width('22%')
          .height(40)
          .fontSize(14)
          .enabled(this.canUndo())
          .backgroundColor(this.canUndo() ? '#4CAF50' : '#CCCCCC')
          .onClick(() => this.undo());
        
        Blank().width('3%');
        
        // 重置按钮
        Button('重置')
          .width('22%')
          .height(40)
          .fontSize(14)
          .backgroundColor('#FF9800')
          .onClick(() => this.reset());
        
        Blank().width('3%');
        
        // 切换模式按钮
        Button(this.gameMode === GameMode.PVP ? '人机模式' : '双人模式')
          .width('22%')
          .height(40)
          .fontSize(14)
          .backgroundColor('#2196F3')
          .onClick(() => this.toggleGameMode());
        
        Blank().width('3%');
        
        // 交换先后手按钮
        Button('交换先手')
          .width('22%')
          .height(40)
          .fontSize(14)
          .enabled(this.canSwitchFirstPlayer())
          .backgroundColor(this.canSwitchFirstPlayer() ? '#9C27B0' : '#CCCCCC')
          .onClick(() => this.switchFirstPlayer());
      }
      .width('90%')
      .justifyContent(FlexAlign.Start);
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 });
  }

  // 统计信息
  @Builder
  StatsPanel() {
    Row() {
      Text(`黑方: ${this.blackWins}胜`)
        .fontSize(12)
        .fontColor('#333333');
      
      Text(`白方: ${this.whiteWins}胜`)
        .fontSize(12)
        .fontColor('#333333');
      
      Text(`和棋: ${this.draws}局`)
        .fontSize(12)
        .fontColor('#333333');
      
      Text(`总计: ${this.totalGames}局`)
        .fontSize(12)
        .fontColor('#333333');
    }
    .width('90%')
    .height(30)
    .justifyContent(FlexAlign.SpaceBetween);
  }

  // 设备列表弹窗
  @Builder
  DeviceListDialog() {
    Column() {
      // 标题
      Row() {
        Text('选择目标设备')
          .fontSize(18)
          .fontWeight(FontWeight.Bold);
        
        Blank();
        
        Button('关闭')
          .fontSize(14)
          .backgroundColor('#CCCCCC')
          .onClick(() => {
            this.showDeviceList = false;
            this.distributedManager.stopDiscovery();
          });
      }
      .width('100%')
      .padding(16);
      
      Divider();
      
      // 设备列表
      if (this.deviceList.length === 0) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50);
          
          Text('正在搜索设备...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 16 });
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center);
      } else {
        List() {
          ForEach(this.deviceList, (device: DeviceInfo) => {
            ListItem() {
              Row() {
                Column() {
                  Text(device.deviceName)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold);
                  
                  Text(device.deviceType)
                    .fontSize(12)
                    .fontColor('#666666');
                }
                .alignItems(HorizontalAlign.Start);
                
                Blank();
                
                Button('迁移')
                  .fontSize(14)
                  .backgroundColor('#4CAF50')
                  .enabled(!this.isMigrating)
                  .onClick(() => {
                    this.migrateToDevice(device.deviceId);
                  });
              }
              .width('100%')
              .padding(16);
            }
          });
        }
        .width('100%')
        .layoutWeight(1);
      }
    }
    .width('80%')
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .shadow({ radius: 10, color: '#000000', offsetY: 5 });
  }

  // Canvas准备完成
  private onCanvasReady(): void {
    const width: number = this.context.width;
    const height: number = this.context.height;
    
    this.canvasWidth = width;
    this.canvasHeight = height;
    this.isCanvasReady = true;
    
    // 初始化绘制器
    this.boardDrawer.initSize(this.canvasWidth, this.canvasHeight);
    
    // 绘制棋盘
    this.drawBoard();
  }

  // 绘制棋盘
  private drawBoard(): void {
    if (!this.isCanvasReady) return;
    
    const params: DrawParams = {
      board: this.gameBoard,
      winLine: this.winLine,
      lastMoveX: this.lastMoveX,
      lastMoveY: this.lastMoveY
    };
    
    this.boardDrawer.drawBoard(this.context, params);
  }

  // Canvas点击事件
  private onCanvasClick(x: number, y: number): void {
    // 检查游戏是否结束
    if (this.isGameOver()) return;
    
    // 检查AI是否在思考
    if (this.isAIThinking) return;
    
    // 转换坐标
    const pos = this.boardDrawer.pixelToBoard(x, y);
    if (!pos) return;
    
    // 尝试落子
    if (this.placeChess(pos.x, pos.y)) {
      // 检查游戏结果
      const result: string = WinChecker.checkGameResult(this.gameBoard, pos.x, pos.y);
      
      if (result !== GameState.PLAYING) {
        this.handleGameEnd(result);
      } else if (this.gameMode === GameMode.PVE && this.gameBoard.getCurrentPlayer() === ChessType.WHITE) {
        // AI回合
        this.makeAIMove();
      }
    }
  }

  // 落子
  private placeChess(x: number, y: number): boolean {
    if (!this.gameBoard.isEmpty(x, y)) return false;
    
    const currentPlayer: number = this.gameBoard.getCurrentPlayer();
    this.gameBoard.placeChess(x, y, currentPlayer);
    
    this.lastMoveX = x;
    this.lastMoveY = y;
    
    // 重绘棋盘
    this.drawBoard();
    
    return true;
  }

  // AI落子
  private async makeAIMove(): Promise<void> {
    this.isAIThinking = true;
    
    // 延迟500ms模拟思考
    await AIPlayer.delay(500);
    
    const aiColor: number = ChessType.WHITE;
    const pos = AIPlayer.getBestMove(this.gameBoard, aiColor);
    
    if (pos) {
      if (this.placeChess(pos.x, pos.y)) {
        const result: string = WinChecker.checkGameResult(this.gameBoard, pos.x, pos.y);
        
        if (result !== GameState.PLAYING) {
          this.handleGameEnd(result);
        }
      }
    }
    
    this.isAIThinking = false;
  }

  // 处理游戏结束
  private handleGameEnd(result: string): void {
    // 更新统计
    this.totalGames++;
    
    if (result === GameState.BLACK_WIN) {
      this.blackWins++;
      // 检查胜利连线
      this.winLine = WinChecker.checkWin(this.gameBoard, this.lastMoveX, this.lastMoveY);
    } else if (result === GameState.WHITE_WIN) {
      this.whiteWins++;
      // 检查胜利连线
      this.winLine = WinChecker.checkWin(this.gameBoard, this.lastMoveX, this.lastMoveY);
    } else {
      this.draws++;
    }
    
    // 重绘棋盘（显示胜利连线）
    this.drawBoard();
  }

  // 悔棋
  private undo(): void {
    if (this.gameMode === GameMode.PVE) {
      // 人机模式悔两步
      this.gameBoard.undo();
      this.gameBoard.undo();
    } else {
      // 双人模式悔一步
      this.gameBoard.undo();
    }
    
    // 更新最后落子位置
    this.lastMoveX = this.gameBoard.getLastMoveX();
    this.lastMoveY = this.gameBoard.getLastMoveY();
    
    // 清除胜利连线
    this.winLine = null;
    
    // 重绘棋盘
    this.drawBoard();
  }

  // 重置游戏
  private reset(): void {
    this.initGame();
    this.drawBoard();
  }

  // 切换游戏模式
  private toggleGameMode(): void {
    this.gameMode = this.gameMode === GameMode.PVP ? GameMode.PVE : GameMode.PVP;
    this.reset();
  }

  // 交换先后手
  private switchFirstPlayer(): void {
    this.reset();
  }

  // 迁移到目标设备
  private migrateToDevice(deviceId: string): void {
    this.isMigrating = true;
    
    const success = this.distributedManager.migrateGameState(this.gameBoard, deviceId);
    
    if (success) {
      console.info('Game state migrated successfully');
    } else {
      this.isMigrating = false;
    }
    
    this.showDeviceList = false;
    this.distributedManager.stopDiscovery();
  }

  // 获取当前玩家文本
  private getCurrentPlayerText(): string {
    if (this.isGameOver()) {
      if (this.winLine) {
        const winner: number = this.gameBoard.getChess(this.winLine.startX, this.winLine.startY);
        return winner === ChessType.BLACK ? '黑方获胜！' : '白方获胜！';
      }
      return '和棋！';
    }
    
    if (this.isAIThinking) {
      return 'AI思考中...';
    }
    
    const currentPlayer: number = this.gameBoard.getCurrentPlayer();
    return currentPlayer === ChessType.BLACK ? '黑方回合' : '白方回合';
  }

  // 获取当前玩家颜色
  private getCurrentPlayerColor(): string {
    if (this.isGameOver()) {
      return '#FF0000';
    }
    
    const currentPlayer: number = this.gameBoard.getCurrentPlayer();
    return currentPlayer === ChessType.BLACK ? '#000000' : '#666666';
  }

  // 检查游戏是否结束
  private isGameOver(): boolean {
    return this.winLine !== null || this.gameBoard.isBoardFull();
  }

  // 检查是否可以悔棋
  private canUndo(): boolean {
    if (this.isGameOver()) return false;
    if (this.isAIThinking) return false;
    
    const moveCount: number = this.gameBoard.getMoveCount();
    if (this.gameMode === GameMode.PVE) {
      return moveCount >= 2;
    }
    return moveCount > 0;
  }

  // 检查是否可以交换先后手
  private canSwitchFirstPlayer(): boolean {
    return this.gameBoard.getMoveCount() === 0 && !this.isAIThinking;
  }
}
