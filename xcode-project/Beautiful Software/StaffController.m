//
//  StaffController.m
//  Beautiful Software
//
//  Created by Jesse Black on 12/11/08.
//  Copyright 2008 Jesse Black. All rights reserved.

#import "StaffController.h"
#import "Beautiful_Software_AppDelegate.h"
#import "BookingSchedule.h"

#import "PasswordController.h"
#import "PasswordConstants.h"
@implementation StaffController
@synthesize personFields;
@synthesize allStaff;
-(BOOL)authenticate
{
	
	int month, day, year;
	month = 3;
	day = 11;
	year = 2009;
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day += 1;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	NSString * serialNumber = [NSString string];
	NSManagedObject * serialNumberForDatabase;
	NSFetchRequest * serialFetch = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * serialDescription = [NSEntityDescription entityForName:@"SerialNumber" inManagedObjectContext:moc];
	[serialFetch setEntity:serialDescription];
	NSArray * serialNumbers = [moc executeFetchRequest:serialFetch error:&error];
	NSLog(@"executing Fetch serialNumber");
	
	if ([serialNumbers count] > 0)	{
		serialNumberForDatabase = [serialNumbers objectAtIndex:0];
		NSLog(@"serial %@", [serialNumberForDatabase valueForKey:@"serialNumber"]);
	} 
	if ([[NSDate date] timeIntervalSinceDate:beginningOfDay] > 0 && [[NSDate date] timeIntervalSinceDate:endOfDay] < 0)	{
		NSDictionary* errorDict;
		NSAppleEventDescriptor* returnDescriptor = NULL;
		
		NSAppleScript * scriptObject = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"\
																			  do shell script \"system_profiler | grep \'Serial Number:\'\""]];
		
		
		returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
		
		[scriptObject release];
		serialNumber = [[returnDescriptor stringValue] substringFromIndex:21];
		serialNumber = [serialNumber substringToIndex:11];
		serialNumberForDatabase = [NSEntityDescription insertNewObjectForEntityForName:@"SerialNumber" inManagedObjectContext:moc];
		[serialNumberForDatabase setValue:serialNumber forKey:@"serialNumber"];
	} else	{
		NSDictionary* errorDict;
		NSAppleEventDescriptor* returnDescriptor = NULL;
		
		NSAppleScript * scriptObject = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"\
																			  do shell script \"system_profiler | grep \'Serial Number:\'\""]];
		
		
		returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
		[scriptObject release];
		serialNumber = [[returnDescriptor stringValue] substringFromIndex:21];
		serialNumber = [serialNumber substringToIndex:11];
		
	}
	if ([serialNumberForDatabase entity] != nil)	{
		if ([serialNumber compare:[serialNumberForDatabase valueForKey:@"serialNumber"]] == NSOrderedSame)	{
			return YES;
		} else	{
			return NO;
		}
		
	} else	{
		return NO;
	}
	return YES;
}
		
		
			
			
			
	
	
