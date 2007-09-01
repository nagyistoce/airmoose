//
//  PrefsWindow.m
//  AirMoose
//
//  Created by Geoffrey Garside on 31/08/2007.
//  Copyright 2007 AirMoose. All rights reserved.
//

#import "PrefsWindow.h"

@implementation PrefsWindow

// Reset the FirstResponder on close.
// This should result in the preferences being 
// saved when the window is closed.
- (void) close
{
    [self makeFirstResponder: nil];
    [super close];
}

@end
