if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface WidgetCard_Params {
    title?: string;
    status?: string;
    mode?: string;
    blackWins?: number;
    whiteWins?: number;
    totalGames?: number;
}
interface FormData {
    title: string;
    status: string;
    mode: string;
    blackWins: number;
    whiteWins: number;
    totalGames: number;
}
export default class GobangWidget extends FormExtension {
    onCreate(formId: string): formBindingData.FormBindingData {
        console.info('GobangWidget onCreate');
        // 创建卡片数据
        const formData: FormData = {
            title: '五子棋',
            status: '黑方回合',
            mode: '双人对战',
            blackWins: 0,
            whiteWins: 0,
            totalGames: 0
        };
        return formBindingData.createFormBindingData(formData);
    }
    onUpdate(formId: string): void {
        console.info('GobangWidget onUpdate');
        // 更新卡片数据
        const formData: FormData = {
            title: '五子棋',
            status: '黑方回合',
            mode: '双人对战',
            blackWins: 0,
            whiteWins: 0,
            totalGames: 0
        };
        formProvider.updateForm(formId, formBindingData.createFormBindingData(formData)).catch((error: Error) => {
            console.error('Failed to update form:', error.message);
        });
    }
    onDestroy(formId: string): void {
        console.info('GobangWidget onDestroy');
    }
}
class WidgetCard extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: WidgetCard_Params) {
    }
    updateStateVars(params: WidgetCard_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__title.purgeDependencyOnElmtId(rmElmtId);
        this.__status.purgeDependencyOnElmtId(rmElmtId);
        this.__mode.purgeDependencyOnElmtId(rmElmtId);
        this.__blackWins.purgeDependencyOnElmtId(rmElmtId);
        this.__whiteWins.purgeDependencyOnElmtId(rmElmtId);
        this.__totalGames.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__title.aboutToBeDeleted();
        this.__status.aboutToBeDeleted();
        this.__mode.aboutToBeDeleted();
        this.__blackWins.aboutToBeDeleted();
        this.__whiteWins.aboutToBeDeleted();
        this.__totalGames.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __title: ObservedPropertyAbstractPU<string> = this.createLocalStorageProp<string>('title', '五子棋', "title");
    get title() {
        return this.__title.get();
    }
    set title(newValue: string) {
        this.__title.set(newValue);
    }
    private __status: ObservedPropertyAbstractPU<string> = this.createLocalStorageProp<string>('status', '黑方回合', "status");
    get status() {
        return this.__status.get();
    }
    set status(newValue: string) {
        this.__status.set(newValue);
    }
    private __mode: ObservedPropertyAbstractPU<string> = this.createLocalStorageProp<string>('mode', '双人对战', "mode");
    get mode() {
        return this.__mode.get();
    }
    set mode(newValue: string) {
        this.__mode.set(newValue);
    }
    private __blackWins: ObservedPropertyAbstractPU<number> = this.createLocalStorageProp<number>('blackWins', 0, "blackWins");
    get blackWins() {
        return this.__blackWins.get();
    }
    set blackWins(newValue: number) {
        this.__blackWins.set(newValue);
    }
    private __whiteWins: ObservedPropertyAbstractPU<number> = this.createLocalStorageProp<number>('whiteWins', 0, "whiteWins");
    get whiteWins() {
        return this.__whiteWins.get();
    }
    set whiteWins(newValue: number) {
        this.__whiteWins.set(newValue);
    }
    private __totalGames: ObservedPropertyAbstractPU<number> = this.createLocalStorageProp<number>('totalGames', 0, "totalGames");
    get totalGames() {
        return this.__totalGames.get();
    }
    set totalGames(newValue: number) {
        this.__totalGames.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("widget/src/main/ets/widget/GobangWidget.ets(66:5)", "widget");
            Column.width('100%');
            Column.height('100%');
            Column.padding(10);
            Column.backgroundColor('#FFFFFF');
            Column.borderRadius(8);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 标题
            Row.create();
            Row.debugLine("widget/src/main/ets/widget/GobangWidget.ets(68:7)", "widget");
            // 标题
            Row.width('100%');
            // 标题
            Row.margin({ bottom: 10 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.title);
            Text.debugLine("widget/src/main/ets/widget/GobangWidget.ets(69:9)", "widget");
            Text.fontSize(16);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#333333');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("widget/src/main/ets/widget/GobangWidget.ets(74:9)", "widget");
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 快捷操作按钮
            Button.createWithLabel('开始');
            Button.debugLine("widget/src/main/ets/widget/GobangWidget.ets(77:9)", "widget");
            // 快捷操作按钮
            Button.fontSize(12);
            // 快捷操作按钮
            Button.height(24);
            // 快捷操作按钮
            Button.backgroundColor('#4CAF50');
            // 快捷操作按钮
            Button.onClick(() => {
                // 点击卡片打开应用
                postCardAction(this, {
                    action: 'router',
                    abilityName: 'FormAbility',
                    params: {
                        targetPage: 'pages/Index'
                    }
                });
            });
        }, Button);
        // 快捷操作按钮
        Button.pop();
        // 标题
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Divider.create();
            Divider.debugLine("widget/src/main/ets/widget/GobangWidget.ets(95:7)", "widget");
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 游戏状态
            Column.create();
            Column.debugLine("widget/src/main/ets/widget/GobangWidget.ets(98:7)", "widget");
            // 游戏状态
            Column.width('100%');
            // 游戏状态
            Column.alignItems(HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("widget/src/main/ets/widget/GobangWidget.ets(99:9)", "widget");
            Row.width('100%');
            Row.margin({ top: 8, bottom: 8 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('当前：');
            Text.debugLine("widget/src/main/ets/widget/GobangWidget.ets(100:11)", "widget");
            Text.fontSize(12);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.status);
            Text.debugLine("widget/src/main/ets/widget/GobangWidget.ets(103:11)", "widget");
            Text.fontSize(12);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#FF0000');
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("widget/src/main/ets/widget/GobangWidget.ets(111:9)", "widget");
            Row.width('100%');
            Row.margin({ bottom: 8 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`模式：${this.mode}`);
            Text.debugLine("widget/src/main/ets/widget/GobangWidget.ets(112:11)", "widget");
            Text.fontSize(12);
        }, Text);
        Text.pop();
        Row.pop();
        // 游戏状态
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Divider.create();
            Divider.debugLine("widget/src/main/ets/widget/GobangWidget.ets(121:7)", "widget");
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 统计信息
            Row.create();
            Row.debugLine("widget/src/main/ets/widget/GobangWidget.ets(124:7)", "widget");
            // 统计信息
            Row.width('100%');
            // 统计信息
            Row.justifyContent(FlexAlign.SpaceBetween);
            // 统计信息
            Row.margin({ top: 8 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`黑${this.blackWins}胜`);
            Text.debugLine("widget/src/main/ets/widget/GobangWidget.ets(125:9)", "widget");
            Text.fontSize(10);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`白${this.whiteWins}胜`);
            Text.debugLine("widget/src/main/ets/widget/GobangWidget.ets(128:9)", "widget");
            Text.fontSize(10);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`共${this.totalGames}局`);
            Text.debugLine("widget/src/main/ets/widget/GobangWidget.ets(131:9)", "widget");
            Text.fontSize(10);
        }, Text);
        Text.pop();
        // 统计信息
        Row.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "WidgetCard";
    }
}
ViewStackProcessor.StartGetAccessRecordingFor(ViewStackProcessor.AllocateNewElmetIdForNextComponent());
loadEtsCard(new WidgetCard(undefined, {}), "com.example.gobang/widget/ets/widget/GobangWidget");
ViewStackProcessor.StopGetAccessRecording();
