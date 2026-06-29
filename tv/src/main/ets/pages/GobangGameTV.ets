// 五子棋游戏主页面 - TV端（适配大屏和遥控器交互）
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
  DeviceInfo
} from 'common';

@Entry
@Component
struct GobangGameTV {
  // 游戏状态
  @State private gameBoard: GameBoard = new GameBoard();
  @State private gameMode: string = GameMode.PVP;
  @State private winLine: WinLine | null = null;
  @State private lastMoveX: number = -1;
  @State private lastMoveY: number = -1;
  @State private isAIThinking: boolean = false;
  
  // 遥控器焦点位置
  @State private focusX: number = 7;
  @State private focusY: number = 7;
  
  // 统计信息
  @State private blackWins: number = 0;
  @State private whiteWins: number = 0;
  @State private draws: number = 0;
  @State private totalGames: number = 0;
  
  // 分布式流转
  @State private showDeviceList: boolean = false;
  @State private deviceList: DeviceInfo[] = [];
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
    this.focusX = 7;
    this.focusY = 7;
  }

  // 初始化分布式管理器
  private initDistributed(): void {
    this.distributedManager.setCallback({
      onDeviceFound: (devices: DeviceInfo[]) => {
        this.deviceList = devices;
      },
      onStateChanged: (state: string) => {
        console.info('Distributed state changed:', state);
      },
      onError: (error: string) => {
        console.error('Distributed error:', error);
      }
    });
  }

  build() {
    Row() {
      // 左侧：棋盘区域
      Column() {
        // 标题
        Text('五子棋')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 20 });
        
        // 棋盘画布
        this.BoardCanvas();
      }
      .width('65%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F5F5F5');
      
      // 右侧：控制面板
      Column() {
        // 状态信息
        this.StatusPanel();
        
        Divider().margin({ top: 20, bottom: 20 });
        
        // 控制按钮
        this.ControlPanel();
        
        Divider().margin({ top: 20, bottom: 20 });
        
        // 统计信息
        this.StatsPanel();
        
        Blank();
        
        // 分布式流转按钮
        if (this.distributedManager.isDistributedSupported()) {
          Button('流转到其他设备')
            .width('80%')
            .height(50)
            .fontSize(18)
            .backgroundColor('#9C27B0')
            .fontColor('#FFFFFF')
            .margin({ bottom: 20 })
            .onClick(() => {
              this.showDeviceList = true;
              this.distributedManager.discoverDevices();
            });
        }
        
        // 操作提示
        Text('方向键移动焦点')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 10 });
        
        Text('确认键落子')
          .fontSize(14)
          .fontColor('#999999');
      }
      .width('35%')
      .height('100%')
      .padding(30)
      .backgroundColor('#FFFFFF');
    }
    .width('100%')
    .height('100%');
  }

  // 状态面板
  @Builder
  StatusPanel() {
    Column() {
      Text('游戏状态')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 });
      
      // 当前玩家
      Row() {
        Text('当前回合：')
          .fontSize(18);
        
        Text(this.getCurrentPlayerText())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getCurrentPlayerColor());
      }
      .width('100%')
      .margin({ bottom: 15 });
      
      // 游戏模式
      Row() {
        Text('游戏模式：')
          .fontSize(18);
        
        Text(this.gameMode === GameMode.PVP ? '双人对战' : '人机对战')
          .fontSize(18);
      }
      .width('100%');
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  // 棋盘画布
  @Builder
  BoardCanvas() {
    Stack() {
      Canvas(this.context)
        .width('90%')
        .aspectRatio(1)
        .backgroundColor('#DEB887')
        .border({ width: 3, color: '#8B4513' })
        .onReady(() => {
          this.onCanvasReady();
        });
      
      // 焦点指示器
      if (!this.isGameOver() && !this.isAIThinking) {
        this.FocusIndicator();
      }
    }
    .width('90%')
    .aspectRatio(1);
  }

  // 焦点指示器
  @Builder
  FocusIndicator() {
    // 这里需要根据focusX和focusY计算位置
    // 实际实现需要根据canvas尺寸动态计算
    Row() {
      Text('●')
        .fontSize(40)
        .fontColor('#FF0000')
        .opacity(0.5);
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center);
  }

  // 控制面板
  @Builder
  ControlPanel() {
    Column() {
      Text('游戏控制')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 });
      
      // 悔棋按钮
      Button('悔棋')
        .width('80%')
        .height(50)
        .fontSize(18)
        .enabled(this.canUndo())
        .backgroundColor(this.canUndo() ? '#4CAF50' : '#CCCCCC')
        .margin({ bottom: 15 })
        .onClick(() => this.undo());
      
      // 重置按钮
      Button('重置游戏')
        .width('80%')
        .height(50)
        .fontSize(18)
        .backgroundColor('#FF9800')
        .margin({ bottom: 15 })
        .onClick(() => this.reset());
      
      // 切换模式按钮
      Button(this.gameMode === GameMode.PVP ? '切换到人机模式' : '切换到双人模式')
        .width('80%')
        .height(50)
        .fontSize(18)
        .backgroundColor('#2196F3')
        .margin({ bottom: 15 })
        .onClick(() => this.toggleGameMode());
      
      // 交换先后手按钮
      Button('交换先后手')
        .width('80%')
        .height(50)
        .fontSize(18)
        .enabled(this.canSwitchFirstPlayer())
        .backgroundColor(this.canSwitchFirstPlayer() ? '#9C27B0' : '#CCCCCC')
        .onClick(() => this.switchFirstPlayer());
    }
    .width('100%');
  }

  // 统计面板
  @Builder
  StatsPanel() {
    Column() {
      Text('游戏统计')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 });
      
      Row() {
        Text(`黑方：${this.blackWins}胜`)
          .fontSize(16)
          .layoutWeight(1);
        
        Text(`白方：${this.whiteWins}胜`)
          .fontSize(16)
          .layoutWeight(1);
      }
      .width('100%')
      .margin({ bottom: 10 });
      
      Row() {
        Text(`和棋：${this.draws}局`)
          .fontSize(16)
          .layoutWeight(1);
        
        Text(`总计：${this.totalGames}局`)
          .fontSize(16)
          .layoutWeight(1);
      }
      .width('100%');
    }
    .width('100%');
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
    this.totalGames++;
    
    if (result === GameState.BLACK_WIN) {
      this.blackWins++;
      this.winLine = WinChecker.checkWin(this.gameBoard, this.lastMoveX, this.lastMoveY);
    } else if (result === GameState.WHITE_WIN) {
      this.whiteWins++;
      this.winLine = WinChecker.checkWin(this.gameBoard, this.lastMoveX, this.lastMoveY);
    } else {
      this.draws++;
    }
    
    this.drawBoard();
  }

  // 悔棋
  private undo(): void {
    if (this.gameMode === GameMode.PVE) {
      this.gameBoard.undo();
      this.gameBoard.undo();
    } else {
      this.gameBoard.undo();
    }
    
    this.lastMoveX = this.gameBoard.getLastMoveX();
    this.lastMoveY = this.gameBoard.getLastMoveY();
    this.winLine = null;
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
