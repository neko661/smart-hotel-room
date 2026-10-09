/**
 * 文本输入框组件 - 使用 v2 装饰器
 */
@ComponentV2
export struct AppTextInput {
  @Param placeholder: string = '';
  @Param value: string = '';
  @Param inputType: 'text' | 'password' | 'number' | 'email' | 'phone' = 'text';
  @Param maxLength: number = 0;
  @Param clearable: boolean = true;
  @Param showCounter: boolean = false;
  @Param errorText: string = '';
  @Local focused: boolean = false;
  @Local showPassword: boolean = false;
  @Event onValueChange: (value: string) => void = () => {};
  @Event onSubmit: () => void = () => {};
  @Event onClear: () => void = () => {};

  build() {
    Column() {
      Row() {
        TextInput({
          placeholder: this.placeholder,
          text: this.value
        })
          .type(this.getInputType())
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .maxLength(this.maxLength > 0 ? this.maxLength : undefined)
          .fontColor('#333333')
          .placeholderColor('#999999')
          .onChange((value: string) => {
            this.onValueChange(value);
          })
          .onSubmit(() => {
            this.onSubmit();
          })
          .onFocus(() => {
            this.focused = true;
          })
          .onBlur(() => {
            this.focused = false;
          })

        if (this.clearable && this.value.length > 0 && this.focused) {
          Text('×')
            .fontSize(18)
            .fontColor('#999999')
            .margin({ left: 8, right: 8 })
            .onClick(() => {
              this.onClear();
            })
        }
      }
      .width('100%')
      .height(48)
      .backgroundColor(this.errorText ? '#FFF5F5' : '#F5F5F5')
      .borderRadius(8)
      .border({
        width: this.errorText || this.focused ? 1 : 0.5,
        color: this.errorText ? '#FF4D4F' :
               this.focused ? '#D4AF37' : '#DDDDDD'
      })

      if (this.errorText) {
        Text(this.errorText)
          .fontSize(12)
          .fontColor('#FF4D4F')
          .margin({ top: 4 })
      }

      if (this.showCounter && this.maxLength > 0) {
        Text(`${this.value.length}/${this.maxLength}`)
          .fontSize(12)
          .fontColor('#999999')
          .alignSelf(ItemAlign.End)
          .margin({ top: 4 })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  private getInputType(): InputType {
    switch (this.inputType) {
      case 'password':
        return InputType.Password;
      case 'number':
        return InputType.Number;
      case 'email':
        return InputType.Email;
      case 'phone':
        return InputType.Normal;
      default:
        return InputType.Normal;
    }
  }
}