-(void)setTargetsForStaffWindow
{
	
	SEL selector = @selector(sundayEdited);
	[appointmentLengthSunday setTarget:self];
	[appointmentLengthSunday setAction:selector];
	[startTimeSunday setTarget:self];
	[startTimeSunday setAction:selector];
	[finishTimeSunday setTarget:self];
	[finishTimeSunday setAction:selector];
	[worksSunday setTarget:self];
	[worksSunday setAction:selector];
	
	selector = @selector(mondayEdited);
	[appointmentLengthMonday setTarget:self];
	[appointmentLengthMonday setAction:selector];
	[startTimeMonday setTarget:self];
	[startTimeMonday setAction:selector];
	[finishTimeMonday setTarget:self];
	[finishTimeMonday setAction:selector];
	[worksMonday setTarget:self];
	[worksMonday setAction:selector];
	
	selector = @selector(tuesdayEdited);
	[appointmentLengthTuesday setTarget:self];
	[appointmentLengthTuesday setAction:selector];
	[startTimeTuesday setTarget:self];
	[startTimeTuesday setAction:selector];
	[finishTimeTuesday setTarget:self];
	[finishTimeTuesday setAction:selector];
	[worksTuesday setTarget:self];
	[worksTuesday setAction:selector];
	
	selector = @selector(wednesdayEdited);
	[appointmentLengthWednesday setTarget:self];
	[appointmentLengthWednesday setAction:selector];
	[startTimeWednesday setTarget:self];
	[startTimeWednesday setAction:selector];
	[finishTimeWednesday setTarget:self];
	[finishTimeWednesday setAction:selector];
	[worksWednesday setTarget:self];
	[worksWednesday setAction:selector];
	
	selector = @selector(thursdayEdited);
	[appointmentLengthThursday setTarget:self];
	[appointmentLengthThursday setAction:selector];
	[startTimeThursday setTarget:self];
	[startTimeThursday setAction:selector];
	[finishTimeThursday setTarget:self];
	[finishTimeThursday setAction:selector];
	[worksThursday setTarget:self];
	[worksThursday setAction:selector];
	
	selector = @selector(fridayEdited);
	[appointmentLengthFriday setTarget:self];
	[appointmentLengthFriday setAction:selector];
	[startTimeFriday setTarget:self];
	[startTimeFriday setAction:selector];
	[finishTimeFriday setTarget:self];
	[finishTimeFriday setAction:selector];
	[worksFriday setTarget:self];
	[worksFriday setAction:selector];
	
	selector = @selector(saturdayEdited);
	[appointmentLengthSaturday setTarget:self];
	[appointmentLengthSaturday setAction:selector];
	[startTimeSaturday setTarget:self];
	[startTimeSaturday setAction:selector];
	[finishTimeSaturday setTarget:self];
	[finishTimeSaturday setAction:selector];
	[worksSaturday setTarget:self];
	[worksSaturday setAction:selector];
	
	selector = @selector(generalTimeEntered);
	[appointmentLengthGeneral setTarget:self];
	[appointmentLengthGeneral setAction:selector];
	
	selector = @selector(personEdited);
	[name setTarget:self];
	[name setAction:selector];
	
	[email setTarget:self];
	[email setAction:selector];
	
	[workPhone setTarget:self];
	[workPhone setAction:selector];
	
	[homePhone setTarget:self];
	[homePhone setAction:selector];
	
	[mobilePhone setTarget:self];
	[mobilePhone setAction:selector];
	
	[street setTarget:self];
	[street setAction:selector];
	
	[state setTarget:self];
	[state setAction:selector];
	
	[city setTarget:self];
	[city setAction:selector];
	
	[zip setTarget:self];
	[zip setAction:selector];
	
	[note setTarget:self];
	[note setAction:selector];
	
	selector = @selector(maleChecked);
	[maleButton setTarget:self];
	[maleButton setAction:selector];
	
	selector = @selector(femaleChecked);
	[femaleButton setTarget:self];
	[femaleButton setAction:selector];
	
	
}
-(void)maleChecked
{
	if ([maleButton state] == 1)	{
		[femaleButton setState:0];
	}
	[self personEdited];
}
-(void)femaleChecked
{
	if ([femaleButton state] == 1)	{
		[maleButton setState:0];
	}
	[self personEdited];
}
@synthesize passwordLevelsPath;

