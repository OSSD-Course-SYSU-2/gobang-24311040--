# 五子棋游戏 - 多端部署与分布式流转

## 项目概述

本项目是一个基于HarmonyOS ArkTS开发的五子棋游戏，实现了**一次开发、多次部署**和**跨设备自由流转**两大核心功能。

## 核心特性

### 1. 一次开发、多次部署

#### 1.1 项目架构
```
gobang/
├── common/              # HSP公共模块
│   ├── src/main/ets/
│   │   ├── model/       # 游戏数据模型
│   │   ├── utils/       # 工具类（AI、胜负判断、分布式管理）
│   │   └── components/  # 公共组件（棋盘绘制）
│   └── index.ets        # 模块导出
├── entry/               # 手机端HAP
├── tv/                  # 智慧屏端HAP
└── widget/              # 桌面卡片HAP
```

#### 1.2 公共模块（common）
- **GameConstants.ets**: 游戏常量定义
- **GameBoard.ets**: 游戏状态管理
- **SerializableGameState.ets**: 可序列化游戏状态（用于分布式流转）
- **WinChecker.ets**: 胜负判定算法
- **AIPlayer.ets**: AI对战逻辑
- **DistributedManager.ets**: 分布式流转管理器
- **BoardDrawer.ets**: Canvas棋盘绘制组件

#### 1.3 多产品风味配置
在 `build-profile.json5` 中配置了三个产品风味：
```json5
products: [
  { name: "phone" },  // 手机端
  { name: "tv" },     // 智慧屏端
  { name: "widget" }  // 桌面卡片
]
```

### 2. 跨设备自由流转

#### 2.1 可序列化GameState
```typescript
@Sendable
class SerializableGameState {
  board: number[][];          // 棋盘状态
  history: ChessMove[];       // 落子历史
  currentPlayer: number;      // 当前玩家
  gameMode: string;           // 游戏模式
  gameState: string;          // 游戏状态
  winLine: WinLine | null;    // 胜利连线
  moveCount: number;          // 落子计数
  deviceId: string;           // 设备ID
  
  serialize(): string;        // 序列化
  static deserialize(jsonStr: string): SerializableGameState; // 反序列化
}
```

#### 2.2 分布式流转流程
1. **设备发现**: 点击"流转"按钮，扫描同账号鸿蒙设备
2. **状态序列化**: 将当前游戏状态序列化为JSON
3. **数据迁移**: 通过分布式软总线传输到目标设备
4. **状态恢复**: 目标设备反序列化并恢复游戏进度

#### 2.3 权限配置
在 `module.json5` 中配置了必要的权限：
```json5
requestPermissions: [
  {
    "name": "ohos.permission.DISTRIBUTED_DATASYNC",
    "reason": "用于跨设备同步游戏数据"
  },
  {
    "name": "ohos.permission.DISTRIBUTED_DEVICE_STATE_CHANGE",
    "reason": "用于发现和连接其他设备"
  },
  {
    "name": "ohos.permission.ACCESS_SERVICE_DM",
    "reason": "用于设备管理和分布式流转"
  }
]
```

## 编译与部署

### 方式一：DevEco Studio编译

#### 编译手机端
1. 选择 Build Variant: `phone`
2. 点击 Build → Build Hap(s)/APP(s)
3. 输出: `entry/build/default/outputs/default/entry-phone-signed.hap`

#### 编译智慧屏端
1. 选择 Build Variant: `tv`
2. 点击 Build → Build Hap(s)/APP(s)
3. 输出: `tv/build/default/outputs/default/tv-tv-signed.hap`

#### 编译桌面卡片
1. 选择 Build Variant: `widget`
2. 点击 Build → Build Hap(s)/APP(s)
3. 输出: `widget/build/default/outputs/default/widget-widget-signed.hap`

### 方式二：命令行编译

```bash
# 编译手机端
hvigorw assembleHap --mode module -p product=phone -p module=entry@default

# 编译智慧屏端
hvigorw assembleHap --mode module -p product=tv -p module=tv@default

# 编译桌面卡片
hvigorw assembleHap --mode module -p product=widget -p module=widget@default

# 编译所有产品
hvigorw assembleHap --mode module -p product=phone -p module=entry@default
hvigorw assembleHap --mode module -p product=tv -p module=tv@default
hvigorw assembleHap --mode module -p product=widget -p module=widget@default
```

### 安装到设备

```bash
# 安装到手机
hdc install entry/build/default/outputs/default/entry-phone-signed.hap

# 安装到智慧屏
hdc install tv/build/default/outputs/default/tv-tv-signed.hap

# 安装桌面卡片
hdc install widget/build/default/outputs/default/widget-widget-signed.hap
```

## 功能说明

### 游戏功能
- ✅ 15×15标准棋盘
- ✅ 双人对战模式
- ✅ 人机对战模式（AI算法）
- ✅ 悔棋功能
- ✅ 游戏重置
- ✅ 交换先后手
- ✅ 胜负判定（四方向五连检测）
- ✅ 胜利连线高亮
- ✅ 游戏统计

### 分布式流转功能
- ✅ 设备发现（扫描同账号鸿蒙设备）
- ✅ 游戏状态序列化
- ✅ 跨设备数据迁移
- ✅ 游戏进度恢复
- ✅ 继续落子、悔棋

### 多端适配
- ✅ 手机端：触摸交互、竖屏布局
- ✅ 智慧屏端：遥控器交互、横屏大屏布局
- ✅ 桌面卡片：快捷状态查看、一键启动

## 使用指南

### 手机端操作
1. 点击棋盘空位落子
2. 点击"悔棋"撤销上一步
3. 点击"重置"重新开始
4. 点击"人机模式/双人模式"切换游戏模式
5. 点击"流转"按钮进行跨设备迁移

### 智慧屏端操作
1. 使用遥控器方向键移动焦点
2. 按确认键落子
3. 侧边栏提供所有控制按钮
4. 支持分布式流转

### 桌面卡片
- 显示当前游戏状态
- 显示游戏统计信息
- 点击"开始"按钮打开主应用

## 技术亮点

### 1. 模块化架构
- HSP公共模块实现代码复用
- 清晰的模块职责划分
- 便于维护和扩展

### 2. 分布式能力
- 完整的流转生命周期管理
- 可序列化状态设计
- 设备发现与连接

### 3. 多端适配
- 响应式布局
- 设备特性适配（触摸/遥控器）
- 统一的业务逻辑

### 4. AI算法
- 基于评分的位置评估
- 攻防策略平衡
- 棋型识别（活四、冲四、活三等）

## 开发环境

- HarmonyOS SDK: 6.0.2(22)
- DevEco Studio: 最新版本
- ArkTS语言
- API版本: 根据项目配置

## 注意事项

1. **分布式流转**需要设备登录同一华为账号
2. **设备发现**需要设备在同一局域网
3. **权限申请**首次使用需要用户授权
4. **桌面卡片**需要单独安装widget模块

## 后续优化

1. **性能优化**
   - AI算法优化（Minimax + Alpha-Beta剪枝）
   - Canvas绘制优化
   - 状态管理优化

2. **功能增强**
   - 音效和震动反馈
   - 自定义棋盘主题
   - 游戏回放功能
   - 在线对战

3. **分布式增强**
   - 实时同步对战
   - 多设备协同
   - 云端存档

## 许可证

MIT License

## 作者

HarmonyOS Development Assistant
