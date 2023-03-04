//
//  AliyunFaceManager.m
//  Huatao
//
//  Created on 2023/3/4.
//  
	

#import "AliyunFaceManager.h"
#import <AliyunFaceAuthFacade/AliyunFaceAuthFacade.h>


@implementation AliyunFaceManager

+ (void)initFaceSDK {
    [AliyunFaceAuthFacade init];
}

+ (NSDictionary *)getMetaInfo {
    return [AliyunFaceAuthFacade getMetaInfo];
}

+ (void)verifyWith:(NSString *)zimId extParams:(NSDictionary *)params onCompletion:(FaceCallBack)callback {
    [AliyunFaceAuthFacade verifyWith:zimId extParams:params onCompletion:^(ZIMResponse * _Nonnull response) {
        switch (response.code) {
            case ZIMResponseSuccess:
                callback(YES, @"");
                break;
            case ZIMInternalError:
                callback(NO, @"用户被动退出(极简核身没有取到协议、toyger启动失败、协议解析失败)[zim不会弹框处理]");
            case ZIMInterrupt:
                callback(NO, @"用户主动退出(无相机权限、超时、用户取消)[zim会弹框处理]");
            case ZIMNetworkfail:
                callback(NO, @"网络失败(标准zim流程，请求协议错误，oss上传失败)[zim不会弹框处理]");
            case ZIMTIMEError:
                callback(NO, @"设备时间设置不对");
            case ZIMResponseFail:
                callback(NO, @"服务端validate失败(人脸比对失败或者证件宝OCR/质量检测失败)[zim不会弹框处理]");
            default:
                callback(NO, @"");
                break;
        }
    }];
}

@end
