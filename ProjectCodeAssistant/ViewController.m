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

    #ifdef DEBUG_DEV
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.userProjectName.stringValue = [NSString stringWithFormat:@"TestProject %@", [dateFormatter stringFromDate:[NSDate date]]];
        // have this be a folder in the user's home directory
        self.FolderDirectoryField.stringValue = [NSString stringWithFormat:@"%@/Xcode_DEV/ProjectCodeAssistant/test/", NSHomeDirectory()];
        // self.userBranchName.stringValue = @"main";
        self.IDESelectorPopUpBox.stringValue = @"CLion";
    #endif

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


static void createFolder(ViewController *object, NSString *userLocation, NSString *userName) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folderPath = [userLocation stringByAppendingPathComponent:userName];
    NSError *error;
    BOOL folderCreationSuccess = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (folderCreationSuccess) {
        NSLog(@"Folder created successfully");
        [object appendTextToTextField:@"Folder created successfully"];
        [object appendTextToTextField:folderPath];
        [[Globals sharedInstance] setLastCreatedProject:folderPath];
    }
    else {
        NSLog(@"Error creating folder: %@", error.localizedDescription);
        [object appendTextToTextField:@"Error creating folder"];
        return;
    }
}

static void buildJSONData(ViewController *object, NSDictionary **jsonData, NSString **userLocation, NSString **userName) {
    *userName = object->_userProjectName.stringValue;
    NSString *userDescription = @"test";
    BOOL userPrivateGit = object->_userPrivateGit.state;
    NSString *userBranchName = object->_userBranchName.stringValue;
    *userLocation = object->_userLocation.stringValue;
    BOOL userPublishRepo = object->_userPublishRepo.state;
    
    
    *jsonData = @{
        @"name": *userName,
        @"description": userDescription,
        @"private": @(userPrivateGit),
        @"branch": userBranchName,
        @"location": *userLocation,
        @"publish": @(userPublishRepo)
    };
}

static void sendJSONData(ViewController *object, NSDictionary *jsonData, SocketClient *socketClient, int socketDescriptor) {
    NSData *jsonDataToSend = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:nil];
    BOOL sendDataSuccess = [socketClient sendData:jsonDataToSend onSocket:socketDescriptor];
    if(sendDataSuccess){
        [object appendTextToTextField:@"Data sent to Microservice"];
    }else{
        [object appendTextToTextField:@"Failed to send data to Microservice"];
        return;
    }
}

static void connectToSocket(ViewController *object, SocketClient **socketClient, int *socketDescriptor) {
    [object appendTextToTextField:@"Connecting to Microservice..."];
    *socketClient = [[SocketClient alloc] init];
    *socketDescriptor = [*socketClient connectToServerWithIP:@"127.0.0.1" andPort:9876];
    if (*socketDescriptor == -1) {
        [object appendTextToTextField:@"Failed to connect to Microservice"];
        //        return;
    }else{
        // Wait to receive "Hello from server" from server before going on
//        NSData *data = [*socketClient receiveDataOnSocket:*socketDescriptor];
//        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"Received data: %@", dataString);
//        if(dataString != nil || [dataString isEqualToString:@"Hello from server"]){
            [object appendTextToTextField:@"Connected to Microservice"];
//        }
    }
}

static void dataFilledOutCheck(ViewController *object) {
    if ([object.userProjectName.stringValue isEqualToString:@""] ||
        [object.userLocation.stringValue isEqualToString:@""] ||
        [object.userBranchName.stringValue isEqualToString:@""] ||
        [object.IDESelectorPopUpBox.stringValue isEqualToString:@""]
        )
    {
        [object appendTextToTextField:@"Please fill out all fields"];
        return;
    }
}


static void runShellScript(const char *command) {
    // Execute the command
    NSLog(@"Executing commands: %s", command);
    int result = system(command);
    
    // Check if the command executed successfully
    if (result == 0) {
        NSLog(@"Command executed successfully");
    } else {
        NSLog(@"Command failed with exit code %d", result);
    }
}

- (IBAction)runCreateProject:(NSButton *)sender {
    [self clearLogTextField];
        
    // #ifndef DEBUG
        dataFilledOutCheck(self);
    // #endif
    
    [self appendTextToTextField:@"Creating Project..."];
    // Connect
    SocketClient * socketClient;
    int socketDescriptor;
    connectToSocket(self, &socketClient, &socketDescriptor);

    //Grab data and convert to JSON with proper bool values/conversions
    NSString * userName;
    NSString * userLocation;
    NSDictionary * jsonData;
    buildJSONData(self, &jsonData, &userLocation, &userName);

    // Create a folder with the name of the project
    createFolder(self, userLocation, userName);
    

    NSString *runCommand = [NSString stringWithFormat:@"cd \"%@\" && git init --initial-branch=\"%@\"", [[Globals sharedInstance] lastCreatedProject], self.userBranchName.stringValue];
    // Execute the command
    runShellScript([runCommand UTF8String]);
    
    // Send Data
    sendJSONData(self, jsonData, socketClient, socketDescriptor);

    // Receive Data and set to "repoLink" variable and print to screen
    NSData *data = [socketClient receiveDataOnSocket:socketDescriptor];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received data: %@", dataString);
    if(dataString != nil){
        // print to screen

    }

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
            NSLog(@"Folder path: %@", folderPath);
            [self appendTextToTextField:@"Folder moved to trash successfully"];
            [self appendTextToTextField:folderPath];
            
        }
        else {
            NSLog(@"Error moving folder to trash: %@", error.localizedDescription);
            [self appendTextToTextField:@"Error moving folder to trash"];
        }
}
@end
