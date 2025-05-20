/*
 * Copyright (C) 2023 westinyang https://gitee.com/ohos-dev
 *
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

import pasteboard from '@ohos.pasteboard'
import promptAction from '@ohos.promptAction'
import { Browser } from '../model/Browser'

const ToastDuration = 1000

/**
 * 长按菜单对话框
 */
@CustomDialog
struct LongPressMenuDialog {
  @Link browser: Browser
  linkUrl: string
  existsImageContents: boolean
  sourceUrl: string
  controller: CustomDialogController
  cancel: () => void
  confirm: () => void

  aboutToAppear() {
  }

  build() {
    Column() {
      if (this.linkUrl.trim().length > 0) {
        Button('打开链接').width('100%').margin({bottom: 15}).onClick((e) => {
          this.browser.webControllerArray[this.browser.tabArrayIndex].controller.loadUrl(`${this.linkUrl}`)
          this.controller.close()
        })
        Button('复制链接').width('100%').margin({bottom: 15}).onClick((e) => {
          this.copyText('链接', this.linkUrl)
          this.controller.close()
        })
      }
      if (this.existsImageContents && this.sourceUrl.length > 0) {
        Button('打开图片链接').width('100%').margin({bottom: 15}).onClick((e) => {
          this.browser.webControllerArray[this.browser.tabArrayIndex].controller.loadUrl(`${this.sourceUrl}`)
          this.controller.close()
        })
        Button('复制图片链接').width('100%').margin({bottom: 15}).onClick((e) => {
          this.copyText('图片链接', this.sourceUrl)
          this.controller.close()
        })
      }
    }.padding({ top: 15, bottom: 0, left: 15, right: 15 })
  }

  copyText(name, value) {
    // 复制
    let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, value)
    pasteboard.getSystemPasteboard()
    let systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteData, (err, data) => {
      if (err) {
        console.error('Failed to set PasteData. Cause: ' + err.message);
        return;
      }
      console.info('Succeeded in setting PasteData.');
      // 提示
      try {
        promptAction.showToast({message: '已复制 ' + name, duration: 1000});
      } catch (error) {
        console.error(`showToast args error code is ${error.code}, message is ${error.message}`);
      };
    });
  }
}

/**
 * 下载对话框
 */
@CustomDialog
struct DownloadDialog {
  controller: CustomDialogController
  // cancel: () => void
  // confirm: () => void

  @State fileName: string = ''
  @Link downloadingProgress: number;

  build() {
    Column() {
      Text(` 下载 ${this.fileName} 进度 ${this.downloadingProgress}% `).width('100%').textAlign(TextAlign.Center).fontSize(20).margin({ bottom: 15 });
      LoadingProgress()
        .width('100%')
        .height(50)
        .color('#3478f6')
        .visibility(Visibility.Visible)
        .margin({ bottom: 10 });
      Button('关闭')
        .onClick(() => {
          this.controller.close()
        });
    }
  }
}

export { LongPressMenuDialog, DownloadDialog }