/*
 * Copyright (c) 2026 Huawei Device Co., Ltd. All rights reserved
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

import { TurboModule, UITurboModuleContext } from '@rnoh/react-native-openharmony/ts';
import { TM } from './generated/ts';
import {
  DouYinOpenConfigBuilder,
  DouYinOpenListener,
  douYinOpenSDK,
  MixObject,
  OpenAuthRequest,
  OpenAuthResponse,
  OpenShareRequest,
  OpenShareResponse,
  OpenTitleObject,
  SupportApiName
} from '@douyin/opensdk-common-external';
import { bundleManager, common, Want } from '@kit.AbilityKit';
import { fileUri } from '@kit.CoreFileKit';

interface ShareConfig {
  videos: string[];
  isPublish?: boolean;
  title?: string;
  shortTitle?: string;
}

export class RNDouYinTurboModule extends TurboModule implements TM.DouYinNativeModule.Spec {
  private appLink: string = '';

  constructor(ctx: UITurboModuleContext) {
    super(ctx);
  }

  init(appKey: string): void {
    let apiParam = new DouYinOpenConfigBuilder(appKey)
      .setDebug(true)
      .build();
    douYinOpenSDK.init(apiParam)
  }

  auth(scope: string, state: string, appLink: string): Promise<ESObject> {
    this.appLink = appLink;
    return new Promise((resolve, reject) => {
      let listener: DouYinOpenListener = {
        onSuccess: (response: OpenAuthResponse, authCode: string, grantedPermissions: string) => {
          let result: ESObject = { code: response.isSuccess() ? 0 : response.errorCode, msg: response.errorMsg }
          resolve(JSON.stringify(result))
        },
        onError: (response: OpenAuthResponse, errCode: number, errMsg: string) => {
          let result: ESObject = { code: errCode, msg: errMsg }
          reject(JSON.stringify(result));
        }
      }
      let authRequest: OpenAuthRequest = new OpenAuthRequest();
      authRequest.scope = scope;
      authRequest.state = state;
      authRequest.callerLocalEntry = "EntryAbility"
      authRequest.redirectUri = appLink
      douYinOpenSDK.createDouYinOpenApi()?.authorize(getContext() as common.UIAbilityContext, authRequest, listener)
    });
  }

  shareVideo(shareConfig: ShareConfig): Promise<ESObject> {
    return new Promise((resolve, reject) => {
      let listener: DouYinOpenListener = {
        onSuccess: (response: OpenShareResponse) => {
          let result: ESObject = { code: response.isSuccess() ? 0 : response.errorCode, msg: response.errorMsg }
          resolve(JSON.stringify(result))
        },
        onError: (response: OpenShareResponse, errCode: number, errMsg: string) => {
          let result: ESObject = { code: errCode, msg: errMsg }
          reject(JSON.stringify(result));
        }
      }
      const request: OpenShareRequest = this.buildShareRequest(shareConfig.title, shareConfig.shortTitle)
      let douYinOpenApi = douYinOpenSDK.createDouYinOpenApi()
      if (douYinOpenApi?.isSupportApi(SupportApiName.SUPPORT_MIX) == true) {
        let mixObject = new MixObject()
        let videos = shareConfig.videos
        if (videos && videos.length > 0) {
          for (let i = 0; i < videos.length; i++) {
            let uri = fileUri.getUriFromPath(videos[i])
            mixObject.uriList.push(uri)
          }
        }
        request.mediaObject = mixObject
      }
      douYinOpenSDK.createDouYinOpenApi()?.share(getContext() as common.UIAbilityContext, request, listener)
    });
  }

  isAppInstalled(): boolean {
    try {
      let link = 'snssdk1128://aweme/detail';
      let canOpen = bundleManager.canOpenLink(link);
      return canOpen;
    } catch (err) {
      let message = (err as BusinessError).message;
      console.info('canOpenLink failed:'+JSON.stringify(message))
      return false;
    }
  }

  private buildShareRequest(title: string | undefined, shortTitle: string | undefined): OpenShareRequest {
    let request = new OpenShareRequest()
    request.state = "state"
    request.callerLocalEntry = "EntryAbility"
    request.redirectUri = this.appLink
    request.titleObject = new OpenTitleObject()
    if (title) {
      request.titleObject.title = title
    }

    if (shortTitle) {
      request.titleObject.shortTitle = shortTitle
    }
    return request
  }
}

export function doResult(context: common.UIAbilityContext, want: Want) {
  douYinOpenSDK.doResult(context, want)
}
