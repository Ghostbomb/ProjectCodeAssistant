//
//  ImageAndTextView.m
//  ProjectCodeAssistant
//
//  Created by Pavlo Havrylyuk on 1/30/23.
//

#import "ImageAndTextView.h"

@implementation ImageAndTextView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    [self.image drawInRect:NSMakeRect(5, 5, 32, 32)];
    [self.text drawAtPoint:NSMakePoint(42, 18) withAttributes:nil];
}

@end
