if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface Index_Params {
}
import type Want from "@ohos:app.ability.Want";
class Index extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Index_Params) {
    }
    updateStateVars(params: Index_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
    }
    aboutToBeDeleted() {
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    aboutToAppear(): void {
        // 跳转到主应用
        setTimeout(() => {
            this.openMainApp();
        }, 100);
    }
    private openMainApp(): void {
        // 启动主应用
        const want: Want = {
            bundleName: 'com.example.gobang',
            abilityName: 'EntryAbility'
        };
        // 由于widget模块独立，这里提示用户打开主应用
        console.info('Please open main application');
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("widget/src/main/ets/pages/Index.ets(27:5)", "widget");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F5F5');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("widget/src/main/ets/pages/Index.ets(28:7)", "widget");
            Column.width('100%');
            Column.height('100%');
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('五子棋');
            Text.debugLine("widget/src/main/ets/pages/Index.ets(29:9)", "widget");
            Text.fontSize(48);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#333333');
            Text.margin({ bottom: 20 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('请打开主应用开始游戏');
            Text.debugLine("widget/src/main/ets/pages/Index.ets(35:9)", "widget");
            Text.fontSize(20);
            Text.fontColor('#666666');
        }, Text);
        Text.pop();
        Column.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "Index";
    }
}
registerNamedRoute(() => new Index(undefined, {}), "", { bundleName: "com.example.gobang", moduleName: "widget", pagePath: "pages/Index", pageFullPath: "widget/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });
