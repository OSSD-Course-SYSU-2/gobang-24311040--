// AI对战逻辑 - Common模块
import { 
  BOARD_SIZE, 
  ChessType, 
  AIScore,
  STAR_POINTS,
  StarPoint
} from '../model/GameConstants';
import { GameBoard } from '../model/GameBoard';
import { WinChecker, LineInfo } from '../utils/WinChecker';

// 位置评分接口
interface PositionScore {
  x: number;
  y: number;
  score: number;
}

// 坐标接口
interface Position {
  x: number;
  y: number;
}

// 方向接口
interface Direction {
  dx: number;
  dy: number;
}

export class AIPlayer {
  // 获取AI的最佳落子位置
  static getBestMove(board: GameBoard, aiColor: number): Position | null {
    const candidatePositions: Position[] = AIPlayer.getCandidatePositions(board);
    
    if (candidatePositions.length === 0) {
      // 如果没有候选位置，返回中心点
      const centerPos: Position = { x: 7, y: 7 };
      return centerPos;
    }

    // 计算每个位置的分数
    const scores: PositionScore[] = [];
    const playerColor: number = aiColor === ChessType.BLACK ? ChessType.WHITE : ChessType.BLACK;

    for (let i: number = 0; i < candidatePositions.length; i++) {
      const pos: Position = candidatePositions[i];
      const attackScore: number = AIPlayer.evaluatePosition(board, pos.x, pos.y, aiColor);
      const defenseScore: number = AIPlayer.evaluatePosition(board, pos.x, pos.y, playerColor);
      
      // 进攻和防守的权重平衡
      const totalScore: number = attackScore * 1.1 + defenseScore;
      
      const posScore: PositionScore = {
        x: pos.x,
        y: pos.y,
        score: totalScore
      };
      scores.push(posScore);
    }

    // 按分数排序
    scores.sort((a: PositionScore, b: PositionScore): number => b.score - a.score);

    // 返回最高分的位置
    const bestPos: Position = { x: scores[0].x, y: scores[0].y };
    return bestPos;
  }

  // 获取候选位置（已有棋子周围的空位）
  private static getCandidatePositions(board: GameBoard): Position[] {
    const positions: Position[] = [];
    const checked: Set<string> = new Set<string>();

    // 遍历棋盘，找到所有棋子周围的空位
    for (let x: number = 0; x < BOARD_SIZE; x++) {
      for (let y: number = 0; y < BOARD_SIZE; y++) {
        if (board.getChess(x, y) !== ChessType.EMPTY) {
          // 检查周围2格范围内的空位
          for (let dx: number = -2; dx <= 2; dx++) {
            for (let dy: number = -2; dy <= 2; dy++) {
              const newX: number = x + dx;
              const newY: number = y + dy;
              const key: string = `${newX},${newY}`;
              
              if (
                AIPlayer.isValidPosition(newX, newY) &&
                board.isEmpty(newX, newY) &&
                !checked.has(key)
              ) {
                const pos: Position = { x: newX, y: newY };
                positions.push(pos);
                checked.add(key);
              }
            }
          }
        }
      }
    }

    return positions;
  }

  // 评估位置分数
  private static evaluatePosition(
    board: GameBoard,
    x: number,
    y: number,
    color: number
  ): number {
    let score: number = 0;

    // 四个方向评分
    const directions: Direction[] = [
      { dx: 1, dy: 0 },
      { dx: 0, dy: 1 },
      { dx: 1, dy: 1 },
      { dx: 1, dy: -1 }
    ];

    for (let i: number = 0; i < directions.length; i++) {
      const dir: Direction = directions[i];
      score += AIPlayer.evaluateDirection(board, x, y, dir.dx, dir.dy, color);
    }

    // 中心位置加分
    score += AIPlayer.getCenterBonus(x, y);

    return score;
  }

  // 评估单个方向的分数
  private static evaluateDirection(
    board: GameBoard,
    x: number,
    y: number,
    dx: number,
    dy: number,
    color: number
  ): number {
    // 临时放置棋子
    board.setChess(x, y, color);
    
    const lineInfo: LineInfo = WinChecker.countLine(board, x, y, dx, dy, color);
    
    // 移除临时棋子
    board.setChess(x, y, ChessType.EMPTY);

    const count: number = lineInfo.count;
    const blocked: number = lineInfo.blocked;

    // 根据连子数和封堵情况评分
    if (count >= 5) {
      return AIScore.FIVE;
    } else if (count === 4) {
      if (blocked === 0) {
        return AIScore.LIVE_FOUR;
      } else if (blocked === 1) {
        return AIScore.DEAD_FOUR;
      }
    } else if (count === 3) {
      if (blocked === 0) {
        return AIScore.LIVE_THREE;
      } else if (blocked === 1) {
        return AIScore.DEAD_THREE;
      }
    } else if (count === 2) {
      if (blocked === 0) {
        return AIScore.LIVE_TWO;
      } else if (blocked === 1) {
        return AIScore.DEAD_TWO;
      }
    }

    return 0;
  }

  // 获取中心位置加分
  private static getCenterBonus(x: number, y: number): number {
    const centerX: number = 7;
    const centerY: number = 7;
    const distance: number = Math.abs(x - centerX) + Math.abs(y - centerY);
    
    // 检查是否是星位点
    for (let i: number = 0; i < STAR_POINTS.length; i++) {
      const point: StarPoint = STAR_POINTS[i];
      if (x === point.x && y === point.y) {
        return AIScore.CENTER * 2;
      }
    }
    
    // 距离中心越近，分数越高
    return Math.max(0, AIScore.CENTER * (14 - distance));
  }

  // 检查位置是否有效
  private static isValidPosition(x: number, y: number): boolean {
    return x >= 0 && x < BOARD_SIZE && y >= 0 && y < BOARD_SIZE;
  }

  // 延迟执行（模拟思考时间）
  static async delay(ms: number): Promise<void> {
    return new Promise<void>((resolve: Function) => setTimeout(resolve, ms));
  }
}
