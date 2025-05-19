/*
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import promptAction from '@ohos.promptAction'
import pasteboard from '@ohos.pasteboard'
import { Browser, LoadingStatus, WebObject } from '../model/Browser'
import Logger from '../model/Logger'
import WindowStageUtil from '../util/WindowStageUtil'
import { DownloadAndInstallHapDialog, LongPressMenuDialog } from './CustomDialog'

const TAG: string = '[TitleBar]'
const BUTTON_WIDTH: number = 22
const BUTTON_RADIUS: number = 4
const DOWN_COLOR: string = '#e4e4e4'
const UP_COLOR: string = '#00000000'

// 不设置UA，测试实际UA
// Mozilla/5.0 (X11; Linux aarch64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.88 Mobile Safari/537.36

// 官方浏览器demo设置的UA
// const PAD_USER_AGENT: string = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTMl, like Gecko) Chrome/92.0.4515.105 Safari/537.36'
// const PHONE_USER_AGENT: string = 'Mozilla/5.0 (Linux; Android 9; VRD-AL10; HMSCore 6.3.0.331) AppleWebKit/537.36 (KHTMl, like Gecko) Chrome/92.0.4515.105 HuaweiBrowser/12.0.4.1 Mobile Safari/537.36'

// UA修正（参考原UA和HarmonyOS3.0的UA）
const PAD_USER_AGENT: string = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTMl, like Gecko) Chrome/99.0.4844.88 Safari/537.36'
const PHONE_USER_AGENT: string = 'Mozilla/5.0 (Linux; Android 10.0; OpenHarmony 3.2; ohos) AppleWebKit/537.36 (KHTMl, like Gecko) Chrome/99.0.4844.88 Mobile Safari/537.36'

@Component
export struct TabletTitle {
  @Link browser: Browser;
  @State inputValue: string = ''
  @State arrayIndex: number = 0
  private addr: string = ''
  private navigationButton: Array<{
    imageSrc: Resource,
    id: number
  }> = [
    {
      imageSrc: $r('app.media.ic_public_back'),
      id: 1
    },
    {
      imageSrc: $r('app.media.ic_public_advance'),
      id: 2
    },
    {
      imageSrc: $r('app.media.ic_public_refresh'),
      id: 3
    },
    {
      imageSrc: $r('app.media.ic_public_home'),
      id: 4
    },
  ]
  private actionButton: Array<{
    imageSrc: Resource,
    id: number
  }> = [
    {
      imageSrc: $r('app.media.submit'),
      id: 5
    },
    {
      imageSrc: $r('app.media.ic_public_add'),
      id: 6
    },
  ]

  build() {
    Row() {
      ForEach(this.navigationButton, item => {
        Button({ type: ButtonType.Normal }) {
          Image(item.imageSrc)
        }
        .margin(8)
        .width(BUTTON_WIDTH)
        .height(BUTTON_WIDTH)
        .backgroundColor(this.arrayIndex === item.id ? DOWN_COLOR : UP_COLOR)
        .borderRadius(BUTTON_RADIUS)
        .flexShrink(0)
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.arrayIndex = item.id
          }

          if (event.type === TouchType.Up) {
            this.arrayIndex = 0
          }
        })
        .onClick((event: ClickEvent) => {
          switch (item.id) {
            case 1:
              this.browser.Back()
              break;
            case 2:
              this.browser.Forward()
              break;
            case 3:
              this.browser.Refresh()
              break;
            case 4:
              this.browser.webControllerArray[this.browser.tabArrayIndex].controller.loadUrl($rawfile('pad.html'))
              break;
          }
        })
      }, item => item.id)

      TextInput({ placeholder: '输入网址...', text: this.browser.inputValue })
        .placeholderFont({ size: 18, weight: 500 })
        .fontSize(18)
        .margin(2)
        .width('51%')
        .layoutWeight(1)
        .onChange((value: string) => {
          this.addr = value
        })
        .onSubmit((enterKey: EnterKeyType) => {
          Logger.info(TAG, `onSubmit`)
          if (this.addr.length !== 0) {
            this.browser.webControllerArray[this.browser.tabArrayIndex].controller.loadUrl(`${this.addr}`) // 移除追加 https:// 前缀
            this.addr = ''
          }
        })

      ForEach(this.actionButton, item => {
        Button({ type: ButtonType.Normal }) {
          Image(item.imageSrc)
        }
        .margin(8)
        .width(BUTTON_WIDTH)
        .height(BUTTON_WIDTH)
        .backgroundColor(this.arrayIndex === item.id ? DOWN_COLOR : UP_COLOR)
        .borderRadius(BUTTON_RADIUS)
        .flexShrink(0)
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.arrayIndex = item.id
          }
          if (event.type === TouchType.Up) {
            this.arrayIndex = 0
          }
        })
        .onClick((event: ClickEvent) => {
          if (item.id === 5) {
            this.browser.loadUrl(this.addr)
            this.addr = ''
          } else if (item.id === 6) {
            Logger.info(TAG, `add tab index = ` + this.arrayIndex)
            this.browser.addTab()
          }
        })
      }, item => item.id)
    }
    .width('100%')
    .padding({ right: 5 })
  }
}

@Component
export struct BrowserTabs {
  @Link browser: Browser;
  @State tabButtonIndex: number = -1;

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start }) {
      ForEach(this.browser.webArray, item => {
        Row() {
          Row() {
            Text('主页')
          }.width('100%').flexShrink(1).justifyContent(FlexAlign.Center).height('100%')

          Button({ type: ButtonType.Normal }) {
            Image($r('app.media.ic_public_cancel_filled')).width(24).height(24)
          }
          .backgroundColor(this.tabButtonIndex == item.key ? DOWN_COLOR : '#00000000')
          .margin({ right: 2 })
          .width(33)
          .height(33)
          .borderRadius(5)
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.tabButtonIndex = item.key
            } else if (event.type == TouchType.Up) {
              this.tabButtonIndex = -1
            }
          })
          .onClick((event: ClickEvent) => {
            if (this.browser.webArray.length > 1) {
              this.browser.deleteTab(item.key)
            }
          })
        }.width(180).height('100%').backgroundColor(this.browser.tabArrayIndex == item.key ? '#ffffff' : '#ececec')
        .onClick((event: ClickEvent) => {
          Logger.info(TAG, `key= ${item.key}`)
          this.browser.setTabArrayIndex(item.key)
          this.browser.tabsController.changeIndex(item.key)
        })

        Divider().vertical(true).color('#c6c6c6')
      }, item => item.timestamp.toString())
    }.height(33).flexShrink(0).backgroundColor('#ececec')
  }
}

@Component
export struct WebTab {
  @Link browser: Browser;
  @Link isPhone: boolean;
  // @Link hideToolBar: Boolean;
  isRegistered: boolean = false
  testObj = {
    test: (addr) => {
      Logger.info(TAG, `addr= ${this.browser.tabArrayIndex}`)
      this.browser.webControllerArray[this.browser.tabArrayIndex].controller.loadUrl(`${addr}`) // 移除追加 https:// 前缀
    },
    searchWord: (word: string) => {
      Logger.info(`search word= ${word}`)
      let code = encodeURI(word)
      this.browser.webControllerArray[this.browser.tabArrayIndex].controller.loadUrl(`https://www.bing.com/search?q=${code}`)
    }
  }

  dialogController: CustomDialogController;
  onCancel() {
    console.info('Callback when the first button is clicked')
  }
  onAccept() {
    console.info('Callback when the second button is clicked')
  }
  existApp() {
    console.info('Click the callback in the blank area')
  }

  dialogController2: CustomDialogController;
  onCancel2() {
    console.info('Callback when the first button is clicked')
  }
  onAccept2() {
    console.info('Callback when the second button is clicked')
  }
  existApp2() {
    console.info('Click the callback in the blank area')
  }

  build() {
    Tabs({ barPosition: BarPosition.Start, controller: this.browser.tabsController }) {
      ForEach(this.browser.webArray, item => {
        TabContent() {
          Web({
            src: this.isPhone ? $rawfile('phone.html') : $rawfile('pad.html'),
            controller: this.browser.webControllerArray[item.key] !== undefined ?
              this.browser.webControllerArray[item.key].controller : undefined
          })
            .databaseAccess(true)
            .onlineImageAccess(true)
            .javaScriptAccess(true)
            .fileAccess(true)
            .domStorageAccess(true)
            .userAgent(this.isPhone ? PHONE_USER_AGENT : PAD_USER_AGENT)
            .onPageBegin((event) => {
              Logger.info(TAG, `onPageBegin= ${JSON.stringify(event)}`)
              this.browser.loadingStatus = LoadingStatus.LOADING
            })
            .onPageEnd((event) => {
              Logger.info(TAG, `onPageEnd= ${JSON.stringify(event)}`)
              if (item.key < this.browser.webControllerArray.length && this.browser.webControllerArray[item.key].controller) {
                this.browser.webControllerArray[item.key].controller.runJavaScript('adapterDevice()')
                this.browser.loadingStatus = LoadingStatus.END
                this.registerFunc(this.browser.webControllerArray[item.key])
                if (event.url.startsWith('http')) {
                  this.browser.inputValue = event.url
                } else {
                  this.browser.inputValue = ''
                }
              }
            })
            .onProgressChange((event) => {
              Logger.info(TAG, `onProgressChange`)
              this.browser.progress = event.newProgress
              if (this.browser.progress === 100) {
                this.browser.hideProgress = true
              } else {
                this.browser.hideProgress = false
              }
            })
            .onInterceptRequest((event) => {
              console.log('url:' + event.request.getRequestUrl())
              return null;
            })
            // 自定义网址拦截器
            .onUrlLoadIntercept((event) => {
              // 当前网址
              let url = event.data.toString();
              console.log('onUrlLoadIntercept ' + url)
              // 网址协议前缀
              let urlProtocolPrefix = 'unknown';
              try {
                urlProtocolPrefix = url.split('://')[0];
              } catch (e) {}
              // 拦截三方客户端协议前缀的网址
              if (!['http', 'https', 'file', 'data', 'resource'].includes(urlProtocolPrefix)) {
                promptAction.showToast({ message: '阻止打开三方协议前缀：'+urlProtocolPrefix, duration: 1000 });
                return true;
              }
              return false;
            })
            // 全屏
            .onFullScreenEnter(() => {
              // console.log("onFullScreenEnter...")
              // WindowStageUtil.setLayoutFullScreen(globalThis.windowStage, WindowStageUtil.COLOR_BLACK, WindowStageUtil.COLOR_WHITE, WindowStageUtil.COLOR_BLACK, WindowStageUtil.COLOR_WHITE);
              // this.hideToolBar = true;
            })
            .onFullScreenExit(() => {
              // console.log("onFullScreenExit...")
              // WindowStageUtil.setLayoutFullScreen(globalThis.windowStage, WindowStageUtil.COLOR_WHITE, WindowStageUtil.COLOR_BLACK, '#fdfdfd', WindowStageUtil.COLOR_BLACK);
              // this.hideToolBar = false;
            })
            // 长按菜单
            .onContextMenuShow((event) => {
              console.info("x coord = " + event.param.x())
              console.info("link url = " + event.param.getLinkUrl())
              // 长按事件
              if (event.param.getSourceType() == ContextMenuSourceType.LongPress) {
                // 自定义对话框
                this.dialogController = new CustomDialogController({
                  builder: LongPressMenuDialog({
                    browser: $browser,
                    linkUrl: event.param.getLinkUrl(),
                    existsImageContents: event.param.existsImageContents(),
                    sourceUrl: event.param.getSourceUrl(),
                    cancel: this.onCancel,
                    confirm: this.onAccept,
                    controller: this.dialogController
                  }),
                  cancel: this.existApp,
                  autoCancel: true,
                  alignment: DialogAlignment.Default,
                  offset: { dx: 0, dy: 0 },
                  gridCount: 3,
                  customStyle: false
                })
                this.dialogController.open()
              }
              return false;
            })
            // 监听下载
            .onDownloadStart((event) => {
              console.log('url:' + event.url)
              console.log('userAgent:' + event.userAgent)
              console.log('contentDisposition:' + event.contentDisposition)
              console.log('contentLength:' + event.contentLength)
              console.log('mimetype:' + event.mimetype)
              if (event.url.endsWith('.hap')) {
                // 自定义对话框
                this.dialogController2 = new CustomDialogController({
                  builder: DownloadAndInstallHapDialog({
                    url: event.url,
                    contentDisposition: event.contentDisposition,
                    controller: this.dialogController2
                  }),
                  cancel: this.existApp,
                  autoCancel: false,
                  alignment: DialogAlignment.Default,
                  offset: { dx: 0, dy: -20 },
                  gridCount: 4,
                  customStyle: false
                })
                this.dialogController2.open()
              }
            })
        }
        .padding({bottom: 35.5})
      }, item => item.timestamp.toString())
    }
    .barHeight(0)
    .scrollable(false)
  }

  registerFunc(webObject: WebObject) {
    if (!webObject.isRegistered) {
      Logger.info(TAG, `registerFunc`)
      webObject.controller.registerJavaScriptProxy(
        this.testObj, 'etsObj', ['test', 'searchWord']
      )
      webObject.isRegistered = true
      webObject.controller.refresh()
    }
  }
}