-(void)awakeFromNib
{
	moc = [appDelegate managedObjectContext];
	NSEntityDescription * employeeDescription = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:moc];
	NSFetchRequest * employeeRequest = [[[NSFetchRequest alloc] init] autorelease];
	[employeeRequest setEntity:employeeDescription];
	NSLog(@"executing Fetch employee");
	NSArray * results = [moc executeFetchRequest:employeeRequest error:&error];
	self.allStaff = [NSMutableArray arrayWithArray:results];
	

	NSMutableString * ppath = [NSMutableString stringWithString:[appDelegate applicationSupportFolder]];
	[ppath appendString:@"/passwordLevelsPath"];
	[self setPasswordLevelsPath:ppath];
	
	self.personFields = [NSMutableArray arrayWithObjects:name, email, homePhone, workPhone, mobilePhone, street, city, state, zip, note,nil];
	[staffWindow setDelegate:self];
	
	
	if (YES)	{
		
		//create employee if no employees
		[self test];
	} else	{
		[[NSApplication sharedApplication] terminate:self];
	}
	
	[self setTargetsForStaffWindow];
	[booksCheckBox setAction:@selector(booksChecked)];
	[booksCheckBox setTarget:self];
	[tracksCheckBox setAction:@selector(tracksChecked)];
	[tracksCheckBox setTarget:self];

}
-(NSArray *)serviceProviders
{
	NSMutableArray * filterArray = [NSMutableArray arrayWithArray:allStaff];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"booksServices == YES"];
	[filterArray filterUsingPredicate:predicate];
	NSSortDescriptor * listOrder = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	[filterArray sortUsingDescriptors:[NSArray arrayWithObject:listOrder]];
	return filterArray;
}
-(NSArray *)clockedEmployees
{
	NSMutableArray * filterArray = [NSMutableArray arrayWithArray:allStaff];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"tracksHours == YES"];
	[filterArray filterUsingPredicate:predicate];
	NSSortDescriptor * listOrder = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	[filterArray sortUsingDescriptors:[NSArray arrayWithObject:listOrder]];
	return filterArray;
}
-(NSArray *)workingServiceProviders:(NSDate *)notTerminatedSince
{
	NSMutableArray * filterArray = [NSMutableArray arrayWithArray:allStaff];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"booksServices == YES && (terminated == nil || terminated > %@)", notTerminatedSince];
	[filterArray filterUsingPredicate:predicate];
	NSSortDescriptor * listOrder = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	[filterArray sortUsingDescriptors:[NSArray arrayWithObject:listOrder]];
	return filterArray;
}
-(NSArray *)workingClockedEmployees:(NSDate *)notTerminatedSince
{
	NSMutableArray * filterArray = [NSMutableArray arrayWithArray:allStaff];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"tracksHours == YES && (terminated == nil || terminated > %@)", notTerminatedSince];
	[filterArray filterUsingPredicate:predicate];
	NSSortDescriptor * listOrder = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	[filterArray sortUsingDescriptors:[NSArray arrayWithObject:listOrder]];
	return filterArray;
}

-(NSArray *)workingStaff:(NSDate *)notTerminatedSince
{
	NSMutableArray * filterArray = [NSMutableArray arrayWithArray:allStaff];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"terminated == nil || terminated > %@", notTerminatedSince];

	[filterArray filterUsingPredicate:predicate];
	NSSortDescriptor * listOrder = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	[filterArray sortUsingDescriptors:[NSArray arrayWithObject:listOrder]];
	return filterArray;
}
-(NSArray *)allEmployees
{
	
	
	NSSortDescriptor * listOrderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];

	[allStaff sortUsingDescriptors:[NSArray arrayWithObject:listOrderDescriptor]];
	return allStaff;
}



-(void)test
{

	NSArray * results = [self workingStaff:[NSDate date]];
	
	if ([results count] == 0)	{
	

		[self initializeStaff];
		[bookingSchedule initialStart];
	}
	else	{
		
		
		[bookingSchedule initialStart];
	}
	
	
}
-(IBAction)goToEditStaffControllerAction:(id)sender
{
	SEL selector = @selector(goToEditStaffController:);
	[passwordController getPasswordFor:self arguments:nil selector:selector];
}
-(void)booksChecked
{
	[[[staffArrayController selectedObjects] objectAtIndex:0] setValue:[NSNumber numberWithInt:[booksCheckBox state]] forKey:@"booksServices"];
}
-(void)tracksChecked
{
	[[[staffArrayController selectedObjects] objectAtIndex:0] setValue:[NSNumber numberWithInt:[tracksCheckBox state]] forKey:@"tracksHours"];
}

