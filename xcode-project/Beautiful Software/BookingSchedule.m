//
//  BookingSchedule.m
//  Beautiful Software
//
//  Created by Jesse Black on 12/11/08.
//  Copyright 2008 Jesse Black. All rights reserved.
//

#import "BookingSchedule.h"
#import "ClientDatabase.h"
#import "PageView.h"
#import "BuildingBlock.h"
#import "InterfaceConstants.h"
#import "PasswordConstants.h"
#import "EmployeeSelect.h"
#import "ResistantScroller.h"

@implementation BookingSchedule

@synthesize lastBookedBy;
@synthesize neverConfirmPath;
@synthesize cancellationsPath;
@synthesize waitlistPath;
@synthesize lastSelectedDate;
@synthesize startBound;
@synthesize availableAppointmentsForTransfer;
@synthesize appointmentsToBook;
@synthesize confirmingSignature;
@synthesize clientForAddColorFile;
@synthesize preferencesPath;
-(void)awakeFromNib
{
	NSMutableString * ppath = [NSMutableString string];
	[ppath setString:[appDelegate applicationSupportFolder]];
	[ppath appendString:@"/preferences"];
	
	self.preferencesPath = [NSMutableString stringWithString:ppath];
	NSMutableString * mstring = [NSMutableString string];

	
	
	[mstring setString:@"~/Library/Application Support/Beautiful_Software/waitlist"];
	
	self.waitlistPath = [mstring stringByExpandingTildeInPath];
	
	[mstring setString:@"~/Library/Application Support/Beautiful_Software/cancellations"];
	self.cancellationsPath = [mstring stringByExpandingTildeInPath];
	
	[mstring setString:@"~/Library/Application Support/Beautiful_Software/neverConfirm"];
	self.neverConfirmPath = [mstring stringByExpandingTildeInPath];
	
	self.availableAppointmentsForTransfer = [NSMutableArray array];
	moc = [appDelegate managedObjectContext];
	[makeAppointmentWindow setDelegate:self];
	[mainDatePicker setDateValue:[NSDate date]];

	
}
-(void)goToMakeEditAppointment
{
	modalRejected = NO;

	if ([[[pageView selectedBlock] appointment] valueForKey:@"client"] == nil)	{
		[createOrFindWindow makeKeyAndOrderFront:self];
	}
	
	//	[makeAppointmentWindow makeKeyAndOrderFront:self];
}
-(void)bookSelectedAppointmentWithClient:(NSManagedObject *)client
{
	id selectedAppointment = [[pageView selectedBlock] appointment];
	NSString * bookedBy = [[[pageView selectedBlock] appointment] valueForKey:@"bookedBy"];
	if ([[[[pageView selectedBlock] appointment] className] compare:@"NSManagedObject"] != NSOrderedSame)	{
		[pageView upgradeStylistDay];
	}
	
	selectedAppointment = [[pageView selectedBlock] appointment];
	[selectedAppointment setValue:client forKey:@"client"];
	[self loadAppointmentInfo:selectedAppointment];
}
-(void)loadAppointmentInfo:(id)appointment
{
	 //initialize make/edit appointment window ... the services and available times
	
	
	[clientField setObjectValue:nil];
	[vcrField setObjectValue:nil];
	[homePhoneField setObjectValue:nil];
	[workPhoneField setObjectValue:nil];
	[mobilePhoneField setObjectValue:nil];
	[emailField setObjectValue:nil];
	[maleButton setState:0];
	[creditField setStringValue:@""];
	[femaleButton setState:0];
	[specialNoteField setString:@""];
	
	[homePhoneField setEditable:YES];
	[workPhoneField setEditable:YES];
	[mobilePhoneField setEditable:YES];
	[emailField setEditable:YES];
	SEL selector = @selector(selectGenderOnNewClient:);
	[maleButton setAction:selector];
	[femaleButton setAction:selector];
	
	id selectedAppointment = appointment;
	if ([[selectedAppointment valueForKey:@"stylist"] valueForKey:@"firstName"])	{
		[stylistField setStringValue:[[selectedAppointment valueForKey:@"stylist"] valueForKey:@"firstName"]];
	} else	{
		[stylistField setStringValue:[[selectedAppointment valueForKey:@"stylist"] valueForKey:@"name"]];
	}
	[dateField setObjectValue:[selectedAppointment valueForKey:@"time"]];
	[timeField setObjectValue:[selectedAppointment valueForKey:@"time"]];
	if ([selectedAppointment valueForKey:@"client"] != nil)	{
		//Set up all known fields 
		id nextVariable;
		nextVariable = [selectedAppointment valueForKeyPath:@"client.name"];
		if (nextVariable) {
			[clientField setStringValue:nextVariable];
			[clientField setEditable:NO];
		}
		
		
		nextVariable = [selectedAppointment valueForKey:@"vcr"];
		if (nextVariable)	[vcrField setStringValue:nextVariable];
		
		nextVariable = [selectedAppointment valueForKeyPath:@"client.homePhone"];
		if ([nextVariable length] > 0)	{
			[homePhoneField setStringValue:nextVariable];
			[homePhoneField setEditable:NO];
		}
		
		nextVariable = [selectedAppointment valueForKeyPath:@"client.workPhone"];
		if ([nextVariable length] > 0)	{
			[workPhoneField setStringValue:nextVariable];
			[workPhoneField setEditable:NO];
		}
		
		nextVariable = [selectedAppointment valueForKeyPath:@"client.mobilePhone"];
		if ([nextVariable length] > 0)	{
			[mobilePhoneField setStringValue:nextVariable];
			[mobilePhoneField setEditable:NO];
			
		}
		
		nextVariable = [selectedAppointment valueForKeyPath:@"client.email"];
		if ([nextVariable length] > 0)	{
			[emailField setStringValue:nextVariable];
			[emailField setEditable:NO];
		}
		
		nextVariable = [selectedAppointment valueForKeyPath:@"client.creditCard"];
		
		if (nextVariable)	{
			NSMutableString * string = [NSMutableString stringWithString:nextVariable];
			if ([string length] > 12)	{
				NSRange range = NSMakeRange(0,12);
				[string replaceCharactersInRange:range withString:@"xxxxxxxxxxxx"];
			}
			
			
			[creditField setStringValue:string];
			
		} 
		
		
		nextVariable = [selectedAppointment valueForKey:@"specialNote"];
		if (nextVariable)		{
			[specialNoteField setString:nextVariable];
		} else	{
			[specialNoteField setString:@""];
		}
		SEL nilSelector = @selector(myNilAction:);
		if ([[selectedAppointment valueForKeyPath:@"client.isMale"] boolValue] == 1)	{
			[maleButton setState:1];
			[femaleButton setState:0];
			[maleButton setAction:nilSelector];
			[femaleButton setAction:nilSelector];
			
		}
		if ([[selectedAppointment valueForKeyPath:@"client.isFemale"] boolValue] == 1)	{
			[maleButton setState:0];
			[femaleButton setState:1];
			[maleButton setAction:nilSelector];
			[femaleButton setAction:nilSelector];
			
		}
		
		
	}
	
	[self createServiceMenu];
	[self findAvailableExtraAppointments];
	[makeAppointmentWindow makeKeyAndOrderFront:self];
	
}
-(void)myNilAction:(id)sender
{
	if ([sender state] == 0)	{
		[sender setState:1];
	} else [sender setState:0];

}
-(NSMutableArray *)availableExtraAppointments
{
	// same as findAvailableExtraAppointments, but handles display
	NSMutableArray * stylistDay = [pageView selectedStylistDay];

	
	NSMutableArray * availableAppointments = [NSMutableArray array];
	int i;
	BuildingBlock * selectedBlock = [pageView selectedBlock];
	BOOL loopTest = NO;
	//loopTest helps get availabletimes after selectedappointment
	for (i = 0 ; i < [stylistDay count]; i++)	{
		if ([stylistDay objectAtIndex:i] != selectedBlock)	{
			if (loopTest)	{
				if ([[[stylistDay objectAtIndex:i] appointment] valueForKey:@"dateBooked"] == nil)	{
					id appointment = [[stylistDay objectAtIndex:i] appointment];
					[availableAppointments addObject:appointment];
				}
				
			}
		} else	{
			loopTest = YES;
		}
	}
	
	return availableAppointments;
	
}
-(void)findAvailableExtraAppointments
{
	
	NSMutableArray * subviews = [NSMutableArray array];
	NSMutableArray * availableAppointments = [self availableExtraAppointments];
	NSMutableArray * availableTimes = [NSMutableArray array];
	int i;
	for (i=0; i< [availableAppointments count]; i++)	{
		NSCalendarDate * date = [[availableAppointments objectAtIndex:i] valueForKey:@"time"];
		[availableTimes addObject:[date dateWithCalendarFormat:@"%I:%M %p" timeZone:nil]];
	}
	double extraHeight, extraWidth;
	extraWidth = 40 + CHECKBOXWIDTH;
	int resultsCount = [availableTimes count];
	if (resultsCount > 0)	{
		extraHeight = (CHECKBOXHEIGHT + CHECKBOXVERTICALSPACING) * resultsCount - CHECKBOXVERTICALSPACING + 40;
		NSRect extraFrame = [extraTimesView frame];
		double gap = extraHeight - extraFrame.size.height;
		if (gap > 0)	{
			extraFrame.size.height = extraHeight;
			extraFrame.size.width = extraWidth;
			[extraTimesView setFrame:extraFrame];
		}
		else extraHeight = extraFrame.size.height;  //<<---initializing height variable for later use...
	}	
	for (i=0; i< resultsCount; i++)	{
		NSButton * newButton = [[[NSButton alloc] init] autorelease];
	
		[newButton setTitle:[availableTimes objectAtIndex:i]];
		[newButton setButtonType:NSSwitchButton];
		
		double originX, originY;
		originX = 20;
		originY = extraHeight - 20 - (CHECKBOXHEIGHT * (i+1)) - (CHECKBOXVERTICALSPACING * i);
		[newButton setFrame:NSMakeRect(originX, originY, CHECKBOXWIDTH, CHECKBOXHEIGHT)];
		
		
		[subviews addObject:newButton];
	}
	
	[extraTimesView setSubviews:subviews];
	[extraTimesView scrollPoint:NSMakePoint(0, extraHeight)];
}
-(void)createServiceMenu
{
	NSMutableArray * subviews = [NSMutableArray array];
	//calculate the size of the view, then align it so the top corner of view matches the corner of scroller
	//...
	id appointment = [[pageView selectedBlock] appointment];
	NSMutableSet * services = [NSMutableSet setWithSet:[appointment valueForKey:@"services"]];

	NSFetchRequest * menuRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * menuDescription = [NSEntityDescription entityForName:@"ServiceMenuItem" inManagedObjectContext:moc];
	NSSortDescriptor * listOrderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	[menuRequest setSortDescriptors:[NSArray arrayWithObject:listOrderDescriptor]];
	[menuRequest setEntity:menuDescription];
	NSArray * results = [moc executeFetchRequest:menuRequest error:&error];
	NSLog(@"executing Fetch ServiceMenuItems");
	int resultsCount = [results count];
	double serviceHeight;
	double serviceWidth = (CHECKBOXWIDTH*2) + 40;
	if (resultsCount > 0)	{
		serviceHeight = (CHECKBOXHEIGHT + CHECKBOXVERTICALSPACING) * resultsCount - CHECKBOXVERTICALSPACING + 40;
		NSRect serviceFrame = [servicesView frame];
		double gap = serviceHeight - serviceFrame.size.height;
		if (gap > 0)	{
			serviceFrame.size.height = serviceHeight;
			serviceFrame.size.width = serviceWidth;
			[servicesView setFrame:serviceFrame];
		}
		else serviceHeight = serviceFrame.size.height;  //<<---initializing height variable for later use...
	}
	int i;
	int j;
	for (i=0; i< resultsCount; i++)	{
		NSButton * newButton = [[[NSButton alloc] init] autorelease];
		[newButton setTitle:[[results objectAtIndex:i] valueForKey:@"serviceDescription"]];
		[newButton setButtonType:NSSwitchButton];

		double originX, originY;
		originX = 20;
		originY = serviceHeight - 20 - (CHECKBOXHEIGHT * (i+1)) - (CHECKBOXVERTICALSPACING * i);
		[newButton setFrame:NSMakeRect(originX, originY, (CHECKBOXWIDTH*2), CHECKBOXHEIGHT)];
		
		for (j=0 ; j< [services count]; j++)	{
			NSArray * servicesArray = [NSArray arrayWithArray:[services allObjects]];
			if ([[[results objectAtIndex:i] valueForKey:@"serviceDescription"] compare:[[servicesArray objectAtIndex:j] valueForKey:@"serviceDescription"]] == NSOrderedSame)	{
				[newButton setState:1];
			}
		}
		[subviews addObject:newButton];
	}
	[servicesView setSubviews:subviews];
	[servicesView scrollPoint:NSMakePoint(0, serviceHeight)];
}
-(IBAction)goToMakeEditAppointmentAction:(id)sender
{
	
	NSManagedObject * appointment = [[pageView selectedBlock] appointment];
	if ([appointment valueForKey:@"parentAppointment"] == nil)	{
		if ([appointment valueForKeyPath:@"client"] == nil)	{
			SEL selector = @selector(setBookedBy:);
			[employeeSelect selectEmployeeFor:self selector:selector windowTitle:@"Who Are You"];
		} else	{
			[self loadAppointmentInfo:appointment];
			[makeAppointmentWindow makeKeyAndOrderFront:self];
		}
	} else	{
		[pageView selectParent];
	}
	
}
-(IBAction)createNewClient:(id)sender
{
	[clientDatabase goToCreateNewClientForBooking:self];
	[createOrFindWindow close];
}
-(IBAction)findExistingClient:(id)sender
{
	[bookWithName setStringValue:@""];
	[bookWithPhone setStringValue:@""];
	[clientsToChooseFrom setContent:[NSMutableArray array]];
	[selectClientWindow makeKeyAndOrderFront:self];
	[createOrFindWindow close];
}
-(void)makeEditAppointment
{
	NSString * bookedBy = [[[pageView selectedBlock] appointment] valueForKey:@"bookedBy"];
	if ([[[[pageView selectedBlock] appointment] className] compare:@"NSManagedObject"] != NSOrderedSame)	{
		[pageView upgradeStylistDay];
	}
	
	// now selected appointment is managedobject, assigns values
	NSManagedObject * appointment = [[pageView selectedBlock] appointment];
	
	if ([appointment valueForKey:@"bookedBy"] == nil)	{
		[appointment setValue:bookedBy forKey:@"bookedBy"];
	}
	NSManagedObject * client = [appointment valueForKey:@"client"];
	if (client == nil)	{
		client = [NSEntityDescription insertNewObjectForEntityForName:@"Client" inManagedObjectContext:moc];
		[appointment setValue:client forKey:@"client"];
	}
	NSString * clientName = [client valueForKey:@"name"];
	
	id nextVariable = [vcrField stringValue];
	if (nextVariable) [appointment setValue:nextVariable forKey:@"vcr"];
	
	nextVariable = [homePhoneField stringValue];
	if (nextVariable) [client setValue:nextVariable forKey:@"homePhone"];
	
	nextVariable = [workPhoneField stringValue];
	if (nextVariable) [client setValue:nextVariable forKey:@"workPhone"];
	
	nextVariable = [mobilePhoneField stringValue];
	if (nextVariable) [client setValue:nextVariable forKey:@"mobilePhone"];
	
	nextVariable = [emailField stringValue];
	if (nextVariable) [client setValue:nextVariable forKey:@"email"];
	
	
	
	nextVariable = [specialNoteField string];
	if (nextVariable) {
		[appointment setValue:nextVariable forKey:@"specialNote"];
	}
	
	if ([maleButton state] == 1)	{
		[client setValue:[NSNumber numberWithBool:YES] forKey:@"isMale"];
		[client setValue:[NSNumber numberWithBool:NO] forKey:@"isFemale"];
	} 
	if ([femaleButton state] == 1)	{
		[client setValue:[NSNumber numberWithBool:YES] forKey:@"isFemale"];
		[client setValue:[NSNumber numberWithBool:NO] forKey:@"isMale"];
	}
	
	if ([appointment valueForKey:@"dateBooked"] == nil)	
	{
		[appointment setValue:[NSDate date] forKey:@"dateBooked"];
		[self notifyEmployeeOfScheduleChange];

	}
	
	// address services selected...
	
	NSArray * serviceSubviews = [servicesView subviews];
	
	//find out which ones are checked
	NSMutableSet * newServices = [NSMutableSet set];
	NSMutableArray * checkedServices = [NSMutableArray array];
	int i;
	for (i=0; i < [serviceSubviews count]; i++)	{
		if ([[serviceSubviews objectAtIndex:i] state] == 1)	{
			[checkedServices addObject:[[serviceSubviews objectAtIndex:i] title]];
		}
	}
	NSFetchRequest * serviceMenuRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * serviceDescription = [NSEntityDescription entityForName:@"ServiceMenuItem" inManagedObjectContext:moc];
	[serviceMenuRequest setEntity:serviceDescription];
	NSArray * results = [moc executeFetchRequest:serviceMenuRequest error:&error];
	NSLog(@"executing Fetch Service Menu Item");
	for (i=0; i< [checkedServices count]; i++)	{
		int j;
		for (j= 0 ; j < [results count]; j++)	{
			if ([[[results objectAtIndex:j] valueForKey:@"serviceDescription"] compare:[checkedServices objectAtIndex:i]] == NSOrderedSame)	{
				NSManagedObject * defaultService = [results objectAtIndex:j];
				NSManagedObject * newService = [NSEntityDescription insertNewObjectForEntityForName:@"Service" inManagedObjectContext:moc];
				[newService setValue:[defaultService valueForKey:@"isChemicalService"] forKey:@"isChemicalService"];
				[newService setValue:[defaultService valueForKey:@"serviceDescription"] forKey:@"serviceDescription"];

				[newService setValue:[defaultService valueForKey:@"listOrder"] forKey:@"listOrder"];
				[newServices addObject:newService];
			}
			
		}
		
	}
	[appointment setValue:newServices forKey:@"services"];
	
	
	// address extraTimes
	// Get checked times, then get available times
	NSArray * extraSubviews = [extraTimesView subviews];
	NSMutableSet * newChildAppointments = [NSMutableSet setWithSet:[appointment valueForKey:@"childAppointments"]];
	NSMutableArray * checkedExtras = [NSMutableArray array];
	
	NSMutableArray * availableAppointments = [self availableExtraAppointments];
	for (i=0; i < [extraSubviews count]; i++)	{
		if ([[extraSubviews objectAtIndex:i] state] == 1)	{
			
			[checkedExtras addObject:[[extraSubviews objectAtIndex:i] title]];
			[newChildAppointments addObject:[availableAppointments objectAtIndex:i]];
			[self bookFiller:[availableAppointments objectAtIndex:i] withClient:client];
			
		}
	}
	if ([newChildAppointments count] > 0)	{
		[appointment setValue:newChildAppointments forKey:@"childAppointments"];
	}
	
	
	

	
	if ([[client valueForKey:@"name"] length] > 0)	{//APPOINTMENT HAS SUFFICIENT DATA
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
		[self updateAppointmentDescription];
		
		[makeAppointmentWindow close];
	}
	[[pageView selectedBlock] updateDisplay];
	[[pageView selectedBlock] selectBlock];
	
}
-(void)bookFiller:(NSManagedObject *)filler withClient:(NSManagedObject *)client
{
	// makes an appointment filler and uses the currently selected appointment as a parent
	[filler setValue:[NSDate date] forKey:@"dateBooked"];
	[filler setValue:client forKey:@"client"];
	[filler setValue:[vcrField stringValue] forKey:@"vcr"];
	[filler setValue:[[pageView selectedBlock] appointment] forKey:@"parentAppointment"];
	
	[pageView updateAllAppointmentBlocks];


}
-(NSString *)appointmentDescription:(NSManagedObject *)appointment
{
	NSMutableString * description = [NSMutableString string];
	
	if (appointment != nil)	{
		NSCalendarDate * date = [[appointment valueForKey:@"time"] dateWithCalendarFormat:@"%a. %b. %d, %Y" timeZone:nil];
		NSCalendarDate * time = [[appointment valueForKey:@"time"] dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
		[description appendFormat:@"Stylist: %@\n\n", [[appointment valueForKey:@"stylist"] valueForKey:@"name"]];
		[description appendFormat:@"Date: %@\n\n", date];
		[description appendFormat:@"Time: %@\n\n", time];
	}
	if ([[appointment className] compare:@"NSManagedObject"] == NSOrderedSame)	{
		id workingVariable;
		if ((workingVariable = [appointment valueForKeyPath:@"bookedBy"]) != nil)	{
			[description appendFormat:@"Booked By: %@\n\n", workingVariable];
		}
		workingVariable = [appointment valueForKeyPath:@"dateBooked"];
		workingVariable = [workingVariable dateWithCalendarFormat:@"%I:%M %p\n\t\t       %a. %b. %d, %Y" timeZone:nil];
		if (workingVariable != nil)	{
			[description appendFormat:@"Date Booked: %@\n\n", workingVariable];
		}
		if ((workingVariable = [appointment valueForKeyPath:@"client.name"]) != nil)	{
			[description appendFormat:@"Client: %@\n\n", workingVariable];
		}
		
		int i;
		NSSortDescriptor * listOrderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
		NSMutableArray * services = [NSMutableArray arrayWithArray:[[appointment valueForKey:@"services"] allObjects]];
		[services sortUsingDescriptors:[NSArray arrayWithObject:listOrderDescriptor]];
		if ([services count] > 0)	{
			[description appendFormat:@"Services: "];
		}
		for (i=0 ; i < [services count]; i++)	{
			[description appendFormat:@"%@, ", [[services objectAtIndex:i] valueForKey:@"serviceDescription"]];
		}
		if ([services count] > 0)	{
			[description appendFormat:@"\n\n"];
		}
		
		if ((workingVariable = [appointment valueForKeyPath:@"transaction.serviceSubtotal"]) != nil)	{
			[description appendFormat:@"Service Total: %@\n\n", workingVariable];
		}
		
		if ((workingVariable = [appointment valueForKeyPath:@"confirmedBy"]) != nil)	{
			[description appendFormat:@"Confirmed By: %@\n\n", workingVariable];
		} else if ((workingVariable = [appointment valueForKeyPath:@"needsConfirmation"]) != nil)	{
			if ([workingVariable boolValue] == NO)	{
				[description appendFormat:@"Not Confirmed --- Left Message\n\n"]; 
			}
		}
		
		if ((workingVariable = [appointment valueForKeyPath:@"transaction.collectedBy"]) != nil)	{
			[description appendFormat:@"Collected By: %@\n\n", workingVariable];
		}
				
		
	}
	return description;
}
-(void)updateAppointmentDescription
{
	id update = [[pageView selectedBlock] appointment];
	NSString * description = [self appointmentDescription:update];
	[appointmentDescription setString:description];
}
-(NSString *)appointmentDescriptionForTransfer
{
	NSMutableString * description = [NSMutableString string];
	id workingVariable;
	NSManagedObject * appointment = [[pageView selectedBlock] appointment];
	if ([[appointment className] compare:@"NSManagedObject"] == NSOrderedSame)	{
		if ((workingVariable = [appointment valueForKeyPath:@"client.name"]) != nil)	{
			[description appendFormat:@"Client: %@\n\n", workingVariable];
		}
		
		int i;
		NSSortDescriptor * listOrderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
		NSMutableArray * services = [NSMutableArray arrayWithArray:[[appointment valueForKey:@"services"] allObjects]];
		[services sortUsingDescriptors:[NSArray arrayWithObject:listOrderDescriptor]];
		if ([services count] > 0)	{
			[description appendFormat:@"Services: "];
		}
		for (i=0 ; i < [services count]; i++)	{
			[description appendFormat:@"%@, ", [[services objectAtIndex:i] valueForKey:@"serviceDescription"]];
		}
		if ([services count] > 0)	{
			[description appendFormat:@"\n\n"];
		}
		
		if ((workingVariable = [appointment valueForKeyPath:@"transaction.serviceSubtotal"]) != nil)	{
			[description appendFormat:@"Service Total: %@\n\n", workingVariable];
		}
		
		
		
		
	}
	
	if (appointment != nil)	{
		NSCalendarDate * date = [[appointment valueForKey:@"time"] dateWithCalendarFormat:@"%a. %b. %d, %Y" timeZone:nil];
		NSCalendarDate * time = [[appointment valueForKey:@"time"] dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
		[description appendFormat:@"Date: %@\n\n", date];
		[description appendFormat:@"Time: %@\n\n", time];
		[description appendFormat:@"Stylist: %@\n\n", [[appointment valueForKey:@"stylist"] valueForKey:@"name"]];
		
	}
	return description;
}
-(void)setBookedBy:(NSManagedObject *)bookedBy
{
	NSManagedObject * appointment = [[pageView selectedBlock] appointment];
	NSString * signature = [bookedBy valueForKey:@"signature"];
	
	if (signature == nil)	{
		signature = [bookedBy valueForKey:@"name"];
	}
	self.lastBookedBy = signature;
	[appointment setValue:signature forKey:@"bookedBy"];
	[self goToMakeEditAppointment];
}
-(IBAction)makeEditAppointmentAction:(id)sender
{
	[self makeEditAppointment];
}

-(NSManagedObject *)defaultBookingSchedule
{
	moc = [appDelegate managedObjectContext];
	
	//above moc value setting should not be necessary , but will be unless a neutral class initializes program
	NSManagedObject * bookingSchedule = [NSEntityDescription insertNewObjectForEntityForName:@"BookingSchedule" inManagedObjectContext:moc];
	NSCalendarDate * tempDate = [NSCalendarDate dateWithYear:2008 month:1 day:1 hour:10 minute:0 second:0 timeZone:nil];
	
	[bookingSchedule setValue:tempDate forKey:@"firstSunday"];
	[bookingSchedule setValue:tempDate forKey:@"firstMonday"];
	[bookingSchedule setValue:tempDate forKey:@"firstTuesday"];
	[bookingSchedule setValue:tempDate forKey:@"firstWednesday"];
	[bookingSchedule setValue:tempDate forKey:@"firstThursday"];
	[bookingSchedule setValue:tempDate forKey:@"firstFriday"];
	[bookingSchedule setValue:tempDate forKey:@"firstSaturday"];
	
	
	tempDate = [tempDate dateByAddingYears:0 months:0 days:0 hours:10 minutes:0 seconds:0];
	
	[bookingSchedule setValue:tempDate forKey:@"lastSunday"];
	[bookingSchedule setValue:tempDate forKey:@"lastMonday"];
	[bookingSchedule setValue:tempDate forKey:@"lastTuesday"];
	[bookingSchedule setValue:tempDate forKey:@"lastWednesday"];
	[bookingSchedule setValue:tempDate forKey:@"lastThursday"];
	[bookingSchedule setValue:tempDate forKey:@"lastFriday"];
	[bookingSchedule setValue:tempDate forKey:@"lastSaturday"];
	
	
	
	return bookingSchedule;
}
-(void)initialStart
{
	moc = [appDelegate managedObjectContext];
	NSCalendarDate * tomorrow = [[NSDate date] addTimeInterval:3600*27];
	[self setLastSelectedDate:tomorrow];
	
	[mainDatePicker setDateValue:[NSDate date]];
	[self changeDateOnMainPageAction:self];
	
}
-(void)changeDateOnMainPage
{
	BOOL changedDate = NO;
	NSTimeInterval timeInterval = [lastSelectedDate timeIntervalSinceDate:[mainDatePicker dateValue]];
	if (timeInterval > 0)	{
		if (timeInterval/(12*3600) > 1)	{
			changedDate = YES;
		}
	} else {
		if (timeInterval/(12*3600) < 1)	{
			changedDate = YES;
		}
	}

	self.lastSelectedDate = [mainDatePicker dateValue];
	if (changedDate)	{

		[[NSNotificationCenter defaultCenter] postNotificationName:@"DateChanged" object:mainDatePicker];
		
		// get date from datepicker and set up date boundaries
		NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
		NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
		int month, day, year;
		month = [workingDate monthOfYear];
		day = [workingDate dayOfMonth];
		year = [workingDate yearOfCommonEra];
		NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
		day++;
		NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
		
		// fetch employees, sort by bool booksServices
		NSMutableArray * stylists = [staffController workingServiceProviders:workingDate];
		// prepare fetch for appointments from date, by stylists,
		NSEntityDescription * appointmentEntity = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
		NSFetchRequest * appointmentRequest = [[[NSFetchRequest alloc] init] autorelease];
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
		predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
		[appointmentRequest setPredicate:predicate];
		[appointmentRequest setEntity:appointmentEntity];
		
		
		
		NSMutableArray * daysAppointments = [NSMutableArray arrayWithArray:[moc executeFetchRequest:appointmentRequest error:&error]];
		NSLog(@"executing Fetch appointment");
		
		if ([daysAppointments count] > 0)	{
			
		}
		NSSortDescriptor * timeSort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
		[daysAppointments sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
		
		
		
		
		int i;
		NSMutableArray * stylistDays = [NSMutableArray array];
		for (i=0; i< [stylists count]; i++)	{
			NSMutableArray * filterArray = [NSMutableArray arrayWithArray:daysAppointments];
			NSPredicate * predicate = [NSPredicate predicateWithFormat:@"stylist == %@", [stylists objectAtIndex:i]];
			[filterArray filterUsingPredicate:predicate];
			NSMutableArray * stylistDay = [NSMutableArray arrayWithArray:filterArray];
			[stylistDay sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
			[stylistDays addObject:stylistDay];
		}
		
		[timeSort release];
		// if employee has no appointments from fetch, ask for blank schedule for the date
		
		for (i=0; i < [stylistDays count]; i++)	{
			if ([[stylistDays objectAtIndex:i] count] == 0)	{
				[stylistDays replaceObjectAtIndex:i withObject:[self blankScheduleForStylist:[stylists objectAtIndex:i] date:workingDate]];
			}
		}
		for (i=0; i < [stylistDays count]; i++)	{
			if ([[stylistDays objectAtIndex:i] count] == 0)	{
				[stylistDays removeObjectAtIndex:i];
				[stylists removeObjectAtIndex:i];
				i--;
				
			}
		}
		
		[pageView displayDataForStylistDays:stylistDays];
		if ([[today description] compare:[workingDate description]] == NSOrderedSame)	{
			[pageView selectCurrentTime];
		}
		[self updateAppointmentDescription];
	}
}
-(IBAction)changeDateOnMainPageAction:(id)sender
{
	[self changeDateOnMainPage];
}
-(IBAction)clientNameEntered:(id)sender
{
	//if (modalRejected == NO)	{
//		if ([[clientField stringValue] length] > 0)	{
//			if ([[[pageView selectedBlock] appointment] valueForKey:@"client"] == nil)	{
//				id selectedAppointment = [[pageView selectedBlock] appointment];
//				NSMutableArray * clients = [clientDatabase clientsMatchingName:[clientField stringValue]];
//				if ([clients count] > 0)	{
//					[self runModalForClients:clients];
//				}
//					
//				
//			}
//			
//		}
//	}
}
-(IBAction)makeAppointmentWithSelectedClient:(id)sender
{
	if ([[clientsToChooseFrom selectedObjects] count] > 0)	{
		if ([[[[pageView selectedBlock] appointment] className] compare:@"NSManagedObject"] != NSOrderedSame)	{
			[pageView upgradeStylistDay];
		}
		
		// now selected appointment is managedobject, assign values
		NSManagedObject * client = [[clientsToChooseFrom selectedObjects] objectAtIndex:0];
		NSManagedObject * selectedAppointment = [[pageView selectedBlock] appointment];
		[selectedAppointment setValue:client forKey:@"client"];
		
		[self loadAppointmentInfo:selectedAppointment];
		[makeAppointmentWindow makeKeyAndOrderFront:self];\
		[selectClientWindow close];
	}

	
}
-(IBAction)makeAppointmentWithNewClient:(id)sender
{
	modalRejected = YES;
	[[NSApplication sharedApplication] stopModal];
	[selectClientWindow close];
}

-(void)runModalForClients:(NSArray *)clients
{
	[clientsToChooseFrom setContent:clients];
//	[selectClientWindow makeKeyAndOrderFront:self];
	[[NSApplication sharedApplication] runModalForWindow:selectClientWindow];
}

-(IBAction)clientPhoneEntered:(id)sender
{
	
	if (modalRejected == NO)	{
		id selectedAppointment = [[pageView selectedBlock] appointment];
		if ([selectedAppointment valueForKey:@"client"] == nil)	{
			NSMutableArray * clients = [clientDatabase clientsMatchingPhone:[sender stringValue]];
			if ([clients count] > 0)	{
				[self runModalForClients:clients];
			
			}
		}
		
		
	}
	
}

-(NSMutableArray *)blankScheduleForStylist:(NSManagedObject *)stylist date:(NSDate*)date
{
	NSString * firstKey;
	NSString *lastKey;
	NSString *worksKey;
	NSString *lengthKey;
	
	NSCalendarDate * workingDate = [date dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	int month, day, year, dayOfWeek;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	dayOfWeek = [workingDate dayOfWeek];
	
	
	if (dayOfWeek == 0)	{
		firstKey = [NSString stringWithString:@"bookingSchedule.firstSunday"];
		lastKey = [NSString stringWithString:@"bookingSchedule.lastSunday"];
		worksKey = [NSString stringWithString:@"bookingSchedule.worksSunday"];
		lengthKey = [NSString stringWithString:@"bookingSchedule.appointmentLengthSunday"];
		
	}
	if (dayOfWeek == 1)	{
		firstKey = [NSString stringWithString:@"bookingSchedule.firstMonday"];
		lastKey = [NSString stringWithString:@"bookingSchedule.lastMonday"];
		worksKey = [NSString stringWithString:@"bookingSchedule.worksMonday"];
		lengthKey = [NSString stringWithString:@"bookingSchedule.appointmentLengthMonday"];
	}
	if (dayOfWeek == 2)	{
		firstKey = [NSString stringWithString:@"bookingSchedule.firstTuesday"];
		lastKey = [NSString stringWithString:@"bookingSchedule.lastTuesday"];
		worksKey = [NSString stringWithString:@"bookingSchedule.worksTuesday"];
		lengthKey = [NSString stringWithString:@"bookingSchedule.appointmentLengthTuesday"];
	}
	if (dayOfWeek == 3)	{
		firstKey = [NSString stringWithString:@"bookingSchedule.firstWednesday"];
		lastKey = [NSString stringWithString:@"bookingSchedule.lastWednesday"];
		worksKey = [NSString stringWithString:@"bookingSchedule.worksWednesday"];
		lengthKey = [NSString stringWithString:@"bookingSchedule.appointmentLengthWednesday"];
	}
	if (dayOfWeek == 4)	{
		firstKey = [NSString stringWithString:@"bookingSchedule.firstThursday"];
		lastKey = [NSString stringWithString:@"bookingSchedule.lastThursday"];
		worksKey = [NSString stringWithString:@"bookingSchedule.worksThursday"];
		lengthKey = [NSString stringWithString:@"bookingSchedule.appointmentLengthThursday"];
	}
	if (dayOfWeek == 5)	{
		firstKey = [NSString stringWithString:@"bookingSchedule.firstFriday"];
		lastKey = [NSString stringWithString:@"bookingSchedule.lastFriday"];
		worksKey = [NSString stringWithString:@"bookingSchedule.worksFriday"];
		lengthKey = [NSString stringWithString:@"bookingSchedule.appointmentLengthFriday"];
	}
	if (dayOfWeek == 6)	{
		firstKey = [NSString stringWithString:@"bookingSchedule.firstSaturday"];
		lastKey = [NSString stringWithString:@"bookingSchedule.lastSaturday"];
		worksKey = [NSString stringWithString:@"bookingSchedule.worksSaturday"];
		lengthKey = [NSString stringWithString:@"bookingSchedule.appointmentLengthSaturday"];
	}
	BOOL works = [[stylist valueForKeyPath:worksKey] boolValue];
	NSMutableArray * appointments = [NSMutableArray array];
	if (works == YES)	{
		NSCalendarDate * lastTime = [stylist valueForKeyPath:lastKey];
		NSCalendarDate * firstTime = [stylist valueForKeyPath:firstKey];
		
		int firstHour, firstMinute, lastHour, lastMinute;
		
		lastTime = [lastTime dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
		firstTime = [firstTime dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
		
		firstHour = [firstTime hourOfDay];
		firstMinute = [firstTime minuteOfHour];
		lastHour = [lastTime hourOfDay];
		lastMinute = [lastTime minuteOfHour];
		
		int length = [[stylist valueForKeyPath:lengthKey] intValue];
		
		NSCalendarDate * firstDate = [NSCalendarDate dateWithYear:year month:month day:day hour:firstHour minute:firstMinute second:0 timeZone:nil];
		NSCalendarDate * lastDate = [NSCalendarDate dateWithYear:year month:month day:day hour:lastHour minute:lastMinute second:0 timeZone:nil];
		
		[firstDate setCalendarFormat:@"%I:%M %p"];
		while ([lastDate timeIntervalSinceDate:firstDate] >= 0)	{
			NSMutableDictionary * appointment = [NSMutableDictionary dictionary];
			[appointment setObject:firstDate forKey:@"time"];
			[appointment setObject:stylist forKey:@"stylist"];
			[appointment setObject:[NSNumber numberWithInt:length] forKey:@"appointmentLength"];
			
			firstDate = [firstDate dateByAddingYears:0 months:0 days:0 hours:0 minutes:length seconds:0];
			[appointments addObject:appointment];

		}
	}	
	return appointments;
}
-(IBAction)selectingGenderOnMakeAppointment:(id)sender
{
	if (sender == femaleButton)	{
		if ([sender state] == 1)	{
			[maleButton setState:0];
		}
	} else	{
		if ([sender state] == 1)	{
			[femaleButton setState:0];
		}
	}
}
- (BOOL)windowShouldClose:(id)window
{
	return YES;
}
-(IBAction)addAppointmentAbove:(id)sender
{
	BuildingBlock * block = [pageView selectedBlock];
	id appointment = [block appointment];
	NSManagedObject * stylist = [appointment valueForKey:@"stylist"];
	NSDate * apptTime;
	if ([pageView moveUp] == NO)	{
		if ([[appointment className] compare:@"NSManagedObject"] != NSOrderedSame)	{
			[pageView upgradeStylistDay];
			appointment = [[pageView selectedBlock] appointment];
		}
		NSString * key;
		NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%A" timeZone:nil];
		key = [NSString stringWithFormat:@"stylist.bookingSchedule.appointmentLength%@", selectedDate];
		int apptLength = [[appointment valueForKeyPath:key] intValue];
		apptTime = [appointment valueForKey:@"time"];
		apptTime = [apptTime addTimeInterval:-apptLength*60];
		NSEntityDescription * newAppointment = [NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:moc];
		[newAppointment setValue:[appointment valueForKey:@"stylist"] forKey:@"stylist"];
		[newAppointment setValue:apptTime forKey:@"time"];
		[newAppointment setValue:[NSNumber numberWithInt:apptLength] forKey:@"appointmentLength"];
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	
		[self changeDateOnMainPage];
		[pageView selectAppointmentForTime:apptTime withStylist:stylist];
		
	} else	{
		[pageView moveDown];
	}
	
		
		
	
}
-(IBAction)addAppointmentBelow:(id)sender
{
	BuildingBlock * block = [pageView selectedBlock];
	id appointment = [block appointment];
	NSManagedObject * stylist = [appointment valueForKey:@"stylist"];
	NSDate * apptTime;
	if ([pageView moveDown] == NO)	{
		if ([[appointment className] compare:@"NSManagedObject"] != NSOrderedSame)	{
			[pageView upgradeStylistDay];
			appointment = [[pageView selectedBlock] appointment];

		}
		NSString * key;
		NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%A" timeZone:nil];
		key = [NSString stringWithFormat:@"stylist.bookingSchedule.appointmentLength%@", selectedDate];
		int apptLength = [[appointment valueForKeyPath:key] intValue];
		apptTime = [appointment valueForKey:@"time"];
		apptTime = [apptTime addTimeInterval:apptLength*60];
		NSEntityDescription * newAppointment = [NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:moc];
		[newAppointment setValue:[appointment valueForKey:@"stylist"] forKey:@"stylist"];
		[newAppointment setValue:apptTime forKey:@"time"];
		[newAppointment setValue:[NSNumber numberWithInt:apptLength] forKey:@"appointmentLength"];
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
		
		[self changeDateOnMainPage];
		[pageView selectAppointmentForTime:apptTime withStylist:stylist];
		
	} else	{
		[pageView moveUp];
	}
	
}
-(IBAction)squeezeAppointmentAbove:(id)sender
{
	squeezeAboveTest = YES;
	id appointment = [[pageView selectedBlock] appointment];
	if ([[appointment className] compare:@"NSManagedObject"] != NSOrderedSame)	{
		[pageView upgradeStylistDay];
		appointment = [[pageView selectedBlock] appointment];
	}

	
	NSFetchRequest * appointmentRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * apptDescription = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];

	
	NSManagedObject * stylist = [appointment valueForKey:@"stylist"];
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END AND stylist == %@", stylist];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",[appointment valueForKey:@"time"], @"END", nil]];
	
	[appointmentRequest setEntity:apptDescription];
	[appointmentRequest setPredicate:predicate];
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:appointmentRequest error:&error]];
	NSLog(@"executing Fetch appointment");
	

	NSSortDescriptor * timeSort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
	[results sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
	[timeSort release];
	if ([results count] > 0)	{
		NSDate * earlyBound = [[[results lastObject] valueForKey:@"time"] addTimeInterval:60*15];
		NSDate * lateBound = [[appointment valueForKey:@"time"] addTimeInterval:-60*15];
		self.startBound = [appointment valueForKey:@"time"];
		affectedAppt = [results lastObject];
		[startTimePicker setMinDate:earlyBound];
		[startTimePicker setMaxDate:lateBound];
		[getStartTimeWindow makeKeyAndOrderFront:self];
	}
		 
									  
	
}

-(IBAction)squeezeAppointmentBelow:(id)sender
{
	squeezeAboveTest = NO;
	id appointment = [[pageView selectedBlock] appointment];
	if ([[appointment className] compare:@"NSManagedObject"] != NSOrderedSame)	{
		[pageView upgradeStylistDay];
		appointment = [[pageView selectedBlock] appointment];
	}
	NSFetchRequest * appointmentRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * apptDescription = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
	
	NSManagedObject * stylist = [appointment valueForKey:@"stylist"];
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END && stylist == %@", stylist];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:[appointment valueForKey:@"time"] , @"BEGINNING",endOfDay, @"END", nil]];
	
	[appointmentRequest setEntity:apptDescription];
	[appointmentRequest setPredicate:predicate];
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:appointmentRequest error:&error]];
	NSLog(@"executing Fetch appointment");
	

	NSSortDescriptor * timeSort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
	[results sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
	[timeSort release];
	if ([results count] > 0)	{
		NSDate * lateBound = [[[results objectAtIndex:0] valueForKey:@"time"] addTimeInterval:-60*15];
		NSDate * earlyBound = [[appointment valueForKey:@"time"] addTimeInterval:60*15];
		self.startBound = [[results objectAtIndex:0] valueForKey:@"time"];
		affectedAppt = [results objectAtIndex:0];
		
		[startTimePicker setMinDate:earlyBound];
		[startTimePicker setMaxDate:lateBound];
		[getStartTimeWindow makeKeyAndOrderFront:self];
	}
	
}
-(IBAction)startTimeEntered:(id)sender
{
	if (squeezeAboveTest)	{
		[self squeezeAbove];
	} else	{
		[self squeezeBelow];
	}
	[getStartTimeWindow close];
}
-(void)squeezeAbove
{
	// affectedAppointment is one above the selectedAppt.
	NSDate * affectedTime = [affectedAppt valueForKey:@"time"];

	NSManagedObject * appointment = [[pageView selectedBlock] appointment];
	int affectedLength = [[startTimePicker dateValue] timeIntervalSinceDate:affectedTime];
	affectedLength /= 60;
	[affectedAppt setValue:[NSNumber numberWithInt:affectedLength] forKey:@"appointmentLength"];
	int newLength = [[appointment valueForKey:@"time"] timeIntervalSinceDate:[startTimePicker dateValue]];
	newLength /= 60;
	NSManagedObject * newAppt = [NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:moc];
	[newAppt setValue:[appointment valueForKey:@"stylist"] forKey:@"stylist"];
	[newAppt setValue:[startTimePicker dateValue] forKey:@"time"];
	[newAppt setValue:[NSNumber numberWithInt:newLength] forKey:@"appointmentLength"];
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	NSDate * time = [appointment valueForKey:@"time"];
	NSManagedObject * stylist = [appointment valueForKey:@"stylist"];
	
	[self changeDateOnMainPage];
	[pageView selectAppointmentForTime:time withStylist:stylist];
	
	
	
	
}
-(void)squeezeBelow
{
	
	// here affected is the one below that acts as a cut off for apptLength
	NSDate * latestTime = [affectedAppt valueForKey:@"time"];
	
	NSManagedObject * appointment = [[pageView selectedBlock] appointment];
	int affectedLength = [[startTimePicker dateValue] timeIntervalSinceDate:[appointment valueForKey:@"time"]];
	affectedLength /= 60;
	[appointment setValue:[NSNumber numberWithInt:affectedLength] forKey:@"appointmentLength"];
	
	int newLength = [latestTime timeIntervalSinceDate:[startTimePicker dateValue]];
	newLength /= 60;
	
	NSManagedObject * newAppt = [NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:moc];
	[newAppt setValue:[appointment valueForKey:@"stylist"] forKey:@"stylist"];
	[newAppt setValue:[startTimePicker dateValue] forKey:@"time"];
	[newAppt setValue:[NSNumber numberWithInt:newLength] forKey:@"appointmentLength"];
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	
	NSDate * time = [appointment valueForKey:@"time"];
	NSManagedObject * stylist = [appointment valueForKey:@"stylist"];
	
	[self changeDateOnMainPage];
	[pageView selectAppointmentForTime:time withStylist:stylist];
	
}

-(IBAction)addScheduleForStylist:(id)sender
{
	SEL selector = @selector(stylistSelectedForAddSchedule:);
	[employeeSelect selectEmployeeFor:self selector:selector windowTitle:@"Add Schedule For Whom?"];
}
-(IBAction)addPageForStylist:(id)sender
{
	int testLength = [addApptLengthField intValue];
	testLength *= 60;
	if ([[lastDatePicker dateValue] timeIntervalSinceDate:[startDatePicker dateValue]] >= testLength)	{
		NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"" timeZone:nil];
		int month, day, year, minute, hour;
		month = [workingDate monthOfYear];
		day = [workingDate dayOfMonth];
		year = [workingDate yearOfCommonEra];
		NSCalendarDate * start = [[startDatePicker dateValue] dateWithCalendarFormat:@"" timeZone:nil];
		minute = [start minuteOfHour];
		hour = [start hourOfDay];
		workingDate = [NSCalendarDate dateWithYear:year month:month day:day hour:hour minute:minute second:0 timeZone:nil];
		NSCalendarDate * endOfDay = [[lastDatePicker dateValue] dateWithCalendarFormat:@"" timeZone:nil];
		minute = [endOfDay minuteOfHour];
		hour = [endOfDay hourOfDay];
		endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:hour minute:minute second:0 timeZone:nil];
		while ([endOfDay timeIntervalSinceDate:workingDate] >= 0)	{
			NSEntityDescription * newAppt = [NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:moc];
			[newAppt setValue:workingDate forKey:@"time"];
			[newAppt setValue:[employeeForAddPage content] forKey:@"stylist"];
			[newAppt setValue:[NSNumber numberWithInt:[addApptLengthField intValue]] forKey:@"appointmentLength"];
			workingDate = [workingDate dateByAddingYears:0 months:0 days:0 hours:0 minutes:[addApptLengthField intValue] seconds:0];
			
		}
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
		[addPageWindow close];
		[self changeDateOnMainPage];
	}
	
}
-(void)stylistSelectedForAddSchedule:(NSManagedObject*)employee
{
	NSFetchRequest * apptRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * apptDescription = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
	NSCalendarDate * beginning = [[mainDatePicker dateValuse] dateWithCalendarFormat:@"" timeZone:nil];
	int month, day, year;
	month = [beginning monthOfYear];
	day = [beginning dayOfMonth];
	year = [beginning yearOfCommonEra];
	beginning = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	NSDate * startOfDay = [beginning addTimeInterval:0];
	NSDate * ending = [startOfDay addTimeInterval:3600*24];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"stylist == %@ AND time > %@ AND time < %@",employee, startOfDay, ending];
	[apptRequest setEntity:apptDescription];
	[apptRequest setPredicate:predicate];
	NSLog(@"executing Fetch appointment");
	if ([[moc executeFetchRequest:apptRequest error:&error] count] == 0)	{
		
		
		[employeeForAddPage setContent:employee];
		[beginning setCalendarFormat:@"%A"];
		NSCalendarDate * start = [NSCalendarDate dateWithYear:2009 month:1 day:1 hour:10 minute:0 second:0 timeZone:nil];
		NSCalendarDate * end = [NSCalendarDate dateWithYear:2009 month:1 day:1 hour:20 minute:0 second:0 timeZone:nil];
		[startDatePicker setDateValue:start];
		[lastDatePicker setDateValue:end];
		[addApptLengthField setIntValue:60];
		[addPageWindow makeKeyAndOrderFront:self];

		
	} else	if ([[self blankScheduleForStylist:employee date:beginning] count] == 0)	{
		[employeeForAddPage setContent:employee];
		[beginning setCalendarFormat:@"%A"];
		NSCalendarDate * start = [NSCalendarDate dateWithYear:2009 month:1 day:1 hour:10 minute:0 second:0 timeZone:nil];
		NSCalendarDate * end = [NSCalendarDate dateWithYear:2009 month:1 day:1 hour:20 minute:0 second:0 timeZone:nil];
		[startDatePicker setDateValue:start];
		[lastDatePicker setDateValue:end];
		[addApptLengthField setIntValue:60];
		[addPageWindow makeKeyAndOrderFront:self];
	}
		
	
}
-(IBAction)cancelAppointmentAction:(id)sender
{
	BuildingBlock * block = [pageView selectedBlock];
	id appointment = [block appointment];
	NSManagedObject * client = [appointment valueForKey:@"client"];

	NSDate * time = [appointment valueForKey:@"time"];
	NSManagedObject * stylist = [appointment valueForKey:@"stylist"];
	NSMutableDictionary * cancellation = [NSMutableDictionary dictionary];
	NSArray * services = [[appointment valueForKey:@"services"] allObjects];
	
	NSMutableString * serviceDescription = [NSMutableString string];
	
	if ([[appointment className] compare:@"NSManagedObject"] == NSOrderedSame)	{
		if ([appointment valueForKeyPath:@"transaction.collectedBy"] == nil)	{
			NSString * message = [self appointmentDescription:appointment];
			
			int choice = NSRunAlertPanel(@"Cancelling Appointment", message, @"OK", @"Cancel", nil);
			if (choice == 1)	{
				id childrenObject = [appointment valueForKey:@"childAppointments"];
				NSArray * children = [NSArray arrayWithArray:[childrenObject allObjects]];
				
				NSDate * time = [appointment valueForKey:@"time"];
				NSManagedObject * stylist = [appointment valueForKey:@"stylist"];
				NSNumber * appointmentLength = [appointment valueForKey:@"appointmentLength"];
				
				[moc deleteObject:appointment];
				NSManagedObject * newAppointment = [NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:moc];
				[newAppointment setValue:appointmentLength forKey:@"appointmentLength"];
				[newAppointment setValue:time forKey:@"time"];
				[newAppointment setValue:stylist forKey:@"stylist"];
				[block setAppointment:newAppointment];
				[block updateDisplay];
				
				if ([[client valueForKey:@"appointments"] count] == 0)	{
					if (![client valueForKey:@"creditCard"])	{
						[moc deleteObject:client];
					}
				}
				
				int i;
				for (i= 0; i < [children count]; i++)	{
					appointment = [children objectAtIndex:i];
					time = [appointment valueForKey:@"time"];
					stylist = [appointment valueForKey:@"stylist"];
					appointmentLength = [appointment valueForKey:@"appointmentLength"];
					
					[moc deleteObject:appointment];
					NSManagedObject * newAppointment = [NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:moc];
					[newAppointment setValue:appointmentLength forKey:@"appointmentLength"];
					[newAppointment setValue:time forKey:@"time"];
					[newAppointment setValue:stylist forKey:@"stylist"];
					
					
				}
				if ([children count] > 0)	{
					[self changeDateOnMainPage];
				}
				error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}	
				for (i=0 ; i < [services count]; i++)	{
					[serviceDescription appendFormat:@"%@, ", [[services objectAtIndex:i] valueForKey:@"serviceDescription"]];
				}
				
				[cancellation setObject:time forKey:@"appointmentTime"];
				[cancellation setObject:[NSDate date] forKey:@"cancellationTime"];
				[cancellation setObject:[stylist valueForKey:@"name"] forKey:@"stylist"];
				[cancellation setObject:[client valueForKey:@"name"] forKey:@"client"];
				[cancellation setObject:serviceDescription forKey:@"serviceDescription"];
				[cancellation setObject:@"no" forKey:@"rescheduled"];
				id test = [NSKeyedUnarchiver unarchiveObjectWithFile:self.cancellationsPath];
				NSMutableArray * cancellations = [NSMutableArray array];
				if (test != nil)	{
					[cancellations setArray:test];
				}
				if ([cancellations count] > 0)	{
					[cancellations insertObject:cancellation atIndex:0];
				}  else	{
					[cancellations addObject:cancellation];
				}
				[NSKeyedArchiver archiveRootObject:cancellations toFile:self.cancellationsPath];
			}
				
		}
	}
	
	
	[pageView selectAppointmentForTime:time withStylist:stylist];
	
	
}
-(IBAction)changeAppointmentLength:(id)sender
{
	[newLengthField setStringValue:@""];
	[changeApptLengthWindow makeKeyAndOrderFront:self];
}
-(IBAction)newLengthEntered:(id)sender
{
	int newLength = [newLengthField intValue];
	
	
	id appointment = [[pageView selectedBlock] appointment];
	if ([[appointment className] compare:@"NSManagedObject"] != NSOrderedSame)	{
		[pageView upgradeStylistDay];
		appointment = [[pageView selectedBlock] appointment];
	}
	NSFetchRequest * appointmentRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * apptDescription = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
	
	NSManagedObject * stylist = [appointment valueForKey:@"stylist"];
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"stylist == %@ AND time > $BEGINNING AND time < $END", stylist];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	[appointmentRequest setEntity:apptDescription];
	[appointmentRequest setPredicate:predicate];
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:appointmentRequest error:&error]];
	NSLog(@"executing Fetch appointment");
	
	NSPredicate * timePredicate = [NSPredicate predicateWithFormat:@"time > %@", [appointment valueForKey:@"time"]];
	NSSortDescriptor * timeSort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
	[results filterUsingPredicate:timePredicate];
	[results sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
	[timeSort release];
	if ([results count] > 0)	{
		NSDate * lateBound = [[results objectAtIndex:0] valueForKey:@"time"];
		
		NSDate * appointmentEnd = [appointment valueForKey:@"time"];
		appointmentEnd = [appointmentEnd addTimeInterval:newLength*60];
		if ([appointmentEnd timeIntervalSinceDate:lateBound] > 0)	{
			NSRunAlertPanel(@"Warning", @"The selected appointment length is too long. Please try again with a shorter time.", @"OK", nil, nil);
		} else	{
			[appointment setValue:[NSNumber numberWithInt:[newLengthField intValue]] forKey:@"appointmentLength"];
		}
		
		
	} else	{
		[appointment setValue:[NSNumber numberWithInt:[newLengthField intValue]] forKey:@"appointmentLength"];
		
	}
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	NSDate * time = [appointment valueForKey:@"time"];
	
	[self changeDateOnMainPage];
	[pageView selectAppointmentForTime:time withStylist:stylist];
	
	[changeApptLengthWindow close];
}
-(void)removeAppointment:(NSManagedObject *)password
{
	if ([password valueForKey:@"passwordLevel"] != nil)	{
		int passwordLevel = [[password valueForKey:@"passwordLevel"] intValue];
		id test = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordLevelsPath];
		
		if (passwordLevel >= [[test valueForKey:@"changeScheduleLevel"] intValue] )	{
			BuildingBlock * block = [pageView selectedBlock];
			id appointment = [block appointment];
			
			
			if ([[appointment className] compare:@"NSManagedObject"] == NSOrderedSame)	{
					
				
				[block removeFromSuperview];
				[block setAppointment:nil];
				
				[moc deleteObject:appointment];
				error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
				[pageView refreshBlocks];
				
			} else	{
				[pageView removeSelectedAppointment];
				[self changeDateOnMainPage];
			}
			
			
		}
	}
		
}
-(IBAction)removeAppointmentAction:(id)sender
{
	id appointment = [[pageView selectedBlock] appointment];
	if ([appointment valueForKey:@"client"] == nil)	{
		SEL selector = @selector(removeAppointment:);
		[passwordController getPasswordFor:self arguments:nil selector:selector];
	} else	{
		NSRunAlertPanel(@"Cannot Remove Appointment Block", @"Please cancel appointment to be able to remove the appointment block" , @"OK", nil, nil);
	}
}
-(void)stylistClicked:(NSEvent *)aEvent sender:(id)sender
{
	ResistantScroller * headers = sender;

	
	int clickCount = [aEvent clickCount];
	if (clickCount == 2)	{
		// get stylist 
		
		NSPoint hitPoint =  [sender convertPoint:[aEvent locationInWindow] fromView:sender];
		NSView * hit = [sender hitTest:hitPoint];
		if (hit == [sender contentView])	{
			[self addScheduleForStylist:self];
		
		} else	{
			
			if ([[hit className] compare:@"BuildingTextField"] == NSOrderedSame)	{
				[self viewStylistDay:[hit stringValue]];
			}
		}
		
		
		
		
	}
}
-(void)viewStylistDay:(NSString *)aStylist
{
	
	// get appointments for day
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSManagedObject * stylist;
	stylist = [[staffController workingServiceProviders:workingDate] objectAtIndex:0];
	
														
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END AND stylist == %@", stylist];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	NSFetchRequest * appointmentRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * apptDescription = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
	[appointmentRequest setEntity:apptDescription];
	[appointmentRequest setPredicate:predicate];
	
	NSMutableArray * appointments = [NSMutableArray arrayWithArray:[moc executeFetchRequest:appointmentRequest error:&error]];
	NSLog(@"executing Fetch appointment");
	
	if ([appointments count] == 0)	{
		NSMutableString * message  = [NSMutableString string];;
		NSString * dayKey = [[[mainDatePicker dateValue] dateWithCalendarFormat:@"%A" timeZone:nil] description];
		NSString * worksTodayPath = [NSString stringWithFormat:@"bookingSchedule.works%@", dayKey];
		
		BOOL worksToday = [[stylist valueForKeyPath:worksTodayPath] boolValue];
		if (worksToday)	{
			NSString * startTimePath = [NSString stringWithFormat:@"bookingSchedule.first%@", dayKey];
			NSString * finishTimePath = [NSString stringWithFormat:@"bookingSchedule.last%@", dayKey];
			NSCalendarDate * startTime = [[stylist valueForKeyPath:startTimePath] dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
			NSCalendarDate * lastTime = [[stylist valueForKeyPath:finishTimePath] dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
			[message appendFormat:@"%@ works today.  First appointment: %@\nLast appointment: %@", aStylist, startTime, lastTime];
		} else	{
			[message appendFormat:@"%@ does not work today", aStylist];
		}
		NSRunAlertPanel(@"No Scheduled Appointments", message, @"OK", nil, nil);
	} else	{
		NSSortDescriptor * timeSort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
		[appointments sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
		[stylistDayArrayController setContent:appointments];	
		[stylistDayWindow makeKeyAndOrderFront:self];
		[timeSort release];
	}
}
-(IBAction)goToTransferAppointmentAction:(id)sender
{
	[transferRescheduleWindow setTitle:@"Advanced Appointment Window"];
	[transferRescheduleButton setTitle:@"Make Future Appointment"];
	[availableAppointmentsViewForTransfer setSubviews:[NSArray array]];
	cancelAfterTransfer = NO;
	// check for client value
	if ([[[pageView selectedBlock] appointment] valueForKey:@"client"] != nil)	{
		[self setUpTransferRescheduleWindow];
	} else	{
		NSRunAlertPanel(@"Warning", @"Please select a booked appointment in order to set an advance appointment", @"OK", nil, nil);
	}
}
-(IBAction)goToRescheduleAppointmentAction:(id)sender
{
	[transferRescheduleWindow setTitle:@"Reschedule Appointment Window"];
	[transferRescheduleButton setTitle:@"Reschedule Appointment"];
	[availableAppointmentsViewForTransfer setSubviews:[NSArray array]];
	cancelAfterTransfer = YES;
	if ([[[pageView selectedBlock] appointment] valueForKey:@"client"] != nil)	{
		if ([[[pageView selectedBlock] appointment] valueForKeyPath:@"transaction.collectedBy"] == nil)	{
			
			[self setUpTransferRescheduleWindow];
		} else	{
			NSRunAlertPanel(@"Warning", @"Cannot reschedule an appointment that has been checked out", @"OK", nil, nil);
		}
	} else	{
		NSRunAlertPanel(@"Warning", @"Please select a booked appointment in order to reschedule", @"OK", nil, nil);
	}
	
}
-(void)setUpTransferRescheduleWindow
{
	// set up window, with just stylists that take appointments
	NSMutableArray * stylists = [staffController workingServiceProviders:[NSDate date]];
	
	int stylistsCount = [stylists count];
	
	int row;
	int column;
	column = 0;
	int maxColumn = 3; // 
	
	double rowssNeeded = stylistsCount+1;
	rowssNeeded = rowssNeeded / 3;
	int rowsNeeded = rowssNeeded;
	double difference = rowssNeeded - rowsNeeded;
	if (difference > 0)	{
		rowsNeeded++;
	}
	double stylistHeight = BUTTONHEIGHT * rowsNeeded + 40;
	NSRect stylistViewFrame = [stylistViewForTransfer frame];
	
	difference = stylistViewFrame.size.height - stylistHeight;
	if (difference < 0)	{
		stylistViewFrame.origin.y = -difference;
		stylistViewFrame.size.height = stylistHeight;
	} else	{
		stylistHeight = stylistViewFrame.size.height;
	}
	int counter = 0;
	[stylistViewForTransfer setFrame:stylistViewFrame];
	NSMutableArray * subviews = [NSMutableArray array];
	for (row = 0 ; row < rowsNeeded; row++)	{
		for (column = 0; column < maxColumn; column++)	{
			NSButton * newButton = [[[NSButton alloc] init] autorelease];
			NSRect newFrame = [newButton frame];
			newFrame.origin.x = 20 + column*BUTTONWIDTH;
			newFrame.origin.y = stylistHeight - 20 - ((row+1)*BUTTONHEIGHT);
			newFrame.size.height = BUTTONHEIGHT;
			newFrame.size.width = BUTTONWIDTH;
			[newButton setFrame:newFrame];
			[newButton setBezelStyle:6];
			
			[newButton setTitle:[[stylists objectAtIndex:counter] valueForKey:@"name"]];
			[newButton setTarget:self];
			[newButton setAction:@selector(stylistSelectedOnTransferRescheduleWindow:)];
			[newButton setButtonType:1];
			[subviews addObject:newButton];
			// raise counter for the test, after ++ counter represents stylists taken care of
			counter++;
			if (counter == stylistsCount)	{
				row = rowsNeeded;
				column = maxColumn;
			}
		}
		
	}
	[stylistViewForTransfer setSubviews:subviews];
	
	[transferRescheduleWindow makeKeyAndOrderFront:self];
}
-(void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	if ([aNotification object] == waitlistTable)	{
		NSString * string = [[[aNotification userInfo] valueForKey:@"NSFieldEditor"] string];

		NSArray * matches = [clientDatabase clientsMatchingName:string];
		if ([matches count] == 1)	{
			NSMutableString * message = [NSMutableString stringWithString:@""];
			int choice = NSRunAlertPanel(@"Client Found", message, @"OK", @"No Thanks", nil);
			if (choice == 1)	{
				NSManagedObject * client = [matches objectAtIndex:0];
				NSMutableDictionary * entry = [[waitlistController selectedObjects] objectAtIndex:0];
				NSString * workingVariable = [client valueForKey:@"mobilePhone"];
				if (workingVariable)	{
					[entry setValue:workingVariable forKey:@"mobilePhone"];
				} else	{
					[entry removeObjectForKey:@"mobilePhone"];
				}
				workingVariable = [client valueForKey:@"homePhone"];
				if (workingVariable)	{
					[entry setValue:workingVariable forKey:@"homePhone"];
				} else	{
					[entry removeObjectForKey:@"homePhone"];
				}
				workingVariable = [client valueForKey:@"workPhone"];
				if (workingVariable)	{
					[entry setValue:workingVariable forKey:@"workPhone"];
				} else	{
					[entry removeObjectForKey:@"workPhone"];
				}
			}

			
		}
		[self saveWaitlist];

	}
}
-(void)textDidEndEditing:(NSNotification *)aNotification
{
	if ([aNotification object] == waitlistDescription)	{
		//NSMutableDictionary * entry = [[waitlistController selectedObjects] objectAtIndex:0];
		//[entry setValue:[waitlistDescription string] forKey:@"description"];
		[self saveWaitlist];
	}
}
-(void)controlTextDidChange:(NSNotification *)aNotification
{
	id sender = [aNotification object];

	// formats input
	if ([aNotification object] == clientField)	{
		char space = ' ';
		
		NSMutableString * mstring = [NSMutableString stringWithString:[clientField stringValue]];
		BOOL lastTest = NO;
		NSRange thisRange = NSMakeRange(0, 1);
		[mstring replaceCharactersInRange:thisRange withString:[[mstring substringWithRange:thisRange] uppercaseString]];
		int i;
		for (i=1; i< [mstring length]; i++)	{
			if (lastTest == YES)	{
				//replace char, with uppercase
				
				thisRange = NSMakeRange(i, 1);
				[mstring replaceCharactersInRange:thisRange withString:[[mstring substringWithRange:thisRange] uppercaseString]];
				lastTest = NO;
			}
			
			if ([mstring characterAtIndex:i] == space)	{
				lastTest = YES;
			}
		} 
		
		[clientField setStringValue:mstring];
	}  else if ([aNotification object] == mobilePhoneField || [aNotification object] == homePhoneField || [aNotification object] == workPhoneField || [aNotification object] == bookWithPhone)	{
		
		NSDictionary * preferences = [NSKeyedUnarchiver unarchiveObjectWithFile:preferencesPath];
		
		NSMutableString * number = [NSMutableString stringWithString:[sender stringValue]];
		NSRange range;
		if ([[preferences valueForKey:@"phoneFormat"] compare:@"phoneDash"] == NSOrderedSame)	{
			
			range = NSMakeRange(0, [number length]);
			[number replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
			range = NSMakeRange(0, [number length]);
			[number replaceOccurrencesOfString:@"-" withString:@"" options:NSLiteralSearch range:range];
			
			if ([number length] == 7)	{
				[number insertString:@"-" atIndex:3];
				[sender setStringValue:number];
			} else if ([number length] == 10)	{
				[number insertString:@"-" atIndex:6];
				[number insertString:@"-" atIndex:3];
				[sender setStringValue:number];
			} else if ([number length] == 11)	{
				[number insertString:@"-" atIndex:7];
				[number insertString:@"-" atIndex:4];
				[number insertString:@"-" atIndex:1];
				[sender setStringValue:number];
			}
		}
		if ([[preferences valueForKey:@"phoneFormat"] compare:@"phoneSpaces"] == NSOrderedSame)	{
			range = NSMakeRange(0, [number length]);
			[number replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
			range = NSMakeRange(0, [number length]);
			[number replaceOccurrencesOfString:@"-" withString:@"" options:NSLiteralSearch range:range];
			
			if ([number length] == 7)	{
				[number insertString:@" " atIndex:3];
				[sender setStringValue:number];
			} else if ([number length] == 10)	{
				[number insertString:@" " atIndex:6];
				[number insertString:@" " atIndex:3];
				[sender setStringValue:number];
			} else if ([number length] == 11)	{
				[number insertString:@" " atIndex:7];
				[number insertString:@" " atIndex:4];
				[number insertString:@" " atIndex:1];
				[sender setStringValue:number];
			}
		}
		if ([[preferences valueForKey:@"phoneFormat"] compare:@"phoneNoSpaces"] == NSOrderedSame)	{
			range = NSMakeRange(0, [number length]);
			[number replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
			range = NSMakeRange(0, [number length]);
			[number replaceOccurrencesOfString:@"-" withString:@"" options:NSLiteralSearch range:range];
			
			[sender setStringValue:number];
		}
	}
	
	// autopopulate the client match fields
	
	if ([aNotification object] == bookWithName)	{
		if ([[sender stringValue] length] > 0)	{

			NSMutableArray * clients = [clientDatabase clientsMatchingName:[bookWithName stringValue]];
			[clientsToChooseFrom setContent:clients];
		}
				
	} else	if ([aNotification object] == bookWithPhone)	{
		NSMutableArray * clients = [clientDatabase clientsMatchingPhone:[bookWithPhone stringValue]];
		[clientsToChooseFrom setContent:clients];
			
	} else if ([aNotification object] == creditField)	{
		[self creditFieldEntered:self];
		
	}

}
-(void)stylistSelectedOnTransferRescheduleWindow:(id)sender
{
	weeksAheadInFetch = 0;
	int i;
	NSArray * subviews = [stylistViewForTransfer subviews];
	int subviewsCount = [subviews count];
	if ([sender state] == 1)	{
		for (i=0; i< subviewsCount; i++)	{
			if ([[subviews objectAtIndex:i] state] == 1)	{
				if ([subviews objectAtIndex:i] != sender)	{
					[[subviews objectAtIndex:i] setState:0];
				}
			}
		}
		
		selectedStylistButtonForTransfer = sender;
		// just 1 stylistSelected
		[selectedStylistNameForTransfer setStringValue:[selectedStylistButtonForTransfer title]];
		[self fetchAvailableAppointmentsForStylist];
	} else	{
		[selectedStylistNameForTransfer setStringValue:@""];
	}
	
}
-(IBAction)viewNextDayOnTransfer:(id)sender
{
	
}
-(IBAction)viewNextWeekOnTranser:(id)sender
{
	
}
-(void)fetchAvailableAppointmentsForStylist
{ 
	self.availableAppointmentsForTransfer = [NSMutableArray array];
	NSCalendarDate * workingDate = [[NSDate date] dateWithCalendarFormat:@"%a. %b. %d, %Y" timeZone:nil];
	
	NSMutableArray * stylists = [staffController workingServiceProviders:workingDate];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name == %@", [selectedStylistNameForTransfer stringValue]];
	[stylists filterUsingPredicate:predicate];
	// get 15 weeks worth of appointments
	NSFetchRequest * appointmentRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * apptDescription = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
	
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	NSCalendarDate * endOfDay = [beginningOfDay dateByAddingYears:0 months:0 days:15*7 hours:0 minutes:0 seconds:0];
	predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END AND stylist == %@", [stylists objectAtIndex:0]];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	[appointmentRequest setEntity:apptDescription];
	[appointmentRequest setPredicate:predicate];
	
	NSArray * allAppointments = [moc executeFetchRequest:appointmentRequest error:&error];
	NSLog(@"executing Fetch appointment");
	
	int daysAhead;
	for (daysAhead = 0; daysAhead < 15*7; daysAhead++)	{
		NSMutableArray * daysResults = [NSMutableArray arrayWithArray:allAppointments];
		NSCalendarDate * beginning = [beginningOfDay dateByAddingYears:0 months:0 days:daysAhead hours:0 minutes:0 seconds:0];
		NSCalendarDate * end = [beginning dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"stylist == %@ AND time > $BEGINNING AND time < $END", [stylists objectAtIndex:0]];
		predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginning , @"BEGINNING",end, @"END", nil]];
		
		
		[daysResults filterUsingPredicate:predicate];
		if ([daysResults count] > 0)	{
			NSSortDescriptor * timeSort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
			[daysResults sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
			[timeSort release];
			[availableAppointmentsForTransfer addObjectsFromArray:daysResults];
		} else	{
			[availableAppointmentsForTransfer addObjectsFromArray:[self blankScheduleForStylist:[stylists objectAtIndex:0] date:beginning]];
		}
	}	
	

	// now load interface, show all appointments on day.  //
	NSSortDescriptor * timeSort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];

	[availableAppointmentsForTransfer sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
	[timeSort release];
	NSMutableArray * subviews = [NSMutableArray array];	
	int dayOfMonth = [workingDate dayOfMonth];
	int i;
	int apptCount = [availableAppointmentsForTransfer count];
	
	float apptViewHeight = 40 + (CHECKBOXHEIGHT* apptCount) +(CHECKBOXVERTICALSPACING*(apptCount-1)) + (15*7* 17)+((15*7)*40);
	NSRect frame = [availableAppointmentsViewForTransfer frame];
	frame.size.height = apptViewHeight;
	[availableAppointmentsViewForTransfer setFrame:frame];
	
	NSTextField * label = [[[NSTextField alloc] initWithFrame:NSMakeRect(20,20, 130, 17)] autorelease];
	[label setBackgroundColor:[transferRescheduleWindow backgroundColor]];
	[label setBordered:NO];
	[label setObjectValue:workingDate];
	[label setEditable:NO];
	[label setTag:-1];
	NSRect labelFrame = [label frame];
	labelFrame.origin.x = 20;
	float yValue = apptViewHeight - 20 - 17;
	labelFrame.origin.y = yValue;
	[label setFrame:labelFrame];
	[subviews addObject:label];
	// want to scroll to top of pages
	NSView * makeVisible = [label retain]; 
	
	
	
	BOOL first = YES;
	for (i=0; i< [availableAppointmentsForTransfer count]; i++)	{
		workingDate = [[[availableAppointmentsForTransfer objectAtIndex:i] valueForKey:@"time"] dateWithCalendarFormat:@"%a. %b. %d, %Y" timeZone:nil];
		
		if (dayOfMonth == [workingDate dayOfMonth])	{
			id appointment = [availableAppointmentsForTransfer objectAtIndex:i];
			NSButton * newButton = [[[NSButton alloc] init] autorelease];
			if (first)	{
				yValue = yValue - 20 - CHECKBOXHEIGHT;
				first = NO;
			} else	{
				yValue = yValue - CHECKBOXVERTICALSPACING - CHECKBOXHEIGHT;
			
			}
			[newButton setTag:i];
			NSCalendarDate * time = [[appointment valueForKey:@"time"] dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
			[newButton setTitle:[time description]];
			
			//check for availability
			BOOL openTest = YES;
			if ([[appointment className] compare:@"NSManagedObject"] == NSOrderedSame)	{
				if ([appointment valueForKeyPath:@"client.name"] != nil)	{
					openTest = NO;
				}
			}
			if (openTest == NO)	{
				[newButton setAllowsMixedState:YES];
				[newButton setState:NSMixedState];
				[newButton setEnabled:NO];
			}
			[newButton setButtonType:NSSwitchButton];
			frame = [newButton frame];
			frame.origin.x = 40;
			frame.origin.y = yValue;
			frame.size.height = CHECKBOXHEIGHT;
			frame.size.width = CHECKBOXWIDTH;
			[newButton setFrame:frame];

			[subviews addObject:newButton];
		} else	{
			dayOfMonth = [workingDate dayOfMonth];
			first = YES;
			yValue -= (20 + 17);
			
			label = [[NSTextField alloc] initWithFrame:NSMakeRect(20,20, 130, 17)];
			[label setBackgroundColor:[transferRescheduleWindow backgroundColor]];
			[label setBordered:NO];
			[label setTag:-1];
			[label setObjectValue:workingDate];
			[label setEditable:NO];
			NSRect labelFrame = [label frame];
			labelFrame.origin.x = 20;
			
			labelFrame.origin.y = yValue;
			[label setFrame:labelFrame];
			[subviews addObject:label];
			[label release];
			
			
			// calculate days and weeks ahead
			NSCalendarDate * startOfToday = [[NSDate date] dateWithCalendarFormat:@"" timeZone:nil];
			int hours, minutes, seconds;
			hours = [startOfToday hourOfDay];
			minutes = [startOfToday minuteOfHour];
			seconds = [startOfToday secondOfMinute];
			startOfToday = [startOfToday dateByAddingYears:0 months:0 days:0 hours:-hours minutes:-minutes seconds:-seconds];
			
			int days = [workingDate timeIntervalSinceDate:startOfToday];
			days = days/(60*60*24);
			int weeks = days/7;
			NSMutableString * timeAhead = [NSMutableString string];
			if (weeks > 1)	{
				[timeAhead appendFormat:@"%d weeks", weeks];
				days = days - (7*weeks);
				if (days > 1)	{
					[timeAhead appendFormat:@" and %d days from today", days];
				} else if (days > 0)	{
					[timeAhead appendFormat:@" and %d day from today", days];
				} else	{
					[timeAhead appendString:@" from today"];
				}
			} else	if (weeks > 0)	{
				[timeAhead appendFormat:@"%d week", weeks];
				days = days - (7*weeks);
				if (days > 1)	{
					[timeAhead appendFormat:@" and %d days from today", days];
				} else if (days > 0)	{
					[timeAhead appendFormat:@" and %d day from today", days];
				} else	{
					[timeAhead appendString:@" from today"];
				}
			} else	if(weeks == 0)	{
				if (days > 1)	{
					[timeAhead appendFormat:@"%d days from today", days];
				} else if (days > 0)	{
					[timeAhead appendFormat:@"%d day from today", days];
				} else	{
					[timeAhead appendString:@" from today"];
				}
			}
			label = [[NSTextField alloc] initWithFrame:NSMakeRect(20,20, 200, 17)];// changed 130 to 200 just in case space is needed
			[label setBackgroundColor:[transferRescheduleWindow backgroundColor]];
			[label setBordered:NO];
			[label setTag:-1];
			[label setStringValue:timeAhead];
			[label setEditable:NO];
			labelFrame = [label frame];
			labelFrame.origin.x = 150;
			
			labelFrame.origin.y = yValue;
			[label setFrame:labelFrame];
			[subviews addObject:label];
			[label release];
			
			id appointment = [availableAppointmentsForTransfer objectAtIndex:i];
			
			NSButton * newButton = [[[NSButton alloc] init] autorelease];
			yValue = yValue - 20 - CHECKBOXHEIGHT;
			first = NO;
			[newButton setTag:i];
			NSCalendarDate * time = [[appointment valueForKey:@"time"] dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
			[newButton setTitle:[time description]];
			if ([appointment valueForKey:@"bookedBy"] != nil || [appointment valueForKey:@"parentAppointment"] != nil)	{
				[newButton setAllowsMixedState:YES];
				[newButton setState:NSMixedState];
				[newButton setEnabled:NO];
			}
			[newButton setButtonType:NSSwitchButton];
			frame = [newButton frame];
			frame.origin.x = 40;
			frame.origin.y = yValue;
			frame.size.height = CHECKBOXHEIGHT;
			frame.size.width = CHECKBOXWIDTH;
			[newButton setFrame:frame];
			
			[subviews addObject:newButton];
		}
	}
	
	[availableAppointmentsViewForTransfer setSubviews:subviews];
	[availableAppointmentsViewForTransfer scrollRectToVisible:[makeVisible frame]];
	[makeVisible release];
	
}
-(NSString *)clientDescription:(NSManagedObject *)client
{
	NSMutableString * string = [NSMutableString string];

	id workingVariable = [client valueForKey:@"name"];
	if (workingVariable != nil)	{
		[string appendFormat:@"%@\n", workingVariable];
	}
	workingVariable = [client valueForKey:@"homePhone"];
	if (workingVariable != nil)	{
		[string appendFormat:@"Home: %@\n", workingVariable];
	}
	workingVariable = [client valueForKey:@"workPhone"];
	if (workingVariable != nil)	{
		[string appendFormat:@"Work: %@\n", workingVariable];
	}
	workingVariable = [client valueForKey:@"mobilePhone"];
	if (workingVariable != nil)	{
		[string appendFormat:@"Mobile: %@\n", workingVariable];
	}
	workingVariable = [client valueForKey:@"email"];
	if (workingVariable != nil)	{
		[string appendFormat:@"Email: %@\n\n", workingVariable];
	}
	
	return string;
}
-(IBAction)transferOrRescheduleAppointment:(id)sender
{
	[self refreshAppointmentsToBook];
	if ([appointmentsToBook count] > 0	)	{
		if (!cancelAfterTransfer)	{
			if ([[transferRescheduleButton title] compare:@"Schedule Appointment"] == NSOrderedSame)	{
				NSString * clientString = [[[waitlistController selectedObjects] objectAtIndex:0] valueForKey:@"client"];
				NSManagedObject * client = [[clientDatabase clientsMatchingName:clientString] objectAtIndex:0];
				NSMutableString * message = [NSMutableString string];
				[message appendFormat:@"Use client: %@", [self clientDescription:client]];
				//set up alert panel...
				[message appendFormat:@"***\n *\n***\n\nwith stylist: %@\nto book following times:\n\n", [selectedStylistButtonForTransfer title]];
				
				
				int i;
				for (i=0; i < [appointmentsToBook count]; i++)	{
					NSCalendarDate * targetTime = [[[appointmentsToBook objectAtIndex:i] valueForKey:@"time"] dateWithCalendarFormat:@"%I:%M %p\t%a. %b. %d, %Y" timeZone:nil];
					[message appendFormat:@"%@\n", targetTime];
				}
				[message appendString:@"No services will be set.  Please make sure to check desired services and book enough time."];
				int choice = NSRunAlertPanel(@"Scheduling Advance Appointment", message, @"OK", @"Cancel", nil);
				if (choice == 1)	{
					
					SEL selector = @selector(transferAdvanceData:);
					[employeeSelect selectEmployeeFor:self selector:selector windowTitle:@"Who Are You?"];
					
					
				} 
				
			} else	{
				
				NSMutableString * message = [NSMutableString string];
				[message appendFormat:@"Use client: %@", [self clientDescription:[[[pageView selectedBlock] appointment] valueForKey:@"client"]]];
				
				//set up alert panel...
				[message appendFormat:@"***\n *\n***\n\nwith stylist: %@\nto book following times:\n\n", [selectedStylistButtonForTransfer title]];
				
				
				int i;
				for (i=0; i < [appointmentsToBook count]; i++)	{
					NSCalendarDate * targetTime = [[[appointmentsToBook objectAtIndex:i] valueForKey:@"time"] dateWithCalendarFormat:@"%I:%M %p\t%a. %b. %d, %Y" timeZone:nil];
					[message appendFormat:@"%@\n", targetTime];
				}
				[message appendString:@"No services will be set.  Please make sure to check desired services and book enough time."];
				int choice = NSRunAlertPanel(@"Scheduling Advance Appointment", message, @"OK", @"Cancel", nil);
				if (choice == 1)	{
					
					SEL selector = @selector(transferAdvanceData:);
					[employeeSelect selectEmployeeFor:self selector:selector windowTitle:@"Who Are You?"];
					
					
				} 
			
			
			} 
				}else	{
			
			id appointment = [[pageView selectedBlock] appointment];
			if ([[appointment className] compare:@"NSManagedObject"] == NSOrderedSame)	{
				if ([appointment valueForKeyPath:@"transaction.collectedBy"] == nil)	{
					NSMutableString * message = [NSMutableString string];
					[message appendFormat:@"Rescheduling following appointment:\n %@", [self appointmentDescriptionForTransfer]];
					int i;
					[message appendFormat:@"***\n *\n***\n\nto following times:\n\n"];
					
					for (i=0; i < [appointmentsToBook count]; i++)	{
						NSCalendarDate * targetTime = [[[appointmentsToBook objectAtIndex:i] valueForKey:@"time"] dateWithCalendarFormat:@"%I:%M %p\t%a. %b. %d, %Y" timeZone:nil];
						[message appendFormat:@"%@\n", targetTime];
					}
					[message appendString:@"\nAny selected services will transfer, please be sure to book any extra time needed after the data has transfered."];
					int choice = NSRunAlertPanel(@"Cancelling Appointment", message, @"OK", @"Cancel", nil);
					
					
					
					if (choice == 1)	{
						
						SEL selector = @selector(transferRescheduleData:);
						[employeeSelect selectEmployeeFor:self selector:selector windowTitle:@"Who Are You?"];
						
						
					} 
					
				}
				else	{
					NSRunAlertPanel(@"Unable To Transfer Data", @"The selected appointment has been checked out.\nIf you wish to make a future appointment use the Advance Appointment button" , @"OK", nil,nil);
				}
			}
			
			
		}
	} else	{
		NSRunAlertPanel(@"No Times Selected", @"Please select a target appointment", @"OK", nil, nil);
	}
}
-(void)cancelAppointmentForReschedule:(NSManagedObject *)appointment
{
	NSString * message = [self appointmentDescription:appointment];

	NSManagedObject * client = [appointment valueForKey:@"client"];
	
	NSDate * time = [appointment valueForKey:@"time"];
	NSManagedObject * stylist = [appointment valueForKey:@"stylist"];
	NSMutableDictionary * cancellation = [NSMutableDictionary dictionary];
	NSArray * services = [[appointment valueForKey:@"services"] allObjects];
	
	NSMutableString * serviceDescription = [NSMutableString string];
	
	int choice = NSRunAlertPanel(@"Cancelling Appointment", message, @"OK", @"Cancel", nil);
	if (choice == 1)	{
		id childrenObject = [appointment valueForKey:@"childAppointments"];
		NSArray * children = [NSArray arrayWithArray:[childrenObject allObjects]];
		[appointment setValue:nil forKey:@"childAppointments"];


		NSNumber * appointmentLength = [appointment valueForKey:@"appointmentLength"];
		
		[moc deleteObject:appointment];
		NSManagedObject * newAppointment = [NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:moc];
		[newAppointment setValue:appointmentLength forKey:@"appointmentLength"];
		[newAppointment setValue:time forKey:@"time"];
		[newAppointment setValue:stylist forKey:@"stylist"];
		
		if ([[client valueForKey:@"appointments"] count] == 0)	{
			[moc deleteObject:client];
		}
		
		int i;
		
		NSArray * subviews = [pageView subviews];
		for (i=0; i < [subviews count]; i++)	{
			id subview = [subviews objectAtIndex:i];
			if ([[subview className] compare:@"BuildingBlock"] == NSOrderedSame)	{
				if ([subview appointment] == appointment)	{
					[subview setAppointment:newAppointment];
					[subview updateDisplay];
				}
				
			}
		}
		
		int j;
		for (j= 0; j < [children count]; j++)	{
			appointment = [children objectAtIndex:j];
			time = [appointment valueForKey:@"time"];
			stylist = [appointment valueForKey:@"stylist"];
			appointmentLength = [appointment valueForKey:@"appointmentLength"];
			
			
			NSManagedObject * newAppointment = [NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:moc];
			[newAppointment setValue:appointmentLength forKey:@"appointmentLength"];
			[newAppointment setValue:time forKey:@"time"];
			[newAppointment setValue:stylist forKey:@"stylist"];
			
			for (i=0; i < [subviews count]; i++)	{
				id subview = [subviews objectAtIndex:i];
				if ([[subview className] compare:@"BuildingBlock"] == NSOrderedSame)	{
					if ([subview appointment] == appointment)	{
						[subview setAppointment:newAppointment];
						[subview updateDisplay];
					}
					
				}
			}
			[moc deleteObject:appointment];
			
		}
		
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
		for (i=0 ; i < [services count]; i++)	{
			[serviceDescription appendFormat:@"%@, ", [[services objectAtIndex:i] valueForKey:@"serviceDescription"]];
		}
		
		[cancellation setObject:time forKey:@"appointmentTime"];
		[cancellation setObject:[NSDate date] forKey:@"cancellationTime"];
		[cancellation setObject:[stylist valueForKey:@"name"] forKey:@"stylist"];
		[cancellation setObject:[client valueForKey:@"name"] forKey:@"client"];
		[cancellation setObject:serviceDescription forKey:@"serviceDescription"];
		[cancellation setObject:@"yes" forKey:@"rescheduled"];
		id test = [NSKeyedUnarchiver unarchiveObjectWithFile:self.cancellationsPath];
		NSMutableArray * cancellations = [NSMutableArray array];
		if (test != nil)	{
			[cancellations setArray:test];
		}
		if ([cancellations count] > 0)	{
			[cancellations insertObject:cancellation atIndex:0];
		} else	{
			[cancellations addObject:cancellation];
		}
		[NSKeyedArchiver archiveRootObject:cancellations toFile:self.cancellationsPath];
	}		
}
-(void)transferAdvanceData:(NSManagedObject *)employee
{
	NSManagedObject * client;
	if ([[transferRescheduleButton title] compare:@"Schedule Appointment"] == NSOrderedSame)	{
		NSString * clientString = [[[waitlistController selectedObjects] objectAtIndex:0] valueForKey:@"client"];
		client = [[clientDatabase clientsMatchingName:clientString] objectAtIndex:0];
		[waitlistController removeObject:[[waitlistController selectedObjects] objectAtIndex:0]];
	} else	{
		id baseAppointment = [[pageView selectedBlock] appointment];
		client = [baseAppointment valueForKey:@"client"];
	}
	int i;
	
	
	NSMutableArray * stylists = [staffController workingServiceProviders:[NSDate date]];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name == %@", [selectedStylistNameForTransfer stringValue]];
	[stylists filterUsingPredicate:predicate];
	NSString * signature = [employee valueForKey:@"signature"];
	if (signature == nil)	{
		signature = [employee valueForKey:@"name"];
	}
	
	NSManagedObject * stylist = [stylists objectAtIndex:0];
	
	//
	NSString * upgradeString = @"a";
	NSManagedObject * lastBooked = nil;
	NSMutableString * lastString = [NSMutableString stringWithString:@"a"];
	for ( i=0; i< [appointmentsToBook count]; i++)	{
		id appointment = [appointmentsToBook objectAtIndex:i];
		NSString * newDayString = [[[appointment valueForKey:@"time"] dateWithCalendarFormat:@"%m%d%y" timeZone:nil] description];
		
		if ([[appointment className] compare:@"NSManagedObject"] != NSOrderedSame)	{
			if ([upgradeString compare:newDayString] != NSOrderedSame)	{
				[self upgradeStylistDayForAppointment:appointment];
				
			} 
			
			upgradeString = newDayString;
			
			NSDate * time = [appointment valueForKey:@"time"];
			NSDate * beginningOfDay = [time addTimeInterval:-60];
			NSDate * endOfDay = [time addTimeInterval:60];
			
			
			NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END AND stylist == %@", stylist];
			predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
			NSEntityDescription * apptDescription = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
			NSFetchRequest * appointmentRequest = [[[NSFetchRequest alloc] init] autorelease];
			[appointmentRequest setEntity:apptDescription];
			[appointmentRequest setPredicate:predicate];
			NSArray * results = [moc executeFetchRequest:appointmentRequest error:&error];
			NSLog(@"executing Fetch appointment");
			appointment = [results objectAtIndex:0];
			
		}
		
		[appointment setValue:client forKey:@"client"];
		[appointment setValue:stylist forKey:@"stylist"];
		[appointment setValue:[NSDate date] forKey:@"dateBooked"];
		
		if (lastBooked == nil)	{
			[appointment setValue:signature forKey:@"bookedBy"];
			lastBooked = appointment;
			
		}
		NSString * bookingString = [[[appointment valueForKey:@"time"] dateWithCalendarFormat:@"%m%d%y" timeZone:nil] description];
		if ([bookingString compare:lastString] == NSOrderedSame)	{
			[appointment setValue:lastBooked forKey:@"parentAppointment"];
		} else	{
			[appointment setValue:signature forKey:@"bookedBy"];
		}
		lastBooked = appointment;
		[lastString setString:bookingString];
		[pageView refreshBlockForAppointment:[appointmentsToBook objectAtIndex:i]];										  

	}
	
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	[transferRescheduleWindow close];
}
-(void)transferRescheduleData:(NSManagedObject *)employee
{
	int i;
	int appointmentCount = [appointmentsToBook count];
	NSMutableArray * stylists = [staffController workingServiceProviders:[NSDate date]];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name == %@", [selectedStylistNameForTransfer stringValue]];
	[stylists filterUsingPredicate:predicate];
	NSString * signature = [employee valueForKey:@"signature"];
	if (signature == nil)	{
		signature = [employee valueForKey:@"name"];
	}
	NSManagedObject * baseAppointment = [[pageView selectedBlock] appointment];
	NSManagedObject * stylist = [stylists objectAtIndex:0];
	NSManagedObject * client = [baseAppointment valueForKey:@"client"];
	NSMutableSet * services = [baseAppointment valueForKey:@"services"];
	NSString * upgradeString = @"a";
	NSManagedObject * lastBooked = nil;
	NSMutableString * lastString = [NSMutableString stringWithString:@"a"];
	for ( i=0; i< [appointmentsToBook count]; i++)	{
		id appointment = [appointmentsToBook objectAtIndex:i];
		NSString * newDayString = [[[appointment valueForKey:@"time"] dateWithCalendarFormat:@"%m%d%y" timeZone:nil] description];
		
		if ([[appointment className] compare:@"NSManagedObject"] != NSOrderedSame)	{
			if ([upgradeString compare:newDayString] != NSOrderedSame)	{
				[self upgradeStylistDayForAppointment:appointment];
				
			} 
			
			upgradeString = newDayString;
			
			NSDate * time = [appointment valueForKey:@"time"];
			NSDate * beginningOfDay = [time addTimeInterval:-60];
			NSDate * endOfDay = [time addTimeInterval:60];
			
			
			NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END AND stylist == %@", stylist];
			predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
			NSEntityDescription * apptDescription = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
			NSFetchRequest * appointmentRequest = [[[NSFetchRequest alloc] init] autorelease];
			[appointmentRequest setEntity:apptDescription];
			[appointmentRequest setPredicate:predicate];
			NSArray * results = [moc executeFetchRequest:appointmentRequest error:&error];
			NSLog(@"executing Fetch appointment");
			appointment = [results objectAtIndex:0];
			
		}
		
		[appointment setValue:client forKey:@"client"];
		[appointment setValue:stylist forKey:@"stylist"];
		[appointment setValue:[NSDate date] forKey:@"dateBooked"];
		
		if (lastBooked == nil)	{
			[appointment setValue:signature forKey:@"bookedBy"];
			[appointment setValue:services forKey:@"services"];
			lastBooked = appointment;
			
		}
		NSString * bookingString = [[[appointment valueForKey:@"time"] dateWithCalendarFormat:@"%m%d%y" timeZone:nil] description];
		if ([bookingString compare:lastString] == NSOrderedSame)	{
			[appointment setValue:lastBooked forKey:@"parentAppointment"];
		} else	{
			[appointment setValue:signature forKey:@"bookedBy"];
			[appointment setValue:services forKey:@"services"];
		}
		lastBooked = appointment;
		[lastString setString:bookingString];
		
	}
	
	NSArray * pageViewSubviews = [pageView subviews];
	for (i=0; i< [pageViewSubviews count]; i++)	{
		id view = [pageViewSubviews objectAtIndex:i];
		if ([[view className] compare:@"BuildingBlock"] == NSOrderedSame)	{
			[view updateDisplay];
		}
	}
	
	[self cancelAppointmentForReschedule:baseAppointment];
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	[transferRescheduleWindow close];
}
-(IBAction)checkinAppointment:(id)sender
{
	id appointment = [[pageView selectedBlock] appointment];
	if ([[appointment className] compare:@"NSManagedObject"] == NSOrderedSame)	{
		[appointment setValue:[NSDate date] forKey:@"checkinTime"];
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	}
	[pageView selectBlock:[pageView selectedBlock]];
}
-(void)upgradeStylistDayForAppointment:(NSMutableDictionary *)appointment
{
	NSArray * day = [self blankScheduleForStylist:[appointment valueForKey:@"stylist"] date:[appointment valueForKey:@"time"]];	
	
	int i;
	for (i=0 ; i< [day count]; i++)	{
		NSManagedObject * newAppointment = [NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:moc];
		NSMutableDictionary * oldAppointment = [day objectAtIndex:i];
		[newAppointment setValue:[oldAppointment valueForKey:@"time"] forKey:@"time"];
		[newAppointment setValue:[oldAppointment valueForKey:@"stylist"] forKey:@"stylist"];
		[newAppointment setValue:[oldAppointment valueForKey:@"appointmentLength"] forKey:@"appointmentLength"];
		if ([[oldAppointment valueForKey:@"time"] timeIntervalSinceDate:[appointment valueForKey:@"time"]] == 0)	{
			[newAppointment setValue:[appointment valueForKey:@"bookedBy"] forKey:@"bookedBy"];
		}
	}
	
}
-(void)refreshAppointmentsToBook
{
	NSMutableArray * appointments = [NSMutableArray array];
	int i;
	NSArray * subviews = [availableAppointmentsViewForTransfer subviews];
	int subviewsCount = [subviews count];
	for (i=0 ; i< subviewsCount; i++)	{
		if ([[[subviews objectAtIndex:i] className] compare:@"NSButton"] == NSOrderedSame)	{
			if ([[subviews objectAtIndex:i] state] == 1)	{
				int tag = [[subviews objectAtIndex:i] tag];
				[appointments addObject:[availableAppointmentsForTransfer objectAtIndex:tag]];
			}
		}
	}
	self.appointmentsToBook = appointments;
	
}
-(void)loadConfirmations:(NSManagedObject *)employee
{
	NSString * signature = [employee valueForKey:@"signature"];
	if (signature == nil)	{
		signature = [employee valueForKey:@"name"];
	}
	
	self.confirmingSignature = signature;
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day += 3;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END AND confirmedBy == nil"];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	
	NSFetchRequest * apptRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * apptDescription = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
	NSSortDescriptor * timeSort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
	[apptRequest setEntity:apptDescription];
	[apptRequest setPredicate:predicate];
	[apptRequest setSortDescriptors:[NSArray arrayWithObject:timeSort]];
	[timeSort release];
	NSMutableArray * removeArray = [NSMutableArray array];
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:apptRequest error:&error]];
	NSLog(@"executing Fetch appointment");
	int i;
	for (i=0 ; i < [results count]; i++)	{
		NSManagedObject * appointment = [results objectAtIndex:i];
		NSString * bookedBy = [appointment valueForKey:@"bookedBy"];
		NSDate * booked = [appointment valueForKey:@"dateBooked"];
		NSDate * time = [appointment valueForKey:@"time"];
		NSTimeInterval interval = [time timeIntervalSinceDate:booked];
		
		if ([bookedBy length] > 0)	{
			// its booked
			if (interval < 3600*24*3)	{
				[removeArray addObject:appointment];
			} else	{
				// its booked over 3 days ago
				if ([appointment valueForKey:@"confirmedBy"] != nil)	{
					[removeArray addObject:appointment];
				} else	{
					id test = [NSKeyedUnarchiver unarchiveObjectWithFile:self.neverConfirmPath];
					if (test != nil)	{
						int j;
						for (j=0; j< [test count] ;j++)	{
							NSString * neverName = [test objectAtIndex:j];
							NSRange range = [[appointment valueForKeyPath:@"client.name"] rangeOfString:neverName];
							
							
							if (range.length > 0)	{
								[appointment setValue:@"Does not like confirmations" forKey:@"confirmedBy"];
								[removeArray addObject:appointment];
							}
						}
					}
				}
			}
			
		} else	{
			[removeArray addObject:appointment];
		}
		/* THIS STOPPED WORKING WHEN I TRIED TO INCORPORATE THE NEVER CONFIRM LOGIC
		 if (booked == nil)	{
		 
		 } else if ([appointment valueForKey:@"parentAppointment"] != nil)	{
		 [results removeObjectAtIndex:i];
		 i--;
		 }
		 else if (interval < 3600*24*6)	{
		 [results removeObjectAtIndex:i];
		 i--;
		 }
		 else	{
		 BOOL stillCheck = YES;
		 id test = [NSKeyedUnarchiver unarchiveObjectWithFile:self.neverConfirmPath];
		 if (test != nil)	{
		 int j;
		 for (j=0; j< [test count]; j++)	{
		 NSRange range = [[[results objectAtIndex:i] valueForKeyPath:@"client.name"] rangeOfString:[test objectAtIndex:j]];
		 int rangeLength = range.length;
		 if (rangeLength > 0)	{
		 [results setValue:@"Does not like confirmations" forKey:@"confirmedBy"];
		 [[results objectAtIndex:i] setValue:[NSNumber numberWithBool:NO] forKey:@"needsConfirmation"];
		 [results removeObjectAtIndex:i];
		 stillCheck = NO;
		 i--;
		 }
		 
		 }
		 if (stillCheck)	{
		 if ([[[results objectAtIndex:i] valueForKey:@"needsConfirmation"] boolValue] == NO)	{
		 
		 } else	{
		 [[results objectAtIndex:i] setValue:[NSNumber numberWithBool:YES] forKey:@"needsConfirmation"];
		 }
		 }
		 
		 
		 }
		 }
		 */
	
	}
	[results removeObjectsInArray:removeArray];
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	[confirmationsController setContent:[NSMutableArray arrayWithArray:results]];
	[confirmationsWindow makeKeyAndOrderFront:self];
	[self updateAppointmentDescriptionOnConfirmations];
	
}
-(void)updateAppointmentDescriptionOnConfirmations
{
	NSManagedObject * appointment = [[confirmationsController selectedObjects] objectAtIndex:0];
	
	NSString * description = [self appointmentDescription:appointment];
	NSString * string;
	if ([appointment valueForKey:@"needsConfirmation"] != nil)	{
		if ([[appointment valueForKey:@"needsConfirmation"] boolValue] == NO)	{
			string = [NSString stringWithFormat:@"***LEFT MESSAGE***\n***LEFT MESSAGE***\n***LEFT MESSAGE***\n\n\n\n\n%@", description];
		} else	{
			string = description;
		}
	} else	{
		string = description;
	}
	
	[appointmentDescriptionForConfirmations setString:string];
	
}
-(IBAction)goToConfirmationsWindow:(id)sender
{
	SEL selector = @selector(loadConfirmations:);
	[employeeSelect selectEmployeeFor:self selector:selector windowTitle:@"Who Are You?"];
	
	
}
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	if ([aNotification object] == confirmationsTable)	{
		[self updateAppointmentDescriptionOnConfirmations];
	}
}
- (void)windowDidResignMain:(NSNotification *)notification
{
	if ([notification object] == waitlistWindow)	{
		[self saveWaitlist];
	} if ([notification object] == makeAppointmentWindow)	{
		// check if appointment is full, otherwise wipe some data
		NSManagedObject * appointment = [[pageView selectedBlock] appointment];
		if ([appointment valueForKey:@"dateBooked"] == nil)	{
			NSManagedObject * client = [appointment valueForKey:@"client"];
			[appointment setValue:nil forKey:@"client"];
			[appointment setValue:nil forKey:@"bookedBy"];
		}
		
	}
}
-(IBAction)markAsConfirmed:(id)sender
{
	NSManagedObject * appointment = [[confirmationsController selectedObjects] objectAtIndex:0];
	[appointment setValue:self.confirmingSignature forKey:@"confirmedBy"];
	[confirmationsController removeObject:appointment];
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
}
-(IBAction)markThatLeftMessage:(id)sender
{
	NSManagedObject * appointment = [[confirmationsController selectedObjects] objectAtIndex:0];
	[appointment setValue:[NSNumber numberWithBool:NO] forKey:@"needsConfirmation"];
	[self updateAppointmentDescriptionOnConfirmations];
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
}

-(IBAction)goToWaitlistWindow:(id)sender
{
	id test = [NSKeyedUnarchiver unarchiveObjectWithFile:waitlistPath];
	NSMutableArray * waitlist;
	if (test != nil)	{
		waitlist = [NSMutableArray arrayWithArray:test];
	} else	{
		waitlist = [NSMutableArray array];
	}
	[waitlistController setContent:waitlist];
	[waitlistWindow makeKeyAndOrderFront:self];
}
-(IBAction)addToWaitlist:(id)sender
{
	NSMutableDictionary * waitlistEntry = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Stylist", @"stylist", @"Client", @"client", @"What the client is looking for", @"description", nil];
	[waitlistController addObject:waitlistEntry];
}
-(IBAction)removeFromWaitlist:(id)sender
{
	[waitlistController remove:self];
	[self saveWaitlist];
}
-(IBAction)scheduleAppointmentFromWaitlist:(id)sender 
{
	[transferRescheduleWindow setTitle:@"Schedule From Appointment From Waitlist"];
	[transferRescheduleButton setTitle:@"Schedule Appointment"];
	[availableAppointmentsViewForTransfer setSubviews:[NSArray array]];
	cancelAfterTransfer = NO;
	// check for client value
	
	NSMutableDictionary * entry = [[waitlistController selectedObjects] objectAtIndex:0];
	NSArray * matches = [clientDatabase clientsMatchingName:[entry valueForKey:@"client"]];

	
	if ([matches count] == 1)	{
		[self setUpTransferRescheduleWindow];
	}
}
-(void)saveWaitlist
{
	[NSKeyedArchiver archiveRootObject:[waitlistController content] toFile:waitlistPath];
}

-(IBAction)viewCancellations:(id)sender
{
	id test = [NSKeyedUnarchiver unarchiveObjectWithFile:self.cancellationsPath];
	NSMutableArray * cancellations = [NSMutableArray array];
	if (test != nil)	{
		[cancellations setArray:test];
		
	}
	[cancellationsController setContent:cancellations];
	[cancellationsWindow makeKeyAndOrderFront:self];
}
-(IBAction)goToStylistMonthPreview:(id)sender
{
	NSMutableArray * stylists = [staffController workingServiceProviders:[NSDate date]];
	
	int stylistsCount = [stylists count];
	
	int row;
	int column;
	column = 0;
	int maxColumn = 3; // 
	
	double rowssNeeded = stylistsCount+1;
	rowssNeeded = rowssNeeded / 3;
	int rowsNeeded = rowssNeeded;
	double difference = rowssNeeded - rowsNeeded;
	if (difference > 0)	{
		rowsNeeded++;
	}
	double stylistHeight = BUTTONHEIGHT * rowsNeeded + 40;
	NSRect stylistViewFrame = [stylistViewForPreview frame];
	
	difference = stylistViewFrame.size.height - stylistHeight;
	if (difference < 0)	{
		stylistViewFrame.origin.y = -difference;
		stylistViewFrame.size.height = stylistHeight;
	} else	{
		stylistHeight = stylistViewFrame.size.height;
	}
	int counter = 0;
	[stylistViewForPreview setFrame:stylistViewFrame];
	NSMutableArray * subviews = [NSMutableArray array];
	for (row = 0 ; row < rowsNeeded; row++)	{
		for (column = 0; column < maxColumn; column++)	{
			NSButton * newButton = [[[NSButton alloc] init] autorelease];
			NSRect newFrame = [newButton frame];
			newFrame.origin.x = 20 + column*BUTTONWIDTH;
			newFrame.origin.y = stylistHeight - 20 - ((row+1)*BUTTONHEIGHT);
			newFrame.size.height = BUTTONHEIGHT;
			newFrame.size.width = BUTTONWIDTH;
			[newButton setFrame:newFrame];
			[newButton setBezelStyle:6];
			
			[newButton setTitle:[[stylists objectAtIndex:counter] valueForKey:@"name"]];
			[newButton setTarget:self];
			[newButton setAction:@selector(stylistSelectedOnPreviewWindow:)];
			[newButton setButtonType:1];
			[subviews addObject:newButton];
			// raise counter for the test, after ++ counter represents stylists taken care of
			counter++;
			if (counter == stylistsCount)	{
				row = rowsNeeded;
				column = maxColumn;
			}
		}
		
	}
	[stylistViewForPreview setSubviews:subviews];
	[stylistPreviewWindow makeKeyAndOrderFront:self];
}
-(void)stylistSelectedOnPreviewWindow:(id)sender
{
	NSArray * subviews = [stylistViewForPreview subviews];
	int subviewsCount = [subviews count];
	if ([sender state] == 1)	{
		int i;
		for (i=0; i< subviewsCount; i++)	{
			if ([[subviews objectAtIndex:i] state] == 1)	{
				if ([subviews objectAtIndex:i] != sender)	{
					[[subviews objectAtIndex:i] setState:0];
				}
			}
		}
	}
	
	
	NSCalendarDate * workingDate = [[NSDate date] dateWithCalendarFormat:@"%a. %b. %d, %Y" timeZone:nil];
	
	NSMutableArray * stylist = [staffController workingServiceProviders:workingDate];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name == %@", [sender title]];
	[stylist filterUsingPredicate:predicate];
	// get 4 weeks worth of appointments
	NSFetchRequest * appointmentRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * apptDescription = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
	
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	int dayOfWeek = [workingDate dayOfWeek];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	int days = 4*7 + 6 - dayOfWeek;
	NSCalendarDate * endOfDay = [beginningOfDay dateByAddingYears:0 months:0 days:days hours:0 minutes:0 seconds:0];
	predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END AND stylist == %@", [stylist objectAtIndex:0]];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	[appointmentRequest setEntity:apptDescription];
	[appointmentRequest setPredicate:predicate];
	
	NSArray * allAppointments = [moc executeFetchRequest:appointmentRequest error:&error];
	NSLog(@"executing Fetch appointment");
	
	NSMutableString * monthDescription = [NSMutableString stringWithFormat:@"%@'s Month's Preview\n\n", [sender title]];
	int daysAhead;
	for (daysAhead = 0; daysAhead < days; daysAhead++)	{
		NSMutableArray * daysResults = [NSMutableArray arrayWithArray:allAppointments];
		NSCalendarDate * beginning = [beginningOfDay dateByAddingYears:0 months:0 days:daysAhead hours:0 minutes:0 seconds:0];
		NSCalendarDate * end = [beginning dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"stylist == %@ AND time > $BEGINNING AND time < $END", [stylist objectAtIndex:0]];
		predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginning , @"BEGINNING",end, @"END", nil]];
		
		[beginning setCalendarFormat:@"%A. %B. %d, %Y"];
		
		[daysResults filterUsingPredicate:predicate];
		[monthDescription appendFormat:@"\n%@:\n\n", beginning];
		if ([daysResults count] > 0)	{
			NSSortDescriptor * timeSort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
			[daysResults sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
			[timeSort release];
			NSCalendarDate * firstTime = [[[daysResults objectAtIndex:0] valueForKey:@"time"] dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
			NSCalendarDate * lastTime = [[[daysResults lastObject] valueForKey:@"time"] dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
			[monthDescription appendFormat:@"First Appointment %@ --- Last Appointment %@\nBooked Appointments:\n", firstTime, lastTime];
			int j;
			for (j=0 ; j< [daysResults count]; j++)	{
				NSManagedObject * appointment = [daysResults objectAtIndex:j];
				if ([appointment valueForKey:@"client"] != nil)	{
					NSCalendarDate * time = [[appointment valueForKey:@"time"] dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
					[monthDescription appendFormat:@"%@ at %@ for %@\n", [appointment valueForKeyPath:@"client.name"], time, [self serviceDescription:[appointment valueForKey:@"services"]]];
					
				}
					
				
			}
		} else	{
			NSArray * blankDay = [self blankScheduleForStylist:[stylist objectAtIndex:0] date:beginning];
			if ([blankDay count] > 0)	{
				NSCalendarDate * firstTime = [[[blankDay objectAtIndex:0] valueForKey:@"time"] dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
				NSCalendarDate * lastTime = [[[blankDay lastObject] valueForKey:@"time"] dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
				[monthDescription appendFormat:@"First Appointment %@ --- Last Appointment %@\n***No Appointments Booked***\n", firstTime, lastTime];
				
			} else	{
				[monthDescription appendString:@"***OFF FROM WORK***\n"];
			}
		}
	}	
	
	[stylistPreviewTextView setString:monthDescription];
	
}
-(NSString*)serviceDescription:(NSMutableSet *)servicesSet
{
	NSMutableString * description = [NSMutableString string];
	NSSortDescriptor * listOrderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	NSMutableArray * services = [NSMutableArray arrayWithArray:[servicesSet allObjects]];
	[services sortUsingDescriptors:[NSArray arrayWithObject:listOrderDescriptor]];
	int i;
	for (i=0 ; i < [services count]; i++)	{
		[description appendFormat:@"%@, ", [[services objectAtIndex:i] valueForKey:@"serviceDescription"]];
	}
	return description;
}

-(IBAction)goToAddColorFile:(id)sender
{
	[colorFileDatePicker setDateValue:[mainDatePicker dateValue]];
	[colorFile setString:@""];
	id appointment = [[pageView selectedBlock] appointment];
	if ([appointment valueForKey:@"client"] != nil)	{
		self.clientForAddColorFile = [appointment valueForKey:@"client"];
		[clientNameForColorFile setStringValue:[self.clientForAddColorFile valueForKey:@"name"]];
		[addColorFileWindow makeKeyAndOrderFront:self];
	}
	
}
-(IBAction)addColorFile:(id)sender
{
	
	if ([colorFile string] != nil && self.clientForAddColorFile != nil)	{
		
		NSManagedObject * newColorFile = [NSEntityDescription insertNewObjectForEntityForName:@"ColorFile" inManagedObjectContext:moc];
		[newColorFile setValue:[colorFileDatePicker dateValue] forKey:@"date"];
		[newColorFile setValue:[colorFile string] forKey:@"formula"];
		[newColorFile setValue:self.clientForAddColorFile forKey:@"client"];
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
		
		self.clientForAddColorFile = nil;
		[addColorFileWindow close];
	}	
}

-(IBAction)neverConfirmForThisClient:(id)sender
{
	id appointment = [[pageView selectedBlock] appointment];
	if ([appointment valueForKey:@"client"] != nil)	{
		id test =[NSKeyedUnarchiver unarchiveObjectWithFile:self.neverConfirmPath];
		if (test == nil)	{
			test = [NSMutableArray array];
		} 
		[test addObject:[appointment valueForKeyPath:@"client.name"]];
		
		[NSKeyedArchiver archiveRootObject:test toFile:self.neverConfirmPath];
	}
}
-(IBAction)viewAppointmentsBookedToday:(id)sender
{
	NSFetchRequest * apptRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * apptDescription = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
	
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	int month, day, year;
	month = [selectedDate monthOfYear];
	day = [selectedDate dayOfMonth];
	year = [selectedDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	NSCalendarDate * endOfDay = [beginningOfDay dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"dateBooked > %@ and dateBooked < %@ AND parentAppointment == nil", beginningOfDay, endOfDay];
	[apptRequest setPredicate:predicate];
	[apptRequest setEntity:apptDescription];
	
	NSLog(@"viewAppointmentsBookedToday");
	
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:apptRequest error:&error]];
	
	NSSortDescriptor * dateBookedSort = [[[NSSortDescriptor alloc] initWithKey:@"dateBooked" ascending:YES] autorelease];
	[results sortUsingDescriptors:[NSArray arrayWithObject:dateBookedSort]];
	
	NSLog(@"executing Fetch appointment");
	
	[bookedTodayController setContent:results];
	[bookedAppointmentsWindow makeKeyAndOrderFront:self];
}
-(IBAction)viewWalkinsForDay:(id)sender
{
	[walkinsController setContent:[NSMutableArray array]];
	NSFetchRequest * apptRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * apptDescription = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
	
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [selectedDate monthOfYear];
	day = [selectedDate dayOfMonth];
	year = [selectedDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	NSCalendarDate * endOfDay = [beginningOfDay dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"dateBooked > $BEGINNING AND dateBooked < $END AND parentAppointment != nil"];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	[apptRequest setPredicate:predicate];
	[apptRequest setEntity:apptDescription];
	NSSortDescriptor * timeSort = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES] autorelease];
	
	
	
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:apptRequest error:&error]];
	
	[results sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
	
	NSLog(@"executing Fetch appointment");
	
	int i;
	for (i=0; i< [results count] ; i++)	{
		NSDate * time = [[results objectAtIndex:i] valueForKey:@"time"];
		NSDate * dateBooked = [[results objectAtIndex:i] valueForKey:@"dateBooked"];
		NSTimeInterval interval = [time timeIntervalSinceDate:dateBooked];
		if (interval < 3600)	{
			[walkinsController addObject:[results objectAtIndex:i]];
		}
	}
 

	[walkinsWindow setTitle:[NSString stringWithFormat:@"Walkins for %@", selectedDate]];
	[walkinsWindow makeKeyAndOrderFront:self];
	
}
-(IBAction)viewWalkinsForWeek:(id)sender
{
	
	[walkinsController setContent:[NSMutableArray array]];
	NSFetchRequest * apptRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * apptDescription = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
	
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [selectedDate monthOfYear];
	day = [selectedDate dayOfMonth];
	year = [selectedDate yearOfCommonEra];
	int dayOfWeek = [selectedDate dayOfWeek];
	NSCalendarDate * sunday = [NSCalendarDate dateWithYear:year month:month day:day - dayOfWeek hour:0 minute:0 second:0 timeZone:nil];
	NSCalendarDate * saturday = [NSCalendarDate dateWithYear:year month:month day:day - dayOfWeek + 6 hour:0 minute:0 second:0 timeZone:nil];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > %@ AND time <  %@ AND parentAppointment == nil", sunday, saturday];
	[apptRequest setPredicate:predicate];
	[apptRequest setEntity:apptDescription];
	NSSortDescriptor * timeSort = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES] autorelease];
	
	
	
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:apptRequest error:&error]];
	
	[results sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
	NSLog(@"executing Fetch appointment");
	
	int i;
	for (i=0; i< [results count] ; i++)	{
		NSDate * time = [[results objectAtIndex:i] valueForKey:@"time"];
		NSDate * dateBooked = [[results objectAtIndex:i] valueForKey:@"dateBooked"];
		NSTimeInterval interval = [time timeIntervalSinceDate:dateBooked];
		if (interval < 3600)	{
			[walkinsController addObject:[results objectAtIndex:i]];
		}
	}
	NSString * format = [NSString stringWithString:@"%m/%d/%y"];
	[sunday setCalendarFormat:format];
	[saturday setCalendarFormat:format];
	
	[walkinsWindow setTitle:[NSString stringWithFormat:@"Walkins for %@ - %@", sunday, saturday]];
	[walkinsWindow makeKeyAndOrderFront:self];
}
-(IBAction)creditFieldEntered:(id)sender
{
	NSManagedObject * client = [[[pageView selectedBlock] appointment] valueForKey:@"client"];
	if ([client valueForKey:@"creditCard"] == nil)	{
		[clientDatabase goToCreateCreditCardForClient:client];
	} else {
		// get password for creditCard
		SEL sel = @selector(passwordEnteredForCreditCard:);
		[passwordController getPasswordFor:self arguments:nil selector:sel];
		
	}

	
}
-(void)creditCardDataEntered:(NSString *)cardNumber
{
	[creditField setStringValue:cardNumber];
	NSString * nextVariable = cardNumber;
	if (nextVariable)	{
		NSMutableString * string = [NSMutableString stringWithString:nextVariable];
		if ([string length] > 12)	{
			NSRange range = NSMakeRange(0,12);
			[string replaceCharactersInRange:range withString:@"xxxxxxxxxxxx"];
		}
		
		
		[creditField setStringValue:string];
		
	}
}
-(void)passwordEnteredForCreditCard:(NSManagedObject *)password
{
	NSManagedObject * client = [[[pageView selectedBlock] appointment] valueForKey:@"client"];
	[clientDatabase goToCreateCreditCardForClient:client];
}
-(IBAction)automaticallyConfirmAppointments:(id)sender
{
	NSArray * appointmentsToConfirm = [confirmationsController content];
	
	
	int i;
	for (i=0; i< [appointmentsToConfirm count]; i++)	{
		NSManagedObject * appointment = [appointmentsToConfirm objectAtIndex:i];
		NSMutableDictionary * messageEntry = [NSMutableDictionary dictionary];
		id workingVariable = [appointment valueForKeyPath:@"client.email"];
		if (workingVariable != nil)	{
			[messageEntry setValue:workingVariable forKey:@"emailAddress"];
		}
		workingVariable = [appointment valueForKey:@"time"];
		if (workingVariable != nil)	{
			NSCalendarDate * date = [workingVariable dateWithCalendarFormat:@"%a. %b. %d, %Y" timeZone:nil];
			NSCalendarDate * time = [workingVariable dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
			[messageEntry setValue:date forKey:@"date"];
			[messageEntry setValue:time forKey:@"time"];
		}
		workingVariable = [appointment valueForKeyPath:@"stylist.name"];
		if (workingVariable != nil)	{
		
			[messageEntry setValue:workingVariable forKey:@"stylist"];
		}
		int j;
		
		workingVariable = [NSArray arrayWithArray:[appointment valueForKey:@"services"]];
		
		NSMutableString * mString = [NSMutableString stringWithString:@"services: "];
		if ([workingVariable count] > 0)	{
		for (j=0; j < [workingVariable count]-1; j++)	{
			[mString appendFormat:@"%@, ", [[workingVariable objectAtIndex:j] valueForKey:@"serviceDescription"]];

		}
		[mString appendFormat:@"%@",[[workingVariable objectAtIndex:j] valueForKey:@"serviceDescription"]];
		[messageEntry setValue:mString forKey:@"services"];
		}
		NSMutableString * appointmentDescriptionString = [NSMutableString string];
		[appointmentDescriptionString appendFormat:@"Hello %@,\n\tThis is a reminder for your appointment scheduled at Salon Harmony on %@ at %@.\n", [appointment valueForKeyPath:@"client.name"], [messageEntry valueForKey:@"date"], [messageEntry valueForKey:@"time"]];
		[appointmentDescriptionString appendFormat:@"We have scheduled time for the following %@.  Please contact us if this information is incorrect.\n\nThank you.\nSalon Harmony\n9 7th Avenue\nBrooklyn, NY 11217\n\n718-622-7722\nSalonHarmony@mac.com",[messageEntry valueForKey:@"services"]];
		
		 
		
		[messageEntry setValue:appointmentDescriptionString forKey:@"messageBody"];
		[mString setString:@"Your appointment for "];
		[mString appendFormat:@"%@", [messageEntry valueForKey:@"date"]];
		[messageEntry setValue:mString forKey:@"subject"];
		
		
		
		NSDictionary* errorDict;
		NSAppleEventDescriptor* returnDescriptor = NULL;
		NSString * addressVar;
		
		
		NSMutableString * scriptMessage = [NSMutableString stringWithFormat:@"\
										   tell application \"Mail\"\n\
										   set theSubject to \"%@\"\n\
										   set theBody to \"%@\"\n\
										   set newMessage to make new outgoing message with properties {subject:theSubject, content:theBody & return & return}\n\
										   tell newMessage\n\
										   set visible to true\n\
										   set sender to \"salonharmony\@mac.com\"\n\
										   make new to recipient with properties {name:\"%@\", address:\"%@\"}\n\
										   end tell\n\
										   end tell\n",[messageEntry valueForKey:@"subject"],[messageEntry valueForKey:@"messageBody"] ,[appointment valueForKeyPath:@"client.name"] ,[messageEntry valueForKey:@"emailAddress"]];
		
		NSAppleScript * scriptObject = [[NSAppleScript alloc] initWithSource:scriptMessage];
				
		returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
		[scriptObject release];
		
		
		
	}
	
	
}
-(void)notifyEmployeeOfScheduleChange
{
	
	// check to see if this the most recent appointment
	NSLog(@"notify employee");
	NSDate * selectedTime = [[[pageView selectedBlock] appointment] valueForKey:@"time"];
	NSManagedObject * stylist = [[[pageView selectedBlock] appointment] valueForKey:@"stylist"];

	
	NSDictionary* errorDict;
	NSAppleEventDescriptor* returnDescriptor = NULL;
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > %@ && time < %@ && stylist.name == %@ && client.name != nil", [NSDate date] , selectedTime, [stylist valueForKey:@"name"]];
	
	NSEntityDescription * ed = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
	NSFetchRequest * fr = [[[NSFetchRequest alloc] init] autorelease];
	[fr setEntity:ed];
	[fr setPredicate:predicate];
	
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:fr error:&error]];
	
	NSSortDescriptor * descriptor = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES] autorelease];
	
	
	NSMutableDictionary * preferences = [NSKeyedUnarchiver unarchiveObjectWithFile:preferencesPath];
	NSString * sender = [preferences valueForKey:@"emailSender"];
	
	
	[results sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	NSMutableString * message;
	
	NSString * email = [stylist valueForKey:@"email"];
	NSString * name = [stylist valueForKey:@"name"];
	NSLog(@"results %@", results);
	if ([email length] > 0)	{
		if ([results count] == 0)	{
			// this is the most recent appointment
			
			
			NSManagedObject *a = [[pageView selectedBlock] appointment];
			NSCalendarDate *date = [[a valueForKey:@"time"] dateWithCalendarFormat:@"%a. %b. %d, %Y" timeZone:nil];
			NSCalendarDate *time = [[a valueForKey:@"time"] dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
			
			message = [NSMutableString stringWithFormat:@"%@'s next appointment is %@ at %@ on %@",[a valueForKeyPath:@"stylist.name"], [a valueForKeyPath:@"client.name"], time, date];
			
			
			
			NSMutableString * scriptMessage = [NSMutableString stringWithFormat:@"\
											   tell application \"Mail\"\n\
											   set theSubject to \"You\'re appointment for tomorrow\"\n\
											   set theBody to \"%@\"\n\
											   set newMessage to make new outgoing message with properties {subject:theSubject, content:theBody & return & return}\n\
											   tell newMessage\n\
											   set sender to \"%@\"\n\
											   make new to recipient with properties {name:\"%@\", address:\"%@\"}\n\
											   send\n\
											   end tell\n\
											   end tell\n",message, sender,name,email];


			
			NSAppleScript * scriptObject = [[NSAppleScript alloc] initWithSource:scriptMessage];
			
			
			
			NSLog(@"script message %@", scriptMessage);
			
			returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
			[scriptObject release];
			
			
			
		}
	}
		
	
}
@end
