//
//  SocketClient.h
//  ProjectCodeAssistant
//
//  Created by Pavlo Havrylyuk on 2/22/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SocketClient : NSObject

- (int)connectToServerWithIP:(NSString *)ipAddress andPort:(int)portNumber;
- (BOOL)sendData:(NSData *)data onSocket:(int)socketDescriptor;
- (NSData *)receiveDataOnSocket:(int)socketDescriptor;

@end


NS_ASSUME_NONNULL_END