-(void)initializeStaff
{
	NSManagedObject * owner = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:moc];
	NSManagedObject * passwordLevel = [NSEntityDescription insertNewObjectForEntityForName:@"Password" inManagedObjectContext:moc];
	[passwordLevel setValue:[NSNumber numberWithInt:10] forKey:@"passwordLevel"];
	[owner setValue:@"Owner" forKey:@"name"];
	[owner setValue:[NSNumber numberWithBool:YES] forKey:@"booksServices"];
	[owner setValue:passwordLevel forKey:@"password"];
	[passwordLevel setValue:@"owner" forKey:@"password"];
	NSManagedObject * bSchedule = [bookingSchedule defaultBookingSchedule];

	[owner setValue:bSchedule forKey:@"bookingSchedule"];
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
}
-(void)goToEditStaffController:(NSManagedObject *)password
{
	if ([password valueForKey:@"passwordLevel"] != nil)	{
		int passwordLevel = [[password valueForKey:@"passwordLevel"] intValue];
		id test = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordLevelsPath];
		
		if (passwordLevel >= [[test valueForKey:@"editStaffLevel"] intValue] )	{
			[self loadEditStaffWindow];
		}		
	}
}
-(void)loadEditStaffWindow
{
	
	NSMutableArray * staff = [self allEmployees];
	

	[staffArrayController setContent:staff];
	
	if ([staff count] > 0)	{
		[self loadSchedule:[[staff objectAtIndex:0] valueForKey:@"bookingSchedule"]];
		[self loadEmployee:[staff objectAtIndex:0]];
		[booksCheckBox setState:[[[staff objectAtIndex:0] valueForKey:@"booksServices"] boolValue]];
		[tracksCheckBox setState:[[[staff objectAtIndex:0] valueForKey:@"tracksHours"] boolValue]];
	}
	
	
	[staffWindow makeKeyAndOrderFront:self];
}
-(void)loadSchedule:(NSManagedObject *)bSchedule
{
	[booksCheckBox setState:[[bSchedule valueForKeyPath:@"employee.booksServices"] boolValue]];
	[tracksCheckBox setState:[[bSchedule valueForKeyPath:@"employee.tracksHours"] boolValue]];
	
	[worksSunday setState:[[bSchedule valueForKey:@"worksSunday"] boolValue]];
	[worksMonday setState:[[bSchedule valueForKey:@"worksMonday"] boolValue]];
	[worksTuesday setState:[[bSchedule valueForKey:@"worksTuesday"] boolValue]];
	[worksWednesday setState:[[bSchedule valueForKey:@"worksWednesday"] boolValue]];
	[worksThursday setState:[[bSchedule valueForKey:@"worksThursday"] boolValue]];
	[worksFriday setState:[[bSchedule valueForKey:@"worksFriday"] boolValue]];
	[worksSaturday setState:[[bSchedule valueForKey:@"worksSaturday"] boolValue]];
	
	[startTimeSunday setDateValue:[bSchedule valueForKey:@"firstSunday"]];
	[startTimeMonday setDateValue:[bSchedule valueForKey:@"firstMonday"]];
	[startTimeTuesday setDateValue:[bSchedule valueForKey:@"firstTuesday"]];
	[startTimeWednesday setDateValue:[bSchedule valueForKey:@"firstWednesday"]];
	[startTimeThursday setDateValue:[bSchedule valueForKey:@"firstThursday"]];
	[startTimeFriday setDateValue:[bSchedule valueForKey:@"firstFriday"]];
	[startTimeSaturday setDateValue:[bSchedule valueForKey:@"firstSaturday"]];
	
	[finishTimeSunday setDateValue:[bSchedule valueForKey:@"lastSunday"]];
	[finishTimeMonday setDateValue:[bSchedule valueForKey:@"lastMonday"]];
	[finishTimeTuesday setDateValue:[bSchedule valueForKey:@"lastTuesday"]];
	[finishTimeWednesday setDateValue:[bSchedule valueForKey:@"lastWednesday"]];
	[finishTimeThursday setDateValue:[bSchedule valueForKey:@"lastThursday"]];
	[finishTimeFriday setDateValue:[bSchedule valueForKey:@"lastFriday"]];
	[finishTimeSaturday setDateValue:[bSchedule valueForKey:@"lastSaturday"]];
	
	[appointmentLengthSunday setIntValue:[[bSchedule valueForKey:@"appointmentLengthSunday"] intValue]];
	[appointmentLengthMonday setIntValue:[[bSchedule valueForKey:@"appointmentLengthMonday"] intValue]];
	[appointmentLengthTuesday setIntValue:[[bSchedule valueForKey:@"appointmentLengthTuesday"] intValue]];
	[appointmentLengthWednesday setIntValue:[[bSchedule valueForKey:@"appointmentLengthWednesday"] intValue]];
	[appointmentLengthThursday setIntValue:[[bSchedule valueForKey:@"appointmentLengthThursday"] intValue]];
	[appointmentLengthFriday setIntValue:[[bSchedule valueForKey:@"appointmentLengthFriday"] intValue]];
	[appointmentLengthSaturday setIntValue:[[bSchedule valueForKey:@"appointmentLengthSaturday"] intValue]];
	
}
-(void)adjustEmployeeListOrder
{
	int i;
	NSArray * staff = [staffArrayController content];
	for (i= 0; i<[staff count]; i++)	{
		[[staff objectAtIndex:i] setValue:[NSNumber numberWithInt:i] forKey:@"listOrder"];
	}
}
-(IBAction)removeEmployee:(id)sender
{
	NSManagedObject * selection = [[staffArrayController selectedObjects] objectAtIndex:0];
	[selection setValue:[NSDate date] forKey:@"terminated"];
	NSMutableArray * content = [NSMutableArray arrayWithArray:[staffArrayController content]];
	[content removeObject:selection];
	[content addObject:selection];
	[staffArrayController setContent:content];
	[self adjustEmployeeListOrder];
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	selection = [[staffArrayController selectedObjects] objectAtIndex:0];
	[self loadEmployee:selection];
	[self loadSchedule:[selection valueForKey:@"bookingSchedule"]];


}
-(IBAction)addEmployee:(id)sender
{
	int selectionIndex = [staffArrayController selectionIndex];
	NSManagedObject * selectedEmployee = [[staffArrayController selectedObjects] objectAtIndex:0];
	if ([selectedEmployee valueForKey:@"terminated"] == nil)	{
		NSManagedObject * employee = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:moc];
		[employee setValue:@"New Employee" forKey:@"name"];
		[employee setValue:[bookingSchedule defaultBookingSchedule] forKey:@"bookingSchedule"];
		if (selectionIndex == [[staffArrayController content] count])	{
			[staffArrayController addObject:employee];
		} else	{
			selectionIndex++;
			[staffArrayController insertObject:employee atArrangedObjectIndex:selectionIndex];
		}
		[self loadSchedule:[employee valueForKey:@"bookingSchedule"]];
		[self loadEmployee:employee];
		[self adjustEmployeeListOrder];
	} else {
		
		[selectedEmployee setValue:nil forKey:@"terminated"];
		
	}

}
-(void)editStaffMember
{
	[self sundayEdited];
	[self mondayEdited];
	[self tuesdayEdited];
	[self wednesdayEdited];
	[self thursdayEdited];
	[self fridayEdited];
	[self saturdayEdited];
	[self serviceProviders];
	[self personEdited];
}
-(IBAction)saveChanges:(id)sender
{
	[self editStaffMember];
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	[staffWindow close];
	[bookingSchedule initialStart];
	
}
-(BOOL)windowWillClose:(NSNotification *)aNotification
{
	return YES;
}
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	NSManagedObject * employee = [[staffArrayController content] objectAtIndex:rowIndex];
	[self loadSchedule:[employee valueForKey:@"bookingSchedule"]];
	[self loadEmployee:employee];
	return YES;
}
-(void)sundayEdited
{
	NSManagedObject * bSchedule = [[[staffArrayController selectedObjects] objectAtIndex:0] valueForKey:@"bookingSchedule"];
	[bSchedule setValue:[startTimeSunday dateValue] forKey:@"firstSunday"];
	[bSchedule setValue:[finishTimeSunday dateValue] forKey:@"lastSunday"];
	[bSchedule setValue:[NSNumber numberWithInt:[appointmentLengthSunday intValue]] forKey:@"appointmentLengthSunday"];
	[bSchedule setValue:[NSNumber numberWithBool:[worksSunday state]] forKey:@"worksSunday"];
}
-(void)mondayEdited
{
	NSManagedObject * bSchedule = [[[staffArrayController selectedObjects] objectAtIndex:0] valueForKey:@"bookingSchedule"];
	[bSchedule setValue:[startTimeMonday dateValue] forKey:@"firstMonday"];
	[bSchedule setValue:[finishTimeMonday dateValue] forKey:@"lastMonday"];
	[bSchedule setValue:[NSNumber numberWithInt:[appointmentLengthMonday intValue]] forKey:@"appointmentLengthMonday"];
	[bSchedule setValue:[NSNumber numberWithBool:[worksMonday state]] forKey:@"worksMonday"];
}
-(void)tuesdayEdited
{
	NSManagedObject * bSchedule = [[[staffArrayController selectedObjects] objectAtIndex:0] valueForKey:@"bookingSchedule"];
	[bSchedule setValue:[startTimeTuesday dateValue] forKey:@"firstTuesday"];
	[bSchedule setValue:[finishTimeTuesday dateValue] forKey:@"lastTuesday"];
	[bSchedule setValue:[NSNumber numberWithInt:[appointmentLengthTuesday intValue]] forKey:@"appointmentLengthTuesday"];
	[bSchedule setValue:[NSNumber numberWithBool:[worksTuesday state]] forKey:@"worksTuesday"];
}
-(void)wednesdayEdited
{
	NSManagedObject * bSchedule = [[[staffArrayController selectedObjects] objectAtIndex:0] valueForKey:@"bookingSchedule"];
	[bSchedule setValue:[startTimeWednesday dateValue] forKey:@"firstWednesday"];
	[bSchedule setValue:[finishTimeWednesday dateValue] forKey:@"lastWednesday"];
	[bSchedule setValue:[NSNumber numberWithInt:[appointmentLengthWednesday intValue]] forKey:@"appointmentLengthWednesday"];
	[bSchedule setValue:[NSNumber numberWithBool:[worksWednesday state]] forKey:@"worksWednesday"];
}
-(void)thursdayEdited
{
	NSManagedObject * bSchedule = [[[staffArrayController selectedObjects] objectAtIndex:0] valueForKey:@"bookingSchedule"];
	[bSchedule setValue:[startTimeThursday dateValue] forKey:@"firstThursday"];
	[bSchedule setValue:[finishTimeThursday dateValue] forKey:@"lastThursday"];
	[bSchedule setValue:[NSNumber numberWithInt:[appointmentLengthThursday intValue]] forKey:@"appointmentLengthThursday"];
	[bSchedule setValue:[NSNumber numberWithBool:[worksThursday state]] forKey:@"worksThursday"];
}
-(void)fridayEdited
{
	NSManagedObject * bSchedule = [[[staffArrayController selectedObjects] objectAtIndex:0] valueForKey:@"bookingSchedule"];
	[bSchedule setValue:[startTimeFriday dateValue] forKey:@"firstFriday"];
	[bSchedule setValue:[finishTimeFriday dateValue] forKey:@"lastFriday"];
	[bSchedule setValue:[NSNumber numberWithInt:[appointmentLengthFriday intValue]] forKey:@"appointmentLengthFriday"];
	[bSchedule setValue:[NSNumber numberWithBool:[worksFriday state]] forKey:@"worksFriday"];
}
-(void)saturdayEdited
{
	NSManagedObject * bSchedule = [[[staffArrayController selectedObjects] objectAtIndex:0] valueForKey:@"bookingSchedule"];
	[bSchedule setValue:[startTimeSaturday dateValue] forKey:@"firstSaturday"];
	[bSchedule setValue:[finishTimeSaturday dateValue] forKey:@"lastSaturday"];
	[bSchedule setValue:[NSNumber numberWithInt:[appointmentLengthSaturday intValue]] forKey:@"appointmentLengthSaturday"];
	[bSchedule setValue:[NSNumber numberWithBool:[worksSaturday state]] forKey:@"worksSaturday"];
}
-(void)generalTimeEntered
{
	NSManagedObject * employee = [[staffArrayController selectedObjects] objectAtIndex:0];
	NSManagedObject * bSchedule = [employee valueForKey:@"bookingSchedule"];
	[bSchedule setValue:[NSNumber numberWithInt:[appointmentLengthGeneral intValue]] forKey:@"appointmentLengthSunday"];
	[bSchedule setValue:[NSNumber numberWithInt:[appointmentLengthGeneral intValue]] forKey:@"appointmentLengthMonday"];
	[bSchedule setValue:[NSNumber numberWithInt:[appointmentLengthGeneral intValue]] forKey:@"appointmentLengthTuesday"];
	[bSchedule setValue:[NSNumber numberWithInt:[appointmentLengthGeneral intValue]] forKey:@"appointmentLengthWednesday"];
	[bSchedule setValue:[NSNumber numberWithInt:[appointmentLengthGeneral intValue]] forKey:@"appointmentLengthThursday"];
	[bSchedule setValue:[NSNumber numberWithInt:[appointmentLengthGeneral intValue]] forKey:@"appointmentLengthFriday"];
	[bSchedule setValue:[NSNumber numberWithInt:[appointmentLengthGeneral intValue]] forKey:@"appointmentLengthSaturday"];
	
	[self loadSchedule:bSchedule];
	
}
-(void)loadEmployee:(NSManagedObject *)employee
{
	
	[personFields makeObjectsPerformSelector:@selector(setStringValue:) withObject:@""];
	if ([employee valueForKey:@"name"])	{
		[name setStringValue:[employee valueForKey:@"name"]];
	}
	if ([employee valueForKey:@"email"])	{
		[email setStringValue:[employee valueForKey:@"email"]];
	}
	if ([employee valueForKey:@"homePhone"])	{
		[homePhone setStringValue:[employee valueForKey:@"homePhone"]];
	}
	if ([employee valueForKey:@"mobilePhone"])	{
		[mobilePhone setStringValue:[employee valueForKey:@"mobilePhone"]];
	}
	if ([employee valueForKey:@"workPhone"])	{
		[workPhone setStringValue:[employee valueForKey:@"workPhone"]];
	}
	if ([employee valueForKey:@"note"])	{
		[note setStringValue:[employee valueForKey:@"note"]];
	}
	if ([employee valueForKey:@"street"])	{
		[street setStringValue:[employee valueForKey:@"street"]];
	}
	if ([employee valueForKey:@"state"])	{
		[state setStringValue:[employee valueForKey:@"state"]];
	}
	if ([employee valueForKey:@"city"])	{
		[city setStringValue:[employee valueForKey:@"city"]];
	}
	if ([employee valueForKey:@"zip"])	{
		[zip setStringValue:[employee valueForKey:@"zip"]];
	}
	if ([employee valueForKey:@"isMale"])	{
		[maleButton setState:[[employee valueForKey:@"isMale"] intValue]];
	}
	if ([employee valueForKey:@"isFemale"])	{
		[femaleButton setState:[[employee valueForKey:@"isFemale"] intValue]];
	}
}
-(void)personEdited
{
	NSManagedObject * employee = [[staffArrayController selectedObjects] objectAtIndex:0];
	[employee setValue:[name stringValue] forKey:@"name"];
	[employee setValue:[email stringValue] forKey:@"email"];
	[employee setValue:[homePhone stringValue] forKey:@"homePhone"];
	[employee setValue:[mobilePhone stringValue] forKey:@"mobilePhone"];
	[employee setValue:[workPhone stringValue] forKey:@"workPhone"];
	[employee setValue:[note stringValue] forKey:@"note"];
	[employee setValue:[street stringValue] forKey:@"street"];
	[employee setValue:[state stringValue] forKey:@"state"];
	[employee setValue:[city stringValue] forKey:@"city"];
	[employee setValue:[zip stringValue] forKey:@"zip"];
	[employee setValue:[NSNumber numberWithInt:[maleButton state]] forKey:@"isMale"];
	[employee setValue:[NSNumber numberWithInt:[femaleButton state]] forKey:@"isFemale"];
}
-(IBAction)moveUpList:(id)sender
{
	int selectionIndex = [staffArrayController selectionIndex];
	if (selectionIndex !=0){
		NSManagedObject * employee = [[staffArrayController selectedObjects] objectAtIndex:0];
		selectionIndex --;
		NSMutableArray * array = [NSMutableArray arrayWithArray:[staffArrayController content]];
		[array removeObject:employee];
		
		[array insertObject:employee atIndex:selectionIndex];
		
		[staffArrayController setContent:array];
		[staffArrayController setSelectionIndex:selectionIndex];
		
		[self adjustEmployeeListOrder];
	}
}
-(IBAction)moveDownList:(id)sender
{
	int selectionIndex = [staffArrayController selectionIndex];
	int max = [[staffArrayController content] count];
	max --;
	if (selectionIndex != max)	{
		NSManagedObject * employee = [[staffArrayController selectedObjects] objectAtIndex:0];
		selectionIndex ++;
		NSMutableArray * array = [NSMutableArray arrayWithArray:[staffArrayController content]];
		[array removeObject:employee];
		
		[array insertObject:employee atIndex:selectionIndex];
		
		[staffArrayController setContent:array];
		[staffArrayController setSelectionIndex:selectionIndex];
		[self adjustEmployeeListOrder];
	}
}

@end
