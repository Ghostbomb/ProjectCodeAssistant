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

#define PROGRESSINDICATORFACTOR 6

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self runDepCheck:@"git --version"]) {
        NSLog(@"Git is installed");
    } else {
        NSLog(@"Git is not installed");
        [self appendTextToTextField:@"ERROR: Git is not installed"];
        [self appendTextToTextField:@"Please install and restart"];
        self.createProjectButton.enabled = NO;
    }

#ifdef DEBUG_DEV
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    self.userProjectName.stringValue = [NSString stringWithFormat:@"TestProject%@", [dateFormatter stringFromDate:[NSDate date]]];
    self.FolderDirectoryField.stringValue = [NSString stringWithFormat:@"%@/Xcode_DEV/ProjectCodeAssistant/test/", NSHomeDirectory()];
    self.IDESelectorPopUpBox.stringValue = @"CLion";
#endif

}


- (BOOL)runDepCheck:(NSString *)command {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:@[@"-c", command]];
    [task setStandardOutput:[NSPipe pipe]];
    [task launch];
    [task waitUntilExit];
    int status = [task terminationStatus];
    NSLog(@"Dep Status: %d", status);

    if (status == 0) {
        return YES;
    } else {
        return NO;
    }
}

- (IBAction)openFileBrowser:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = YES;
    openPanel.canCreateDirectories = YES;
    openPanel.allowsMultipleSelection = NO;
    openPanel.canChooseFiles = NO;
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
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
}

- (void)appendTextToTextField:(NSString *)text {
    NSString *currentText = self.LogTextField.stringValue;
    if ([currentText isEqualToString:@""]) {
        self.LogTextField.stringValue = text;
    } else {
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
    } else {
        NSLog(@"Error creating folder: %@", error.localizedDescription);
        [object appendTextToTextField:@"Error creating folder"];
        return;
    }
}

static void
buildJSONData(ViewController *object, NSDictionary **jsonData, NSString **userLocation, NSString **userName) {
    *userName = object->_userProjectName.stringValue;
    NSString *userDescription = @"test";
    BOOL userPrivateGit = object->_userPrivateGit.state;
    NSString *userBranchName = object->_userBranchName.stringValue;
    *userLocation = object->_userLocation.stringValue;
    BOOL userPublishRepo = object->_userPublishRepo.state;

    *jsonData = @{@"name": *userName, @"description": userDescription, @"private": @(userPrivateGit),
                  @"branch": userBranchName, @"location": *userLocation, @"publish": @(userPublishRepo)};
}

static void
sendJSONData(ViewController *object, NSDictionary *jsonData, SocketClient *socketClient, int socketDescriptor) {
    NSData *jsonDataToSend = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:nil];
    BOOL sendDataSuccess = [socketClient sendData:jsonDataToSend onSocket:socketDescriptor];
    if (sendDataSuccess) {
        [object appendTextToTextField:@"Data sent to Microservice"];
    } else {
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
    } else {
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
        [object.IDESelectorPopUpBox.stringValue isEqualToString:@""]) {
        [object appendTextToTextField:@"Please fill out all fields"];
        return;
    }
}


static BOOL runShellScript(const char *command) {
    // Execute the command
    NSLog(@"Executing commands: %s", command);
    int result = system(command);

    // Check if the command executed successfully
    if (result == 0) {
        NSLog(@"Command executed successfully");
        return YES;
    } else {
        NSLog(@"Command failed with exit code %d", result);
        return NO;
    }
}

static void ideSelectorCommand(ViewController *object, NSString **runCommand) {
    //create a switch with Visual studio, Intellij, CLion, PyCharm and open each program with passing in the path to the folder
    if ([object.IDESelectorPopUpBox.stringValue isEqualToString:@"Visual Studio Code"]) {
        *runCommand = [NSString stringWithFormat:@"cd \"%@\" && code .", [[Globals sharedInstance] lastCreatedProject]];
    } else if ([object.IDESelectorPopUpBox.stringValue isEqualToString:@"Intellij"]) {
        *runCommand = [NSString stringWithFormat:@"open -a \"IntelliJ IDEA.app\" \"%@\"", [[Globals sharedInstance] lastCreatedProject]];
    } else if ([object.IDESelectorPopUpBox.stringValue isEqualToString:@"CLion"]) {
        *runCommand = [NSString stringWithFormat:@"open -a \"CLion.app\" \"%@\"", [[Globals sharedInstance] lastCreatedProject]];
    } else if ([object.IDESelectorPopUpBox.stringValue isEqualToString:@"PyCharm"]) {
        *runCommand = [NSString stringWithFormat:@"open -a \"PyCharm.app\" \"%@\"", [[Globals sharedInstance] lastCreatedProject]];
    }
}

