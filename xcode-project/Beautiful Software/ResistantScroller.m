//
//  ResistantScroller.m
//  Beautiful Software
//
//  Created by Jesse Black on 2/7/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import "ResistantScroller.h"

#import "BookingSchedule.h"

@implementation ResistantScroller
@synthesize receiver;
-(id)init
{
	self = [super init];
	self.receiver = nil;
	return self;
}
-(BOOL)acceptsFirstResponder
{
	return NO;
}
- (void)scrollWheel:(NSEvent *)theEvent
{
	
}
-(void)mouseUp:(NSEvent*)aEvent
{
	[super mouseUp:aEvent];
	if ([[receiver className] compare:@"BookingSchedule"] == NSOrderedSame)	{
		[receiver stylistClicked:aEvent sender:self];
	}
	
}

@end
