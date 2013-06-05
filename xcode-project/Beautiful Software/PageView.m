//
//  PageView.m
//  Beautiful Software
//
//  Created by Jesse Black on 12/18/08.
//  Copyright 2008 Jesse Black. All rights reserved.
//

#import "PageView.h"
#import "InterfaceConstants.h"
#import "EventConstants.h"
#import "BuildingBlock.h"
#import "BookingSchedule.h"
#import "Beautiful_Software_AppDelegate.h"

@implementation PageView

@synthesize stylistColumns;
@synthesize startTime;
@synthesize finishTime;
@synthesize selectedBlock;
@synthesize stylistBlocks;
@synthesize dateView;
@synthesize keyedIn;
@synthesize stylistHeaders;

-(void)awakeFromNib
{
	NSLog(@"start awakeFromNib pageView");
	moc = [appDelegate managedObjectContext];
	self.stylistColumns = [NSMutableArray array];
	self.keyedIn = [NSMutableString string];
	self.stylistHeaders = [NSMutableArray array];
	[stylistHeaderView setReceiver:bookingSchedule];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageViewScrolled:) name:nil object:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainDatePickerChanged:) name:nil object:mainDatePicker];
	
	[timeHeaderView setBackgroundColor:[[self window] backgroundColor]];
	[stylistHeaderView setBackgroundColor:[[self window] backgroundColor]];
	
	[[self window] makeFirstResponder:self];
	
	NSLog(@"end awakeFromNib pageView");
}
-(void)mainDatePickerChanged:(id)sender
{
	if (!dateView)	{
		NSRect timeFrame = NSMakeRect(0,0,APPOINTMENTBLOCKWIDTH, APPOINTMENTBLOCKHEIGHT);
		[self setDateView:[[NSTextField alloc] initWithFrame:timeFrame]];
		[dateView setEditable:NO];
		[dateView setSelectable:NO];
		[dateView setAlignment:NSCenterTextAlignment];
		[dateView setBackgroundColor:[NSColor blackColor]];
		
		[dateViewContainer addSubview:dateView];
	}
	NSCalendarDate * date = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	[dateView setStringValue:[date description]];
	
}

