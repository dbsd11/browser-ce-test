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
import { Browser, LoadingStatus, WebObject, WebKey } from '../model/Browser'
import Logger from '../model/Logger'
import WindowStageUtil from '../util/WindowStageUtil'
import { DownloadDialog, LongPressMenuDialog } from './CustomDialog'
import { BusinessError } from '@kit.BasicServicesKit'
import { abilityAccessCtrl } from '@kit.AbilityKit';
import { webview } from '@kit.ArkWeb'
import { fileUri, picker, fileIo as fs } from '@kit.CoreFileKit';

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
    // {
    //   imageSrc: $r('app.media.submit'),
    //   id: 5
    // },
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
        .id('navigationButton' + item.id)
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
              if (this.browser.webControllerArray[this.browser.tabArrayIndex].isRegistered && this.browser.webControllerArray[this.browser.tabArrayIndex].controller) {
                this.browser.webControllerArray[this.browser.tabArrayIndex].controller.loadUrl($rawfile('phone.html'))
              } else {
                this.browser.Refresh()
              }
              break;
          }
        })
      }, item => item.id)

      // TextInput({ placeholder: '输入网址...', text: this.browser.inputValue })
      //   .placeholderFont({ size: 18, weight: 500 })
      //   .fontSize(18)
      //   .margin(2)
      //   .width('51%')
      //   .layoutWeight(1)
      //   .onChange((value: string) => {
      //     this.addr = value
      //   })
      //   .onSubmit((enterKey: EnterKeyType) => {
      //     Logger.info(TAG, `onSubmit`)
      //     if (this.addr.length !== 0) {
      //       this.browser.webControllerArray[this.browser.tabArrayIndex].controller.loadUrl(`${this.addr}`) // 移除追加 https:// 前缀
      //       this.addr = ''
      //     }
      //   })

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
          // if (item.id === 5) {
          //   this.browser.loadUrl(this.addr)
          //   this.addr = ''
          // }
          if (item.id === 6) {
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
      ForEach(this.browser.webArray, (item:WebKey) => {
        Row() {
          Row() {
            Text((item.url||"PComputer").replace(/(https)|(http)|[:./]|(\?.*)/g, ""))
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
  @State downloadingProgress: number = 0;

  @Link hideToolBar: Boolean;
  isRegistered: boolean = false
  testObj = {
    test: (addr) => {
      Logger.info(TAG, `addr= ${this.browser.tabArrayIndex}`)
      if(this.browser.webControllerArray[this.browser.tabArrayIndex].isRegistered) {
        this.browser.webControllerArray[this.browser.tabArrayIndex].controller.loadUrl(`${addr}`) // 移除追加 https:// 前缀
      }
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

  aboutToAppear(): void {
    let atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(getContext(this), ['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE', 'ohos.permission.READ_WRITE_DOWNLOAD_DIRECTORY', 'ohos.permission.READ_WRITE_DOCUMENTS_DIRECTORY', 'ohos.permission.FILE_ACCESS_PERSIST'])
      .then((data) => {
        console.info('data:' + JSON.stringify(data));
        console.info('data permissions:' + data.permissions);
        console.info('data authResults:' + data.authResults);
      }).catch((error: BusinessError) => {
      console.error(`Failed to request permissions from user. Code is ${error.code}, message is ${error.message}`);
    })
  }

  build() {
    Tabs({ barPosition: BarPosition.Start, controller: this.browser.tabsController }) {
      ForEach(this.browser.webArray, (item: WebKey) => {
        TabContent() {
          Web({
            src: item.url || (this.isPhone ? $rawfile('phone.html') : $rawfile('pad.html')),
            controller: this.browser.webControllerArray[item.key] !== undefined ?
              this.browser.webControllerArray[item.key].controller : undefined
          })
            .databaseAccess(true)
            .onlineImageAccess(true)
            .javaScriptAccess(true)
            .fileAccess(true)
            .domStorageAccess(true)
            .mediaPlayGestureAccess(true)
            .zoomAccess(true)
            .onPermissionRequest((event) => {
              event.request.grant(event.request.getAccessibleResource())
            })
            .userAgent(this.isPhone ? PHONE_USER_AGENT : PAD_USER_AGENT)
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
            .onOverrideUrlLoading((webResourceRequest: WebResourceRequest) => {
              if (this.browser.webArray[item.key].url) {
                return false
              }
              this.browser.addTabWithUrl(webResourceRequest.getRequestUrl())
              return true
            })
            .onSslErrorEvent((sslErrorEvent: SslErrorEvent) => {
              sslErrorEvent.handler.handleConfirm()
            })
            .onSslErrorEventReceive((event) => {
              event.handler.handleConfirm()
            })
            .onSslErrorEvent((event) => {
              event.handler.handleConfirm()
            })
            .onInterceptRequest((event) => {
              console.log('url:' + event.request.getRequestUrl())
              return null;
            })
            .onPageBegin((event) => {
              Logger.info(TAG, `onPageBegin= ${JSON.stringify(event)}`)
              this.browser.loadingStatus = LoadingStatus.LOADING
            })
            .onPageEnd((event) => {
              Logger.info(TAG, `onPageEnd= ${JSON.stringify(event)}`)
              this.browser.loadingStatus = LoadingStatus.END
              if (item.key >= this.browser.webControllerArray.length || !this.browser.webControllerArray[item.key].controller) {
                return
              }

              let controller = this.browser.webControllerArray[item.key].controller
              let webId: number = -1
              try {
                webId = controller.getWebId()
              } catch (e) {
              }
              // 判断controller是否attach到web component
              if (webId == -1) {
                return
              }

              controller.runJavaScript('adapterDevice()')
              this.registerFunc(this.browser.webControllerArray[item.key])
              if (event.url.startsWith('http')) {
                this.browser.inputValue = event.url
              } else {
                this.browser.inputValue = ''
              }

              let delegate: webview.WebDownloadDelegate = new webview.WebDownloadDelegate()
              delegate.onBeforeDownload((webDownloadItem: webview.WebDownloadItem) => {
                let context = getContext(this)
                const documentSaveOptions = new picker.DocumentSaveOptions();
                documentSaveOptions.defaultFilePathUri = context.filesDir;
                documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD
                const documentViewPicker = new picker.DocumentViewPicker(context);
                documentViewPicker.select(documentSaveOptions).then((DocumentSelectResult: Array<string>) => {
                  if (!DocumentSelectResult || DocumentSelectResult.length == 0) {
                    return
                  }
                  let downloadPath = DocumentSelectResult[0] + "/Download"
                  const downloadFilePath = downloadPath  + "/" + webDownloadItem.getSuggestedFileName()
                  console.log("will start a download ", webDownloadItem.getSuggestedFileName(), " to ", downloadFilePath);
                  webDownloadItem.start(downloadFilePath);

                  // 自定义对话框
                  this.downloadingProgress = 0;
                  this.dialogController2 = new CustomDialogController({
                    builder: DownloadDialog({
                      fileName: webDownloadItem.getSuggestedFileName(),
                      downloadingProgress: this.downloadingProgress
                    }),
                    cancel: this.existApp,
                    autoCancel: false,
                    alignment: DialogAlignment.Default,
                    offset: { dx: 0, dy: -20 },
                    gridCount: 4,
                    customStyle: false
                  })
                  this.dialogController2.open()
                }).catch((err: BusinessError) => {
                  console.error(`Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
                })
              });
              delegate.onDownloadUpdated((webDownloadItem: webview.WebDownloadItem) => {
                console.log("download update guid: ", webDownloadItem.getGuid(), " percent: ", webDownloadItem.getPercentComplete());
                this.downloadingProgress = webDownloadItem.getPercentComplete()
              })
              delegate.onDownloadFinish((webDownloadItem: webview.WebDownloadItem) => {
                console.log("download finished guid: ", webDownloadItem.getGuid());
                promptAction.showToast({ message: '下载完成', duration: 1000 })
                if (this.dialogController2) {
                  this.dialogController2.close()
                }

                // let sourceDownloadPath = getContext().filesDir + "/Download"
                // const sourceDownloadFilePath = sourceDownloadPath + "/" + webDownloadItem.getSuggestedFileName()
                // const sourceDownloadFileUrl = new fileUri.FileUri(sourceDownloadFilePath).path
                //
                // const destDownloadPath = "file://docs/storage/Users/currentUser/Download"
                // const destDownloadFilePath = destDownloadPath + "/aaaaa"
                // const destDownloadFileUrl = new fileUri.FileUri(destDownloadFilePath).path
                //
                // fs.copyFileSync(sourceDownloadFileUrl, destDownloadFileUrl, 0);
                // fs.unlinkSync(sourceDownloadFileUrl)
              })
              delegate.onDownloadFailed((webDownloadItem: webview.WebDownloadItem) => {
                console.log("download failed guid: ", webDownloadItem.getGuid());
                if (this.dialogController2) {
                  this.dialogController2.close()
                }
              })
              controller.setDownloadDelegate(delegate)
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
            // 全屏
            .onFullScreenEnter(() => {
              console.log("onFullScreenEnter...")
              this.hideToolBar = true;
              // WindowStageUtil.setLayoutFullScreen(globalThis.windowStage, WindowStageUtil.COLOR_BLACK, WindowStageUtil.COLOR_WHITE, WindowStageUtil.COLOR_BLACK, WindowStageUtil.COLOR_WHITE);
              WindowStageUtil.setFullScreen(globalThis.windowStage)
            })
            .onFullScreenExit(() => {
              console.log("onFullScreenExit...")
              this.hideToolBar = false;
              WindowStageUtil.setLayoutFullScreen(globalThis.windowStage, WindowStageUtil.COLOR_WHITE, WindowStageUtil.COLOR_BLACK, '#fdfdfd', WindowStageUtil.COLOR_BLACK);
            })
            // 长按菜单
            .onContextMenuShow((event) => {
              // console.info("x coord = " + event.param.x())
              // console.info("link url = " + event.param.getLinkUrl())
              // // 长按事件
              // if (event.param.getSourceType() == ContextMenuSourceType.LongPress) {
              //   // 自定义对话框
              //   this.dialogController = new CustomDialogController({
              //     builder: LongPressMenuDialog({
              //       browser: $browser,
              //       linkUrl: event.param.getLinkUrl(),
              //       existsImageContents: event.param.existsImageContents(),
              //       sourceUrl: event.param.getSourceUrl(),
              //       cancel: this.onCancel,
              //       confirm: this.onAccept,
              //       controller: this.dialogController
              //     }),
              //     cancel: this.existApp,
              //     autoCancel: true,
              //     alignment: DialogAlignment.Default,
              //     offset: { dx: 0, dy: 0 },
              //     gridCount: 3,
              //     customStyle: false,
              //   })
              //   this.dialogController.open()
              // }
              return true;
            })
            // 上传文件
            .domStorageAccess(true)
            .onShowFileSelector((event) => {
              console.log('MyFileUploader onShowFileSelector invoked')
              const documentSelectOptions = new picker.DocumentSelectOptions();
              documentSelectOptions.defaultFilePathUri = getContext().filesDir
              documentSelectOptions.authMode = true;
              // 选择媒体文件的最大数目
              documentSelectOptions.maxSelectNumber = 1;
              let uris: Array<string> = [];
              let success = false;
              const documentViewPicker = new picker.DocumentViewPicker();
              documentViewPicker.select(documentSelectOptions).then((DocumentSelectResult: Array<string>) => {
                uris[0] = DocumentSelectResult[0];
                console.info('photoViewPicker.select to file succeed and uris are:' + uris);
                success = true;
              }).catch((err: BusinessError) => {
                console.error(`Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
              })
              return success;
            })
        }
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