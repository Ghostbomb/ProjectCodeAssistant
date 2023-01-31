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
@property (strong) IBOutlet NSButton *button;
@property (strong) IBOutlet NSTextField *FolderDirectoryField;
@property (weak) IBOutlet NSPathControl *FolderDirectoryPathController;

@property (strong) IBOutlet NSButton *FolderSelectionButton;

@property (strong) IBOutlet NSProgressIndicator *ProgressIndicator;

@property (strong) IBOutlet NSTextField *LogTextField;



//Function Prototypes
- (void)appendTextToTextField:(NSString *)text;

@end

