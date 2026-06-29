import { BOARD_SIZE, ChessType, GameState } from "@normalized:N&&&common/src/main/ets/model/GameConstants&";
import type { GameBoard } from '../model/GameBoard';
import type { WinLine } from '../model/SerializableGameState';
// 方向接口
interface Direction {
    dx: number;
    dy: number;
    name: string;
}
// 连子信息接口
export interface LineInfo {
    count: number;
    blocked: number;
}
export class WinChecker {
    // 检查是否获胜
    static checkWin(board: GameBoard, x: number, y: number): WinLine | null {
        const chess: number = board.getChess(x, y);
        if (chess === ChessType.EMPTY) {
            return null;
        }
        // 定义四个方向
        const directions: Direction[] = [
            { dx: 1, dy: 0, name: 'horizontal' },
            { dx: 0, dy: 1, name: 'vertical' },
            { dx: 1, dy: 1, name: 'diagonal' },
            { dx: 1, dy: -1, name: 'anti-diagonal' } // 反斜（右上到左下）
        ];
        // 检查四个方向
        for (let i: number = 0; i < directions.length; i++) {
            const dir: Direction = directions[i];
            const line: WinLine | null = WinChecker.checkDirection(board, x, y, dir.dx, dir.dy, chess);
            if (line) {
                return line;
            }
        }
        return null;
    }
    // 检查指定方向
    private static checkDirection(board: GameBoard, x: number, y: number, dx: number, dy: number, chess: number): WinLine | null {
        // 向正方向计数
        let count: number = 1;
        let startX: number = x;
        let startY: number = y;
        let endX: number = x;
        let endY: number = y;
        // 正方向搜索
        let i: number = 1;
        while (true) {
            const newX: number = x + i * dx;
            const newY: number = y + i * dy;
            if (!WinChecker.isValidPosition(newX, newY))
                break;
            if (board.getChess(newX, newY) !== chess)
                break;
            count++;
            endX = newX;
            endY = newY;
            i++;
        }
        // 反方向搜索
        i = 1;
        while (true) {
            const newX: number = x - i * dx;
            const newY: number = y - i * dy;
            if (!WinChecker.isValidPosition(newX, newY))
                break;
            if (board.getChess(newX, newY) !== chess)
                break;
            count++;
            startX = newX;
            startY = newY;
            i++;
        }
        // 判断是否五连
        if (count >= 5) {
            const winLine: WinLine = {
                startX: startX,
                startY: startY,
                endX: endX,
                endY: endY,
                direction: WinChecker.getDirectionName(dx, dy)
            };
            return winLine;
        }
        return null;
    }
    // 检查位置是否有效
    private static isValidPosition(x: number, y: number): boolean {
        return x >= 0 && x < BOARD_SIZE && y >= 0 && y < BOARD_SIZE;
    }
    // 获取方向名称
    private static getDirectionName(dx: number, dy: number): string {
        if (dx === 1 && dy === 0)
            return '水平';
        if (dx === 0 && dy === 1)
            return '垂直';
        if (dx === 1 && dy === 1)
            return '正斜';
        if (dx === 1 && dy === -1)
            return '反斜';
        return '未知';
    }
    // 检查是否和棋
    static checkDraw(board: GameBoard): boolean {
        return board.isBoardFull();
    }
    // 综合判定游戏结果
    static checkGameResult(board: GameBoard, x: number, y: number): string {
        // 先检查是否获胜
        const winLine: WinLine | null = WinChecker.checkWin(board, x, y);
        if (winLine) {
            const chess: number = board.getChess(x, y);
            return chess === ChessType.BLACK ? GameState.BLACK_WIN : GameState.WHITE_WIN;
        }
        // 再检查是否和棋
        if (WinChecker.checkDraw(board)) {
            return GameState.DRAW;
        }
        return GameState.PLAYING;
    }
    // 统计指定位置的连子数（用于AI评估）
    static countLine(board: GameBoard, x: number, y: number, dx: number, dy: number, chess: number): LineInfo {
        let count: number = 1;
        let blocked: number = 0;
        // 正方向
        let i: number = 1;
        while (true) {
            const newX: number = x + i * dx;
            const newY: number = y + i * dy;
            if (!WinChecker.isValidPosition(newX, newY)) {
                blocked++;
                break;
            }
            const c: number = board.getChess(newX, newY);
            if (c === chess) {
                count++;
                i++;
            }
            else if (c === ChessType.EMPTY) {
                break;
            }
            else {
                blocked++;
                break;
            }
        }
        // 反方向
        i = 1;
        while (true) {
            const newX: number = x - i * dx;
            const newY: number = y - i * dy;
            if (!WinChecker.isValidPosition(newX, newY)) {
                blocked++;
                break;
            }
            const c: number = board.getChess(newX, newY);
            if (c === chess) {
                count++;
                i++;
            }
            else if (c === ChessType.EMPTY) {
                break;
            }
            else {
                blocked++;
                break;
            }
        }
        const lineInfo: LineInfo = { count: count, blocked: blocked };
        return lineInfo;
    }
}
