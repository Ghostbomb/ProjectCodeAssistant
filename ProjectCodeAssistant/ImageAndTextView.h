//
//  ImageAndTextView.h
//  ProjectCodeAssistant
//
//  Created by Pavlo Havrylyuk on 1/30/23.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageAndTextView : NSView

@property (strong, nonatomic) NSImage *image;
@property (copy, nonatomic) NSString *text;

@end

NS_ASSUME_NONNULL_END
