// 可序列化的游戏状态 - 用于分布式流转
import { BOARD_SIZE, ChessType, GameMode, GameState } from './GameConstants';

// 落子历史记录
export interface ChessMove {
  x: number;        // 棋盘x坐标 (0-14)
  y: number;        // 棋盘y坐标 (0-14)
  color: number;    // 棋子颜色 (ChessType.BLACK 或 ChessType.WHITE)
  timestamp: number; // 落子时间戳
}

// 胜利连线信息
export interface WinLine {
  startX: number;   // 起点x坐标
  startY: number;   // 起点y坐标
  endX: number;     // 终点x坐标
  endY: number;     // 终点y坐标
  direction: string; // 连线方向描述
}

// 游戏统计信息
export interface GameStats {
  blackWins: number;   // 黑方胜场数
  whiteWins: number;   // 白方胜场数
  draws: number;       // 和棋场数
  totalGames: number;  // 总对局数
}

// 游戏设置
export interface GameSettings {
  mode: string;        // 游戏模式
  firstPlayer: number; // 先手方 (ChessType.BLACK 或 ChessType.WHITE)
  soundEnabled: boolean; // 是否开启音效
}

// 序列化状态接口
export interface SerializedGameState {
  board: number[][];
  history: ChessMove[];
  currentPlayer: number;
  gameMode: string;
  gameState: string;
  winLine: WinLine | null;
  moveCount: number;
  lastMoveX: number;
  lastMoveY: number;
  deviceId: string;
}

// 可序列化的游戏状态类
export class SerializableGameState {
  // 棋盘状态二维数组
  board: number[][] = [];
  // 落子历史栈
  history: ChessMove[] = [];
  // 当前落子方
  currentPlayer: number = ChessType.BLACK;
  // 游戏模式
  gameMode: string = GameMode.PVP;
  // 游戏状态
  gameState: string = GameState.PLAYING;
  // 胜利连线信息
  winLine: WinLine | null = null;
  // 落子计数
  moveCount: number = 0;
  // 最后落子X坐标
  lastMoveX: number = -1;
  // 最后落子Y坐标
  lastMoveY: number = -1;
  // 设备ID（用于流转）
  deviceId: string = '';

  constructor() {
    this.board = this.createEmptyBoard();
  }

  // 创建空棋盘
  private createEmptyBoard(): number[][] {
    const board: number[][] = [];
    for (let i = 0; i < BOARD_SIZE; i++) {
      board[i] = [];
      for (let j = 0; j < BOARD_SIZE; j++) {
        board[i][j] = ChessType.EMPTY;
      }
    }
    return board;
  }

  // 序列化为JSON字符串
  serialize(): string {
    const data: SerializedGameState = {
      board: this.board,
      history: this.history,
      currentPlayer: this.currentPlayer,
      gameMode: this.gameMode,
      gameState: this.gameState,
      winLine: this.winLine,
      moveCount: this.moveCount,
      lastMoveX: this.lastMoveX,
      lastMoveY: this.lastMoveY,
      deviceId: this.deviceId
    };
    return JSON.stringify(data);
  }

  // 从JSON字符串反序列化
  static deserialize(jsonStr: string): SerializableGameState {
    const state = new SerializableGameState();
    try {
      const data = JSON.parse(jsonStr) as SerializedGameState;
      state.board = data.board;
      state.history = data.history;
      state.currentPlayer = data.currentPlayer;
      state.gameMode = data.gameMode;
      state.gameState = data.gameState;
      state.winLine = data.winLine;
      state.moveCount = data.moveCount;
      state.lastMoveX = data.lastMoveX;
      state.lastMoveY = data.lastMoveY;
      state.deviceId = data.deviceId;
    } catch (e) {
      console.error('Failed to deserialize game state:', e);
    }
    return state;
  }

  // 深拷贝
  clone(): SerializableGameState {
    const cloned = new SerializableGameState();
    cloned.board = JSON.parse(JSON.stringify(this.board));
    cloned.history = JSON.parse(JSON.stringify(this.history));
    cloned.currentPlayer = this.currentPlayer;
    cloned.gameMode = this.gameMode;
    cloned.gameState = this.gameState;
    cloned.winLine = this.winLine ? JSON.parse(JSON.stringify(this.winLine)) : null;
    cloned.moveCount = this.moveCount;
    cloned.lastMoveX = this.lastMoveX;
    cloned.lastMoveY = this.lastMoveY;
    cloned.deviceId = this.deviceId;
    return cloned;
  }
}
