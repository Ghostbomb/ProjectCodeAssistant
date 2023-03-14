//
//  ViewController.h
//  ProjectCodeAssistant
//
//  Created by Pavlo Havrylyuk on 1/29/23.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
//Outlets
@property (strong) IBOutlet NSComboBox *IDESelectorPopUpBox;
@property (strong) IBOutlet NSTextField *FolderDirectoryField;
@property (weak) IBOutlet NSPathControl *FolderDirectoryPathController;

@property (strong) IBOutlet NSButton *FolderSelectionButton;

@property (strong) IBOutlet NSProgressIndicator *ProgressIndicator;

@property (strong) IBOutlet NSTextField *LogTextField;
@property (weak) IBOutlet NSButton *createProjectButton;

- (IBAction)runCreateProject:(NSButton *)sender;
@property (weak) IBOutlet NSTextField *userProjectName;
@property (weak) IBOutlet NSButton *userPrivateGit;
@property (weak) IBOutlet NSTextField *userBranchName;
@property (weak) IBOutlet NSTextField *userLocation;
@property (weak) IBOutlet NSButton *userPublishRepo;
- (IBAction)userUndoButton:(NSButton *)sender;
- (IBAction)updatedFolderIconPath:(id)sender;
- (IBAction)updatedFolderStringPath:(id)sender;



//Function Prototypes
- (void)appendTextToTextField:(NSString *)text;
- (void)clearLogTextField;
- (BOOL) runDepCheck:(NSString *)command;

@end

