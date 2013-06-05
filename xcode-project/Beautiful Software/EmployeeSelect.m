//
//  EmployeeSelect.m
//  Beautiful Software
//
//  Created by Jesse Black on 2/1/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import "EmployeeSelect.h"
#import "InterfaceConstants.h"

@implementation EmployeeSelect

@synthesize buttons;
@synthesize requestedFrom;
@synthesize employees;
@synthesize keyedIn;

-(void)selectEmployeeFor:(id)newRequestedFrom selector:(SEL)newSelector windowTitle:(NSString *)windowTitle
{
	moc = [appDelegate managedObjectContext];

	[employeeSelectWindow setTitle:windowTitle];
	[self setRequestedFrom:newRequestedFrom];
	selector = newSelector;
	
	if ([windowTitle compare:@"Who's Time Card?"] == NSOrderedSame)	{
		[self loadEmployeeSelectForTimeCard];
	} else if([windowTitle compare:@"Add Schedule For Whom?"] == NSOrderedSame)	{
		[self loadStylistSelect];
	} else	{
		[self loadEmployeeSelect];
	}
}
-(void)loadEmployeeSelectForTimeCard
{
	NSMutableArray * results = [NSMutableArray arrayWithArray:[staffController workingClockedEmployees:[mainDatePicker dateValue]]];
	
								
	NSLog(@"executing Fetch employee");
	NSSortDescriptor * listOrderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	[results sortUsingDescriptors:[NSArray arrayWithObject:listOrderDescriptor]];
	
	int resultsCount = [results count];
	[self setEmployees:results];
	// calculate window size ...  
	// use max window size of ... and a scroller if the staff is larger than that
	
	NSView * contentView;// = [[[NSView alloc] init] autorelease];
	// if using scroller set content view for scroller, if not set for window
	if (YES)	{// don't need scroller
		contentView = self;
	}
	[contentView setSubviews:[NSMutableArray array]];
	float contentHeight = [contentView frame].size.height;
	int i;
	int gridSize = 1;
	NSMutableArray * newButtons = [NSMutableArray array];
	for (i= 0; i < resultsCount; i++)	{
		NSButton * newButton = [[[NSButton alloc] init] autorelease];
		//		[newButton setButtonType:NSMomentaryPushInButton];
		[newButton setBezelStyle:6];
		
		int column = i;
		column++;
		int row = 1;
		while (column > gridSize)	{
			column -= gridSize; 
			row++;
		}
		[newButton setFrame:NSMakeRect(20 + ((column-1) * BUTTONWIDTH), contentHeight - 20 - (BUTTONHEIGHT * row), BUTTONWIDTH, BUTTONHEIGHT)];
		[newButton setTitle:[[results objectAtIndex:i] valueForKey:@"name"]];
		[newButton setTarget:self];
		[newButton setAction:@selector(employeeSelected:)];
		[contentView addSubview:newButton];
		[newButtons addObject:newButton];
		
		
	}
	[self setButtons:newButtons];
	[employeeSelectWindow setContentView:contentView];
	[employeeSelectWindow makeKeyAndOrderFront:self];
	
	
	
}
-(void)loadStylistSelect
{

	NSMutableArray * results = [NSMutableArray arrayWithArray:[staffController workingServiceProviders:[mainDatePicker dateValue]]];
	
								
	NSLog(@"executing Fetch employee");
	NSSortDescriptor * listOrderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	

	[results sortUsingDescriptors:[NSArray arrayWithObject:listOrderDescriptor]];
	
	int resultsCount = [results count];
	[self setEmployees:results];
	// calculate window size ...  
	// use max window size of ... and a scroller if the staff is larger than that
	
	NSView * contentView;// = [[[NSView alloc] init] autorelease];
	// if using scroller set content view for scroller, if not set for window
	if (YES)	{// don't need scroller
		contentView = self;
	}
	[contentView setSubviews:[NSArray array]];
	float contentHeight = [contentView frame].size.height;
	int i;
	int gridSize = 1;
	NSMutableArray * newButtons = [NSMutableArray array];
	for (i= 0; i < resultsCount; i++)	{
		NSButton * newButton = [[[NSButton alloc] init] autorelease];
		//		[newButton setButtonType:NSMomentaryPushInButton];
		[newButton setBezelStyle:6];
		
		int column = i;
		column++;
		int row = 1;
		while (column > gridSize)	{
			column -= gridSize; 
			row++;
		}
		[newButton setFrame:NSMakeRect(20 + ((column-1) * BUTTONWIDTH), contentHeight - 20 - (BUTTONHEIGHT * row), BUTTONWIDTH, BUTTONHEIGHT)];
		[newButton setTitle:[[results objectAtIndex:i] valueForKey:@"name"]];
		[newButton setTarget:self];
		[newButton setAction:@selector(employeeSelected:)];
		[contentView addSubview:newButton];
		[newButtons addObject:newButton];
		
		
	}
	[self setButtons:newButtons];
	[employeeSelectWindow setContentView:contentView];
	[employeeSelectWindow makeKeyAndOrderFront:self];
	
}
-(void)loadEmployeeSelect
{
	
	NSMutableArray * results = [NSMutableArray arrayWithArray:[staffController workingStaff:[mainDatePicker dateValue]]];
	
	NSLog(@"executing Fetch employee");
	NSSortDescriptor * listOrderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	[results sortUsingDescriptors:[NSArray arrayWithObject:listOrderDescriptor]];
	
	int resultsCount = [results count];
	[self setEmployees:results];
	// calculate window size ...  
	// use max window size of ... and a scroller if the staff is larger than that
	
	NSView * contentView;// = [[[NSView alloc] init] autorelease];
	// if using scroller set content view for scroller, if not set for window
	if (YES)	{// don't need scroller
		contentView = self;
	}
	[contentView setSubviews:[NSMutableArray array]];
	float contentHeight = [contentView frame].size.height;
	int i;
	int gridSize = 1;
	NSMutableArray * newButtons = [NSMutableArray array];
	for (i= 0; i < resultsCount; i++)	{
		NSButton * newButton = [[[NSButton alloc] init] autorelease];
//		[newButton setButtonType:NSMomentaryPushInButton];
		[newButton setBezelStyle:6];
		
		int column = i;
		column++;
		int row = 1;
		while (column > gridSize)	{
			column -= gridSize; 
			row++;
		}
		[newButton setFrame:NSMakeRect(20 + ((column-1) * BUTTONWIDTH), contentHeight - 20 - (BUTTONHEIGHT * row), BUTTONWIDTH, BUTTONHEIGHT)];
		[newButton setTitle:[[results objectAtIndex:i] valueForKey:@"name"]];
		[newButton setTarget:self];
		[newButton setAction:@selector(employeeSelected:)];
		[contentView addSubview:newButton];
		[newButtons addObject:newButton];
		
				
	}
	[self setButtons:newButtons];
	[employeeSelectWindow setContentView:contentView];
	[employeeSelectWindow makeKeyAndOrderFront:self];
	
	
}
-(void)employeeSelected:(id)sender
{
	
	int i;
	int match = -1;
	for (i=0; i < [buttons count]; i++)	{
		if ([buttons objectAtIndex:i] == sender)	{
			match = i;
		}
	}
	
	[requestedFrom performSelector:selector withObject:[employees objectAtIndex:match]];
	[employeeSelectWindow close];

}
-(void)windowDidBecomeKey:(NSNotification *)notification
{
	[employeeSelectWindow makeFirstResponder:self];
	self.keyedIn = [NSMutableString string];

}
-(void)windowDidResignKey:(NSNotification *)notification
{
	 
}
-(void)keyDown:(NSEvent *)event
{
	[keyedIn appendString:[event characters]];
	
	int i;
	int match = -1;
	int test = 0;
	for (i=0; i< [buttons count]; i++)	{
		if ([[[buttons objectAtIndex:i] title] rangeOfString:keyedIn options:NSCaseInsensitiveSearch].length > 0)	{
			if ([[[buttons objectAtIndex:i] title] rangeOfString:keyedIn options:NSCaseInsensitiveSearch].location == 0)	{
				match = i;
				test++;
			}
		} 
		
	}
	if (test == 0)		{
		[keyedIn setString:@""];
	}
		
	if (test == 1)	{
		[[buttons objectAtIndex:match] performClick:self];
	}
	
	NSLog(@"%@:\nmatch %d   test %d",keyedIn, match, test);
}
@end
