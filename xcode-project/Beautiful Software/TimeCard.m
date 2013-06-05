//
//  TimeCard.m
//  Beautiful Software
//
//  Created by Jesse Black on 4/9/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import "TimeCard.h"
#import "EmployeeSelect.h"
#import "PasswordConstants.h"

@implementation TimeCard
@synthesize passwordLevelsPath;

-(void)awakeFromNib
{
	NSMutableString * ppath = [NSMutableString stringWithString:[appDelegate applicationSupportFolder]];
	[ppath appendString:@"/passwordLevelsPath"];
	[self setPasswordLevelsPath:ppath];
	moc = [appDelegate managedObjectContext];

}
-(IBAction)goToTimeCardWindow:(id)sender
{
	moc = [appDelegate managedObjectContext];
	edit = NO;
	NSArray * tableColumns = [timeCardTable tableColumns];
	int i;
	for (i=0; i<[tableColumns count]; i++)	{
		[[tableColumns objectAtIndex:i] setEditable:NO];
	}
	SEL selector = @selector(employeeSelected:);
	[employeeSelect selectEmployeeFor:self selector:selector windowTitle:@"Who's Time Card?"];
}
-(IBAction)editTimeCardAction:(id)sender
{
	moc = [appDelegate managedObjectContext];

	SEL selector = @selector(passwordEntered:);
	[passwordController getPasswordFor:self arguments:nil selector:selector];
}
-(void)passwordEntered:(NSManagedObject *)password
{
	if ([password valueForKey:@"passwordLevel"] != nil)	{
		int passwordLevel = [[password valueForKey:@"passwordLevel"] intValue];
		id test = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordLevelsPath];
		
		if (passwordLevel >= [[test valueForKey:@"changeScheduleLevel"] intValue] )	{
			NSArray * tableColumns = [timeCardTable tableColumns];
			int i;
			for (i=0; i<[tableColumns count]; i++)	{
				if ([[[tableColumns objectAtIndex:i] identifier] intValue]== 1)	{
					[[tableColumns objectAtIndex:i] setEditable:YES];
				} else	{
					[[tableColumns objectAtIndex:i] setEditable:NO];
				}
			}
			SEL selector = @selector(employeeSelected:);
			[employeeSelect selectEmployeeFor:self selector:selector windowTitle:@"Who's Time Card?"];
		}
	}
	edit = YES;
	
}
-(void)controlTextDidEndEditing:(NSNotification *)notification
{
	NSManagedObject * timecard = [[timeCardArrayController selectedObjects] objectAtIndex:0];
	NSCalendarDate * time = [[timecard valueForKey:@"date"] dateWithCalendarFormat:@"" timeZone:nil];
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"" timeZone:nil];
	int month, day, year, hour, minute;
	month = [selectedDate monthOfYear];
	day = [selectedDate dayOfMonth];
	year = [selectedDate yearOfCommonEra];
	hour = [time hourOfDay];
	minute = [time minuteOfHour];
	NSCalendarDate * newTime = [NSCalendarDate dateWithYear:year month:month day:day hour:hour minute:minute second:0 timeZone:nil];
	[timecard setValue:newTime forKey:@"date"];
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
}
-(void)employeeSelected:(NSManagedObject*)employee
{
	selectedEmployee = employee;
	NSString * windowTitle = [NSString stringWithFormat:@"%@'s Time Card", [employee valueForKey:@"name"]];
	[timeCardWindow setTitle:windowTitle];
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"employee == %@ AND date > $BEGINNING AND date < $END", employee];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSFetchRequest * timeCardRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * timeCardDescription = [NSEntityDescription entityForName:@"TimeCard" inManagedObjectContext:moc];
	[timeCardRequest setEntity:timeCardDescription];
	[timeCardRequest setPredicate:predicate];
	
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:timeCardRequest error:&error]];
	NSLog(@"executing Fetch timeCard");
	
	int count = [results count];

	NSSortDescriptor * timeSort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	[results sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
	double dcount = count/2.0;
	[timeSort release];
	count = count/ 2;
	if ((count - dcount) != 0)	{
		[clockInClockOutButton setTitle:@"Clock Out"];
	} else	{
		[clockInClockOutButton setTitle:@"Clock In"];
	}
	[timeCardArrayController setContent:results];
	[timeCardWindow makeKeyAndOrderFront:self];
}

-(IBAction)clockInClockOut:(id)sender
{
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	if ([[workingDate description] compare:[today description]] == NSOrderedSame)	{
		
		NSManagedObject * timeCard = [NSEntityDescription insertNewObjectForEntityForName:@"TimeCard" inManagedObjectContext:moc];
		[timeCard setValue:[NSDate date] forKey:@"date"];
		[timeCard setValue:selectedEmployee forKey:@"employee"];
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
		[timeCardWindow close];
	} else	if (edit)	{
		NSManagedObject * timeCard = [NSEntityDescription insertNewObjectForEntityForName:@"TimeCard" inManagedObjectContext:moc];
		NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"" timeZone:nil];
		NSCalendarDate * time = [[NSDate date] dateWithCalendarFormat:@"" timeZone:nil];
		int hour, minute;
		int day, month, year;
		hour = [time hourOfDay];
		minute = [time minuteOfHour];
		day = [workingDate dayOfMonth];
		month = [workingDate monthOfYear];
		year = [workingDate yearOfCommonEra];
		workingDate = [NSCalendarDate dateWithYear:year month:month day:day hour:hour minute:minute second:0 timeZone:nil];
		
		[timeCard setValue:workingDate forKey:@"date"];
		[timeCard setValue:selectedEmployee forKey:@"employee"];
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
		
		[self employeeSelected:selectedEmployee];
	}
	
	
}
-(IBAction)reviewTimeCards:(id)sender
{
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"" timeZone:nil];
	int dayOfWeek = [selectedDate dayOfWeek];
	int monthOfYear = [selectedDate monthOfYear];
	int year = [selectedDate yearOfCommonEra];
	int dayOfMonth = [selectedDate dayOfMonth];
	
	NSCalendarDate * sunday = [NSCalendarDate dateWithYear:year month:monthOfYear day:dayOfMonth-dayOfWeek hour:0 minute:0 second:0 timeZone:nil];
	NSCalendarDate * nextSunday = [NSCalendarDate dateWithYear:year month:monthOfYear day:dayOfMonth+7-dayOfWeek hour:0 minute:0 second:0 timeZone:nil];
	
	NSFetchRequest * fr = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * ed = [NSEntityDescription entityForName:@"TimeCard" inManagedObjectContext:moc];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"date > %@ AND date < %@", sunday, nextSunday];
	
	[fr setPredicate:predicate];
	[fr setEntity:ed];
	
	NSArray * timeCards = [moc executeFetchRequest:fr error:&error];
	NSLog(@"executing Fetch timeCard");
	
	//TODO
}
@end
