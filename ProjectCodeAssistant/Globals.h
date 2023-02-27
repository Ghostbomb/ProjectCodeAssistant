//
//  Globals.h
//  ProjectCodeAssistant
//
//  Created by Pavlo Havrylyuk on 2/22/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Globals : NSObject

#define DEBUG_DEV

@property (nonatomic, strong) NSString *lastCreatedProject;
//@property (nonatomic, assign) NSInteger myInteger;

+ (Globals *)sharedInstance;

@end

NS_ASSUME_NONNULL_END
