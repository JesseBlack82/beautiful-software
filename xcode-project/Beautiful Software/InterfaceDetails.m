//
//  InterfaceDetails.m
//  Beautiful Software
//
//  Created by Jesse Black on 6/19/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import "InterfaceDetails.h"


@implementation InterfaceDetails
-(IBAction)cycleThroughWindows:(id)sender
{
	NSApplication * myApp = [NSApplication sharedApplication];
	NSArray * windowsMenu = [[myApp windowsMenu] itemArray];
	int i;
	BOOL foundMain = NO;
	for (i=0 ; i< [windowsMenu count] ; i++)	{
		if ([[[[windowsMenu objectAtIndex:i] target] className] compare:@"NSWindow"] == NSOrderedSame)	{
			NSWindow * window = [[windowsMenu objectAtIndex:i] target];
			if ([window isMainWindow])	{
				foundMain = YES;
			} else	{
				if (foundMain)	{
					[window makeKeyAndOrderFront:self];
					i = [windowsMenu count] + 2;
				}
			}
		}
	}
	if (i == [windowsMenu count])	{
		
		for (i=0 ; i< [windowsMenu count] ; i++)	{
			if ([[[[windowsMenu objectAtIndex:i] target] className] compare:@"NSWindow"] == NSOrderedSame)	{
				NSWindow * window = [[windowsMenu objectAtIndex:i] target];
				if (window != nil)	{
					if ([window isMainWindow] == NO)	{
						[window makeKeyAndOrderFront:self];
						i = [windowsMenu count] + 2;
					}
				}
			}
						
		}
	}
}
@end
