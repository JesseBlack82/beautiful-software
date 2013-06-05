//
//  DailyReport.m
//  Beautiful Software
//
//  Created by Jesse Black on 2/3/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import "DailyReport.h"
#import "PasswordConstants.h"
#import "InterfaceConstants.h"


@implementation DailyReport
@synthesize retailRefundedPath;
@synthesize passwordLevelsPath;
@synthesize preferencesPath;
-(void)awakeFromNib
{
	NSMutableString * ppath = [NSMutableString string];
	[ppath setString:[appDelegate applicationSupportFolder]];
	[ppath appendString:@"/Preferences"];
	
	self.preferencesPath = [NSMutableString stringWithString:ppath];
	NSMutableString * path = [NSMutableString stringWithString:[appDelegate applicationSupportFolder]];
	[path appendString:@"/retailRefunded"];
	self.retailRefundedPath = path;
	
	[progressIndicator setIndeterminate:NO];
	[progressIndicatorCalendarFormat setIndeterminate:NO];

	[firstWeekPicker setDateValue:[NSDate date]];
	[lastWeekPicker setDateValue:[NSDate date]];
	 
	[firstWeekPickerCalendarFormat setDateValue:[NSDate date]];
	[lastWeekPickerCalendarFormat setDateValue:[NSDate date]];
	
	[firstWeekPickerRetention setDateValue:[NSDate date]];
	[lastWeekPickerRetention setDateValue:[NSDate date]];
	
	moc = [appDelegate managedObjectContext];
}
-(IBAction)goToInitialCount:(id)sender
{
	// fetch initial count for [NSDAte date] if none proceed TODO  ---> override = YES

	NSCalendarDate * today = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];	
	[initialCountWindow setTitle:[today description]];
	[startOnes setIntValue:0];
	[startFives setIntValue:0];
	[startTens setIntValue:0];
	[startTwenties setIntValue:0];
	[startFifties setIntValue:0];
	[startHundreds setIntValue:0];
	[startChange setDoubleValue:0.0];
	
	if ([self fetchInitialCount])	{
		override = YES;
		SEL selector = @selector(passwordEnteredForCountRegister:);
		[passwordController getPasswordFor:self arguments:nil selector:selector];
	} else	{
		override = NO;
		
		[initialCountWindow makeKeyAndOrderFront:self];
	}
}
-(IBAction)goToMiddayCloseout:(id)sender
{
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	[countRegisterWindow setTitle:[today description]];
	finalCount = NO;
	override = NO;

	BOOL test = [[[self fetchFullCount] valueForKey:@"isFinal"] boolValue];
	if (test)	{
		
	} else	{
		[fullOnes setIntValue:0];
		[fullFives setIntValue:0];
		[fullTens setIntValue:0];
		[fullTwenties setIntValue:0];
		[fullFifties setIntValue:0];
		[fullHundreds setIntValue:0];
		[creditBatchTips setDoubleValue:0];
		[creditBatchTotal setDoubleValue:0];
		[checks setDoubleValue:0];
		[fullChange setDoubleValue:0.0];
		[countRegisterButton setTitle:@"Make Midday Report"];
		[countRegisterWindow makeKeyAndOrderFront:self];
	}
		
	
}
-(IBAction)goToCloseRegister:(id)sender
{
	NSCalendarDate * today = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];	
	[countRegisterWindow setTitle:[today description]];
	// fetch initial count for [NSDAte date] if none proceed TODO   ---> override = YES
	[fullOnes setIntValue:0];
	[fullFives setIntValue:0];
	[fullTens setIntValue:0];
	[fullTwenties setIntValue:0];
	[fullFifties setIntValue:0];
	[fullHundreds setIntValue:0];
	[creditBatchTips setDoubleValue:0];
	[creditBatchTotal setDoubleValue:0];
	[checks setDoubleValue:0];
	[fullChange setDoubleValue:0.0];
	[countRegisterButton setTitle:@"Make Final Report"];
	
	finalCount = YES;
	BOOL test = [[[self fetchFullCount] valueForKey:@"isFinal"] boolValue];
	if (test)	{
		//
		override = YES;
		SEL selector = @selector(passwordEnteredForCountRegister:);
		[passwordController getPasswordFor:self arguments:nil selector:selector];
	} else	{
		override = NO;
		[countRegisterWindow makeKeyAndOrderFront:self];
		
		
	}

	
	
}

