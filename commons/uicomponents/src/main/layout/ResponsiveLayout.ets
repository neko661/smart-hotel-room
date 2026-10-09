/**
 * 响应式布局容器组件 - 使用 v2 装饰器
 * 根据设备类型自动调整布局
 */

export interface ResponsiveSize {
  phone?: number;
  tablet?: number;
  default?: number;
}

export interface ResponsiveLayoutConfig {
  spacing?: ResponsiveSize;
  padding?: ResponsiveSize;
  gridCols?: ResponsiveSize;
}

@ComponentV2
export struct ResponsiveLayout {
  @Param bgColor: string = '#FFFFFF';
  @Param paddingValue: number = 16;

  build() {
    Column() {
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor)
    .padding(this.paddingValue)
  }
}

// 响应式Grid组件
@ComponentV2
export struct ResponsiveGrid {
  @Param columnCount: number = 2;
  @Param columnGapValue: number = 8;
  @Param rowGapValue: number = 8;

  build() {
    Grid() {
    }
    .columnsTemplate(`repeat(${this.columnCount}, 1fr)`)
    .columnsGap(this.columnGapValue)
    .rowsGap(this.rowGapValue)
  }
}
