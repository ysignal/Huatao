//
//  AliyunFaceManager.h
//  Huatao
//
//  Created on 2023/3/4.
//  
	

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FaceCallBack)(BOOL result, NSString* errorMsg);
@interface AliyunFaceManager : NSObject

+ (void)initFaceSDK;

+ (NSDictionary *)getMetaInfo;

+ (void)verifyWith:(NSString *)zimId
         extParams:(NSDictionary *)params
      onCompletion:(FaceCallBack)callback;

@end

NS_ASSUME_NONNULL_END