static void convertHTTPtoSSH(NSString **dataString) {
    *dataString = [*dataString stringByReplacingOccurrencesOfString:@"https://" withString:@"git@"];
    *dataString = [*dataString stringByReplacingOccurrencesOfString:@".com/" withString:@".com:"];
    *dataString = [*dataString stringByReplacingOccurrencesOfString:@".git" withString:@".git"];
    NSLog(@"Converted data: %@", *dataString);
}

//create funciton to incarment ProgressIndicator
static void incarmentProgressIndicator(ViewController *object) {
    [object.ProgressIndicator setDoubleValue:[object.ProgressIndicator doubleValue] + 100 / PROGRESSINDICATORFACTOR];
}

- (IBAction)runCreateProject:(NSButton *)sender {
    [self clearLogTextField];
    dataFilledOutCheck(self);
    incarmentProgressIndicator(self);


    [self appendTextToTextField:@"Creating Project..."];

    // Connect Socket
    SocketClient *socketClient;
    int socketDescriptor;
    connectToSocket(self, &socketClient, &socketDescriptor);
    incarmentProgressIndicator(self);


    //Grab data and convert to JSON with proper bool values/conversions
    NSString *userName;
    NSString *userLocation;
    NSDictionary *jsonData;
    buildJSONData(self, &jsonData, &userLocation, &userName);

    // Create a folder with the name of the project
    createFolder(self, userLocation, userName);
    incarmentProgressIndicator(self);

    // Execute commands for git initializiation
    NSString *runCommand = [NSString stringWithFormat:@"cd \"%@\" && git init --initial-branch=\"%@\"", [[Globals sharedInstance] lastCreatedProject], self.userBranchName.stringValue];

    if (!runShellScript([runCommand UTF8String])) {
        [self appendTextToTextField:@"Failed to run command:"];
        [self appendTextToTextField:runCommand];
        return;
    };
    runCommand = [NSString stringWithFormat:@"cd \"%@\" && echo \"# %@\" >> README.md", [[Globals sharedInstance] lastCreatedProject], self.userProjectName.stringValue];
    if (!runShellScript([runCommand UTF8String])) {
        [self appendTextToTextField:@"Failed to run command:"];
        [self appendTextToTextField:runCommand];
        return;
    };
    incarmentProgressIndicator(self);

    // Send Data to Microservice
    sendJSONData(self, jsonData, socketClient, socketDescriptor);

    // Receive Data and set to "repoLink" variable and print to screen
    NSData *data = [socketClient receiveDataOnSocket:socketDescriptor];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received data: %@", dataString);
    if (dataString != nil) {
        [self appendTextToTextField:@"Received data from Microservice"];
        [self appendTextToTextField:dataString];
//        convertHTTPtoSSH(&dataString);
        runCommand = [NSString stringWithFormat:@"cd \"%@\" && git remote add origin \"%@\"", [[Globals sharedInstance] lastCreatedProject], dataString];
        if (!runShellScript([runCommand UTF8String])) {
            [self appendTextToTextField:@"Failed to run command:"];
            [self appendTextToTextField:runCommand];
            return;
        };;
    } else {
        [self appendTextToTextField:@"Failed to receive data from Microservice"];
        return;
    }
    incarmentProgressIndicator(self);

    runCommand = [NSString stringWithFormat:@"cd \"%@\" && git add . && git commit -m \"Initial Commit\" && git push -u origin %@", [[Globals sharedInstance] lastCreatedProject], self.userBranchName.stringValue];
    if (!runShellScript([runCommand UTF8String])) {
        [self appendTextToTextField:@"Failed to run command:"];
        [self appendTextToTextField:runCommand];
//        return;
    };

    // Check IDE selector and run proper command to open IDE
    ideSelectorCommand(self, &runCommand);
    if (!runShellScript([runCommand UTF8String])) {
        [self appendTextToTextField:@"Failed to run command:"];
        [self appendTextToTextField:runCommand];
        return;
    };
    incarmentProgressIndicator(self);

}

- (IBAction)updatedFolderIconPath:(id)sender {
    self.FolderDirectoryField.stringValue = self.FolderDirectoryPathController.URL.path;
}

- (IBAction)updatedFolderStringPath:(id)sender {
    self.FolderDirectoryPathController.URL = [NSURL fileURLWithPath:self.FolderDirectoryField.stringValue];
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

    } else {
        NSLog(@"Error moving folder to trash: %@", error.localizedDescription);
        [self appendTextToTextField:@"Error moving folder to trash"];
    }
}
@end