-(void)passwordEnteredForCountRegister:(NSManagedObject*)password
{
	if ([password valueForKey:@"passwordLevel"] != nil)	{
		int passwordLevel = [[password valueForKey:@"passwordLevel"] intValue];
		id test = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordLevelsPath];
		
		if (passwordLevel >= [[test valueForKey:@"viewReportsLevel"] intValue] )	{
			[countRegisterWindow makeKeyAndOrderFront:self];
		}
	}
			
}
-(IBAction)registerInitialCount:(id)sender
{
	if (!override)	{
		NSManagedObject * initialCount = [NSEntityDescription insertNewObjectForEntityForName:@"InitialCount" inManagedObjectContext:moc];
		[initialCount setValue:[mainDatePicker dateValue] forKey:@"time"];
		[initialCount setValue:[NSNumber numberWithInt:[startOnes intValue]] forKey:@"ones"];
		[initialCount setValue:[NSNumber numberWithInt:[startFives intValue]] forKey:@"fives"];
		[initialCount setValue:[NSNumber numberWithInt:[startTens intValue]] forKey:@"tens"];
		[initialCount setValue:[NSNumber numberWithInt:[startTwenties intValue]] forKey:@"twenties"];
		[initialCount setValue:[NSNumber numberWithInt:[startFifties intValue]] forKey:@"fifties"];
		[initialCount setValue:[NSNumber numberWithInt:[startHundreds intValue]] forKey:@"hundreds"];
		[initialCount setValue:[NSNumber numberWithDouble:[startChange doubleValue]] forKey:@"change"];
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	}
	[initialCountWindow close];
}
-(IBAction)registerFullCount:(id)sender
{
	if (!override)	{
		NSManagedObject * fullCount = [NSEntityDescription insertNewObjectForEntityForName:@"FullCount" inManagedObjectContext:moc];
		[fullCount setValue:[mainDatePicker dateValue] forKey:@"time"];
		[fullCount setValue:[NSNumber numberWithInt:[fullOnes intValue]] forKey:@"ones"];
		[fullCount setValue:[NSNumber numberWithInt:[fullFives intValue]] forKey:@"fives"];
		[fullCount setValue:[NSNumber numberWithInt:[fullTens intValue]] forKey:@"tens"];
		[fullCount setValue:[NSNumber numberWithInt:[fullTwenties intValue]] forKey:@"twenties"];
		[fullCount setValue:[NSNumber numberWithInt:[fullFifties intValue]] forKey:@"fifties"];
		[fullCount setValue:[NSNumber numberWithInt:[fullHundreds intValue]] forKey:@"hundreds"];
		[fullCount setValue:[NSNumber numberWithInt:[checks doubleValue]] forKey:@"checks"];
		[fullCount setValue:[NSNumber numberWithDouble:[fullChange doubleValue]] forKey:@"change"];
		[fullCount setValue:[NSNumber numberWithInt:[creditBatchTotal doubleValue]] forKey:@"creditBatchTotal"];
		[fullCount setValue:[NSNumber numberWithInt:[creditBatchTips doubleValue]] forKey:@"creditBatchTips"];
		[fullCount setValue:[NSNumber numberWithBool:finalCount] forKey:@"isFinal"];
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
		if (finalCount == YES)	{
			[self sendEmailReminderToServiceProviders];
		}
	} else {
		[self wipeCloseouts];
		if (finalCount == YES)	{
			NSManagedObject * fullCount = [NSEntityDescription insertNewObjectForEntityForName:@"FullCount" inManagedObjectContext:moc];
			[fullCount setValue:[mainDatePicker dateValue] forKey:@"time"];
			[fullCount setValue:[NSNumber numberWithInt:[fullOnes intValue]] forKey:@"ones"];
			[fullCount setValue:[NSNumber numberWithInt:[fullFives intValue]] forKey:@"fives"];
			[fullCount setValue:[NSNumber numberWithInt:[fullTens intValue]] forKey:@"tens"];
			[fullCount setValue:[NSNumber numberWithInt:[fullTwenties intValue]] forKey:@"twenties"];
			[fullCount setValue:[NSNumber numberWithInt:[fullFifties intValue]] forKey:@"fifties"];
			[fullCount setValue:[NSNumber numberWithInt:[fullHundreds intValue]] forKey:@"hundreds"];
			[fullCount setValue:[NSNumber numberWithInt:[checks doubleValue]] forKey:@"checks"];
			[fullCount setValue:[NSNumber numberWithDouble:[fullChange doubleValue]] forKey:@"change"];
			[fullCount setValue:[NSNumber numberWithInt:[creditBatchTotal doubleValue]] forKey:@"creditBatchTotal"];
			[fullCount setValue:[NSNumber numberWithInt:[creditBatchTips doubleValue]] forKey:@"creditBatchTips"];
			[fullCount setValue:[NSNumber numberWithBool:finalCount] forKey:@"isFinal"];
			error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
			
			[self sendEmailReminderToServiceProviders];
			
		}
	}

	[countRegisterWindow close];
}
-(NSManagedObject *)fetchFullCount
{
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSFetchRequest * fullCountRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * fullDescription = [NSEntityDescription entityForName:@"FullCount" inManagedObjectContext:moc];
	[fullCountRequest setEntity:fullDescription];
	[fullCountRequest setPredicate:predicate];
	NSSortDescriptor * sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO] autorelease];
	[fullCountRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSArray * results = [moc executeFetchRequest:fullCountRequest error:&error];
	NSLog(@"executing Fetch full count");
	if ([results count] > 0)	{
		return [results objectAtIndex:0];	
	} else	{
		return nil;
	}
	
	
}
-(NSManagedObject *)fetchInitialCount
{
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSFetchRequest * initialCountRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * initialDescription = [NSEntityDescription entityForName:@"InitialCount" inManagedObjectContext:moc];
	[initialCountRequest setEntity:initialDescription];
	[initialCountRequest setPredicate:predicate];
	NSSortDescriptor * sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO] autorelease];
	[initialCountRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSArray * results = [moc executeFetchRequest:initialCountRequest error:&error];
	NSLog(@"executing Fetch initial count");
	if ([results count] > 0)	{
		return [results objectAtIndex:0];	
	} else	{
		return nil;
	}
}
-(NSDictionary *)fetchFullCountBetweenDates:(NSDate *)startDate endDate:(NSDate *)endDate
{
	NSCalendarDate * workingDate = [startDate dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	workingDate = [endDate dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSFetchRequest * fullCountRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * fullDescription = [NSEntityDescription entityForName:@"FullCount" inManagedObjectContext:moc];
	[fullCountRequest setEntity:fullDescription];
	[fullCountRequest setPredicate:predicate];
	NSSortDescriptor * sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO] autorelease];
	[fullCountRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSArray * results = [moc executeFetchRequest:fullCountRequest error:&error];
	NSLog(@"executing Fetch full count");
	
	// calculate
	
	
	double change = 0;
	checkTotal = 0;
	creditTips = 0;
	creditTotal = 0;
	int fifties = 0;
	int fives = 0;
	int hundreds = 0;
	int ones = 0;
	int tens = 0;
	int twenties = 0;
	
	while ([startDate timeIntervalSinceDate:endDate] < 0)	{
		NSDate * workingDate = [[startDate dateWithCalendarFormat:@"" timeZone:nil] dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
		
		NSMutableArray * array = [NSMutableArray arrayWithArray:results];
		NSPredicate * timePredicate = [NSPredicate predicateWithFormat:@"time > %@ AND time < %@",startDate, workingDate];
		
		[array filterUsingPredicate:timePredicate];
		NSSortDescriptor * timeSort = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO] autorelease];
		[array sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
		
		if ([array count] > 0)	{
	
			NSManagedObject * closeOut = [array objectAtIndex:0];
			change += [[closeOut valueForKey:@"change"] doubleValue];
			checkTotal += [[closeOut valueForKey:@"checks"] doubleValue];
			creditTips += [[closeOut valueForKey:@"creditBatchTips"] doubleValue];
			creditTotal += [[closeOut valueForKey:@"creditBatchTotal"] doubleValue];
			fifties += [[closeOut valueForKey:@"fifties"] intValue];
			fives += [[closeOut valueForKey:@"fives"] intValue];
			hundreds += [[closeOut valueForKey:@"hundreds"] intValue];
			ones += [[closeOut valueForKey:@"ones"] intValue];
			tens += [[closeOut valueForKey:@"tens"] intValue];
			twenties += [[closeOut valueForKey:@"twenties"] intValue];
			
		}
		startDate = [[startDate dateWithCalendarFormat:@"" timeZone:nil] dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
		
	}
	
	NSMutableDictionary * result = [NSMutableDictionary dictionary];
	[result setObject:[NSNumber numberWithFloat:change] forKey:@"change"];
	[result setObject:[NSNumber numberWithFloat:checkTotal] forKey:@"checks"];
	[result setObject:[NSNumber numberWithFloat:creditTips] forKey:@"creditBatchTips"];
	[result setObject:[NSNumber numberWithFloat:creditTotal] forKey:@"creditBatchTotal"];
	[result setObject:[NSNumber numberWithInt:fifties] forKey:@"fifties"];
	[result setObject:[NSNumber numberWithInt:fives] forKey:@"fives"];
	[result setObject:[NSNumber numberWithInt:hundreds] forKey:@"hundreds"];
	[result setObject:[NSNumber numberWithInt:ones] forKey:@"ones"];
	[result setObject:[NSNumber numberWithInt:tens] forKey:@"tens"];
	[result setObject:[NSNumber numberWithInt:twenties] forKey:@"twenties"];
	
	return result;
	
	
}
-(NSDictionary *)fetchInitialCountBetweenDates:(NSDate *)startDate endDate:(NSDate *)endDate
{
	NSCalendarDate * workingDate = [startDate dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	workingDate = [endDate dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSFetchRequest * fullCountRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * fullDescription = [NSEntityDescription entityForName:@"InitialCount" inManagedObjectContext:moc];
	[fullCountRequest setEntity:fullDescription];
	[fullCountRequest setPredicate:predicate];
	NSSortDescriptor * sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO] autorelease];
	[fullCountRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSArray * results = [moc executeFetchRequest:fullCountRequest error:&error];
	NSLog(@"executing Fetch full count");
	
	// calculate
	
	
	double change = 0;
	checks = 0;
	creditTips = 0;
	creditTotal = 0;
	int fifties = 0;
	int fives = 0;
	int hundreds = 0;
	int ones = 0;
	int tens = 0;
	int twenties = 0;
	
	while ([startDate timeIntervalSinceDate:endDate] < 0)	{
		NSDate * workingDate = [[startDate dateWithCalendarFormat:@"" timeZone:nil] dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
		
		NSMutableArray * array = [NSMutableArray arrayWithArray:results];
		NSPredicate * timePredicate = [NSPredicate predicateWithFormat:@"time > %@ AND time < %@",startDate, workingDate];
		
		[array filterUsingPredicate:timePredicate];
		NSSortDescriptor * timeSort = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO] autorelease];
		[array sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
		
		if ([array count] > 0)	{
			
			NSManagedObject * closeOut = [array objectAtIndex:0];
			change += [[closeOut valueForKey:@"change"] doubleValue];
			fifties += [[closeOut valueForKey:@"fifties"] intValue];
			fives += [[closeOut valueForKey:@"fives"] intValue];
			hundreds += [[closeOut valueForKey:@"hundreds"] intValue];
			ones += [[closeOut valueForKey:@"ones"] intValue];
			tens += [[closeOut valueForKey:@"tens"] intValue];
			twenties += [[closeOut valueForKey:@"twenties"] intValue];
		
		}
		startDate = [[startDate dateWithCalendarFormat:@"" timeZone:nil] dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
		
	}
	
	NSMutableDictionary * result = [NSMutableDictionary dictionary];
	[result setObject:[NSNumber numberWithFloat:change] forKey:@"change"];
	[result setObject:[NSNumber numberWithInt:fifties] forKey:@"fifties"];
	[result setObject:[NSNumber numberWithInt:fives] forKey:@"fives"];
	[result setObject:[NSNumber numberWithInt:hundreds] forKey:@"hundreds"];
	[result setObject:[NSNumber numberWithInt:ones] forKey:@"ones"];
	[result setObject:[NSNumber numberWithInt:tens] forKey:@"tens"];
	[result setObject:[NSNumber numberWithInt:twenties] forKey:@"twenties"];
	
	return result;
}
-(NSManagedObject *)fetchFullCount:(NSDate *)date
{
	NSCalendarDate * workingDate = [date dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSFetchRequest * fullCountRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * fullDescription = [NSEntityDescription entityForName:@"FullCount" inManagedObjectContext:moc];
	[fullCountRequest setEntity:fullDescription];
	[fullCountRequest setPredicate:predicate];
	NSSortDescriptor * sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO] autorelease];
	[fullCountRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSArray * results = [moc executeFetchRequest:fullCountRequest error:&error];
	NSLog(@"executing Fetch full count");
	if ([results count] > 0)	{
		return [results objectAtIndex:0];	
	} else	{
		return nil;
	}
	
}
-(NSManagedObject *)fetchInitialCount:(NSDate *)date
{
	NSCalendarDate * workingDate = [date dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSFetchRequest * initialCountRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * initialDescription = [NSEntityDescription entityForName:@"InitialCount" inManagedObjectContext:moc];
	[initialCountRequest setEntity:initialDescription];
	[initialCountRequest setPredicate:predicate];
	NSSortDescriptor * sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO] autorelease];
	[initialCountRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSArray * results = [moc executeFetchRequest:initialCountRequest error:&error];
	NSLog(@"executing Fetch initial");
	if ([results count] > 0)	{
		return [results objectAtIndex:0];	
	} else	{
		return nil;
	}
}
-(IBAction)viewDailyPaperwork:(id)sender
{
	
	NSArray * dailyArray = [self viewDailyPaperworkForDate:[mainDatePicker dateValue]];
	[dailyArrayController setContent:dailyArray];
	[dailyDate setObjectValue:[mainDatePicker dateValue]];
	[dailyInfoWindow makeKeyAndOrderFront:self];
}
-(double)employeeBookingForDay:(NSManagedObject *)employee
{
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	NSPredicate * todayPredicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	todayPredicate = [todayPredicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSMutableArray * appointments = [NSMutableArray array];
	NSFetchRequest * apptRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * apptDescription = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
	[apptRequest setEntity:apptDescription];
	[apptRequest setPredicate:todayPredicate];
	[appointments addObjectsFromArray:[moc executeFetchRequest:apptRequest error:&error]];
	NSLog(@"executing Fetch appointment");

	
	
	float total = 0;
	NSMutableSet * stylistTransactions = [NSMutableSet setWithArray:appointments];
	NSMutableArray * stylistServices = [NSMutableArray array];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"stylist == %@", employee];
	[stylistTransactions filterUsingPredicate:predicate];
	NSArray * stylistTransactionsArray = [stylistTransactions allObjects];
	int j;
	for (j=0 ; j< [stylistTransactionsArray count]; j++)	{
		int k;
		NSMutableSet * services = [[stylistTransactionsArray objectAtIndex:j] valueForKey:@"services"];
		NSArray * serviceArray = [services allObjects];
		for (k=0 ; k < [serviceArray count]; k++)	{
			total += [[[serviceArray objectAtIndex:k] valueForKey:@"price"] doubleValue];
		}
			 
		
	}	
	
	
	return total;
}
-(double)employeeBookingForDay:(NSManagedObject *)employee forDate:(NSDate *)date
{
	NSCalendarDate * workingDate = [date dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	NSPredicate * todayPredicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	todayPredicate = [todayPredicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSMutableArray * appointments = [NSMutableArray array];
	NSFetchRequest * apptRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * apptDescription = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
	[apptRequest setEntity:apptDescription];
	[apptRequest setPredicate:todayPredicate];
	[appointments addObjectsFromArray:[moc executeFetchRequest:apptRequest error:&error]];
	NSLog(@"executing Fetch appointment");
	
	
	
	float total = 0;
	NSMutableSet * stylistTransactions = [NSMutableSet setWithArray:appointments];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"stylist == %@", employee];
	[stylistTransactions filterUsingPredicate:predicate];
	NSArray * stylistTransactionsArray = [stylistTransactions allObjects];
	int j;
	for (j=0 ; j< [stylistTransactionsArray count]; j++)	{
		int k;
		NSMutableSet * services = [[stylistTransactionsArray objectAtIndex:j] valueForKeyPath:@"services"];
		NSArray * serviceArray = [services allObjects];
		for (k=0 ; k < [serviceArray count]; k++)	{
			total += [[[serviceArray objectAtIndex:k] valueForKey:@"price"] doubleValue];
		}
		
	}	
	
	
	return total;
}

-(NSArray *)timeCardsInfoBetweenDates:(NSDate *)startDate endDate:(NSDate *)endDate
{
	NSArray * employees = [staffController clockedEmployees];
	NSMutableArray * finalDetails = [NSMutableArray array];
	NSLog(@"employees %@", employees);
	int i;
	for (i=0; i< [employees count]; i++)	{
		NSCalendarDate * workingDate = [startDate dateWithCalendarFormat:@"" timeZone:nil];
		int month, day, year;
		month = [workingDate monthOfYear];
		day = [workingDate dayOfMonth];
		year = [workingDate yearOfCommonEra];
		NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];

		
		workingDate = [endDate dateWithCalendarFormat:@"" timeZone:nil];
		month = [workingDate monthOfYear];
		day = [workingDate dayOfMonth];
		year = [workingDate yearOfCommonEra];
		
		NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
		endOfDay = [endOfDay dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
		
		
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"employee == %@ AND date > $BEGINNING AND date < $END", [employees objectAtIndex:i]];
		predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
		
		NSFetchRequest * timeCardRequest = [[[NSFetchRequest alloc] init] autorelease];
		NSEntityDescription * timeCardDescription = [NSEntityDescription entityForName:@"TimeCard" inManagedObjectContext:moc];
		[timeCardRequest setEntity:timeCardDescription];
		[timeCardRequest setPredicate:predicate];
		
		NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:timeCardRequest error:&error]];
		NSLog(@"executing Fetch timecard");
		int count = [results count];
		NSLog(@"results %@", results);
		NSSortDescriptor * timeSort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
		[results sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
		[timeSort release];
		double dcount = count/2.0;
		
		count = count/ 2;
		float time = 0;
		
		// somehow missing first time card // as long as there are 4 time cards this is fixed
		if ((count - dcount) != 0)	{
			double x = dcount-1.0; 
			int j;
			for (j=0; j < x; j++)	{
				int index = ((j+1)*2) - 1;
				NSTimeInterval interval = [[[results objectAtIndex:index] valueForKey:@"date"] timeIntervalSinceDate:[[results objectAtIndex:index-1] valueForKey:@"date"]];
				
				time += interval;
			}
			
		} else	{
			int j;
			for (j=0; j < count; j++)	{
				
				int index = ((j+1)*2) - 1;
				NSTimeInterval interval = [[[results objectAtIndex:index] valueForKey:@"date"] timeIntervalSinceDate:[[results objectAtIndex:index-1] valueForKey:@"date"]];
				
				time += interval;
			}
			
		}
		time /= 3600;
		[finalDetails addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@'s Hours" ,[[employees objectAtIndex:i] valueForKey:@"name"]], @"description", [NSNumber numberWithFloat:time], @"amount", nil]];
		
	}
	return finalDetails;
}

-(NSArray *)timeCardsInfoForDate:(NSDate *)date
{
	NSArray * employees = [self fetchAssistantsForDate:date];
	NSMutableArray * finalDetails = [NSMutableArray array];
	
	int i;
	for (i=0; i< [employees count]; i++)	{
		NSCalendarDate * workingDate = [date dateWithCalendarFormat:@"" timeZone:nil];
		int month, day, year;
		month = [workingDate monthOfYear];
		day = [workingDate dayOfMonth];
		year = [workingDate yearOfCommonEra];
		NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
		day++;
		NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
		
		
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"employee == %@ AND date > $BEGINNING AND date < $END", [employees objectAtIndex:i]];
		predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
		
		NSFetchRequest * timeCardRequest = [[[NSFetchRequest alloc] init] autorelease];
		NSEntityDescription * timeCardDescription = [NSEntityDescription entityForName:@"TimeCard" inManagedObjectContext:moc];
		[timeCardRequest setEntity:timeCardDescription];
		[timeCardRequest setPredicate:predicate];
		
		NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:timeCardRequest error:&error]];
		NSLog(@"executing Fetch timecard");
		int count = [results count];
		
		NSSortDescriptor * timeSort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
		[results sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
		[timeSort release];
		double dcount = count/2.0;
		
		count = count/ 2;
		float time = 0;
		

		if ((count - dcount) != 0)	{
			int x = count-1; 
			int j;
			for (j=0; j < x; j++)	{
				int index = ((j+1)*2) - 1;
				NSTimeInterval interval = [[[results objectAtIndex:index] valueForKey:@"date"] timeIntervalSinceDate:[[results objectAtIndex:index-1] valueForKey:@"date"]];
				
				time += interval;
			}
			
		} else	{
			int j;
			for (j=0; j < count; j++)	{
				
				int index = ((j+1)*2) - 1;
				NSTimeInterval interval = [[[results objectAtIndex:index] valueForKey:@"date"] timeIntervalSinceDate:[[results objectAtIndex:index-1] valueForKey:@"date"]];
				
				time += interval;
			}
			
		}
		time /= 3600;
		[finalDetails addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@'s Hours" ,[[employees objectAtIndex:i] valueForKey:@"name"]], @"description", [NSNumber numberWithFloat:time], @"amount", nil]];
		
	}
	return finalDetails;
}
-(NSArray *)timeCardInfoForEmployee:(NSManagedObject*)employee forWeekWithDate:(NSDate*)date
{
	return nil;
}
-(IBAction)goToReportForExtendedTimePeriod:(id)sender
{
	NSArray * serviceProviders = [self fetchStylists];
	NSMutableArray * choices = [NSMutableArray array];
	int i;
	for (i=0; i< [serviceProviders count]; i++)	{
		[choices addObject:[[serviceProviders objectAtIndex:i] valueForKey:@"name"]];
	}
	[choices addObjectsFromArray:[NSArray  arrayWithObjects:@"Service Total", @"Service Tax", @"Retail Total", @"Retail Tax", @"Transactions Total", @"Payouts", @"Employee (+/-)", @"Service Transactions", @"Service/Service Transaction", @"Transactions", @"Retail/Tran",@"Credit Total", nil]]; 
	NSArray * hourlyEmployees = [self fetchAssistants];
	for (i=0; i < [hourlyEmployees count]; i++)	{
		[choices addObject:[NSString stringWithFormat:@"%@'s Hours", [[hourlyEmployees objectAtIndex:i] valueForKey:@"name"]]];
		
		
	}

	[reportItemsController setContent:choices];
	[reportSetUpPage makeKeyAndOrderFront:self];
}
-(IBAction)weekChosenForMultipleReports:(id)sender
{
	NSCalendarDate * firstWeek = [[firstWeekPicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	int dayOfWeek = [firstWeek dayOfWeek];
	firstWeek = [firstWeek dateByAddingYears:0 months:0 days:-dayOfWeek hours:0 minutes:0 seconds:0];
	[firstWeekPicker setDateValue:firstWeek];
	
	NSCalendarDate * lastWeek = [[lastWeekPicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	dayOfWeek = [lastWeek dayOfWeek];
	lastWeek = [lastWeek dateByAddingYears:0 months:0 days:6-dayOfWeek hours:0 minutes:0 seconds:0];
	[lastWeekPicker setDateValue:lastWeek];

}
-(NSMutableArray *)generatePaperworkStartingDate:(NSDate *)startDate endingDate:(NSDate *)endingDate
{
	NSMutableArray * dailyArray = [NSMutableArray array];
	NSCalendarDate * selectedDate = [startDate dateWithCalendarFormat:@"%a. %b. %d, %Y" timeZone:nil];
	NSCalendarDate * endDate = [endingDate dateWithCalendarFormat:@"%a. %b. %d, %Y" timeZone:nil];
	NSString * title = [NSString stringWithFormat:@"Daily Info --- %@", selectedDate];
	[dailyInfoWindow setTitle:title];
	
	// query  payouts and load arraycontrollers ...
	
	NSCalendarDate * workingDate = [selectedDate dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	int endMonth, endDay, endYear;
	endMonth = [endDate monthOfYear];
	endYear = [endDate yearOfCommonEra];
	endDay = [endDate dayOfMonth];
	endDay++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:endYear month:endMonth day:endDay hour:0 minute:0 second:0 timeZone:nil];
	
	
	NSPredicate * todayPredicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	todayPredicate = [todayPredicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	
	
	
	double total = 0;
	retailTaxCollected = 0;
	retailTotal = 0;
	serviceTaxCollected = 0;
	serviceTotal = 0;
	NSArray * serviceProviders = [staffController workingServiceProviders:workingDate];
	NSLog(@"serviceProviders %@", serviceProviders);
	NSArray * timeCardInfo = [self timeCardsInfoForDate:workingDate];
	int i;
	int j;
	
	int serviceTransactions = 0;
	double transactionsTotal =0;
	NSMutableArray * transactions = [NSMutableArray array];
	NSFetchRequest * transactionRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * transactionDescription = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc];
	[transactionRequest setEntity:transactionDescription];
	[transactionRequest setPredicate:todayPredicate];
	[transactions addObjectsFromArray:[moc executeFetchRequest:transactionRequest error:&error]];
	NSLog(@"executing Fetch transaction");
	int transactionsCount = [transactions count];
	NSMutableArray * serviceTotals = [NSMutableArray array];
	NSMutableArray * transactionsTakenCareOf = [NSMutableArray array];
	
	for (i=0; i < [transactions count]; i++)	{
		transactionsTotal += [[[transactions objectAtIndex:i] valueForKey:@"transactionTotal"] doubleValue];
	}
	for (i=0; i<[serviceProviders count]; i++)	{
		total = 0;
		NSMutableSet * stylistTransactions = [NSMutableSet setWithArray:transactions];
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"appointment.stylist == %@", [serviceProviders objectAtIndex:i]];
		[stylistTransactions filterUsingPredicate:predicate];
		NSArray * stylistTransactionsArray = [stylistTransactions allObjects];
		for (j=0 ; j< [stylistTransactionsArray count]; j++)	{
			total += [[[stylistTransactionsArray objectAtIndex:j] valueForKey:@"serviceSubtotal"] doubleValue];
			serviceTaxCollected += [[[stylistTransactionsArray objectAtIndex:j] valueForKey:@"serviceTax"] doubleValue];
			retailTaxCollected += [[[stylistTransactionsArray objectAtIndex:j] valueForKey:@"retailTax"] doubleValue];
			retailTotal += [[[stylistTransactionsArray objectAtIndex:j] valueForKey:@"retailSubtotal"] doubleValue];
		}
		[serviceTotals addObject:[NSNumber numberWithDouble:total]];
		serviceTotal += total;
		[transactionsTakenCareOf addObjectsFromArray:stylistTransactionsArray];
	}
	serviceTransactions = [transactionsTakenCareOf count];
	[transactions removeObjectsInArray:transactionsTakenCareOf];
	for (i=0; i< [transactions count]; i++)	{
		retailTaxCollected += [[[transactions objectAtIndex:i] valueForKey:@"retailTax"] doubleValue];
		retailTotal += [[[transactions objectAtIndex:i] valueForKey:@"retailSubtotal"] doubleValue];	
	}
	NSArray * miscellaneous = [self fetchMiscellaneous:workingDate];
	NSArray * payoutArray = [self fetchPayouts:workingDate];
	NSArray * empInfoArray = [self fetchEmpPlusMinus:workingDate];
	miscPlus = 0;
	miscMinus = 0;
	for (i=0; i< [miscellaneous count]; i++)	{
		if ([[[miscellaneous objectAtIndex:i] valueForKey:@"isPlus"] boolValue] == YES)	{
			miscPlus += [[[miscellaneous objectAtIndex:i] valueForKey:@"amount"] doubleValue];
		} else	{
			miscMinus += [[[miscellaneous objectAtIndex:i] valueForKey:@"amount"] doubleValue];
		}
	}
	payouts = 0;
	for (i=0; i < [payoutArray count]; i++)	{
		payouts += [[[payoutArray objectAtIndex:i] valueForKey:@"amount"] doubleValue];
	}
	employeePlusMinus = 0;
	for (i=0; i < [empInfoArray count]; i++)	{
		if ([[[empInfoArray objectAtIndex:i] valueForKey:@"isPlus"] boolValue] == YES)	{
			employeePlusMinus += [[[empInfoArray objectAtIndex:i] valueForKey:@"amount"] doubleValue];
		} else	{
			employeePlusMinus -= [[[empInfoArray objectAtIndex:i] valueForKey:@"amount"] doubleValue];
		}
	}
	// get start
	NSManagedObject * initialStart = [self fetchInitialCount:workingDate];
	start = 0;
	if (initialStart)	{
		start = [[initialStart valueForKey:@"ones"] intValue];
		start += ([[initialStart valueForKey:@"fives"] intValue] * 5);
		start += ([[initialStart valueForKey:@"tens"] intValue] * 10);
		start += ([[initialStart valueForKey:@"twenties"] intValue] * 20);
		start += ([[initialStart valueForKey:@"fifties"] intValue] * 50);
		start += ([[initialStart valueForKey:@"hundreds"] intValue] * 100);
		start += ([[initialStart valueForKey:@"change"] doubleValue]);
	}
	NSManagedObject * fullCount = [self fetchFullCount:workingDate];
	cash = 0;
	creditTotal = 0;
	creditTips = 0;
	checkTotal = 0;
	if (fullCount)	{
		cash = [[fullCount valueForKey:@"ones"] intValue];
		cash += ([[fullCount valueForKey:@"fives"] intValue] * 5);
		cash += ([[fullCount valueForKey:@"tens"] intValue] * 10);
		cash += ([[fullCount valueForKey:@"twenties"] intValue] * 20);
		cash += ([[fullCount valueForKey:@"fifties"] intValue] * 50);
		cash += ([[fullCount valueForKey:@"hundreds"] intValue] * 100);
		cash += ([[fullCount valueForKey:@"change"] intValue]);
		creditTotal = [[fullCount valueForKey:@"creditBatchTotal"] doubleValue];
		creditTips = [[fullCount valueForKey:@"creditBatchTips"] doubleValue];
		checkTotal = [[fullCount valueForKey:@"checks"] doubleValue];
	}
	expected = transactionsTotal + start  + miscPlus - payouts - miscMinus + employeePlusMinus;
	have = cash + creditTotal + checkTotal;
	dailyPlusMinus = have - expected;
	
	for (i=0; i< [serviceProviders count]; i++)	{
		[dailyArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[serviceProviders objectAtIndex:i] valueForKey:@"name"], @"description", [serviceTotals objectAtIndex:i], @"amount", nil]];
	}
	
	
	NSMutableDictionary * newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Service Total", @"description", [NSNumber numberWithDouble:serviceTotal], @"amount", nil];
	[dailyArray addObject:newObject];
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Service Tax", @"description", [NSNumber numberWithDouble:serviceTaxCollected], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Retail Total", @"description", [NSNumber numberWithDouble:retailTotal], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Retail Tax", @"description", [NSNumber numberWithDouble:retailTaxCollected], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Transactions Total", @"description", [NSNumber numberWithDouble:transactionsTotal], @"amount", nil];
	[dailyArray addObject:newObject];
	
	
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Start", @"description", [NSNumber numberWithDouble:start], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Miscellaneous (+)", @"description", [NSNumber numberWithDouble:miscPlus], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Miscellaneous (-)", @"description", [NSNumber numberWithDouble:miscMinus], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Payouts", @"description", [NSNumber numberWithDouble:payouts], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Employee (+/-)", @"description", [NSNumber numberWithDouble:employeePlusMinus], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Expected", @"description", [NSNumber numberWithDouble:expected], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Cash", @"description", [NSNumber numberWithDouble:cash], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Check Total", @"description", [NSNumber numberWithDouble:checkTotal], @"amount", nil];
	[dailyArray addObject:newObject];
	
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Credit Total", @"description", [NSNumber numberWithDouble:creditTotal], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Have", @"description", [NSNumber numberWithDouble:have], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"(+/-)", @"description", [NSNumber numberWithDouble:dailyPlusMinus], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Credit Tips", @"description", [NSNumber numberWithDouble:creditTips], @"amount", nil];
	[dailyArray addObject:newObject];
	
	
	for (i=0 ; i< [timeCardInfo count] ;i++)	{
		[dailyArray addObject:[timeCardInfo objectAtIndex:i]];
	}
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Service Transactions", @"description", [NSNumber numberWithInt:serviceTransactions], @"amount", nil];
	[dailyArray addObject:newObject];
	float serviceAverage = 0;
	if (serviceTransactions != 0)	{
		serviceAverage = serviceTotal / serviceTransactions;
	}
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Service/Service Transaction", @"description", [NSNumber numberWithFloat:serviceAverage], @"amount", nil];
	[dailyArray addObject:newObject];	
	
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Transactions", @"description", [NSNumber numberWithInt:transactionsCount], @"amount", nil];
	[dailyArray addObject:newObject];
	float rpt = 0;
	if (transactionsCount != 0)	{
		rpt = retailTotal / transactionsCount;
	}
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Retail/Tran", @"description", [NSNumber numberWithFloat:rpt], @"amount", nil];
	[dailyArray addObject:newObject];	
	
	
	
	
	return dailyArray;
}
-(IBAction)generateReportForMultipleWeeks:(id)sender
{
	int weekCount;
	NSCalendarDate * firstWeek = [[firstWeekPicker dateValue] dateWithCalendarFormat:@"%m/%d" timeZone:nil];
	int dayOfWeek = [firstWeek dayOfWeek];
	firstWeek = [firstWeek dateByAddingYears:0 months:0 days:-dayOfWeek hours:0 minutes:0 seconds:0];
	NSCalendarDate * lastWeek = [[lastWeekPicker dateValue] dateWithCalendarFormat:@"%m/%d" timeZone:nil];
	NSMutableArray * weeks = [NSMutableArray array];
	NSCalendarDate * workingDate = [firstWeek dateByAddingYears:0 months:0 days:6 hours:0 minutes:0 seconds:0];
	NSTimeInterval timeInterval = [lastWeek timeIntervalSinceDate:workingDate];
	weekCount = timeInterval/(60*60*24*7);
	weekCount += 2;
	NSMutableArray * weeksArray = [NSMutableArray array];
	[progressIndicator setDoubleValue:0.0];
	while([workingDate dayOfCommonEra] <= [lastWeek dayOfCommonEra])	{
		[progressIndicator incrementBy:100.0/weekCount];
		[progressIndicator displayIfNeeded];
		[weeks addObject:[self viewWeeklyPaperworkForDate:workingDate]];
		[weeksArray addObject:workingDate];
		
		
		workingDate = [workingDate dateByAddingYears:0 months:0 days:7 hours:0 minutes:0 seconds:0];
	}
	NSMutableArray * results = [NSMutableArray array];
	int i;
	int j;
	int k;
	BOOL matches = NO;
	NSArray * reportItems = [reportItemsController selectedObjects];
	for (k=0; k< [reportItems count]; k++)	{
		[results addObject:[NSMutableArray arrayWithObject:[reportItems objectAtIndex:k]]];
		for (i=0; i< [weeks count]; i++)	{
			NSMutableArray * result = [results objectAtIndex:k];
			NSArray * week = [weeks objectAtIndex:i];
			matches = NO;
			for (j=0 ; j< [week count]; j++)	{
				
				if ([[reportItems objectAtIndex:k] compare:[[week objectAtIndex:j] valueForKey:@"description"]] == NSOrderedSame)	{
					
					NSMutableDictionary * entry = [week objectAtIndex:j];
					[result addObject:[entry valueForKey:@"Week"]];
					matches = YES;
				}
				
					
			}
			if (matches == NO)	{
				[result addObject:[NSNumber numberWithInt:0]];
			}
			
		}
			
	}
	
	NSDictionary* errorDict;
	NSAppleEventDescriptor* returnDescriptor = NULL;
	
	NSString * path = [NSString stringWithFormat:@"%@/Contents/Resources/weeklyOriginal.cwk",[[NSBundle mainBundle] bundlePath]];
	

	path = [path stringByReplacingOccurrencesOfString:@"/Users" withString:@"Macintosh HD:Users"];
	path = [path stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
	path = [path stringByReplacingOccurrencesOfString:@"/" withString:@":"];
	
	NSMutableString * mstring = [NSMutableString string];
	[mstring appendFormat:@"tell application \"Finder\"\n\
	 open file \"%@\"\n\
	 tell application \"AppleWorks 6\"\n\
	 tell document 1\n", path];
	
	int row;
	int column;
	float total = 0;
	int sTransactions = 0;
	int transactions = 0;
	float rTotal;
	float sTotal;
	
	
	// drop week count for calculations
	weekCount--;
	for (i=0 ; i< [results count]; i++)	{
		total = 0;
		NSMutableArray * result = [results objectAtIndex:i];
		
		for(j= 0; j< [result count]; j++)	{
			row = j+1;
			column = i + 2;
			
			if (j>0)	{
				total += [[result objectAtIndex:j] floatValue];
				
			}
			

			
			[mstring appendFormat:@"set cell %d of row %d to \"\%@\"\n", column, row, [result objectAtIndex:j]];
		}
		if ([[result objectAtIndex:0] compare:@"Service/Service Transaction"] != NSOrderedSame && [[result objectAtIndex:0] compare:@"Retail/Tran"] != NSOrderedSame)	{
			[result addObject:[NSString stringWithFormat:@"%f", total]];
			[result addObject:[NSString stringWithFormat:@"%f", total/weekCount]];
			if ([[result objectAtIndex:0] compare:@"Service Transactions"] == NSOrderedSame)	{
				sTransactions = total;
			}
			if ([[result objectAtIndex:0] compare:@"Transactions"] == NSOrderedSame)	{
				transactions = total;
			}
			if ([[result objectAtIndex:0] compare:@"Service Total"] == NSOrderedSame)	{
				sTotal = total;
			}
			if ([[result objectAtIndex:0] compare:@"Retail Total"] == NSOrderedSame)	{
				rTotal = total;
			}
			
		
		} else	{
			
			if ([[result objectAtIndex:0] compare:@"Service/Service Transaction"] == NSOrderedSame)	{
				[result addObject:@"N/A"];
				total = sTotal/sTransactions;
				[result addObject:[NSString stringWithFormat:@"%f", total]];
			}
			if ([[result objectAtIndex:0] compare:@"Retail/Tran"] == NSOrderedSame)	{
				[result addObject:@"N/A"];
				total = rTotal/transactions;
				[result addObject:[NSString stringWithFormat:@"%f", total]];
			}
			
		}
	}
	
	for (i=0; i< [weeksArray count]; i++)	{
		[mstring appendFormat:@"set cell 1 of row %d to \"\%@\"\n", i+2, [weeksArray objectAtIndex:i]];
		
	}
	// set cells for totals and averages
	int index = [[results objectAtIndex:0] count];
	index = index-2;
	for (i=0; i< [results count]; i++)	{
		NSMutableArray * result = [results objectAtIndex:i];
		row = index+1;
		column = i + 2;
		
		[mstring appendFormat:@"set cell %d of row %d to \"\%@\"\n", column, row, [result objectAtIndex:index]];
			
		row = index+2;

		[mstring appendFormat:@"set cell %d of row %d to \"\%@\"\n", column, row, [result objectAtIndex:index+1]];
	}
	[mstring appendString:@"end tell\n\
	   end tell\n\
	 end tell"];
	// raise week count after calculations
	weekCount++;
	
	NSAppleScript * scriptObject = [[NSAppleScript alloc] initWithSource:[NSString stringWithString:mstring]];
	returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
	
	[progressIndicator incrementBy:100/weekCount];
	
	[scriptObject release];
}


-(NSMutableArray *)viewDailyPaperworkForDate:(NSDate *)date
{
	NSMutableArray * dailyArray = [NSMutableArray array];
	NSCalendarDate * selectedDate = [date dateWithCalendarFormat:@"%a. %b. %d, %Y" timeZone:nil];
	NSString * title = [NSString stringWithFormat:@"Daily Info --- %@", selectedDate];
	[dailyInfoWindow setTitle:title];
	
	// query  payouts and load arraycontrollers ...
	
	NSCalendarDate * workingDate = [selectedDate dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	NSPredicate * todayPredicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	todayPredicate = [todayPredicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	
	

	double total = 0;
	retailTaxCollected = 0;
	retailTotal = 0;
	serviceTaxCollected = 0;
	serviceTotal = 0;
	NSArray * serviceProviders = [staffController workingServiceProviders:beginningOfDay];
	NSArray * timeCardInfo = [self timeCardsInfoForDate:date];
	int i;
	int j;
	cashCollected = 0;
	creditBaseCollected = 0;
	checkCollected = 0;
	int serviceTransactions = 0;
	double transactionsTotal =0;
	NSMutableArray * transactions = [NSMutableArray array];
	NSFetchRequest * transactionRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * transactionDescription = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc];
	[transactionRequest setEntity:transactionDescription];
	[transactionRequest setPredicate:todayPredicate];
	[transactions addObjectsFromArray:[moc executeFetchRequest:transactionRequest error:&error]];
	NSLog(@"executing Fetch transaction");
	int transactionsCount = [transactions count];
	NSMutableArray * serviceTotals = [NSMutableArray array];
	NSMutableArray * transactionsTakenCareOf = [NSMutableArray array];
	
	for (i=0; i < [transactions count]; i++)	{
		transactionsTotal += [[[transactions objectAtIndex:i] valueForKey:@"transactionTotal"] doubleValue];
		if ([[[transactions objectAtIndex:i] valueForKey:@"paidCash"] boolValue] == YES)	{
			cashCollected += [[[transactions objectAtIndex:i] valueForKey:@"transactionTotal"] doubleValue];
		} else if ([[[transactions objectAtIndex:i] valueForKey:@"paidByCharge"] boolValue] == YES)	{
			creditBaseCollected += [[[transactions objectAtIndex:i] valueForKey:@"transactionTotal"] doubleValue];
		} else if ([[[transactions objectAtIndex:i] valueForKey:@"paidByCheck"] boolValue] == YES)	{
			checkCollected += [[[transactions objectAtIndex:i] valueForKey:@"transactionTotal"] doubleValue];
		}
			
		
	}
	for (i=0; i<[serviceProviders count]; i++)	{
		total = 0;
		NSMutableSet * stylistTransactions = [NSMutableSet setWithArray:transactions];
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"appointment.stylist == %@", [serviceProviders objectAtIndex:i]];
		[stylistTransactions filterUsingPredicate:predicate];
		NSArray * stylistTransactionsArray = [stylistTransactions allObjects];
		for (j=0 ; j< [stylistTransactionsArray count]; j++)	{
			total += [[[stylistTransactionsArray objectAtIndex:j] valueForKey:@"serviceSubtotal"] doubleValue];
			serviceTaxCollected += [[[stylistTransactionsArray objectAtIndex:j] valueForKey:@"serviceTax"] doubleValue];
			retailTaxCollected += [[[stylistTransactionsArray objectAtIndex:j] valueForKey:@"retailTax"] doubleValue];
			retailTotal += [[[stylistTransactionsArray objectAtIndex:j] valueForKey:@"retailSubtotal"] doubleValue];
		}
		[serviceTotals addObject:[NSNumber numberWithDouble:total]];
		serviceTotal += total;
		[transactionsTakenCareOf addObjectsFromArray:stylistTransactionsArray];
	}
	serviceTransactions = [transactionsTakenCareOf count];
	[transactions removeObjectsInArray:transactionsTakenCareOf];
	for (i=0; i< [transactions count]; i++)	{
		retailTaxCollected += [[[transactions objectAtIndex:i] valueForKey:@"retailTax"] doubleValue];
		retailTotal += [[[transactions objectAtIndex:i] valueForKey:@"retailSubtotal"] doubleValue];	
	}
	NSArray * miscellaneous = [self fetchMiscellaneous:date];
	NSArray * payoutArray = [self fetchPayouts:date];
	NSArray * empInfoArray = [self fetchEmpPlusMinus:date];
	miscPlus = 0;
	miscMinus = 0;
	for (i=0; i< [miscellaneous count]; i++)	{
		if ([[[miscellaneous objectAtIndex:i] valueForKey:@"isPlus"] boolValue] == YES)	{
			miscPlus += [[[miscellaneous objectAtIndex:i] valueForKey:@"amount"] doubleValue];
		} else	{
			miscMinus += [[[miscellaneous objectAtIndex:i] valueForKey:@"amount"] doubleValue];
		}
	}
	payouts = 0;
	for (i=0; i < [payoutArray count]; i++)	{
		payouts += [[[payoutArray objectAtIndex:i] valueForKey:@"amount"] doubleValue];
	}
	cashCollected = cashCollected - payouts;
	employeePlusMinus = 0;
	for (i=0; i < [empInfoArray count]; i++)	{
		if ([[[empInfoArray objectAtIndex:i] valueForKey:@"isPlus"] boolValue] == YES)	{
			employeePlusMinus += [[[empInfoArray objectAtIndex:i] valueForKey:@"amount"] doubleValue];
		} else	{
			employeePlusMinus -= [[[empInfoArray objectAtIndex:i] valueForKey:@"amount"] doubleValue];
		}
	}
	// get start
	NSManagedObject * initialStart = [self fetchInitialCount:date];
	start = 0;
	if (initialStart)	{
		start = [[initialStart valueForKey:@"ones"] intValue];
		start += ([[initialStart valueForKey:@"fives"] intValue] * 5);
		start += ([[initialStart valueForKey:@"tens"] intValue] * 10);
		start += ([[initialStart valueForKey:@"twenties"] intValue] * 20);
		start += ([[initialStart valueForKey:@"fifties"] intValue] * 50);
		start += ([[initialStart valueForKey:@"hundreds"] intValue] * 100);
		start += ([[initialStart valueForKey:@"change"] doubleValue]);
	}
	NSManagedObject * fullCount = [self fetchFullCount:date];
	cash = 0;
	creditTotal = 0;
	creditTips = 0;
	checkTotal = 0;
	if (fullCount)	{
		cash = [[fullCount valueForKey:@"ones"] intValue];
		cash += ([[fullCount valueForKey:@"fives"] intValue] * 5);
		cash += ([[fullCount valueForKey:@"tens"] intValue] * 10);
		cash += ([[fullCount valueForKey:@"twenties"] intValue] * 20);
		cash += ([[fullCount valueForKey:@"fifties"] intValue] * 50);
		cash += ([[fullCount valueForKey:@"hundreds"] intValue] * 100);
		cash += ([[fullCount valueForKey:@"change"] intValue]);
		creditTotal = [[fullCount valueForKey:@"creditBatchTotal"] doubleValue];
		creditTips = [[fullCount valueForKey:@"creditBatchTips"] doubleValue];
		checkTotal = [[fullCount valueForKey:@"checks"] doubleValue];
	}
	expected = transactionsTotal + start  + miscPlus - payouts - miscMinus + employeePlusMinus;
	have = cash + creditTotal + checkTotal;
	dailyPlusMinus = have - expected;
	
	for (i=0; i< [serviceProviders count]; i++)	{
		[dailyArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[serviceProviders objectAtIndex:i] valueForKey:@"name"], @"description", [serviceTotals objectAtIndex:i], @"amount", nil]];
	}
	
	
	NSMutableDictionary * newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Service Total", @"description", [NSNumber numberWithDouble:serviceTotal], @"amount", nil];
	[dailyArray addObject:newObject];
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Service Tax", @"description", [NSNumber numberWithDouble:serviceTaxCollected], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Retail Total", @"description", [NSNumber numberWithDouble:retailTotal], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Retail Tax", @"description", [NSNumber numberWithDouble:retailTaxCollected], @"amount", nil];
	[dailyArray addObject:newObject];

	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Transactions Total", @"description", [NSNumber numberWithDouble:transactionsTotal], @"amount", nil];
	[dailyArray addObject:newObject];

	
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Start", @"description", [NSNumber numberWithDouble:start], @"amount", nil];
	[dailyArray addObject:newObject];

	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Miscellaneous (+)", @"description", [NSNumber numberWithDouble:miscPlus], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Miscellaneous (-)", @"description", [NSNumber numberWithDouble:miscMinus], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Payouts", @"description", [NSNumber numberWithDouble:payouts], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Employee (+/-)", @"description", [NSNumber numberWithDouble:employeePlusMinus], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Expected", @"description", [NSNumber numberWithDouble:expected], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Cash", @"description", [NSNumber numberWithDouble:cash], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Check Total", @"description", [NSNumber numberWithDouble:checkTotal], @"amount", nil];
	[dailyArray addObject:newObject];
	
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Credit Total", @"description", [NSNumber numberWithDouble:creditTotal], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Have", @"description", [NSNumber numberWithDouble:have], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"(+/-)", @"description", [NSNumber numberWithDouble:dailyPlusMinus], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Credit Tips", @"description", [NSNumber numberWithDouble:creditTips], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Cash Collected", @"description", [NSNumber numberWithDouble:cashCollected], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Check Collected", @"description", [NSNumber numberWithDouble:checkCollected], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Credit Base Collected", @"description", [NSNumber numberWithDouble:creditBaseCollected], @"amount", nil];
	[dailyArray addObject:newObject];
	
	for (i=0 ; i< [timeCardInfo count] ;i++)	{
		[dailyArray addObject:[timeCardInfo objectAtIndex:i]];
	}
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Service Transactions", @"description", [NSNumber numberWithInt:serviceTransactions], @"amount", nil];
	[dailyArray addObject:newObject];
	float serviceAverage = 0;
	if (serviceTransactions != 0)	{
		serviceAverage = serviceTotal / serviceTransactions;
	}
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Service/Service Transaction", @"description", [NSNumber numberWithFloat:serviceAverage], @"amount", nil];
	[dailyArray addObject:newObject];	
	
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Transactions", @"description", [NSNumber numberWithInt:transactionsCount], @"amount", nil];
	[dailyArray addObject:newObject];
	float rpt = 0;
	if (transactionsCount != 0)	{
		rpt = retailTotal / transactionsCount;
	}

	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Retail/Tran", @"description", [NSNumber numberWithFloat:rpt], @"amount", nil];
	[dailyArray addObject:newObject];	
	
	

	
	return dailyArray;
}
-(IBAction)viewWeeklyReport:(id)sender
{
	
	NSArray * dailyArray = [self viewWeeklyPaperworkForDate:[mainDatePicker dateValue]];
	[weeklyArrayController setContent:dailyArray];
	[weeklyDate setObjectValue:[mainDatePicker dateValue]];
	[weeklyInfoWindow makeKeyAndOrderFront:self];
}
-(NSMutableArray *)viewWeeklyPaperworkForDate:(NSDate *)date
{
	NSCalendarDate * workingDate = [date dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int dayOfWeek = [workingDate dayOfWeek];
	workingDate = [workingDate dateByAddingYears:0 months:0 days:-dayOfWeek hours:0 minutes:0 seconds:0];
	NSMutableArray * week = [NSMutableArray array];
	NSArray * day = [self viewDailyPaperworkForDate:workingDate];
	int i;
	NSMutableDictionary * dictionary;
	for (i=0; i < [day count]; i++)	{
		dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[day objectAtIndex:i] valueForKey:@"description"], @"description", nil];
		[week addObject:dictionary];
	}
	NSArray * daysOfWeek = [NSArray arrayWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
	int j;
	for (j=0; j < [daysOfWeek count];j++)	{
		for (i=0; i< [day count]; i++)	{
			
			NSDictionary * dictionary = [week objectAtIndex:i];
			[dictionary setValue:[[day objectAtIndex:i] valueForKey:@"amount"] forKey:[daysOfWeek objectAtIndex:j]];

		}
		workingDate = [workingDate dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
		day = [self viewDailyPaperworkForDate:workingDate];
		
	}
	double retailWeek=0;
	int transactionsWeek=0;
	double service = 0;
	int serviceTransactions = 0;
	for (i=0; i< [week count]; i++)	{
		// go through each row and total the days of the week
		double total = 0;
		for (j=0; j < [daysOfWeek count]; j++)	{
			if ([[[week objectAtIndex:i] valueForKey:@"description"] compare:@"Transactions"] == NSOrderedSame)	{
				total += [[[week objectAtIndex:i] valueForKey:[daysOfWeek objectAtIndex:j]] doubleValue];
				transactionsWeek = total;
			} else if ([[[week objectAtIndex:i] valueForKey:@"description"] compare:@"Retail Total"] == NSOrderedSame)	{
				total += [[[week objectAtIndex:i] valueForKey:[daysOfWeek objectAtIndex:j]] doubleValue];
				retailWeek = total;
			} else if ([[[week objectAtIndex:i] valueForKey:@"description"] compare:@"Retail/Tran"] == NSOrderedSame)	{
				if (transactionsWeek != 0)	{
					total = retailWeek/ transactionsWeek;
				} else total=0;
				
			} else if ([[[week objectAtIndex:i] valueForKey:@"description"] compare:@"Service Total"] == NSOrderedSame)	{
				total += [[[week objectAtIndex:i] valueForKey:[daysOfWeek objectAtIndex:j]] doubleValue];
				service = total;
			} else if ([[[week objectAtIndex:i] valueForKey:@"description"] compare:@"Service Transactions"] == NSOrderedSame)	{
				total += [[[week objectAtIndex:i] valueForKey:[daysOfWeek objectAtIndex:j]] doubleValue];
				serviceTransactions = total;
			} else if ([[[week objectAtIndex:i] valueForKey:@"description"] compare:@"Service/Service Transaction"] == NSOrderedSame)	{
				if (serviceTransactions != 0)	{
					total = service/ serviceTransactions;
				}
			} else	{
				total += [[[week objectAtIndex:i] valueForKey:[daysOfWeek objectAtIndex:j]] doubleValue];
			}
		}
		[[week objectAtIndex:i] setValue:[NSNumber numberWithDouble:total] forKey:@"Week"];
	}
	
	return week;
}
-(NSArray *)fetchEmpPlusMinus:(NSDate *)date
{
	// query  empPlusMinus and load arraycontrollers ...	
	NSCalendarDate * workingDate = [date dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	
	NSPredicate * todayPredicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	todayPredicate = [todayPredicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSEntityDescription * empPlusMinusDescription = [NSEntityDescription entityForName:@"EmployeePlusMinus" inManagedObjectContext:moc];
	NSFetchRequest * empPlusMinusRequest = [[[NSFetchRequest alloc] init] autorelease];
	[empPlusMinusRequest setEntity:empPlusMinusDescription];
	[empPlusMinusRequest setPredicate:todayPredicate];
	NSLog(@"executing Fetch emp+/-");
	return [moc executeFetchRequest:empPlusMinusRequest error:&error];
}
-(NSArray *)fetchMiscellaneous:(NSDate *)date
{
	
	// query  payouts and load arraycontrollers ...
	
	NSCalendarDate * workingDate = [date dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	NSPredicate * todayPredicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	todayPredicate = [todayPredicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSEntityDescription * miscellaneousDescription = [NSEntityDescription entityForName:@"MiscellaneousPlusMinus" inManagedObjectContext:moc];
	NSFetchRequest * miscellaneousRequest = [[[NSFetchRequest alloc] init] autorelease];
	[miscellaneousRequest setEntity:miscellaneousDescription];
	[miscellaneousRequest setPredicate:todayPredicate];
	
	NSLog(@"executing Fetch misc+/-");
	return [moc executeFetchRequest:miscellaneousRequest error:&error];
}
-(NSArray *)fetchPayouts:(NSDate *)date
{
	// query  payouts and load arraycontrollers ...
	
	NSCalendarDate * workingDate = [date dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	NSPredicate * todayPredicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	todayPredicate = [todayPredicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSEntityDescription * payoutsDescription = [NSEntityDescription entityForName:@"Payouts" inManagedObjectContext:moc];
	NSFetchRequest * payoutsRequest = [[[NSFetchRequest alloc] init] autorelease];
	[payoutsRequest setEntity:payoutsDescription];
	[payoutsRequest setPredicate:todayPredicate];
	
	NSLog(@"executing Fetch payouts");
	return [moc executeFetchRequest:payoutsRequest error:&error];
}
-(NSArray *)fetchStylists
{
	NSEntityDescription * employeeDescription = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:moc];
	NSFetchRequest * employeeRequest = [[[NSFetchRequest alloc] init] autorelease];
	[employeeRequest setEntity:employeeDescription];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"booksServices == YES"];
	[employeeRequest setPredicate:predicate];
	
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:employeeRequest error:&error]];
	NSLog(@"executing Fetch employee");
	
	NSSortDescriptor * listOrderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	[results sortUsingDescriptors:[NSArray arrayWithObject:listOrderDescriptor]];
	
	return results;
}
-(NSArray *)fetchAssistants
{
	NSEntityDescription * employeeDescription = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:moc];
	NSFetchRequest * employeeRequest = [[[NSFetchRequest alloc] init] autorelease];
	[employeeRequest setEntity:employeeDescription];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"tracksHours == YES"];
	[employeeRequest setPredicate:predicate];
	
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:employeeRequest error:&error]];
	NSLog(@"executing Fetch employee");
	
	NSSortDescriptor * listOrderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	[results sortUsingDescriptors:[NSArray arrayWithObject:listOrderDescriptor]];
	
	return results;
}

