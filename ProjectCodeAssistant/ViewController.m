//
//  ViewController.m
//  ProjectCodeAssistant
//
//  Created by Pavlo Havrylyuk on 1/29/23.
//

#import "ViewController.h"
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
    self.LogTextField.stringValue = [currentText stringByAppendingFormat:@"\n%@", text];
//    [self.scrollView.contentView scrollToPoint:NSMakePoint(0, self.textField.frame.size.height)];
//    [self.scrollView reflectScrolledClipView:self.scrollView.contentView];
}


@end
