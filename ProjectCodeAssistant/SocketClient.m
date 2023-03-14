//
//  SocketClient.m
//  ProjectCodeAssistant
//
//  Created by Pavlo Havrylyuk on 2/22/23.
//

#import "SocketClient.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

@implementation SocketClient
- (int)connectToServerWithIP:(NSString *)ip andPort:(int)port {
    int socketDescriptor = socket(AF_INET, SOCK_STREAM, 0);
    if (socketDescriptor == -1) {
        NSLog(@"Failed to create socket");
        return -1;
    }
    struct sockaddr_in address;
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    address.sin_addr.s_addr = inet_addr([ip UTF8String]);
    bzero(&(address.sin_zero), 8);

    int connectionStatus = connect(socketDescriptor, (struct sockaddr *) &address, sizeof(address));
    NSLog(@"Socket Info:");
    NSLog(@"ipAddress: %@", ip);
    NSLog(@"portNumber: %d", port);
    if (connectionStatus == -1) {
        NSLog(@"Failed to connect to server");
        return -1;
    }
    return socketDescriptor;
}

// Send data to the socket server
- (BOOL)sendData:(NSData *)data onSocket:(int)socketDescriptor {
    const void *dataPtr = [data bytes];
    size_t dataSize = [data length];
    ssize_t bytesSent = send(socketDescriptor, dataPtr, dataSize, 0);
    if (bytesSent == -1) {
        NSLog(@"Failed to send data");
        return NO;
    }
    return YES;
}

// Receive data from the socket server
- (NSData *)receiveDataOnSocket:(int)socketDescriptor {
    char buffer[1024];
    ssize_t bytesRead = recv(socketDescriptor, buffer, sizeof(buffer), 0);
    if (bytesRead == -1) {
        NSLog(@"Failed to receive data");
        return nil;
    }
    return [NSData dataWithBytes:buffer length:bytesRead];
}


@end