-(NSArray *)fetchStylistsForDate:(NSDate *)date
{
	NSEntityDescription * employeeDescription = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:moc];
	NSFetchRequest * employeeRequest = [[[NSFetchRequest alloc] init] autorelease];
	[employeeRequest setEntity:employeeDescription];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"booksServices == YES"];
	[employeeRequest setPredicate:predicate];
	
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:employeeRequest error:&error]];
	NSLog(@"executing Fetch employee");
	
	NSSortDescriptor * listOrderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	[results sortUsingDescriptors:[NSArray arrayWithObject:listOrderDescriptor]];
	NSCalendarDate * cDate = [date dateWithCalendarFormat:@"" timeZone:nil];
	cDate = [cDate dateByAddingYears:0 months:0 days:-[cDate dayOfWeek] hours:-[cDate hourOfDay] minutes:-[cDate minuteOfHour] seconds:-[cDate secondOfMinute]];
	
	
	int i;
	for (i=0 ; i< [results count]; i++)	{
		NSDate * tDate = [[results objectAtIndex:i] valueForKey:@"terminated"];
		if (tDate)	{
			if ([tDate timeIntervalSinceDate:cDate] > 0)	{
				[results removeObjectAtIndex:i];
				i--;
			}
		}
				 
	}
	return results;
}
-(NSArray *)fetchAssistantsForDate:(NSDate *)date
{
	NSEntityDescription * employeeDescription = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:moc];
	NSFetchRequest * employeeRequest = [[[NSFetchRequest alloc] init] autorelease];
	[employeeRequest setEntity:employeeDescription];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"tracksHours == YES"];
	[employeeRequest setPredicate:predicate];
	
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:employeeRequest error:&error]];
	NSLog(@"executing Fetch employee");
	
	NSSortDescriptor * listOrderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	[results sortUsingDescriptors:[NSArray arrayWithObject:listOrderDescriptor]];
	NSCalendarDate * cDate = [date dateWithCalendarFormat:@"" timeZone:nil];
	cDate = [cDate dateByAddingYears:0 months:0 days:-[cDate dayOfWeek] hours:-[cDate hourOfDay] minutes:-[cDate minuteOfHour] seconds:-[cDate secondOfMinute]];
	
	
	int i;
	for (i=0 ; i< [results count]; i++)	{
		NSDate * tDate = [[results objectAtIndex:i] valueForKey:@"terminated"];
		if (tDate)	{
			if ([tDate timeIntervalSinceDate:cDate] > 0)	{
				[results removeObjectAtIndex:i];
				i--;
			}
		}
		
	}
	return results;
}
-(IBAction)viewWeeklyRetailInAppleworks:(id)sender
{
	if ([[NSDate date] timeIntervalSinceDate:[mainDatePicker dateValue]] > 0)	{
		NSCalendarDate * findSaturday = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
		int toSaturday = 6 - [findSaturday dayOfWeek];
		findSaturday = [findSaturday dateByAddingYears:0 months:0 days:toSaturday hours:0 minutes:0 seconds:0];
		[findSaturday setCalendarFormat:@"%m/%d/%y"];
		
		NSSortDescriptor * nameSort = [[[NSSortDescriptor alloc] initWithKey:@"productDescription" ascending:YES] autorelease];
		NSCountedSet * retailSet = [self retailSoldForWeek];
		NSMutableArray * content = [NSMutableArray arrayWithArray:[retailSet allObjects]];
		int i;
		for (i=0; i< [content count]; i++)	{
			int retailSoldCount = [retailSet countForObject:[content objectAtIndex:i]];
			[[content objectAtIndex:i] setValue:[NSNumber numberWithInt:retailSoldCount] forKey:@"soldAtThisPrice"];
		}
		[content sortUsingDescriptors:[NSArray arrayWithObject:nameSort]];
		
		NSDictionary* errorDict;
		NSAppleEventDescriptor* returnDescriptor = NULL;
		NSMutableString * string = [NSMutableString string];
		
		NSMutableString * path = [NSMutableString stringWithString:[[NSBundle mainBundle] bundlePath]];
		
		[path appendString:@"/Contents/Resources/retailOriginal.cwk"];
		path = [path stringByReplacingOccurrencesOfString:@"/Users" withString:@"Macintosh HD:Users"];
		path = [path stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
		path = [path stringByReplacingOccurrencesOfString:@"/" withString:@":"];
		[string appendFormat:@"tell application \"Finder\"\n\
		 open file \"%@\"\n\
		 tell application \"AppleWorks 6\"\n\
		 tell document 1\n\
		 set cell 1 of row 1 to \"\%@\"\n\
		 set cell 1 of row 2 to \"\%@\"\n\
		 set cell 2 of row 2 to \"\%@\"\n\
		 set cell 3 of row 2 to \"\%@\"\n\
		 set cell 4 of row 2 to \"\%@\"\n", path, findSaturday, @"Company"  ,@"Product Description", @"Retail Price", @"Number Sold"];
		
		for (i = 0; i < [content count]; i++)	{
			NSMutableDictionary * sale = [content objectAtIndex:i];
			int row = i+3;
			[string appendFormat:@"set cell 1 of row %d to \"\%@\"\n", row, [sale valueForKey:@"company"]];
			[string appendFormat:@"set cell 2 of row %d to \"\%@\"\n", row, [sale valueForKey:@"productDescription"]];
			[string appendFormat:@"set cell 3 of row %d to %.2f\n", row, [[sale valueForKey:@"salonCost"] floatValue]];
			[string appendFormat:@"set cell 4 of row %d to %d\n", row, [[sale valueForKey:@"soldAtThisPrice"] intValue]];
		}
		
		[string appendString:@"end tell\n\
		 end tell\n\
		 end tell"];
		NSAppleScript * scriptObject = [[NSAppleScript alloc] initWithSource:[NSString stringWithString:string]];
		returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
		[scriptObject release];
	}
}
-(IBAction)viewWeeklyPaperworkInAppleworks:(id)sender
{
	if ([[NSDate date] timeIntervalSinceDate:[mainDatePicker dateValue]] > 0)	{
		NSCalendarDate * findSaturday = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
		int toSaturday = 6 - [findSaturday dayOfWeek];
		findSaturday = [findSaturday dateByAddingYears:0 months:0 days:toSaturday hours:0 minutes:0 seconds:0];
		[findSaturday setCalendarFormat:@"%m/%d/%y"];
		NSArray * week = [self viewWeeklyPaperworkForDate:findSaturday];
		NSDictionary* errorDict;
		NSAppleEventDescriptor* returnDescriptor = NULL;
		NSMutableString * string = [NSMutableString string];
		
		NSMutableString * path = [NSMutableString stringWithString:[[NSBundle mainBundle] bundlePath]];
		
		[path appendString:@"/Contents/Resources/weeklyOriginal.cwk"];
		path = [path stringByReplacingOccurrencesOfString:@"/Users" withString:@"Macintosh HD:Users"];
		path = [path stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
		path = [path stringByReplacingOccurrencesOfString:@"/" withString:@":"];
		[string appendFormat:@"tell application \"Finder\"\n\
		 open file \"%@\"\n\
		 tell application \"AppleWorks 6\"\n\
		 tell document 1\n\
		 set cell 1 of row 1 to \"\%@\"\n\
		 set cell 2 of row 1 to \"\%@\"\n\
		 set cell 3 of row 1 to \"\%@\"\n\
		 set cell 4 of row 1 to \"\%@\"\n\
		 set cell 5 of row 1 to \"\%@\"\n\
		 set cell 6 of row 1 to \"\%@\"\n\
		 set cell 7 of row 1 to \"\%@\"\n\
		 set cell 8 of row 1 to \"\%@\"\n\
		 set cell 9 of row 1 to \"\%@\"\n", path, findSaturday  , @"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Week"];
		
		NSArray * keys = [NSArray arrayWithObjects:@"description", @"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Week", nil];
		int i;
		int j;
		for (i=0; i< [keys count]; i++)	{
			for (j=0; j < [week count]; j++)	{
				int row, cell;
				row = j+2;
				cell = i+1;
				[string appendFormat:@"set cell %d of row %d to \"\%@\"\n", cell, row, [[week objectAtIndex:j] objectForKey:[keys objectAtIndex:i]]];
				 
			}
		}
		[string appendString:@"end tell\n\
		 end tell\n\
		 end tell"];
		
		NSAppleScript * scriptObject = [[NSAppleScript alloc] initWithSource:[NSString stringWithString:string]];
		returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
		[scriptObject release];
	}
}
-(IBAction)goToMonthlyReportsWindow:(id)sender
{
	[monthlyStart setDateValue:[NSDate date]];
	[monthlyEnd setDateValue:[NSDate date]];
	[self monthlyStartChosen:self];
	[monthlyReportsWindow makeKeyAndOrderFront:self];
}
-(IBAction)monthlyStartChosen:(id)sender
{
	
}
-(IBAction)monthlyEndChosen:(id)sender
{
	
}
-(IBAction)viewMonthlyReportInAppleworks:(id)sender
{
	int startMonth, startYear, endMonth, endYear;
	
	NSDate * date = [monthlyStart dateValue];
	
	NSMutableArray * dailyArray = [NSMutableArray array];
	NSCalendarDate * selectedDate = [date dateWithCalendarFormat:@"%a. %b. %d, %Y" timeZone:nil];
	NSString * title = [NSString stringWithFormat:@"Daily Info --- %@", selectedDate];
	[dailyInfoWindow setTitle:title];
	
	// query  payouts and load arraycontrollers ...
	
	NSCalendarDate * workingDate = [selectedDate dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	workingDate = [[monthlyEnd dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];

	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	endOfDay = [endOfDay dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
	
	
	NSPredicate * todayPredicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	todayPredicate = [todayPredicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	
	
	
	double total = 0;
	retailTaxCollected = 0;
	retailTotal = 0;
	serviceTaxCollected = 0;
	serviceTotal = 0;
	NSArray * serviceProviders = [staffController workingServiceProviders:beginningOfDay];
	NSArray * timeCardInfo = [self timeCardsInfoBetweenDates:beginningOfDay endDate:endOfDay];
	
	
	int i;
	int j;
	
	int serviceTransactions = 0;
	double transactionsTotal =0;
	NSMutableArray * transactions = [NSMutableArray array];
	NSFetchRequest * transactionRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * transactionDescription = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc];
	[transactionRequest setEntity:transactionDescription];
	[transactionRequest setPredicate:todayPredicate];
	[transactions addObjectsFromArray:[moc executeFetchRequest:transactionRequest error:&error]];
	NSLog(@"executing Fetch transaction");
	int transactionsCount = [transactions count];
	NSMutableArray * serviceTotals = [NSMutableArray array];
	NSMutableArray * transactionsTakenCareOf = [NSMutableArray array];
	
	for (i=0; i < [transactions count]; i++)	{
		transactionsTotal += [[[transactions objectAtIndex:i] valueForKey:@"transactionTotal"] doubleValue];
	}
	for (i=0; i<[serviceProviders count]; i++)	{
		total = 0;
		NSMutableSet * stylistTransactions = [NSMutableSet setWithArray:transactions];
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"appointment.stylist == %@", [serviceProviders objectAtIndex:i]];
		[stylistTransactions filterUsingPredicate:predicate];
		NSArray * stylistTransactionsArray = [stylistTransactions allObjects];
		for (j=0 ; j< [stylistTransactionsArray count]; j++)	{
			total += [[[stylistTransactionsArray objectAtIndex:j] valueForKey:@"serviceSubtotal"] doubleValue];
			serviceTaxCollected += [[[stylistTransactionsArray objectAtIndex:j] valueForKey:@"serviceTax"] doubleValue];
			retailTaxCollected += [[[stylistTransactionsArray objectAtIndex:j] valueForKey:@"retailTax"] doubleValue];
			retailTotal += [[[stylistTransactionsArray objectAtIndex:j] valueForKey:@"retailSubtotal"] doubleValue];
		}
		[serviceTotals addObject:[NSNumber numberWithDouble:total]];
		serviceTotal += total;
		[transactionsTakenCareOf addObjectsFromArray:stylistTransactionsArray];
	}
	serviceTransactions = [transactionsTakenCareOf count];
	[transactions removeObjectsInArray:transactionsTakenCareOf];
	for (i=0; i< [transactions count]; i++)	{
		retailTaxCollected += [[[transactions objectAtIndex:i] valueForKey:@"retailTax"] doubleValue];
		retailTotal += [[[transactions objectAtIndex:i] valueForKey:@"retailSubtotal"] doubleValue];	
	}	
	
	NSFetchRequest * fr = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * ed = [NSEntityDescription entityForName:@"MiscellaneousPlusMinus" inManagedObjectContext:moc];
	[fr setEntity:ed];
	[fr setPredicate:todayPredicate];
	NSArray * miscellaneous = [moc executeFetchRequest:fr error:&error];
	ed = [NSEntityDescription entityForName:@"Payouts" inManagedObjectContext:moc];
	[fr setEntity:ed];
	[fr setPredicate:todayPredicate];
	NSArray * payoutArray = [moc executeFetchRequest:fr error:&error];
	ed = [NSEntityDescription entityForName:@"EmployeePlusMinus" inManagedObjectContext:moc];
	[fr setEntity:ed];
	[fr setPredicate:todayPredicate];
	NSArray * empInfoArray = [moc executeFetchRequest:fr error:&error];
	miscPlus = 0;
	miscMinus = 0;
	for (i=0; i< [miscellaneous count]; i++)	{
		if ([[[miscellaneous objectAtIndex:i] valueForKey:@"isPlus"] boolValue] == YES)	{
			miscPlus += [[[miscellaneous objectAtIndex:i] valueForKey:@"amount"] doubleValue];
		} else	{
			miscMinus += [[[miscellaneous objectAtIndex:i] valueForKey:@"amount"] doubleValue];
		}
	}
	payouts = 0;
	for (i=0; i < [payoutArray count]; i++)	{
		payouts += [[[payoutArray objectAtIndex:i] valueForKey:@"amount"] doubleValue];
	}
	employeePlusMinus = 0;
	for (i=0; i < [empInfoArray count]; i++)	{
		if ([[[empInfoArray objectAtIndex:i] valueForKey:@"isPlus"] boolValue] == YES)	{
			employeePlusMinus += [[[empInfoArray objectAtIndex:i] valueForKey:@"amount"] doubleValue];
		} else	{
			employeePlusMinus -= [[[empInfoArray objectAtIndex:i] valueForKey:@"amount"] doubleValue];
		}
	}
	// get start
	NSDictionary * initialStart = [self fetchInitialCountBetweenDates:beginningOfDay endDate:endOfDay];
	start = 0;
	if (initialStart)	{
		start = [[initialStart valueForKey:@"ones"] intValue];
		start += ([[initialStart valueForKey:@"fives"] intValue] * 5);
		start += ([[initialStart valueForKey:@"tens"] intValue] * 10);
		start += ([[initialStart valueForKey:@"twenties"] intValue] * 20);
		start += ([[initialStart valueForKey:@"fifties"] intValue] * 50);
		start += ([[initialStart valueForKey:@"hundreds"] intValue] * 100);
		start += ([[initialStart valueForKey:@"change"] doubleValue]);
	}
	NSDictionary * fullCount = [self fetchFullCountBetweenDates:beginningOfDay endDate:endOfDay];
	cash = 0;
	creditTotal = 0;
	creditTips = 0;
	checkTotal = 0;
	if (fullCount)	{
		cash = [[fullCount valueForKey:@"ones"] intValue];
		cash += ([[fullCount valueForKey:@"fives"] intValue] * 5);
		cash += ([[fullCount valueForKey:@"tens"] intValue] * 10);
		cash += ([[fullCount valueForKey:@"twenties"] intValue] * 20);
		cash += ([[fullCount valueForKey:@"fifties"] intValue] * 50);
		cash += ([[fullCount valueForKey:@"hundreds"] intValue] * 100);
		cash += ([[fullCount valueForKey:@"change"] intValue]);
		creditTotal = [[fullCount valueForKey:@"creditBatchTotal"] doubleValue];
		creditTips = [[fullCount valueForKey:@"creditBatchTips"] doubleValue];
		checkTotal = [[fullCount valueForKey:@"checks"] doubleValue];
	}
	expected = transactionsTotal + start  + miscPlus - payouts - miscMinus + employeePlusMinus;
	have = cash + creditTotal + checkTotal;
	dailyPlusMinus = have - expected;
	
	for (i=0; i< [serviceProviders count]; i++)	{
		[dailyArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[serviceProviders objectAtIndex:i] valueForKey:@"name"], @"description", [serviceTotals objectAtIndex:i], @"amount", nil]];
	}
	
	
	NSMutableDictionary * newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Service Total", @"description", [NSNumber numberWithDouble:serviceTotal], @"amount", nil];
	[dailyArray addObject:newObject];
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Service Tax", @"description", [NSNumber numberWithDouble:serviceTaxCollected], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Retail Total", @"description", [NSNumber numberWithDouble:retailTotal], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Retail Tax", @"description", [NSNumber numberWithDouble:retailTaxCollected], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Transactions Total", @"description", [NSNumber numberWithDouble:transactionsTotal], @"amount", nil];
	[dailyArray addObject:newObject];
	
	
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Start", @"description", [NSNumber numberWithDouble:start], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Miscellaneous (+)", @"description", [NSNumber numberWithDouble:miscPlus], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Miscellaneous (-)", @"description", [NSNumber numberWithDouble:miscMinus], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Payouts", @"description", [NSNumber numberWithDouble:payouts], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Employee (+/-)", @"description", [NSNumber numberWithDouble:employeePlusMinus], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Expected", @"description", [NSNumber numberWithDouble:expected], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Cash", @"description", [NSNumber numberWithDouble:cash], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Check Total", @"description", [NSNumber numberWithDouble:checkTotal], @"amount", nil];
	[dailyArray addObject:newObject];
	
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Credit Total", @"description", [NSNumber numberWithDouble:creditTotal], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Have", @"description", [NSNumber numberWithDouble:have], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"(+/-)", @"description", [NSNumber numberWithDouble:dailyPlusMinus], @"amount", nil];
	[dailyArray addObject:newObject];
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Credit Tips", @"description", [NSNumber numberWithDouble:creditTips], @"amount", nil];
	[dailyArray addObject:newObject];
	
	
	for (i=0 ; i< [timeCardInfo count] ;i++)	{
		[dailyArray addObject:[timeCardInfo objectAtIndex:i]];
	}
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Service Transactions", @"description", [NSNumber numberWithInt:serviceTransactions], @"amount", nil];
	[dailyArray addObject:newObject];
	float serviceAverage = 0;
	if (serviceTransactions != 0)	{
		serviceAverage = serviceTotal / serviceTransactions;
	}
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Service/Service Transaction", @"description", [NSNumber numberWithFloat:serviceAverage], @"amount", nil];
	[dailyArray addObject:newObject];	
	
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Transactions", @"description", [NSNumber numberWithInt:transactionsCount], @"amount", nil];
	[dailyArray addObject:newObject];
	float rpt = 0;
	if (transactionsCount != 0)	{
		rpt = retailTotal / transactionsCount;
	}
	
	newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Retail/Tran", @"description", [NSNumber numberWithFloat:rpt], @"amount", nil];
	[dailyArray addObject:newObject];	
	

	NSArray  * week = dailyArray;
	NSDictionary* errorDict;
	NSAppleEventDescriptor* returnDescriptor = NULL;
	NSMutableString * string = [NSMutableString string];
	
	NSMutableString * path = [NSMutableString stringWithString:[[NSBundle mainBundle] bundlePath]];
	
	[path appendString:@"/Contents/Resources/weeklyOriginal.cwk"];
	path = [path stringByReplacingOccurrencesOfString:@"/Users" withString:@"Macintosh HD:Users"];
	path = [path stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
	path = [path stringByReplacingOccurrencesOfString:@"/" withString:@":"];
	[string appendFormat:@"tell application \"Finder\"\n\
	 open file \"%@\"\n\
	 tell application \"AppleWorks 6\"\n\
	 tell document 1\n", path];
	
	
	

		for (j=0; j < [dailyArray count]; j++)	{
			int row, cell;
			i=0;
			row = j+2;
			cell = i+1;
			[string appendFormat:@"set cell %d of row %d to \"\%@\"\n", cell, row, [[dailyArray objectAtIndex:j] valueForKey:@"description"]];
			i=1;
			cell = i+1;
			[string appendFormat:@"set cell %d of row %d to \"\%@\"\n", cell, row, [[dailyArray objectAtIndex:j] valueForKey:@"amount"]];
			
		}

	[string appendString:@"end tell\n\
	 end tell\n\
	 end tell"];
	
	
	NSAppleScript * scriptObject = [[NSAppleScript alloc] initWithSource:[NSString stringWithString:string]];
	returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
	[scriptObject release];
	
	
}
-(IBAction)viewRetailSold:(id)sender
{
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSFetchRequest * transactionRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * tranDescription = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc];
	[transactionRequest setEntity:tranDescription];
	[transactionRequest setPredicate:predicate];
	NSArray * transactions = [moc executeFetchRequest:transactionRequest error:&error];
	NSLog(@"executing Fetch transaction");
	NSCountedSet * retailSet = [NSCountedSet set];
	int i;
	for (i=0; i< [transactions count]; i++)	{
		NSMutableSet * retailSaleItems = [[transactions objectAtIndex:i] valueForKey:@"retailSaleItems"];
		if ([retailSaleItems count] > 0)	{
			NSArray * retailSales = [retailSaleItems allObjects];
			int j;
			for (j=0; j< [retailSaleItems count]; j++)	{
				NSManagedObject * sale = [retailSales objectAtIndex:j];
				NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[sale valueForKey:@"productDescription"], @"productDescription"
											 , [sale valueForKey:@"company"], @"company", [sale valueForKey:@"salonCost"], @"salonCost", nil];
				int k;
				int sold = [[sale valueForKey:@"clientOrder"] intValue];
				for (k = 0; k< sold; k++)	{
					NSMutableDictionary * copy = [NSMutableDictionary dictionaryWithDictionary:dictionary];
					[retailSet addObject:copy];	
				}
				
			}
		}
	}
	
	NSSortDescriptor * nameSort = [[[NSSortDescriptor alloc] initWithKey:@"productDescription" ascending:YES] autorelease];
	NSMutableArray * content = [NSMutableArray arrayWithArray:[retailSet allObjects]];
	for (i=0; i< [content count]; i++)	{
		int retailSoldCount = [retailSet countForObject:[content objectAtIndex:i]];
		[[content objectAtIndex:i] setValue:[NSNumber numberWithInt:retailSoldCount] forKey:@"soldAtThisPrice"];
		
	}
	[content sortUsingDescriptors:[NSArray arrayWithObject:nameSort]];
	
	[retailSoldDailyController setContent:content];
	
	[retailSoldDailyWindow makeKeyAndOrderFront:self];
}
-(NSCountedSet *)retailSoldForWeek
{
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	int dayOfWeek = [workingDate dayOfWeek];
	day -= dayOfWeek;
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day += 7;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSFetchRequest * transactionRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * tranDescription = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc];
	[transactionRequest setEntity:tranDescription];
	[transactionRequest setPredicate:predicate];
	NSArray * transactions = [moc executeFetchRequest:transactionRequest error:&error];
	NSLog(@"executing Fetch transaction");
	NSCountedSet * retailSet = [NSCountedSet set];
	int i;
	for (i=0; i< [transactions count]; i++)	{
		NSMutableSet * retailSaleItems = [[transactions objectAtIndex:i] valueForKey:@"retailSaleItems"];
		if ([retailSaleItems count] > 0)	{
			NSArray * retailSales = [retailSaleItems allObjects];
			int j;
			for (j=0; j< [retailSaleItems count]; j++)	{
				NSManagedObject * sale = [retailSales objectAtIndex:j];
				NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[sale valueForKey:@"productDescription"], @"productDescription"
													, [sale valueForKey:@"company"], @"company", [sale valueForKey:@"salonCost"], @"salonCost", nil];
				int k;
				int sold = [[sale valueForKey:@"clientOrder"] intValue];
				for (k = 0; k< sold; k++)	{
					NSMutableDictionary * copy = [NSMutableDictionary dictionaryWithDictionary:dictionary];
					[retailSet addObject:copy];	
				}
				
			}
		}
	}
	return retailSet;
}
-(IBAction)viewRetailSoldForWeek:(id)sender
{
	NSSortDescriptor * nameSort = [[[NSSortDescriptor alloc] initWithKey:@"productDescription" ascending:YES] autorelease];
	NSCountedSet * retailSet = [self retailSoldForWeek];
	NSMutableArray * content = [NSMutableArray arrayWithArray:[retailSet allObjects]];
	int i;
	for (i=0; i< [content count]; i++)	{
		int retailSoldCount = [retailSet countForObject:[content objectAtIndex:i]];
		[[content objectAtIndex:i] setValue:[NSNumber numberWithInt:retailSoldCount] forKey:@"soldAtThisPrice"];
	}
	[content sortUsingDescriptors:[NSArray arrayWithObject:nameSort]];
	
	[retailSoldWeeklyController setContent:content];
	
	
	[retailSoldWeeklyWindow makeKeyAndOrderFront:self];
}
-(IBAction)productivityForTheWeek:(id)sender
{
	SEL selector = @selector(passwordEnteredForProductivity:);
	[passwordController getPasswordFor:self arguments:nil selector:selector];
}
-(void)passwordEnteredForProductivity:(NSManagedObject*)password
{
	if ([password valueForKey:@"passwordLevel"] != nil)	{
		int passwordLevel = [[password valueForKey:@"passwordLevel"] intValue];
		id test = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordLevelsPath];
		
		if (passwordLevel >= [[test valueForKey:@"viewReportsLevel"] intValue] )	{
			[self makeProductivityReports];
		}
	}
}
-(void)makeProductivityReports
{
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	int dayOfWeek = [selectedDate dayOfWeek];
	int month = [selectedDate monthOfYear];
	int year = [selectedDate yearOfCommonEra];
	int dayOfMonth = [selectedDate dayOfMonth];
	
	NSCalendarDate * sunday = [NSCalendarDate dateWithYear:year month:month day:dayOfMonth-dayOfWeek hour:0 minute:0 second:0 timeZone:nil];
	NSCalendarDate * lastDate = [NSCalendarDate dateWithYear:year month:month day:dayOfMonth+1 hour:0 minute:0 second:0 timeZone:nil];
	
	NSArray * stylists = [staffController workingServiceProviders:sunday];
	
	int stylistIndex = 0;
	int dayIndex = 0;
	NSMutableString * productivityDescription = [NSMutableString string];
	for (  ; stylistIndex < [stylists count]; stylistIndex++)	{
		float hoursAtWork=0;
		float hoursBooked=0;
		float hoursBlocked=0;
		
		NSManagedObject * stylist = [stylists objectAtIndex:stylistIndex];
		for (dayIndex = 0 ; dayIndex <= dayOfWeek; dayIndex++)	{
			NSDate * beginningOfDay = [sunday addTimeInterval:(3600*24*dayIndex)];
			NSDate * endOfDay = [beginningOfDay addTimeInterval:(3600*24)];
			
			NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END AND stylist == %@", [stylists objectAtIndex:stylistIndex]];
			predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
			
			NSFetchRequest * apptRequest = [[[NSFetchRequest alloc] init] autorelease];
			NSEntityDescription * apptDescription = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
			[apptRequest setPredicate:predicate];
			[apptRequest setEntity:apptDescription];
			
			NSArray * results = [moc executeFetchRequest:apptRequest error:&error];
			NSLog(@"executing Fetch appointment");
			if ([results count] == 0)	{
				NSArray * results = [bookingSchedule blankScheduleForStylist:[stylists objectAtIndex:stylistIndex] date:beginningOfDay];
				int i;
				for (i=0; i < [results count] ; i++)	{
					int apptLength = [[[results objectAtIndex:i] valueForKey:@"appointmentLength"] intValue];
					hoursAtWork += apptLength / 60.0;
				}
			} else	{
				int i;
				for (i=0; i < [results count] ; i++)	{
					NSManagedObject * appointment = [results objectAtIndex:i];
					NSManagedObject * client = [appointment valueForKey:@"client"];
					if (client == nil)	{
						
					} else if ([appointment valueForKeyPath:@"transaction.collectedBy"] != nil)	{
						int apptLength = [[appointment valueForKey:@"appointmentLength"] intValue];
						hoursBooked += apptLength/60.0;
					} else	if ([appointment valueForKeyPath:@"parentAppointment.transaction.collectedBy"] != nil)	{
						int apptLength = [[appointment valueForKey:@"appointmentLength"] intValue];
						hoursBooked += apptLength/60.0;
					} else {
						
					}
					int apptLength = [[appointment valueForKey:@"appointmentLength"] intValue];
					hoursAtWork += apptLength/60.0;
				}
			}
			
		}
		[productivityDescription appendFormat:@"%@ worked %2.2f hours and was booked %2.2f hours\n", [[stylists objectAtIndex:stylistIndex] valueForKey:@"name"], hoursAtWork, hoursBooked];
		
		
	}
	[productivityView setString:productivityDescription];
	
	[productivityWindow makeKeyAndOrderFront:self];
}
-(IBAction)goToReportInCalendarFormat:(id)sender
{
	NSArray * serviceProviders = [self fetchStylists];
	NSMutableArray * choices = [NSMutableArray array];
	int i;
	for (i=0; i< [serviceProviders count]; i++)	{
		[choices addObject:[[serviceProviders objectAtIndex:i] valueForKey:@"name"]];
	}
	[choices addObjectsFromArray:[NSArray arrayWithObjects:@"Service Total", @"Service Tax", @"Retail Total", @"Retail Tax", @"Transactions Total", @"Payouts", @"Employee (+/-)", @"(+/-)",
								  @"Service Transactions", @"Service/Service Transaction", @"Transactions", @"Retail/Tran", nil]]; 
	[reportItemsControllerCalendarFormat setContent:choices];
	[reportSetUpPageCalendarFormat makeKeyAndOrderFront:self];
	
}


