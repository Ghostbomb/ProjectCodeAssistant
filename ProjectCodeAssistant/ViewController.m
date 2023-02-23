//
//  ViewController.m
//  ProjectCodeAssistant
//
//  Created by Pavlo Havrylyuk on 1/29/23.
//

#import "ViewController.h"
#import "SocketClient.h"
#import "Globals.h"
//#import "ImageAndTextView.h"

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
//    ImageAndTextView *item1 = [[ImageAndTextView alloc] initWithFrame:NSMakeRect(0, 0, 200, 42)];
//        item1.image = [NSImage imageNamed:@"square.and.arrow.up"];
//        item1.text = @"Item 1";
//        [self.IDESelectorPopUpBox addItemWithObjectValue:item1];
//
//        ImageAndTextView *item2 = [[ImageAndTextView alloc] initWithFrame:NSMakeRect(0, 0, 200, 42)];
//        item2.image = [NSImage imageNamed:@"square.and.arrow.up"];
//        item2.text = @"Item 2";
//        [self.IDESelectorPopUpBox addItemWithObjectValue:item2];

    // Do any additional setup after loading the view.
}

- (IBAction)openFileBrowser:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = YES;
    openPanel.canCreateDirectories = YES;
    openPanel.allowsMultipleSelection = NO;
    openPanel.canChooseFiles = NO;
    [openPanel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSModalResponseOK) {
            NSURL *selectedURL = openPanel.URLs[0];
            NSLog(@"Selected URL: %@", selectedURL);
            self.FolderDirectoryField.stringValue = selectedURL.path;
            self.FolderDirectoryPathController.URL = selectedURL;
            [self appendTextToTextField:@"Selected Folder:"];
            [self appendTextToTextField:selectedURL.path];
        }
    }];

}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)appendTextToTextField:(NSString *)text {
    NSString *currentText = self.LogTextField.stringValue;
    if ([currentText isEqualToString:@""]) {
        self.LogTextField.stringValue = text;
    }else{
        self.LogTextField.stringValue = [currentText stringByAppendingFormat:@"\n%@", text];
    }
}

- (void)clearLogTextField {
    self.LogTextField.stringValue = @"";
}


- (IBAction)runCreateProject:(NSButton *)sender {
    [self clearLogTextField];
    [self appendTextToTextField:@"Creating Project..."];
    [self appendTextToTextField:@"Connecting to Microservice..."];
    SocketClient *socketClient = [[SocketClient alloc] init];
    int socketDescriptor = [socketClient connectToServerWithIP:@"127.0.0.1" andPort:9876];
    if (socketDescriptor == -1) {
        [self appendTextToTextField:@"Failed to connect to Microservice"];
        return;
    }else{
        [self appendTextToTextField:@"Connected to Microservice"];
    }

    //Grab data and convert to JSON with proper bool values/conversions
    NSString *userName = _userProjectName.stringValue;
    NSString *userDescription = @"test";
    BOOL userPrivateGit = _userPrivateGit.state;
    NSString *userBranchName = _userBranchName.stringValue;
    NSString *userLocation = _userLocation.stringValue;
    BOOL userPublishRepo = _userPublishRepo.state;   


    NSDictionary *jsonData = @{
        @"name": userName,
        @"description": userDescription,
        @"private": @(userPrivateGit),
        @"branch": userBranchName,
        @"location": userLocation,
        @"publish": @(userPublishRepo)
    };

    NSData *jsonDataToSend = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:nil];
    BOOL success = [socketClient sendData:jsonDataToSend onSocket:socketDescriptor];

    //Once confimation recieved
    // [[Globals sharedInstance] setLastCreatedProject:userLocation];
    
}

- (IBAction)userUndoButton:(NSButton *)sender {
    NSString *folderPath = [[Globals sharedInstance] lastCreatedProject];
    [self appendTextToTextField:@"Undoing Project..."];
    NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // Check if the folder exists
        if (![fileManager fileExistsAtPath:folderPath]) {
            NSLog(@"Folder does not exist");
            [self appendTextToTextField:@"Folder does not exist"];
            return;
        }
        
        // Move the folder to the trash
        NSError *error;
        BOOL success = [fileManager trashItemAtURL:[NSURL fileURLWithPath:folderPath] resultingItemURL:nil error:&error];
        if (success) {
            NSLog(@"Folder moved to trash successfully");
            [self appendTextToTextField:@"Folder moved to trash successfully"];
        }
        else {
            NSLog(@"Error moving folder to trash: %@", error.localizedDescription);
            [self appendTextToTextField:@"Error moving folder to trash"];
        }
}
@end
