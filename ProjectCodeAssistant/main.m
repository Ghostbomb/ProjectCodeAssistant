//
//  main.m
//  ProjectCodeAssistant
//
//  Created by Pavlo Havrylyuk on 1/29/23.
//

#import <Cocoa/Cocoa.h>

#import "SocketClient.h"


NSDictionary *jsonData = @{
    @"name": @"John Doe",
    @"age": @30,
    @"email": @"john.doe@example.com"
};


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
    }
    SocketClient *socketClient = [[SocketClient alloc] init];
        int socketDescriptor = [socketClient connectToServerWithIP:@"127.0.0.1" andPort:9876];
        NSLog(@"Socket descriptor: %d", socketDescriptor);
        if (socketDescriptor != -1) {
            NSString *message = @"Hello, server!";
            NSData *dataToSend = [message dataUsingEncoding:NSUTF8StringEncoding];
            BOOL success = [socketClient sendData:dataToSend onSocket:socketDescriptor];

            if (success) {
                NSLog(@"Sent data successfully");
            }
            else {
                NSLog(@"Failed to send data");
            }
        }
        else {
            NSLog(@"Failed to connect to server");
        }
        // Receive/print data from the socket server
        NSData *dataReceived = [socketClient receiveDataOnSocket:socketDescriptor];
        if (dataReceived) {
            NSString *message = [[NSString alloc] initWithData:dataReceived encoding:NSUTF8StringEncoding];
            NSLog(@"Received data: %@", message);
        }
        else {
            NSLog(@"Failed to receive data");
        }
        // Send JSON data to the socket server
        NSData *jsonDataToSend = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:nil];
        BOOL success = [socketClient sendData:jsonDataToSend onSocket:socketDescriptor];
        if (success) {
            NSLog(@"Sent JSON data successfully");
        }
        else {
            NSLog(@"Failed to send JSON data");
        }
        
        
    
    return NSApplicationMain(argc, argv);
}