-(IBAction)weekChosenForCalendarFormat:(id)sender
{
	NSCalendarDate * firstWeek = [[firstWeekPickerCalendarFormat dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	int dayOfWeek = [firstWeek dayOfWeek];
	firstWeek = [firstWeek dateByAddingYears:0 months:0 days:-dayOfWeek hours:0 minutes:0 seconds:0];
	[firstWeekPickerCalendarFormat setDateValue:firstWeek];
	
	NSCalendarDate * lastWeek = [[lastWeekPickerCalendarFormat dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	dayOfWeek = [lastWeek dayOfWeek];
	lastWeek = [lastWeek dateByAddingYears:0 months:0 days:6-dayOfWeek hours:0 minutes:0 seconds:0];
	[lastWeekPickerCalendarFormat setDateValue:lastWeek];
	
}

-(IBAction)generateReportForCalendarFormat:(id)sender
{
	int weekCount;
	NSCalendarDate * firstWeek = [[firstWeekPickerCalendarFormat dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int dayOfWeek = [firstWeek dayOfWeek];
	firstWeek = [firstWeek dateByAddingYears:0 months:0 days:-dayOfWeek hours:0 minutes:0 seconds:0];
	NSCalendarDate * lastWeek = [[lastWeekPickerCalendarFormat dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	NSMutableArray * weeks = [NSMutableArray array];
	NSCalendarDate * workingDate = [firstWeek dateByAddingYears:0 months:0 days:6 hours:0 minutes:0 seconds:0];
	NSTimeInterval timeInterval = [lastWeek timeIntervalSinceDate:workingDate];
	weekCount = timeInterval/(60*60*24*7);
	weekCount += 2;
	NSMutableArray * weeksArray = [NSMutableArray array];
	[progressIndicatorCalendarFormat setDoubleValue:0.0];
	while([workingDate dayOfCommonEra] <= [lastWeek dayOfCommonEra])	{
		[progressIndicatorCalendarFormat incrementBy:100.0/weekCount];
		[progressIndicatorCalendarFormat displayIfNeeded];
		[weeks addObject:[self viewWeeklyPaperworkForDate:workingDate]];
		[weeksArray addObject:workingDate];
		
		
		workingDate = [workingDate dateByAddingYears:0 months:0 days:7 hours:0 minutes:0 seconds:0];
	}
	NSMutableArray * results = [NSMutableArray array];
	int i;
	int j;
	int k;
	NSArray * reportItems = [reportItemsControllerCalendarFormat selectedObjects];
	for (k=0; k< [reportItems count]; k++)	{
		[results addObject:[NSMutableArray array]];
		for (i=0; i< [weeks count]; i++)	{
			NSArray * week = [weeks objectAtIndex:i];
			for (j=0 ; j< [week count]; j++)	{
				NSMutableArray * result = [results objectAtIndex:k];
				if ([[reportItems objectAtIndex:k] compare:[[week objectAtIndex:j] valueForKey:@"description"]] == NSOrderedSame)	{
					
					NSMutableDictionary * entry = [week objectAtIndex:j];
					[result addObject:entry];
				}
				
				
			}
		}
		
	}
	NSDictionary* errorDict;
	NSAppleEventDescriptor* returnDescriptor = NULL;
	
	NSString * path = [NSString stringWithFormat:@"%@/Contents/Resources/weeklyOriginal.cwk",[[NSBundle mainBundle] bundlePath] ];
	
	
	path = [path stringByReplacingOccurrencesOfString:@"/Users" withString:@"Macintosh HD:Users"];
	path = [path stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
	path = [path stringByReplacingOccurrencesOfString:@"/" withString:@":"];
	
	NSMutableString * mstring = [NSMutableString string];
	[mstring appendFormat:@"tell application \"Finder\"\n\
	 open file \"%@\"\n\
	 tell application \"AppleWorks 6\"\n\
	 tell document 1\n", path];
	
	int row;
	int column;
	float total = 0;
	int sTransactions = 0;
	int transactions = 0;
	float rTotal;
	float sTotal;
	
	int literalWeeks = weekCount -1;
	[mstring appendFormat:@"set cell 1 of row 1 to \"\%@\"\n", [reportItems objectAtIndex:0]];
	for (i=0; i< literalWeeks; i++)	{
		NSCalendarDate * sunday = [[firstWeekPickerCalendarFormat dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
		NSCalendarDate * saturday = [[firstWeekPickerCalendarFormat dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
		sunday = [sunday dateByAddingYears:0 months:0 days:i*7 hours:0 minutes:0 seconds:0];
		saturday = [sunday dateByAddingYears:0 months:0 days:6 hours:0 minutes:0 seconds:0];
		NSString * date = [NSString stringWithFormat:@"%@-%@", sunday, saturday];
		column = 1;
		row = i+2;
		[mstring appendFormat:@"set cell %d of row %d to \"\%@\"\n", column, row, date];

	}

	NSArray * keys = [NSArray arrayWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Week", nil];

	for(i=0; i< [keys count]; i++)	{
		column = i+2;
		row = 1;
		[mstring appendFormat:@"set cell %d of row %d to \"\%@\"\n", column, row, [keys objectAtIndex:i]];
		for (j=0 ; j< [[results objectAtIndex:0] count]; j++)	{
			column = i+2;
			row = j+2;
			[mstring appendFormat:@"set cell %d of row %d to %f\n", column, row, [[[[results objectAtIndex:0] valueForKey:[keys objectAtIndex:i]] objectAtIndex:j] floatValue]];
			
		}
	}
	
	
	[mstring appendString:@"end tell\n\
	 end tell\n\
	 end tell"];
	
	NSAppleScript * scriptObject = [[NSAppleScript alloc] initWithSource:[NSString stringWithString:mstring]];
	returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
	[progressIndicatorCalendarFormat incrementBy:100/weekCount];
	
	[scriptObject release];
	
	
}
-(IBAction)goToRetentionWindow:(id)sender
{
	[retentionWindow makeKeyAndOrderFront:self];
}
-(float)generateRetentionRatesForStartingDate:(NSDate *)retentionStart toEndingDate:(NSDate *)retentionEnd
{
	NSCalendarDate * startDate = [retentionStart dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	int dayOfMonth = [startDate dayOfMonth];
	int yearOfCommonEra = [startDate yearOfCommonEra];
	int monthOfYear = [startDate monthOfYear];
	startDate = [NSCalendarDate dateWithYear:yearOfCommonEra month:monthOfYear day:dayOfMonth hour:0 minute:0 second:0 timeZone:nil];
	
	NSCalendarDate * endDate = [retentionEnd dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	dayOfMonth = [endDate dayOfMonth];
	yearOfCommonEra = [endDate yearOfCommonEra];
	monthOfYear = [endDate monthOfYear];
	endDate = [NSCalendarDate dateWithYear:yearOfCommonEra month:monthOfYear day:dayOfMonth hour:0 minute:0 second:0 timeZone:nil];
	NSCalendarDate * endEndDate;
	if ([startDate dayOfMonth] == 1)	{
		endEndDate = [endDate dateByAddingYears:0 months:3 days:0 hours:0 minutes:0 seconds:0];
	} else	{
		endEndDate = [endDate dateByAddingYears:0 months:0 days:91 hours:0 minutes:0 seconds:0];
	}
		
		
	NSFetchRequest * fr = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:startDate , @"BEGINNING",endEndDate, @"END", nil]];
	[fr setEntity:entity];
	[fr setPredicate:predicate];
	
	NSMutableArray * firstPeriodAppointments = [NSMutableArray arrayWithArray:[moc executeFetchRequest:fr error:&error]];
NSLog(@"executing Fetch appointment");
	
	NSMutableArray * secondPeriodAppointments = [NSMutableArray arrayWithArray:firstPeriodAppointments];

	predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:startDate , @"BEGINNING",endDate, @"END", nil]];
	[firstPeriodAppointments filterUsingPredicate:predicate];
	
	predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:endDate , @"BEGINNING",endEndDate, @"END", nil]];
	[secondPeriodAppointments filterUsingPredicate:predicate];
	
	NSMutableSet * firstPeriodClients = [NSMutableSet set];
	NSMutableSet * secondPeriodClients = [NSMutableSet set];
	int i;
	int counter = 0;
	for (i=0; i < [firstPeriodAppointments count]; i++)	{
		NSManagedObject * appointment = [firstPeriodAppointments objectAtIndex:i];
		if ([appointment valueForKeyPath:@"transaction.collectedBy"] != nil)	{
			[firstPeriodClients addObject:[appointment valueForKeyPath:@"client.name"]];
			counter++;
		}
	}
	counter = 0;
	for (i=0; i < [secondPeriodAppointments count]; i++)	{
		NSManagedObject * appointment = [secondPeriodAppointments objectAtIndex:i];
		if ([appointment valueForKeyPath:@"transaction.collectedBy"] != nil)	{
			[secondPeriodClients addObject:[appointment valueForKeyPath:@"client.name"]];
			counter++;
		}
	}
	
	NSArray * fpcArray = [firstPeriodClients allObjects];
//	NSArray * spcArray = [secondPeriodClients allObjects];
	counter = 0;
	for (i=0; i < [fpcArray count] ; i++)	{
		if ([secondPeriodClients containsObject:[fpcArray objectAtIndex:i]])	{
			counter ++;
		}
	}
	int fpcCount = [firstPeriodClients count];
	float result = counter * 1.0;
	result = result/ fpcCount;
	
	return result;
}
-(IBAction)generateRetentionRatesAction:(id)sender
{
	float retentionRateFloat = [self generateRetentionRatesForStartingDate:[firstWeekPickerRetention dateValue] toEndingDate:[lastWeekPickerRetention dateValue]];
	[retentionRate setFloatValue:retentionRateFloat];
}
-(IBAction)weekChosenForRetention:(id)sender
{
	
	NSCalendarDate * senderDate = [[sender dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	int dayOfMonth = [senderDate dayOfMonth];
	if (dayOfMonth == 1)	{
		//3 month exactly
		if (sender == lastWeekPickerRetention)	{
			senderDate = [senderDate dateByAddingYears:0 months:-3 days:0 hours:0 minutes:0 seconds:0];
			[firstWeekPickerRetention setDateValue:senderDate];
		} else	{
			senderDate = [senderDate dateByAddingYears:0 months:3 days:0 hours:0 minutes:0 seconds:0];
			[lastWeekPickerRetention setDateValue:senderDate];
		}
	} else	{
		//3 month, but week to week --- so i want 13*7= 91 days
		// sunday to sunday on the calendar
		int dayOfWeek = [senderDate dayOfWeek];
		
		if (sender == lastWeekPickerRetention)	{
			senderDate = [senderDate dateByAddingYears:0 months:0 days:-dayOfWeek hours:0 minutes:0 seconds:0];
			[lastWeekPickerRetention setDateValue:senderDate];
			senderDate = [senderDate dateByAddingYears:0 months:0 days:-91 hours:0 minutes:0 seconds:0];
			[firstWeekPickerRetention setDateValue:senderDate];
		} else	{
			senderDate = [senderDate dateByAddingYears:0 months:0 days:-dayOfWeek hours:0 minutes:0 seconds:0];
			[firstWeekPickerRetention setDateValue:senderDate];
			senderDate = [senderDate dateByAddingYears:0 months:0 days:91 hours:0 minutes:0 seconds:0];
			[lastWeekPickerRetention setDateValue:senderDate];
		}
	}
	
}

-(IBAction)searchForTransactionsByService:(id)sender
{
	[self createServiceMenu];
	[searchStartDate setDateValue:[NSDate date]];
	[searchEndDate setDateValue:[NSDate date]];
	[searchByServiceWindow makeKeyAndOrderFront:self];
}


-(NSArray *)servicesSelectedForSearch
{
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
	NSLog(@"executing Fetch service menu item");
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
	return [newServices allObjects];
}
-(IBAction)performServiceSpecificSearch:(id)sender
{
	
	// insert code
	NSFetchRequest *fr = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *ed = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc];
	[fr setEntity:ed];
	
	NSPredicate * predicate;
	NSString * predicateFormat = [NSMutableString string];
	if ([searchSpecificTime state] == 1)	{
		NSCalendarDate * startDate = [[searchStartDate dateValue] dateWithCalendarFormat:@"" timeZone:nil];
		NSCalendarDate * endDate = [[searchEndDate dateValue] dateWithCalendarFormat:@"" timeZone:nil];
		
		int dayOfMonth, month, year;
		dayOfMonth = [startDate dayOfMonth];
		month = [startDate monthOfYear];
		year = [startDate yearOfCommonEra];
		startDate = [NSCalendarDate dateWithYear:year month:month day:dayOfMonth hour:0 minute:0 second:0 timeZone:nil];
		
		dayOfMonth = [endDate dayOfMonth];
		dayOfMonth++;
		month = [endDate monthOfYear];
		year = [endDate yearOfCommonEra];
		endDate = [NSCalendarDate dateWithYear:year month:month day:dayOfMonth hour:0 minute:0 second:0 timeZone:nil];
		
		predicate = [NSPredicate predicateWithFormat:@"time > %@ AND time < %@",startDate, endDate];
		
		[fr setPredicate:predicate];	
	} 
	
	
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:fr error:&error]];
	NSLog(@"executing Fetch transaction");
	
	
	// have a list of transactions for the requested time period
	
	NSMutableSet * serviceDescriptionSet = [NSMutableSet set];
	NSArray * searchServices = [self servicesSelectedForSearch];
	int i;
	for (i=0; i< [searchServices count]; i++)	{
		[serviceDescriptionSet addObject:[[searchServices objectAtIndex:i] valueForKey:@"serviceDescription"]];
		
	}
	if ([exactlyTheseServices state] == 1)	{
		NSMutableArray * toBeRemoved = [NSMutableArray array];
		int serviceSetCount = [serviceDescriptionSet count];
		for (i=0; i< [results count]; i++)	{
			if ([[[results objectAtIndex:i] valueForKey:@"services"] count] == serviceSetCount)	{
				NSArray * tranServices = [NSArray arrayWithArray:[[results objectAtIndex:i] valueForKey:@"services"]];
				NSMutableSet * tranServiceSet = [NSMutableSet set];
				int j;
				for(j=0; j < serviceSetCount; j++)	{
					[tranServiceSet addObject:[[tranServices objectAtIndex:j] valueForKey:@"serviceDescription"]];
				}
				if ([tranServiceSet isEqualToSet:serviceDescriptionSet] == NO)	{
					[toBeRemoved addObject:[results objectAtIndex:i]];
				}
				
			} else	{
				[toBeRemoved addObject:[results objectAtIndex:i]];
			}
			
			
			
		}
		[results removeObjectsInArray:toBeRemoved];
					 
	} else {
		NSMutableArray * toBeRemoved = [NSMutableArray array];
		int serviceSetCount = [serviceDescriptionSet count];
		for (i=0; i < [results count]; i++)	{
			if ([[[results objectAtIndex:i] valueForKey:@"services"] count] > serviceSetCount)	{
				NSArray * tranServices = [NSArray arrayWithArray:[[results objectAtIndex:i] valueForKey:@"services"]];
				NSMutableSet * tranServiceSet = [NSMutableSet set];
				int j;
				for(j=0; j < serviceSetCount; j++)	{
					[tranServiceSet addObject:[[tranServices objectAtIndex:j] valueForKey:@"serviceDescription"]];
				}
				if ([serviceDescriptionSet isSubsetOfSet:tranServiceSet] == NO)	{
					[toBeRemoved addObject:[results objectAtIndex:i]];
				}
				
			} else	{
				[toBeRemoved addObject:[results objectAtIndex:i]];
			}
		}
			
			
	}
	
	NSMutableArray * sortArray = [NSMutableArray arrayWithArray:results];
	NSSortDescriptor * timeSort = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO] autorelease];
	[sortArray sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
	
	
	
	[transactionByServiceController setContent:sortArray];
	
}
-(IBAction)atLeastTheseServicesSelected:(id)sender
{
	if ([atLeastTheseServices state] == 0)	{
		[exactlyTheseServices setState:1];
	} else	{
		[exactlyTheseServices setState:0];
	}
}
-(IBAction)exactlyTheseServicesSelected:(id)sender
{
	if ([exactlyTheseServices state] == 0)	{
		[atLeastTheseServices setState:1];
	} else	{
		[atLeastTheseServices setState:0];
	}
}
-(IBAction)searchAllTimeSelected:(id)sender
{
	if ([searchAllTime state] == 1)	{	
		[searchSpecificTime setState:0];
	} else {
		[searchSpecificTime setState:1];
	}

}
-(IBAction)searchSpecificTimeSelected:(id)sender
{
	if ([searchSpecificTime state] == 1)	{	
		[searchAllTime setState:0];
	} else {
		[searchAllTime setState:1];
	}
	
}

-(void)createServiceMenu
{
	NSMutableArray * subviews = [NSMutableArray array];
	//calculate the size of the view, then align it so the top corner of view matches the corner of scroller
	//...
	
	NSFetchRequest * menuRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * menuDescription = [NSEntityDescription entityForName:@"ServiceMenuItem" inManagedObjectContext:moc];
	NSSortDescriptor * listOrderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	[menuRequest setSortDescriptors:[NSArray arrayWithObject:listOrderDescriptor]];
	[menuRequest setEntity:menuDescription];
	NSArray * results = [moc executeFetchRequest:menuRequest error:&error];
	NSLog(@"executing Fetch service menu item");
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
		[subviews addObject:newButton];
	}
	[servicesView setSubviews:subviews];
	[servicesView scrollPoint:NSMakePoint(0, serviceHeight)];
}
-(NSString * )transactionDescriptionByService
{
	NSManagedObject * transaction = [[transactionByServiceController selectedObjects] objectAtIndex:0];
	NSArray * services = [NSArray arrayWithArray:[[transaction valueForKeyPath:@"services"] allObjects]];
	NSArray * retailSaleItems = [NSArray arrayWithArray:[[transaction valueForKeyPath:@"retailSaleItems"] allObjects]];
	
	int i;
	NSMutableString * description = [NSMutableString stringWithString:@"Transactions Description:\n\n"];
	NSCalendarDate * time = [[transaction valueForKey:@"time"] dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
	NSCalendarDate * date = [[transaction valueForKey:@"time"] dateWithCalendarFormat:@"%a. %b. %d, %Y" timeZone:nil];
	
	[description appendFormat:@"Date: %@\n\n", date];
	[description appendFormat:@"Time: %@\n\n", time];
	int servicesCount = [services count];
	int retailCount = [retailSaleItems count];
	if (servicesCount > 0)	{
		[description appendString:@"Services:\n"];
	}
	for (i = 0; i < servicesCount; i++)	{
		NSManagedObject * service = [services objectAtIndex:i];
		[description appendFormat:@"%@: %1.2f\n", [service valueForKey:@"serviceDescription"], [[service valueForKey:@"price"] floatValue]];
	}
	if (servicesCount > 0)	{
		[description appendFormat:@"\nService Total: %1.2f\n\n", [[transaction valueForKey:@"serviceSubtotal"] floatValue]];
	}
	
	if (retailCount > 0)	{
		[description appendString:@"Retail:\n"];
	}
	for (i = 0; i < retailCount; i++)	{
		NSManagedObject * retailSale = [retailSaleItems objectAtIndex:i];
		[description appendFormat:@"%@: %1.2f\nBought %d\n", [retailSale valueForKey:@"productDescription"], [[retailSale valueForKey:@"salonCost"] floatValue], [[retailSale valueForKeyPath:@"clientOrder"] intValue]];
	}
	if (retailCount > 0)	{
		[description appendFormat:@"\nRetail Total: %1.2f\n\n", [[transaction valueForKey:@"retailSubtotal"] floatValue]];
	}
	[description appendFormat:@"\nTransaction Total: %1.2f\n\n", [[transaction valueForKey:@"transactionTotal"] floatValue]];
	[description appendFormat:@"CollectedBy: %@", [transaction valueForKey:@"collectedBy"]];
	
	return description;
}
-(NSString *)appointmentDescriptionByService
{
	NSManagedObject * appointment = [[[transactionByServiceController selectedObjects] objectAtIndex:0] valueForKey:@"appointment"];
	
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

-(void)loadTransactionAppointmentByService
{
	[transactionByServiceDescription setString:[self transactionDescriptionByService]];
	[appointmentByServiceDescription setString:[self appointmentDescriptionByService]];
}

-(void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id  object = [aNotification object];
	if (object == transactionByServiceTable)	{
		[self loadTransactionAppointmentByService];
	}
}


-(IBAction)viewRefundsForDay:(id)sender
{
	NSMutableArray * retailRefunded = [NSKeyedUnarchiver unarchiveObjectWithFile:retailRefundedPath];
	
	
}
-(IBAction)viewRefundsForWeek:(id)sender
{
	
}
-(void)sendEmailReminderToServiceProviders
{
	/*
	NSDictionary* errorDict;
	NSAppleEventDescriptor* returnDescriptor = NULL;
	
	NSFetchRequest * fr = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * ed = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc];
	[fr setEntity:ed];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > %@ && client != nil", [NSDate date]];
	[fr setPredicate:predicate];
	 
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:fr error:&error]];
	NSSortDescriptor * descriptor = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES] autorelease];
	
	
	NSMutableDictionary * preferences = [NSKeyedUnarchiver unarchiveObjectWithFile:preferencesPath];
	NSString * sender = [preferences valueForKey:@"emailSender"];
	
	
	NSArray * staff = [staffController serviceProviders];
	int i; 
	NSMutableArray * emails = [NSMutableArray array];
	for (i=0; i< [staff count]; i++)	{
		if ([[[staff objectAtIndex:i] valueForKey:@"email"] length] > 0)	{
			NSDictionary * entry = [NSDictionary dictionaryWithObjectsAndKeys:[[staff objectAtIndex:i] valueForKey:@"email"], @"email",
																			   [staff objectAtIndex:i] , @"stylist", nil];
			[emails addObject:entry];
									
		}
	}
	[results sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	NSMutableString * message;

	if ([results count] > 0)	{
		
		for (i=0; i < [emails count]; i++)	{
			NSMutableArray * workingResults = [NSMutableArray arrayWithArray:results];
			predicate = [NSPredicate predicateWithFormat:@"stylist == %@", [[emails objectAtIndex:i] valueForKey:@"stylist"]];
			[workingResults filterUsingPredicate:predicate];
			NSLog(@"workingResults %@", workingResults);
			for (i=0; i< [workingResults count]; i++)	{
				if ([[[workingResults objectAtIndex:i] valueForKeyPath:@"client.name"] length] ==0)	{
					[workingResults removeObjectAtIndex:i];
					i--; 
				}
			}
			if ([workingResults count] > 0)	{
	 			NSManagedObject * a = [workingResults objectAtIndex:0];
				NSCalendarDate * date = [[a valueForKey:@"time"] dateWithCalendarFormat:@"%a. %b. %d, %Y" timeZone:nil];
				NSCalendarDate * time = [[a valueForKey:@"time"] dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
				
				message = [NSMutableString stringWithFormat:@"%@'s next appointment is %@ at %@ on %@",[a valueForKeyPath:@"stylist.name"], [a valueForKeyPath:@"client.name"], time, date];
				
				
				NSString * email = [[emails objectAtIndex:i] valueForKey:@"email"];
				NSString * name = [[[emails objectAtIndex:i] valueForKey:@"stylist"] valueForKey:@"name"];
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
				
				
				
				returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
				[scriptObject release];
			} else {
				NSLog(@"no email to %@ because they have no more appointments", [[[emails objectAtIndex:i] valueForKey:@"stylist"] valueForKey:@"name"]);
				
			}
	
		}
	
	
	}
	
	
	 */
}
-(void)wipeCloseouts
{
	NSDate * selectedDate = [mainDatePicker dateValue];
	[selectedDate setCalendarFormat:@"%m/%d/%y"];
	NSString * message = [NSString stringWithFormat:@"Do you want to override the closeout for %@", selectedDate];
	int choice = NSRunAlertPanel(@"Warning", message, @"OK", @"Cancel", nil);
	if (choice == 1)	{
		NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
		int month, day, year;
		month = [workingDate monthOfYear];
		day = [workingDate dayOfMonth];
		year = [workingDate yearOfCommonEra];
		NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
		day++;
		NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
		
		
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
		predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
		
		NSFetchRequest * fullCountRequest = [[[NSFetchRequest alloc] init] autorelease];
		NSEntityDescription * fullDescription = [NSEntityDescription entityForName:@"FullCount" inManagedObjectContext:moc];
		[fullCountRequest setEntity:fullDescription];
		[fullCountRequest setPredicate:predicate];
		NSSortDescriptor * sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO] autorelease];
		[fullCountRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		
		NSArray * results = [moc executeFetchRequest:fullCountRequest error:&error];
		int i; 
		for (i=0; i< [results count] ; i++)		{
			[moc deleteObject:[results objectAtIndex:i]];
		}
	}
		
}

@end
