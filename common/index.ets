// Common模块导出 - 五子棋游戏公共模块
// 导出常量
export { 
  BOARD_SIZE,
  ChessType,
  GameMode,
  GameState,
  BoardColors,
  STAR_POINTS,
  AIScore,
  DeviceType
} from './src/main/ets/model/GameConstants';

// 导出数据模型
export { 
  ChessMove,
  WinLine,
  GameStats,
  GameSettings,
  SerializableGameState
} from './src/main/ets/model/SerializableGameState';

export { GameBoard } from './src/main/ets/model/GameBoard';

// 导出工具类
export { WinChecker, LineInfo } from './src/main/ets/utils/WinChecker';
export { AIPlayer } from './src/main/ets/utils/AIPlayer';
export { DistributedManager, DeviceInfo, DistributedCallback } from './src/main/ets/utils/DistributedManager';

// 导出组件
export { BoardDrawer, DrawParams, BoardPosition } from './src/main/ets/components/BoardDrawer';
