//
//  VidyoIOBridge.h
//  CustomLayoutSample
//
//  Created by Sachin Hegde on 7/24/17.
//  Copyright © 2017 Sachin Hegde. All rights reserved.
//

#ifndef VidyoIOBridge_h
#define VidyoIOBridge_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <VidyoClientIOS.framework/Headers/Lmi/VidyoClient/VidyoConnector_Objc.h>



@interface VidyoClientConnector (VidyoIOBridge)

+(void) initializeVidyoClient;

@end


#endif /* VidyoIOBridge_h */
