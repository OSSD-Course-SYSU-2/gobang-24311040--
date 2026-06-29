// 棋盘Canvas绘制组件
import { 
  BOARD_SIZE, 
  ChessType, 
  BoardColors, 
  STAR_POINTS,
  StarPoint
} from '../model/GameConstants';
import { GameBoard, WinLine } from '../model/GameModel';

// 绘制参数接口
export interface DrawParams {
  board: GameBoard;
  winLine: WinLine | null;
  lastMoveX: number;
  lastMoveY: number;
}

// 坐标接口
export interface BoardPosition {
  x: number;
  y: number;
}

export class BoardDrawer {
  private canvasWidth: number = 0;
  private canvasHeight: number = 0;
  private cellSize: number = 0;
  private padding: number = 0;
  private chessRadius: number = 0;

  // 初始化画布尺寸
  initSize(width: number, height: number): void {
    this.canvasWidth = width;
    this.canvasHeight = height;
    
    // 计算棋盘尺寸（正方形，留出边距）
    const minSize: number = Math.min(width, height);
    this.padding = minSize * 0.05; // 5%边距
    const boardSize: number = minSize - this.padding * 2;
    
    // 计算格子大小（14个格子）
    this.cellSize = boardSize / (BOARD_SIZE - 1);
    
    // 棋子半径（略小于格子的一半）
    this.chessRadius = this.cellSize * 0.42;
  }

  // 获取格子大小
  getCellSize(): number {
    return this.cellSize;
  }

  // 获取边距
  getPadding(): number {
    return this.padding;
  }

  // 绘制整个棋盘
  drawBoard(ctx: CanvasRenderingContext2D, params: DrawParams): void {
    if (this.cellSize === 0) return;

    // 清空画布
    ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    
    // 绘制棋盘背景
    this.drawBackground(ctx);
    
    // 绘制棋盘线条
    this.drawLines(ctx);
    
    // 绘制星位点
    this.drawStarPoints(ctx);
    
    // 绘制所有棋子
    this.drawAllChess(ctx, params.board);
    
    // 绘制胜利连线
    if (params.winLine) {
      this.drawWinLine(ctx, params.winLine);
    }
    
    // 绘制最后落子标记
    if (params.lastMoveX >= 0 && params.lastMoveY >= 0) {
      this.drawLastMoveMark(ctx, params.lastMoveX, params.lastMoveY, params.board);
    }
  }

  // 绘制棋盘背景
  private drawBackground(ctx: CanvasRenderingContext2D): void {
    ctx.fillStyle = BoardColors.background;
    ctx.fillRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  // 绘制棋盘线条
  private drawLines(ctx: CanvasRenderingContext2D): void {
    ctx.strokeStyle = BoardColors.line;
    ctx.lineWidth = 1;
    
    // 绘制横线
    for (let i: number = 0; i < BOARD_SIZE; i++) {
      const y: number = this.padding + i * this.cellSize;
      ctx.beginPath();
      ctx.moveTo(this.padding, y);
      ctx.lineTo(this.padding + (BOARD_SIZE - 1) * this.cellSize, y);
      ctx.stroke();
    }
    
    // 绘制竖线
    for (let i: number = 0; i < BOARD_SIZE; i++) {
      const x: number = this.padding + i * this.cellSize;
      ctx.beginPath();
      ctx.moveTo(x, this.padding);
      ctx.lineTo(x, this.padding + (BOARD_SIZE - 1) * this.cellSize);
      ctx.stroke();
    }
  }

  // 绘制星位点
  private drawStarPoints(ctx: CanvasRenderingContext2D): void {
    ctx.fillStyle = BoardColors.starPoint;
    const radius: number = this.cellSize * 0.08; // 星位点半径
    
    for (let i: number = 0; i < STAR_POINTS.length; i++) {
      const point: StarPoint = STAR_POINTS[i];
      const x: number = this.padding + point.x * this.cellSize;
      const y: number = this.padding + point.y * this.cellSize;
      
      ctx.beginPath();
      ctx.arc(x, y, radius, 0, 2 * Math.PI);
      ctx.fill();
    }
  }

  // 绘制所有棋子
  private drawAllChess(ctx: CanvasRenderingContext2D, board: GameBoard): void {
    for (let x: number = 0; x < BOARD_SIZE; x++) {
      for (let y: number = 0; y < BOARD_SIZE; y++) {
        const chess: number = board.getChess(x, y);
        if (chess !== ChessType.EMPTY) {
          this.drawChess(ctx, x, y, chess);
        }
      }
    }
  }

  // 绘制单个棋子
  drawChess(ctx: CanvasRenderingContext2D, x: number, y: number, color: number): void {
    const centerX: number = this.padding + x * this.cellSize;
    const centerY: number = this.padding + y * this.cellSize;
    
    ctx.beginPath();
    ctx.arc(centerX, centerY, this.chessRadius, 0, 2 * Math.PI);
    
    if (color === ChessType.BLACK) {
      // 黑棋
      ctx.fillStyle = BoardColors.blackChess;
      ctx.fill();
      ctx.strokeStyle = BoardColors.blackBorder;
      ctx.lineWidth = 1;
      ctx.stroke();
    } else {
      // 白棋
      ctx.fillStyle = BoardColors.whiteChess;
      ctx.fill();
      ctx.strokeStyle = BoardColors.whiteBorder;
      ctx.lineWidth = 2;
      ctx.stroke();
    }
  }

  // 绘制胜利连线
  private drawWinLine(ctx: CanvasRenderingContext2D, winLine: WinLine): void {
    const startX: number = this.padding + winLine.startX * this.cellSize;
    const startY: number = this.padding + winLine.startY * this.cellSize;
    const endX: number = this.padding + winLine.endX * this.cellSize;
    const endY: number = this.padding + winLine.endY * this.cellSize;
    
    ctx.strokeStyle = BoardColors.winLine;
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.moveTo(startX, startY);
    ctx.lineTo(endX, endY);
    ctx.stroke();
  }

  // 绘制最后落子标记
  private drawLastMoveMark(ctx: CanvasRenderingContext2D, x: number, y: number, board: GameBoard): void {
    const centerX: number = this.padding + x * this.cellSize;
    const centerY: number = this.padding + y * this.cellSize;
    const markRadius: number = this.chessRadius * 0.3;
    
    const chess: number = board.getChess(x, y);
    if (chess === ChessType.BLACK) {
      ctx.fillStyle = '#FFFFFF';
    } else {
      ctx.fillStyle = '#FF0000';
    }
    
    ctx.beginPath();
    ctx.arc(centerX, centerY, markRadius, 0, 2 * Math.PI);
    ctx.fill();
  }

  // 像素坐标转棋盘坐标
  pixelToBoard(pixelX: number, pixelY: number): BoardPosition | null {
    // 计算相对棋盘的位置
    const relX: number = pixelX - this.padding;
    const relY: number = pixelY - this.padding;
    
    // 转换为棋盘坐标
    const x: number = Math.round(relX / this.cellSize);
    const y: number = Math.round(relY / this.cellSize);
    
    // 检查是否在有效范围内
    if (x < 0 || x >= BOARD_SIZE || y < 0 || y >= BOARD_SIZE) {
      return null;
    }
    
    const pos: BoardPosition = { x: x, y: y };
    return pos;
  }
}