-(BOOL)acceptsFirstResponder
{
	return YES;
}
-(void)displayDataForStylistDays:(NSMutableArray *)stylistDays
{
	self.stylistColumns = [NSMutableArray array];
	[self setSubviews:[NSArray array]];
	moc = [appDelegate managedObjectContext];
	if ([stylistDays count] > 0)	{
		NSMutableArray * earlyAppointments = [NSMutableArray array];
		NSMutableArray * lateAppointments = [NSMutableArray array];
		int i;
		for (i=0; i< [stylistDays count]; i++)	{
			if ([[stylistDays objectAtIndex:i] count] > 0)	{
				[earlyAppointments addObject:[[stylistDays objectAtIndex:i] objectAtIndex:0]];
				[lateAppointments addObject:[[stylistDays objectAtIndex:i] lastObject]];
			}
		}
		NSSortDescriptor * timeSort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
		[earlyAppointments sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
		[timeSort release];
		NSTimeInterval dayInMinutes;
		NSDate * firstAppointmentTime;
		id latestFinish;
		NSCalendarDate * lateFinish;
		if ([earlyAppointments count] > 0)	{
			firstAppointmentTime = [[earlyAppointments objectAtIndex:0] valueForKey:@"time"];
			
			latestFinish = [earlyAppointments objectAtIndex:0];
			
			for (i=0; i < [lateAppointments count]; i++)	{
				NSCalendarDate * endOfLatest = [[[latestFinish valueForKey:@"time"] dateWithCalendarFormat:@"" timeZone:nil] dateByAddingYears:0 months:0 days:0 hours:0 minutes:[[latestFinish valueForKey:@"appointmentLength"] intValue] seconds:0];
				NSCalendarDate * endOfLateAppointment = [[[[lateAppointments objectAtIndex:i] valueForKey:@"time"] dateWithCalendarFormat:@"" timeZone:nil] dateByAddingYears:0 months:0 days:0 hours:0 minutes:[[[lateAppointments objectAtIndex:i] valueForKey:@"appointmentLength"] intValue] seconds:0];
				if ([endOfLatest timeIntervalSinceDate:endOfLateAppointment] < 0)	{
					latestFinish = [lateAppointments objectAtIndex:i];
					
				}
			}
			lateFinish = [latestFinish valueForKey:@"time"];
			lateFinish = [lateFinish addTimeInterval:[[latestFinish valueForKey:@"appointmentLength"] intValue]*60];
			
			dayInMinutes = [[latestFinish valueForKey:@"time"] timeIntervalSinceDate:[[earlyAppointments objectAtIndex:0] valueForKey:@"time"]];
			
			dayInMinutes = dayInMinutes / 60.0;
			dayInMinutes += [[latestFinish valueForKey:@"appointmentLength"] intValue];
		} else	{
			dayInMinutes = 0;
		}
		
		if (firstAppointmentTime != nil)	{
			[self setStartTime:[firstAppointmentTime dateWithCalendarFormat:@"%I:%M %p" timeZone:nil]];
		}
		lateFinish = [lateFinish dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
		[self setFinishTime:lateFinish];
		
		// length of day in minutes is calculated
		int stylistWorking = 0;
		for (i=0; i < [stylistDays count]; i++)	{
			if ([[stylistDays objectAtIndex:i] count] > 0)	{
				stylistWorking++;
			}
		}
		
		float pageWidth = stylistWorking * APPOINTMENTBLOCKWIDTH;
		float pageHeight = dayInMinutes / 60.0 * APPOINTMENTBLOCKHEIGHT;
		NSRect pageFrame = [self frame];
		pageFrame.size.width = pageWidth;
		pageFrame.size.height = pageHeight;
		[self setFrame:pageFrame];
		pageFrame.origin.x = 0;
		pageFrame.origin.y = 0;
		
		NSMutableArray * days = [NSMutableArray array];
		//Start Laying out buildingblocks
		int stylist, slot;
		for (stylist = 0; stylist < [stylistDays count]; stylist++)	{
			[days addObject:[NSMutableArray array]];
			NSMutableArray * day = [stylistDays objectAtIndex:stylist];
			NSLog(@"dayToLoad %@", day);
			for (slot =0 ; slot < [[stylistDays objectAtIndex:stylist] count]; slot++)	{
				id appointment = [[stylistDays objectAtIndex:stylist] objectAtIndex:slot];
				int appointmentLength = [[appointment valueForKey:@"appointmentLength"] intValue];
				float appointmentHeight = appointmentLength / 60.0 * APPOINTMENTBLOCKHEIGHT;
				float appointmentWidth = APPOINTMENTBLOCKWIDTH;
				float howFarDown;
				NSDate * thisTime = [appointment valueForKey:@"time"];
				NSTimeInterval  downInterval = [thisTime timeIntervalSinceDate:firstAppointmentTime];
				
				howFarDown = (downInterval / 3600 * APPOINTMENTBLOCKHEIGHT) + appointmentHeight;
				BuildingBlock * newBlock = [[BuildingBlock alloc] initWithAppointment:appointment forPageView:self];
				NSRect blockFrame = NSMakeRect((stylist) * APPOINTMENTBLOCKWIDTH,pageHeight - howFarDown, appointmentWidth, appointmentHeight);
				[newBlock setFrame:blockFrame];
				[newBlock updateDisplay];
				[self addSubview:newBlock];
				[[days objectAtIndex:stylist] addObject:newBlock];
				[stylistColumns addObject:newBlock];
				[newBlock release];
			}
		
		}
		[self setStylistBlocks:days];
		[self setNeedsDisplay:YES];
		[self scrollPoint:NSMakePoint(0, pageHeight)];
		[[[self superview] superview] reflectScrolledClipView:[[[self superview] superview] contentView]];
		
		[self prepareHeaders];
	} else	{
		[self setSubviews:[NSMutableArray array]];
		selectedBlock = nil;
		[timeHeaderView setDocumentView:[[[NSView alloc] init] autorelease]];
		[stylistHeaderView setDocumentView:[[[NSView alloc] init] autorelease]];
	}
	if ([[self subviews] count] > 0	)	{
		[self setNeedsDisplay:YES];
		[self selectBlock:[[self subviews] objectAtIndex:0]];
		[self selectBlock:[[self selectedStylistDay] objectAtIndex:0]];
	}
	
	selectedStylistIndex = 0;
	
}
-(void)prepareHeaders
{

	NSCalendarDate * workingDate = [startTime dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
	int remainder = 60 - [workingDate minuteOfHour];
	float timeHeight;
	NSTimeInterval dayLength = [finishTime timeIntervalSinceDate:startTime];
	timeHeight = dayLength / (60.0 * 60.0);
	timeHeight *= APPOINTMENTBLOCKHEIGHT;
	NSView * timeView = [[NSView alloc] init];
	NSRect timeFrame = [timeView frame];
	timeFrame.size.width = APPOINTMENTBLOCKWIDTH;
	timeFrame.size.height = timeHeight;
	[timeView setFrame:timeFrame];
	float originY = timeHeight;
	NSTextField * topView = [[NSTextField alloc] init];
	[topView setEditable:NO];
	[topView setSelectable:NO];
	[topView setStringValue:[workingDate description]];
	[topView setAlignment:NSCenterTextAlignment];
	[topView setBackgroundColor:[NSColor blackColor]];
	timeFrame = [topView frame];
	timeFrame.size.width = APPOINTMENTBLOCKWIDTH;
	timeFrame.size.height = (remainder/ 60.0) * APPOINTMENTBLOCKHEIGHT;
	timeFrame.origin.x = 0;
	timeFrame.origin.y = timeHeight - timeFrame.size.height;
	[topView setFrame:timeFrame];
	originY = timeFrame.origin.y;
	[timeView addSubview:topView];
	
	
	workingDate = [workingDate dateByAddingYears:0 months:0 days:0 hours:0 minutes:remainder seconds:0];
	while ([finishTime timeIntervalSinceDate:workingDate] > 0)	{
		NSTextField * newView = [[NSTextField alloc] init];
		timeFrame = [newView frame];
		timeFrame.size.width = APPOINTMENTBLOCKWIDTH;
		timeFrame.size.height = APPOINTMENTBLOCKHEIGHT;
		timeFrame.origin.y = originY - timeFrame.size.height;
		[newView setEditable:NO];
		[newView setSelectable:NO];
		[newView setStringValue:[workingDate description]];
		[newView setAlignment:NSCenterTextAlignment];
		[newView setBackgroundColor:[NSColor blackColor]];
		
		originY = timeFrame.origin.y;
		[newView setFrame:timeFrame];
		
		[timeView addSubview:newView];
		[newView release];
		workingDate = [workingDate dateByAddingYears:0 months:0 days:0 hours:1 minutes:0 seconds:0];
	}
	


	[timeHeaderView setDocumentView:timeView];
	[timeView release];
	[[timeHeaderView documentView] scrollRectToVisible:[topView frame]];
	[timeHeaderView reflectScrolledClipView:[timeHeaderView documentView]];
	[topView release];
	
	NSMutableArray * stylists = [self fetchStylists];
	
	NSView * stylistView = [[NSView alloc] init];
	NSRect stylistFrame = [stylistView frame];
	stylistFrame.size.height = APPOINTMENTBLOCKHEIGHT;
	stylistFrame.size.width = [self frame].size.width;
	[stylistView setFrame:stylistFrame];
	int i;
	self.stylistHeaders = [NSMutableArray array];
	for (i=0; i<[stylists count]; i++)	{
		NSTextField * newView = [[NSTextField alloc] init];
		timeFrame = [newView frame];
		timeFrame.size.width = APPOINTMENTBLOCKWIDTH;
		timeFrame.size.height = APPOINTMENTBLOCKHEIGHT;
		timeFrame.origin.x = (i * APPOINTMENTBLOCKWIDTH);
		[newView setEditable:NO];
		[newView setSelectable:NO];
		[newView setStringValue:[[stylists objectAtIndex:i] valueForKey:@"name"]];
		[newView setAlignment:NSCenterTextAlignment];
		[newView setBackgroundColor:[NSColor blackColor]];
		
		originY = timeFrame.origin.y;
		[newView setFrame:timeFrame];
		
		[stylistView addSubview:newView];
		[stylistHeaders addObject:newView];
		[newView release];
		
	}
	[stylistHeaderView setDocumentView:stylistView];
	
	[stylistView release];
}
-(NSMutableArray *)selectedStylistDay
{
	int i;
	NSMutableArray * selectedStylistDay;
	NSString * selectedStylist = [[[[self selectedBlock] appointment] valueForKey:@"stylist"] valueForKey:@"name"];
	for (i=0; i < [stylistBlocks count]; i++)	{
		NSString * workingStylist = [[[[[stylistBlocks objectAtIndex:i] objectAtIndex:0] appointment] valueForKey:@"stylist"] valueForKey:@"name"];
		if ([workingStylist compare:selectedStylist] == NSOrderedSame)	{
			selectedStylistDay = [stylistBlocks objectAtIndex:i];
			i += [stylistBlocks count];
		}
		
	}
	return selectedStylistDay;
}
-(void)upgradeStylistDay
{
	// get all blocks for selectedStylist
	int i;
	NSMutableArray * selectedStylistDay = [self selectedStylistDay];;
	// make appointment entities from all the blocks and set them as the blocks' appointments
	
	for (i=0; i< [selectedStylistDay count]; i++)	{
		NSManagedObject * appointment = [NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:moc];
		NSMutableDictionary * oldAppointment = [[selectedStylistDay objectAtIndex:i] appointment];
		[appointment setValue:[oldAppointment valueForKey:@"time"] forKey:@"time"];
		[appointment setValue:[oldAppointment valueForKey:@"stylist"] forKey:@"stylist"];
		[appointment setValue:[oldAppointment valueForKey:@"appointmentLength"] forKey:@"appointmentLength"];
		[[selectedStylistDay objectAtIndex:i] setAppointment:appointment];

	}
	
	
}
-(void)removeSelectedAppointment
{
	int i;
	NSMutableArray * selectedStylistDay = [self selectedStylistDay];;
	// make appointment entities from all the blocks and set them as the blocks' appointments
	
	for (i=0; i< [selectedStylistDay count]; i++)	{
		if ([selectedStylistDay objectAtIndex:i] != selectedBlock)	{
			NSManagedObject * appointment = [NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:moc];
			NSMutableDictionary * oldAppointment = [[selectedStylistDay objectAtIndex:i] appointment];
			[appointment setValue:[oldAppointment valueForKey:@"time"] forKey:@"time"];
			[appointment setValue:[oldAppointment valueForKey:@"stylist"] forKey:@"stylist"];
			[appointment setValue:[oldAppointment valueForKey:@"appointmentLength"] forKey:@"appointmentLength"];
			[[selectedStylistDay objectAtIndex:i] setAppointment:appointment];
		}
			
			
		
	}
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
}
-(NSMutableArray *)fetchStylists
{
	NSMutableArray * results = [NSMutableArray array];
	int i;
	for (i=0; i< [stylistBlocks count]; i++)	{
		[results addObject:[[[[stylistBlocks objectAtIndex:i] objectAtIndex:0] appointment] valueForKey:@"stylist"]];
	}
	return results;
}
-(void)selectBlock:(BuildingBlock *)hit
{
	
	if (selectedBlock)	{
		[selectedBlock unselectBlock];
	}


	selectedBlock = hit;
	[selectedBlock selectBlock];
	[self scrollRectToVisible:selectedBlock.frame];

	
	int i;
	int j;
	for (i=0; i < [stylistBlocks count]; i++)	{
		NSArray * aDay = [stylistBlocks objectAtIndex:i];
		for (j=0; j < [aDay count]; j++)	{
			if ([aDay objectAtIndex:j] == hit)	{
				selectedStylistIndex = i;
			}
		}
	}
}
-(void)refreshBlocks
{
	NSArray * subviews = [self subviews];
	int i;
	for (i=0; i < [subviews count]; i++)	{
		id view = [subviews objectAtIndex:i];
		if ([[view className] compare:@"BuildingBlock"] == NSOrderedSame)	{
			[view updateDisplay];
		}
	}
	[self selectBlock:selectedBlock];
	[bookingSchedule updateAppointmentDescription];
}
-(void)refreshBlockForAppointment:(NSManagedObject *)appointment
{
	NSArray * subviews = [self subviews];
	int i;
	for (i=0; i < [subviews count]; i++)	{
		id view = [subviews objectAtIndex:i];
		if ([[view className] compare:@"BuildingBlock"] == NSOrderedSame)	{
			if ([view appointment] == appointment)	{
				[view updateDisplay];
				i += [subviews count];
			}
		}
	}
}

-(void)mouseUp:(NSEvent*)aEvent
{
	NSLog(@"mouseEvent in pageView");
	[super mouseUp:aEvent];
	int clickCount = [aEvent clickCount];
	if (selectedBlock)	{
		[selectedBlock unselectBlock];
	}
	NSView * hit = [self hitTest:[self convertPoint:[aEvent locationInWindow] fromView:nil]];
	if ([[hit className] compare:@"BuildingBlock"] == NSOrderedSame)	{
		[self selectBlock:hit];
	}
	if ([[hit className] compare:@"BuildingTextField"] == NSOrderedSame)	{
		[self selectBlock:[hit superview]];
	}
	[selectedBlock selectBlock];
	[bookingSchedule updateAppointmentDescription];
	if ( clickCount == 2)	{
		id appointment = [selectedBlock appointment];
		if ([[selectedBlock appointment] valueForKey:@"parentAppointment"] == nil)	{
			if ([appointment valueForKeyPath:@"client"] == nil)	{
				SEL selector = @selector(setBookedBy:);
				[employeeSelect selectEmployeeFor:bookingSchedule selector:selector windowTitle:@"Who Are You"];
			} else	{
				[bookingSchedule goToMakeEditAppointment];	
			}
		}
		else {
			[self selectParent];
			[bookingSchedule goToMakeEditAppointmentAction:self];
		}
	}
	
}
-(void)pageViewScrolled:(NSNotification *)aNotification
{
	NSRect visibleTime = [self visibleRect];
	visibleTime.size.width = APPOINTMENTBLOCKWIDTH;
	
	NSRect visibleStylist = [self visibleRect];
	visibleStylist.size.height = APPOINTMENTBLOCKHEIGHT;
	
	[[timeHeaderView documentView] scrollRectToVisible:visibleTime];
	[timeHeaderView reflectScrolledClipView:[timeHeaderView documentView]];
	
	[[stylistHeaderView documentView] scrollRectToVisible:visibleStylist]; 
	[stylistHeaderView reflectScrolledClipView:[stylistHeaderView documentView]];
}
-(void)keyDown:(NSEvent *)aEvent
{
	
//	[super keyDown:aEvent];
	int modifier = [aEvent modifierFlags];
	int key = [aEvent keyCode];
	if (modifier == LEFTALTKEY || modifier == RIGHTALTKEY)	{
		switch (key)	{
			case LEFTKEY : [self calendarLeft];
				break;
			case RIGHTKEY : [self calendarRight];
				break;
			case UPKEY : [self calendarUp];
				break;
			case DOWNKEY : [self calendarDown];
				break;
			case TKEY : [self calendarToToday];
			default :
				break;
		}
	} else if (modifier == LEFTOPTIONKEY)	{
		switch (key)	{
			case LEFTKEY : [self pageLeft];
				break;
			case RIGHTKEY : [self pageRight];
				break;
			case UPKEY : [self pageUp];
				break;
			case DOWNKEY : [self pageDown];
				break;
			default :
				break;
		}
	} else	{
		switch (key)	{
			case LEFTKEY : [self moveLeft];
				break;
			case RIGHTKEY : [self moveRight];
				break;
			case UPKEY : [self moveUp];
				break;
			case DOWNKEY : [self moveDown];
				break;
			case TKEY : [self moveToToday];
				break;
			case ENTERKEY : if ([[selectedBlock appointment] valueForKey:@"parentAppointment"] == nil)	{
					[bookingSchedule goToMakeEditAppointmentAction:self];				
			} else	{
				[self selectParent];
				[bookingSchedule goToMakeEditAppointmentAction:self];

			}
				break;
			default : 
				break;
		}
	}
	
	[keyedIn appendString:[aEvent characters]];

	int i;
	int match = -1;
	int test = 0;
	NSLog(@"stylistHeaders %@", stylistHeaders);
	for (i=0; i< [stylistHeaders count]; i++)	{
		
		if ([[[stylistHeaders objectAtIndex:i] stringValue] rangeOfString:keyedIn options:NSCaseInsensitiveSearch].length > 0)	{
			if ([[[stylistHeaders objectAtIndex:i] stringValue] rangeOfString:keyedIn options:NSCaseInsensitiveSearch].location == 0)	{
				match = i;
				test++;
			}
		} 
		
	}
	

	NSLog(@"keyedIn %@   test %d", keyedIn, test);
	
	if (test == 0)		{
		NSLog(@"deleting because no match");
		[keyedIn setString:@""];
	}
	
	if (test == 1)	{
		
		// move to stylist's page
		NSArray * aDay = [stylistBlocks objectAtIndex:match];
		
		match = -1;
		test = 0;
		
		NSDate * selectedTime = [[selectedBlock appointment] valueForKey:@"time"];
		for (i=0; i< [aDay count]; i++)	{
			if ([[[[aDay objectAtIndex:i] appointment] valueForKey:@"time"] timeIntervalSinceDate:selectedTime] >= 0)	{
				[self selectBlock:[aDay objectAtIndex:i]];
				NSLog(@"deleting because selected new block");
				[keyedIn setString:@""];
				match = i;
				i += [aDay count];							
			}
		}
		if (match < 0)	{
			[self selectBlock:[aDay lastObject]];
			NSLog(@"deleting because selected new block");
			[keyedIn setString:@""];
		}
		
	}
	
	
	[bookingSchedule updateAppointmentDescription];
	
}
-(void)selectParent
{
	NSManagedObject * parent = [[[self selectedBlock] appointment] valueForKey:@"parentAppointment"];
	int i;
	NSArray * subviews = [self subviews];
	for (i=0 ; i< [subviews count]; i++)	{
		if ([[subviews objectAtIndex:i] appointment] == parent)	{
			[self selectBlock:[subviews objectAtIndex:i]];
			[[self selectedBlock] setNeedsDisplay:YES];
			break;
		}
	}
	[bookingSchedule goToMakeEditAppointment];
}

-(BOOL)pageLeft
{
	[self moveLeft];
	return YES;
}
-(BOOL)pageUp
{
	NSRect frame = [self visibleRect];
	float bounceUp = frame.size.height;
	NSRect selectedFrame = [self selectedBlock].frame;
	// there are APPOINTMENTBLOCKHEIGHT PIXELS/HOUR
	//	NSLog(@"pixels %f", dropDown);
	float timePerPage = bounceUp/APPOINTMENTBLOCKHEIGHT;
	//	NSLog(@"hours %f", timePerPage);
	// timepp is in hours
	timePerPage = timePerPage*3600;
	//	NSLog(@"seconds %f", timePerPage);
	NSDate * selectedStartTime = [[selectedBlock appointment] valueForKey:@"time"];
	NSDate * searchTime = [selectedStartTime addTimeInterval:-timePerPage];
	int i;
	NSArray * aDay = [stylistBlocks objectAtIndex:selectedStylistIndex];;
	NSView * firstMatch = nil;
	for (i=0; i < [aDay count]; i++)	{
		if ([[[[aDay objectAtIndex:i] appointment] valueForKey:@"time"] timeIntervalSinceDate:searchTime] >=0)	{
			firstMatch = [aDay objectAtIndex:i];
			i+= [aDay count];
		}
		
	}
	
	// make view scroll one page worth
	NSLog(@"superview %@", [[self superview] superview]);
	NSPoint currentScrollPosition=[[[[self superview] superview] documentView] bounds].origin;
	currentScrollPosition.y += bounceUp;
	// restore the scroll location
	[[[[self superview] superview] documentView] scrollPoint:currentScrollPosition];
	
	if (firstMatch)	{
		[self selectBlock:firstMatch];
	} else {
		[self selectBlock:[[stylistBlocks objectAtIndex:selectedStylistIndex] objectAtIndex:0]];
	}

	
	return YES;
}
-(BOOL)pageRight
{
	[self moveRight];
	return YES;
}
-(BOOL)pageDown
{
	NSRect frame = [self visibleRect];
	float dropDown = frame.size.height;
	NSRect selectedFrame = [self selectedBlock].frame;
	// there are APPOINTMENTBLOCKHEIGHT PIXELS/HOUR
//	NSLog(@"pixels %f", dropDown);
	float timePerPage = dropDown/APPOINTMENTBLOCKHEIGHT;
//	NSLog(@"hours %f", timePerPage);
	// timepp is in hours
	timePerPage = timePerPage*3600;
//	NSLog(@"seconds %f", timePerPage);
	NSDate * selectedStartTime = [[selectedBlock appointment] valueForKey:@"time"];
	NSDate * searchTime = [selectedStartTime addTimeInterval:timePerPage];
	int i;
	NSArray * aDay = [stylistBlocks objectAtIndex:selectedStylistIndex];;
	NSView * firstMatch = nil;
	for (i=0; i < [aDay count]; i++)	{
		if ([[[[aDay objectAtIndex:i] appointment] valueForKey:@"time"] timeIntervalSinceDate:searchTime] >=0)	{
			firstMatch = [aDay objectAtIndex:i];
			i+= [aDay count];
		}
			
	}
	
	// make view scroll one page worth
	NSLog(@"superview %@", [[self superview] superview]);
	NSPoint currentScrollPosition=[[[[self superview] superview] documentView] bounds].origin;
	 currentScrollPosition.y -= dropDown;
	// restore the scroll location
	[[[[self superview] superview] documentView] scrollPoint:currentScrollPosition];
	
	if (firstMatch)	{
		[self selectBlock:firstMatch];
	} else {
		[self selectBlock:[[stylistBlocks objectAtIndex:selectedStylistIndex] lastObject]];
		
	}

	
	return YES;
}

-(BOOL)moveLeft
{
	// determine if there is appointment starting or ending same time as the selected appointment in next column
	id appointment = [selectedBlock appointment];
	NSDate * selectedStartTime = [appointment valueForKey:@"time"];
	NSDate * selectedEndTime = [selectedStartTime addTimeInterval:[[appointment valueForKey:@"appointmentLength"] intValue]*60];
	NSLog(@"startDate %@ endDate %@", selectedStartTime, selectedEndTime);
	
	
	
	int index = selectedStylistIndex;
	index--;
	NSDate * findTime = [selectedStartTime addTimeInterval:[selectedEndTime timeIntervalSinceDate:selectedStartTime]/2];
	NSLog(@"findTime %@", findTime);
	
	BOOL matchedStart = NO;
	BOOL matchedEnd = NO;
	NSView * firstMatch = nil;
	while (index >= 0)	{
		NSArray * aDay = [stylistBlocks objectAtIndex:index];
		int i;
		for (i=0; i < [aDay count]; i++)	{
			id appointment = [[aDay objectAtIndex:i] appointment];
			NSDate * nStartTime = [appointment valueForKey:@"time"];
			NSDate * nEndTime = [nStartTime addTimeInterval:[[appointment valueForKey:@"appointmentLength"] intValue] *60];
			
			if ([nStartTime timeIntervalSinceDate:selectedStartTime] == 0)	{
				matchedStart = YES;
				firstMatch = [aDay objectAtIndex:i];
				i+= [aDay count];
				index = -1;
			} else {
				if ([nEndTime timeIntervalSinceDate:selectedEndTime] == 0)	{
					firstMatch = [aDay objectAtIndex:i];
					matchedEnd = YES;
					i+= [aDay count];
					index = -1;
				}
				
			}
			
			if (!matchedStart && !matchedEnd)	{
				if ([nStartTime timeIntervalSinceDate:selectedStartTime] > 0)	{
					NSTimeInterval startDifference = [nStartTime timeIntervalSinceDate:selectedStartTime];
					NSTimeInterval endDifference = [nEndTime timeIntervalSinceDate:selectedEndTime];
					if (endDifference < 0)	{
						endDifference *= -1;
					}
					NSLog(@"%f %f", startDifference, endDifference);
					
					if (startDifference - endDifference <= 0)	{
						// the nextColumns start time is closer
						firstMatch = [aDay objectAtIndex:i];
						i+= [aDay count];
						index = -1;
					} else {
						if (i > 0)	{
							firstMatch = [aDay objectAtIndex:i-1];
							i+= [aDay count];
							index = -1;
							
						}
					}
					
				} 
				
			}
			
			
		}
		index--;
	}
	
	if (firstMatch)	{
		[self selectBlock:firstMatch];
		return YES;
	} else {
		if (selectedStylistIndex > 0)	{
			[self selectBlock:[[stylistBlocks objectAtIndex:selectedStylistIndex-1] lastObject]];
			return YES;
		}
		return NO;
	}
	
	
	
}
-(BOOL)moveRight
{
	// determine if there is appointment starting or ending same time as the selected appointment in next column
	id appointment = [selectedBlock appointment];
	NSDate * selectedStartTime = [appointment valueForKey:@"time"];
	NSDate * selectedEndTime = [selectedStartTime addTimeInterval:[[appointment valueForKey:@"appointmentLength"] intValue]*60];
	NSLog(@"startDate %@ endDate %@", selectedStartTime, selectedEndTime);
	
	int maxIndex = [stylistBlocks count];
	
	
	int index = selectedStylistIndex;
	index++;
	NSDate * findTime = [selectedStartTime addTimeInterval:[selectedEndTime timeIntervalSinceDate:selectedStartTime]/2];
	NSLog(@"findTime %@", findTime);
	
	BOOL matchedStart = NO;
	BOOL matchedEnd = NO;
	NSView * firstMatch = nil;
	for (; index < maxIndex; index++)	{
		NSArray * aDay = [stylistBlocks objectAtIndex:index];
		int i;
		for (i=0; i < [aDay count]; i++)	{
			id appointment = [[aDay objectAtIndex:i] appointment];
			NSDate * nStartTime = [appointment valueForKey:@"time"];
			NSDate * nEndTime = [nStartTime addTimeInterval:[[appointment valueForKey:@"appointmentLength"] intValue] *60];
			
			if ([nStartTime timeIntervalSinceDate:selectedStartTime] == 0)	{
				matchedStart = YES;
				firstMatch = [aDay objectAtIndex:i];
				i+= [aDay count];
				index+= maxIndex;
			} else {
				if ([nEndTime timeIntervalSinceDate:selectedEndTime] == 0)	{
					firstMatch = [aDay objectAtIndex:i];
					matchedEnd = YES;
					i+= [aDay count];
					index+= maxIndex;
				}
	
			}
 
			if (!matchedStart && !matchedEnd)	{
				if ([nStartTime timeIntervalSinceDate:selectedStartTime] > 0)	{
					NSTimeInterval startDifference = [nStartTime timeIntervalSinceDate:selectedStartTime];
					NSTimeInterval endDifference = [nEndTime timeIntervalSinceDate:selectedEndTime];
					if (endDifference < 0)	{
						endDifference *= -1;
					}
					NSLog(@"%f %f", startDifference, endDifference);
					
					if (startDifference - endDifference <= 0)	{
						// the nextColumns start time is closer
						firstMatch = [aDay objectAtIndex:i];
						i+= [aDay count];
						index+= maxIndex;
					} else {
						if (i > 0)	{
							firstMatch = [aDay objectAtIndex:i-1];
							i+= [aDay count];
							index+= maxIndex;
							
						}
					}

				} 
				
			}
			
			
		}
	}
	
	if (firstMatch)	{
		[self selectBlock:firstMatch];
		return YES;
	} else {
		if (selectedStylistIndex < maxIndex)	{
			[self selectBlock:[[stylistBlocks objectAtIndex:selectedStylistIndex+1] lastObject]];
			
			return YES;
			 
			 
		}
			 
		return NO;
	}

	
	
}
-(BOOL)moveUp
{
	// figure out coordinates of selectedAppointment
	NSRect selectedFrame = [selectedBlock frame];
	double x = selectedFrame.origin.x + selectedFrame.size.width/2;
	double y = selectedFrame.origin.y + selectedFrame.size.height/2;
	
	NSView * hit;
	while (((hit =[self hitTest:NSMakePoint(x,y)]) == selectedBlock || [selectedBlock hasHit:hit]) && hit != nil)	{
		//x += APPOINTMENTBLOCKWIDTH/2;
		y += APPOINTMENTBLOCKHEIGHT/(2*4);   //2*4 IS HALF OF FIFTEEN MINUTES
	}
	if (hit)	{
		if ([[hit className] compare:@"BuildingBlock"] == NSOrderedSame)	{
			
			[self selectBlock:hit];
			return YES;
		} else	{
			int i;
			for (i= 0 ;i < [[self subviews] count]; i++)	{
				if ([[[[self subviews] objectAtIndex:i] className] compare:@"NSTextField"] != NSOrderedSame)	{
					if ([[[self subviews] objectAtIndex:i] hasHit:hit])	{
						[self selectBlock:[[self subviews] objectAtIndex:i]];
						[self scrollRectToVisible:selectedBlock.frame];
						return YES;
					}
				}
				
				
			}
		}
	}
	return NO;
}
-(BOOL)moveDown
{
	if (selectedBlock)	{
	// figure out coordinates of selectedAppointment
	NSRect selectedFrame = [selectedBlock frame];
	double x = selectedFrame.origin.x + selectedFrame.size.width/2;
	double y = selectedFrame.origin.y + selectedFrame.size.height/2;
	
	NSView * hit;
	while (((hit =[self hitTest:NSMakePoint(x,y)]) == selectedBlock || [selectedBlock hasHit:hit]) && hit != nil || hit == self)	{
		//x += APPOINTMENTBLOCKWIDTH/2;
		y -= APPOINTMENTBLOCKHEIGHT/(2*4);   //2*4 IS HALF OF FIFTEEN MINUTES
	}
	if (hit)	{
		if ([[hit className] compare:@"BuildingBlock"] == NSOrderedSame)	{
			[self selectBlock:hit];
			return YES;
		} else	{
			int i;
			for (i= 0 ;i < [[self subviews] count]; i++)	{
				if ([[[[self subviews] objectAtIndex:i] className] compare:@"NSTextField"] != NSOrderedSame)	{
					if ([[[self subviews] objectAtIndex:i] hasHit:hit])	{
						[self selectBlock:[[self subviews] objectAtIndex:i]];
						[self scrollRectToVisible:selectedBlock.frame];
						return YES;
					}
				}
				
				
			}
		}
	}
	
	}
	return NO;
}
-(void)calendarLeft
{
	NSCalendarDate * date = [[mainDatePicker dateValue] dateWithCalendarFormat:@"" timeZone:nil];
	date = [date dateByAddingYears:0 months:0 days:-1 hours:0 minutes:0 seconds:0];
	[mainDatePicker setDateValue:date];
	[bookingSchedule changeDateOnMainPage];
}
-(void)calendarRight
{
	NSCalendarDate * date = [[mainDatePicker dateValue] dateWithCalendarFormat:@"" timeZone:nil];
	date = [date dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
	[mainDatePicker setDateValue:date];
	[bookingSchedule changeDateOnMainPage];
}
-(void)calendarUp
{
	NSCalendarDate * date = [[mainDatePicker dateValue] dateWithCalendarFormat:@"" timeZone:nil];
	date = [date dateByAddingYears:0 months:0 days:-7 hours:0 minutes:0 seconds:0];
	[mainDatePicker setDateValue:date];
	[bookingSchedule changeDateOnMainPage];
}
-(void)calendarDown
{
	NSCalendarDate * date = [[mainDatePicker dateValue] dateWithCalendarFormat:@"" timeZone:nil];
	date = [date dateByAddingYears:0 months:0 days:7 hours:0 minutes:0 seconds:0];
	[mainDatePicker setDateValue:date];
	[bookingSchedule changeDateOnMainPage];
}
-(void)moveToToday
{
	[mainDatePicker setDateValue:[NSDate date]];
	[bookingSchedule changeDateOnMainPage];
}
-(void)selectAppointmentForTime:(NSDate *)time withStylist:(NSManagedObject *)stylist
{
	int i;
	NSArray * subviews = [self subviews];
	int subviewsCount = [subviews count];
	for (i=0; i < subviewsCount; i++)	{
		id block = [subviews objectAtIndex:i];
		if ([[block className] compare:@"BuildingBlock"] == NSOrderedSame)	{
			NSManagedObject * appointment = [block appointment];
			int twoChecks = 0;
			if ([[appointment valueForKey:@"time"] timeIntervalSinceDate:time] == 0)	twoChecks++;
			if ([appointment valueForKey:@"stylist"] == stylist)	twoChecks++;
			if (twoChecks == 2)		{
				[self selectBlock:[subviews objectAtIndex:i]];
				break;
			}
			
		}
	}
}

-(void)selectCurrentTime
{
	NSArray * appointmentBlocks = [stylistBlocks objectAtIndex:0];
	int i;
	NSMutableArray * appointments = [NSMutableArray array];
	
	for(i=0; i< [appointmentBlocks count] ; i++)	{
		[appointments addObject:[[appointmentBlocks objectAtIndex:i] appointment]];
	}
	NSDate * now = [NSDate date];
	NSScroller * scroller = [[[self superview] superview] verticalScroller];
//	[scroller setFloatValue:1 knobProportion:0];
//	[[[self superview] superview] reflectScrolledClipView:[[[self superview] superview] contentView]];
	[self scrollPoint:NSMakePoint(0,0)];
	i = 0;
	while (i < [appointments count] && [now timeIntervalSinceDate:[[appointments objectAtIndex:i] valueForKey:@"time"]] > 0)	{
		i++;
	}
	i--;
	if (i>=0 && i < [appointmentBlocks count])	{
		[self selectBlock:[appointmentBlocks objectAtIndex:i]];
	}

}
-(void)goToMakeEditAppointmentAction:(id)sender
{
	[bookingSchedule goToMakeEditAppointmentAction:self];
}
-(void)checkOutSelectedAppointment
{
	[transactionController checkOutSelectedAppointmentAction:self];
}
-(void)viewClientHistory
{
	[clientDatabase viewClientDatabase:self];
}
-(void)updateAllAppointmentBlocks
{
	int i;
	for(i=0; i< [stylistColumns count]; i++)	{
		[[stylistColumns objectAtIndex:i] updateDisplay];
	}
}
@end

