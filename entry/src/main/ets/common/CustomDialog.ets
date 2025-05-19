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
import request from '@ohos.request'
import installer from '@ohos.bundle.installer'
import { Browser } from '../model/Browser'
import fs from '@ohos.file.fs'

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
 * 下载并安装hap对话框
 */
@CustomDialog
struct DownloadAndInstallHapDialog {
  url: string = ''
  contentDisposition: string = '' // attachment; filename="DeviceInfo-1.2.3.hap"
  controller: CustomDialogController
  // cancel: () => void
  // confirm: () => void

  fileName: string = ''
  @State installLoading: boolean = false;

  aboutToAppear() {
    // 解析文件名
    let fileName = new Date().getTime() + '.hap'
    try {
      this.contentDisposition.split(';').forEach((v, i) => {
        if (('' + v).trim().startsWith('filename')) {
          let fn = v.split('=')[1].replace(/"/g, '')
          if (!fn.endsWith('.hap')) {
            fn += '.hap'
          }
          fileName = fn
        }
      })
    } catch (e) {
    }
    this.fileName = fileName
  }

  build() {
    Column() {
      Text('下载').width('100%').fontSize(20).margin({ bottom: 15 })
      Text('检测到文件为hap安装包，是否下载并安装？').width('100%').fontSize(16).margin({ bottom: 5 })
      LoadingProgress().width('100%').height(50).color('#3478f6').visibility(this.installLoading ? Visibility.Visible : Visibility.Hidden).margin({ bottom: 10 })
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('取消').width('100%').backgroundColor('#eeeeee').fontColor(Color.Black).margin({right:7.5}).onClick(() => {
          if (this.installLoading) {
            promptAction.showToast({ message: '下载并安装中，请稍后...', duration: ToastDuration })
            return
          }
          this.controller.close()
        })
        Button('安装').width('100%').backgroundColor('#3478f6').fontColor('#eeeeee').margin({left:7.5}).onClick(() => {
          if (this.installLoading) {
            promptAction.showToast({ message: '下载并安装中，请稍后...', duration: ToastDuration })
            return
          }
          this.installLoading = true
          this.checkLocalFile()
        })
      }
    }.padding(15)
  }

  checkLocalFile() {
    let filePath = globalThis.abilityContext.filesDir + '/' + this.fileName;

    fs.access(filePath).then((res) => {
      if (res) {
        fs.unlink(filePath).then(() => {
          console.info("remove file succeed");
          this.downloadHap()
        }).catch((err) => {
          console.info("remove file failed with error message: " + err.message + ", error code: " + err.code);
          this.installLoading = false
        });
        return;
      }
      this.downloadHap()
    }).catch((err) => {
      console.info("access failed with error message: " + err.message + ", error code: " + err.code);
      this.installLoading = false;
    });
  }

  downloadHap() {
    let filePath = globalThis.abilityContext.filesDir + '/' + this.fileName;
    let downloadTask;

    try {
      request.downloadFile(globalThis.abilityContext, {
        url: this.url,
        filePath: filePath
      }).then((data) => {
        downloadTask = data;
        // 监听下载完成
        downloadTask.on('complete', () => {
          console.info('Download task completed.');
          // 安装应用
          this.installApp(filePath);
        });
        // 监听下载失败
        downloadTask.on('fail', function callBack(err) {
          console.info('Download task failed. Cause:' + err);
          this.installLoading = false;
          promptAction.showToast({ message: '下载失败', duration: ToastDuration });
        });
      }).catch((err) => {
        console.error('Failed to request the download. Cause: ' + JSON.stringify(err));
        this.installLoading = false;
        promptAction.showToast({ message: '下载失败', duration: ToastDuration });
      })
    } catch (err) {
      // err.message: bad file path   Download File already exists
      console.error('err.code : ' + err.code + ', err.message : ' + err.message);
      this.installLoading = false;
      promptAction.showToast({ message: '下载失败', duration: ToastDuration });
    }
  }

  installApp(hapPath: string) {
    let hapFilePaths = [hapPath];
    let installParam = {
      userId: 100,
      isKeepData: false,
      installFlag: 1,
    };

    try {
      installer.getBundleInstaller().then(data => {
        data.install(hapFilePaths, installParam, err => {
          this.installLoading = false;
          if (err) {
            console.error('install failed:' + err.message);
            promptAction.showToast({ message: '安装失败：' + err.message, duration: ToastDuration });
          } else {
            console.info('install successfully.');
            promptAction.showToast({ message: '安装成功', duration: ToastDuration });
            this.controller.close()
          }
        });
      }).catch(error => {
        console.error('getBundleInstaller failed. Cause: ' + error.message);
        this.installLoading = false;
        promptAction.showToast({ message: '安装失败：' + error.message, duration: ToastDuration });
      });
    } catch (error) {
      console.error('getBundleInstaller failed. Cause: ' + error.message);
      this.installLoading = false;
      promptAction.showToast({ message: '安装失败：' + error.message, duration: ToastDuration });
    }
  }
}

export { LongPressMenuDialog, DownloadAndInstallHapDialog }