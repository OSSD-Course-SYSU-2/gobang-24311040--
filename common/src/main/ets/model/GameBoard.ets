// 游戏状态管理类 - Common模块
import { ChessType, GameMode, GameState, BOARD_SIZE } from './GameConstants';
import { ChessMove, WinLine, GameStats, GameSettings, SerializableGameState } from './SerializableGameState';

export class GameBoard {
  private board: number[][];           // 棋盘状态二维数组
  private history: ChessMove[];        // 落子历史栈
  private currentPlayer: number;       // 当前落子方
  private gameState: string;           // 游戏状态
  private winLine: WinLine | null;     // 胜利连线信息
  private moveCount: number;           // 落子计数
  private lastMoveX: number;           // 最后落子X坐标
  private lastMoveY: number;           // 最后落子Y坐标

  constructor() {
    this.board = this.createEmptyBoard();
    this.history = [];
    this.currentPlayer = ChessType.BLACK;
    this.gameState = GameState.PLAYING;
    this.winLine = null;
    this.moveCount = 0;
    this.lastMoveX = -1;
    this.lastMoveY = -1;
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

  // 获取棋盘状态
  getBoard(): number[][] {
    return this.board;
  }

  // 获取指定位置的棋子
  getChess(x: number, y: number): number {
    if (x < 0 || x >= BOARD_SIZE || y < 0 || y >= BOARD_SIZE) {
      return -1; // 无效坐标
    }
    return this.board[x][y];
  }

  // 设置棋子
  setChess(x: number, y: number, color: number): void {
    if (x >= 0 && x < BOARD_SIZE && y >= 0 && y < BOARD_SIZE) {
      this.board[x][y] = color;
    }
  }

  // 获取当前玩家
  getCurrentPlayer(): number {
    return this.currentPlayer;
  }

  // 设置当前玩家
  setCurrentPlayer(player: number): void {
    this.currentPlayer = player;
  }

  // 切换玩家
  switchPlayer(): void {
    this.currentPlayer = this.currentPlayer === ChessType.BLACK 
      ? ChessType.WHITE 
      : ChessType.BLACK;
  }

  // 获取游戏状态
  getGameState(): string {
    return this.gameState;
  }

  // 设置游戏状态
  setGameState(state: string): void {
    this.gameState = state;
  }

  // 获取落子历史
  getHistory(): ChessMove[] {
    return this.history;
  }

  // 添加落子记录
  addMove(move: ChessMove): void {
    this.history.push(move);
    this.moveCount++;
  }

  // 移除最后一步落子
  removeLastMove(): ChessMove | null {
    if (this.history.length > 0) {
      this.moveCount--;
      const move = this.history.pop();
      return move !== undefined ? move : null;
    }
    return null;
  }

  // 获取落子数量
  getMoveCount(): number {
    return this.moveCount;
  }

  // 获取胜利连线
  getWinLine(): WinLine | null {
    return this.winLine;
  }

  // 设置胜利连线
  setWinLine(line: WinLine | null): void {
    this.winLine = line;
  }

  // 获取最后落子X坐标
  getLastMoveX(): number {
    return this.lastMoveX;
  }

  // 获取最后落子Y坐标
  getLastMoveY(): number {
    return this.lastMoveY;
  }

  // 检查位置是否为空
  isEmpty(x: number, y: number): boolean {
    return this.getChess(x, y) === ChessType.EMPTY;
  }

  // 检查游戏是否结束
  isGameOver(): boolean {
    return this.gameState !== GameState.PLAYING;
  }

  // 检查棋盘是否已满
  isBoardFull(): boolean {
    return this.moveCount >= BOARD_SIZE * BOARD_SIZE;
  }

  // 重置游戏
  reset(): void {
    this.board = this.createEmptyBoard();
    this.history = [];
    this.currentPlayer = ChessType.BLACK;
    this.gameState = GameState.PLAYING;
    this.winLine = null;
    this.moveCount = 0;
    this.lastMoveX = -1;
    this.lastMoveY = -1;
  }

  // 检查是否可以悔棋
  canUndo(): boolean {
    return this.history.length > 0 && !this.isGameOver();
  }

  // 检查是否可以切换先后手
  canSwitchFirstPlayer(): boolean {
    return this.moveCount === 0;
  }

  // 落子
  placeChess(x: number, y: number, color: number): void {
    this.setChess(x, y, color);
    const move: ChessMove = {
      x: x,
      y: y,
      color: color,
      timestamp: Date.now()
    };
    this.addMove(move);
    this.lastMoveX = x;
    this.lastMoveY = y;
    this.switchPlayer();
  }

  // 悔棋
  undo(): void {
    const lastMove: ChessMove | null = this.removeLastMove();
    if (lastMove) {
      this.setChess(lastMove.x, lastMove.y, ChessType.EMPTY);
      this.switchPlayer();
      // 更新最后落子位置
      if (this.history.length > 0) {
        const prevMove = this.history[this.history.length - 1];
        this.lastMoveX = prevMove.x;
        this.lastMoveY = prevMove.y;
      } else {
        this.lastMoveX = -1;
        this.lastMoveY = -1;
      }
    }
  }

  // 获取最后一步
  getLastMove(): ChessMove | undefined {
    if (this.history.length > 0) {
      return this.history[this.history.length - 1];
    }
    return undefined;
  }

  // 转换为可序列化状态（用于分布式流转）
  toSerializableState(deviceId: string): SerializableGameState {
    const state = new SerializableGameState();
    state.board = JSON.parse(JSON.stringify(this.board));
    state.history = JSON.parse(JSON.stringify(this.history));
    state.currentPlayer = this.currentPlayer;
    state.gameState = this.gameState;
    state.winLine = this.winLine ? JSON.parse(JSON.stringify(this.winLine)) : null;
    state.moveCount = this.moveCount;
    state.lastMoveX = this.lastMoveX;
    state.lastMoveY = this.lastMoveY;
    state.deviceId = deviceId;
    return state;
  }

  // 从可序列化状态恢复（用于分布式流转）
  fromSerializableState(state: SerializableGameState): void {
    this.board = JSON.parse(JSON.stringify(state.board));
    this.history = JSON.parse(JSON.stringify(state.history));
    this.currentPlayer = state.currentPlayer;
    this.gameState = state.gameState;
    this.winLine = state.winLine ? JSON.parse(JSON.stringify(state.winLine)) : null;
    this.moveCount = state.moveCount;
    this.lastMoveX = state.lastMoveX;
    this.lastMoveY = state.lastMoveY;
  }
}
