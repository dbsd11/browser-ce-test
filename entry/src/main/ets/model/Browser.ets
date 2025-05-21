/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import Logger from './Logger'
import prompt from '@ohos.prompt';
import webview from '@ohos.web.webview';

export class WebObject {
  controller: WebviewController;
  isRegistered: boolean;
  constructor(controller: WebviewController, isRegistered: boolean) {
    this.controller = controller
    this.isRegistered = isRegistered
  }
}

@Observed
export class WebKey {
  key: number;
  timestamp: number;
  url: string;

  constructor(key: number, timestamp: number, url: string) {
    this.key = key
    this.timestamp = timestamp
    this.url = url
  }
}

export enum LoadingStatus {
  LOADING,
  END
}

const TAG: string = '[browser]'

export class Browser {
  inputValue: string = ""
  tabArrayIndex: number = 0
  progress: number = 0
  hideProgress: boolean = true
  loadingStatus: LoadingStatus = LoadingStatus.END

  webArray: Array<WebKey> = [new WebKey(0, new Date().getTime(), "")]
  tabsController: TabsController = new TabsController()
  webControllerArray: Array<WebObject> = [new WebObject(new webview.WebviewController(), false)]

  deleteTab(index: number) {
    Logger.info(TAG, `delete before tab index= ${index} controller length ${this.webControllerArray.length} tabArrayIndex= ${this.tabArrayIndex}`)
    this.webArray.splice(index, 1)
    this.webControllerArray.splice(index, 1)
    let needChangeTabIndex = false;
    if(this.tabArrayIndex == index) {
      needChangeTabIndex = true;
    }
    if (this.tabArrayIndex > index || this.tabArrayIndex === this.webArray.length) {
      this.tabArrayIndex -= 1
    }
    for (let i = index;i < this.webArray.length; ++i) {
      this.webArray[i].key -= 1
    }
    for (let i = 0;i < this.webArray.length; ++i) {
      Logger.info(TAG, `key ${this.webArray[i].key}, time=${this.webArray[i].timestamp}`)
    }
    Logger.info(`delete after tab index=${index}, controller length=${this.webControllerArray.length}, tabArrayIndex=${this.tabArrayIndex}`)
    if (needChangeTabIndex) {
      this.tabsController.changeIndex(this.tabArrayIndex)
    }
  }

  getWebArray() {
    return this.webArray
  }

  addTab() {
    this.addTabWithUrl("")
  }

  addTabWithUrl(url:string) {
    if (this.webArray.length >= 10) {
      this.deleteTab(0)
    }
    let webController: WebviewController = new webview.WebviewController();
    let object = new WebObject(webController, false)
    this.webControllerArray.push(object)
    this.webArray.push(new WebKey(this.webArray.length, new Date().getTime(), url))
    Logger.info(TAG, `add tab index= ${this.tabArrayIndex}`)
    this.inputValue = Math.random().toString(36).substr(2, 9) + new Date().getTime();
  }

  setTabArrayIndex(tabArrayIndex: number) {
    this.tabArrayIndex = tabArrayIndex
  }

  getTabArrayIndex() {
    return this.tabArrayIndex
  }

  setInputVal(inputValue: string) {
    this.inputValue = inputValue
  }

  getInputVal() {
    return this.inputValue
  }

  loadUrl(addr: string) {
//    addr = "https://" + addr; // 移除追加 https:// 前缀
    this.webControllerArray[this.tabArrayIndex].controller.loadUrl(addr)
  }

  Back() {
    if (this.webControllerArray[this.tabArrayIndex].controller.accessBackward()) {
      this.webControllerArray[this.tabArrayIndex].controller.backward()
    }
  }

  Forward() {
    if (this.webControllerArray[this.tabArrayIndex].controller.accessForward()) {
      this.webControllerArray[this.tabArrayIndex].controller.forward()
    }
  }

  Refresh() {
    this.webControllerArray[this.tabArrayIndex].controller.refresh()
  }
}
