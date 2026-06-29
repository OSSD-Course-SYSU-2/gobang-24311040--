// 游戏常量定义 - Common模块
// 棋盘尺寸
export const BOARD_SIZE: number = 15; // 15x15棋盘
// 棋子类型
export class ChessType {
    static readonly EMPTY: number = 0; // 空位
    static readonly BLACK: number = 1; // 黑棋
    static readonly WHITE: number = 2; // 白棋
}
// 游戏模式
export class GameMode {
    static readonly PVP: string = 'pvp'; // 双人对战
    static readonly PVE: string = 'pve'; // 人机对战
}
// 游戏状态
export class GameState {
    static readonly PLAYING: string = 'playing'; // 游戏进行中
    static readonly BLACK_WIN: string = 'black_win'; // 黑方获胜
    static readonly WHITE_WIN: string = 'white_win'; // 白方获胜
    static readonly DRAW: string = 'draw'; // 和棋
}
// 棋盘颜色配置
export class BoardColors {
    static readonly background: string = '#DEB887'; // 原木浅黄色
    static readonly line: string = '#8B4513'; // 深棕色线条
    static readonly starPoint: string = '#000000'; // 星位点黑色
    static readonly blackChess: string = '#000000'; // 黑棋
    static readonly blackBorder: string = '#FFFFFF'; // 黑棋描边
    static readonly whiteChess: string = '#FFFFFF'; // 白棋
    static readonly whiteBorder: string = '#808080'; // 白棋描边
    static readonly winLine: string = '#FF0000'; // 胜利连线红色
}
// 星位点坐标接口
export interface StarPoint {
    x: number;
    y: number;
}
// 星位点坐标（天元和四角星）
export const STAR_POINTS: StarPoint[] = [
    { x: 7, y: 7 },
    { x: 3, y: 3 },
    { x: 3, y: 11 },
    { x: 11, y: 3 },
    { x: 11, y: 11 } // 右下星
];
// AI评分权重
export class AIScore {
    static readonly FIVE: number = 100000; // 五连
    static readonly LIVE_FOUR: number = 10000; // 活四
    static readonly DEAD_FOUR: number = 1000; // 冲四
    static readonly LIVE_THREE: number = 1000; // 活三
    static readonly DEAD_THREE: number = 100; // 眠三
    static readonly LIVE_TWO: number = 100; // 活二
    static readonly DEAD_TWO: number = 10; // 眠二
    static readonly CENTER: number = 5; // 中心位置加分
}
// 设备类型
export class DeviceType {
    static readonly PHONE: string = 'phone'; // 手机
    static readonly TABLET: string = 'tablet'; // 平板
    static readonly TV: string = 'tv'; // 智慧屏
    static readonly WIDGET: string = 'widget'; // 桌面卡片
}
