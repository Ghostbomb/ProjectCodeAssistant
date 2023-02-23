//
//  Globals.m
//  ProjectCodeAssistant
//
//  Created by Pavlo Havrylyuk on 2/22/23.
//

#import "Globals.h"

@implementation Globals

+ (Globals *)sharedInstance {
    static Globals *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _lastCreatedProject = nil;
    }
    return self;
}

@end
