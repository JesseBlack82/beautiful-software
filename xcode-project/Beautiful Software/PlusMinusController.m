//
//  PlusMinusController.m
//  Beautiful Software
//
//  Created by Jesse Black on 2/1/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import "PlusMinusController.h"
#import "EmployeeSelect.h"
#import "PageView.h"
#import "BuildingBlock.h"
#import "Beautiful_Software_AppDelegate.h"
#import "DailyReport.h"
#import "InterfaceConstants.h"

@implementation PlusMinusController
@synthesize lastSelectedDate;
@synthesize lastWhoAreYou;

-(void)awakeFromNib
{
	moc = [appDelegate managedObjectContext];
	[payoutsWindow setDelegate:self];
	[miscellaneousWindow setDelegate:self];
	[employeeInfoWindow setDelegate:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainDatePickerChanged:) name:nil object:mainDatePicker];
}
-(IBAction)goToEmployeeInfo:(id)sender
{
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	if ([[today description] compare:[selectedDate description]] != NSOrderedSame)	{
		int i;
		NSArray * tableColumns = [employeePlusTable tableColumns];
		for ( i=0 ; i< [tableColumns count]; i++)	{
			[[tableColumns objectAtIndex:i] setEditable:NO];
			
		}
		
		tableColumns = [employeeMinusTable tableColumns];
		for ( i=0 ; i< [tableColumns count]; i++)	{
			[[tableColumns objectAtIndex:i] setEditable:NO];
			
		}
	} else	{
		int i;
		NSArray * tableColumns = [employeePlusTable tableColumns];
		for ( i=0 ; i< [tableColumns count]; i++)	{
			[[tableColumns objectAtIndex:i] setEditable:YES];
			
		}
		
		tableColumns = [employeeMinusTable tableColumns];
		for ( i=0 ; i< [tableColumns count]; i++)	{
			[[tableColumns objectAtIndex:i] setEditable:YES];
			
		}
	}
		
	moc = [appDelegate managedObjectContext];
	// here arguments and selector are for the method i want to use right in now
	SEL selector = @selector(loadEmployeeInfo:);
	[employeeSelect selectEmployeeFor:self selector:selector windowTitle:@"Who is this for?"];
}
-(void)mainDatePickerChanged:(id)sender
{
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	if (!lastSelectedDate)	{
		[self setLastSelectedDate:selectedDate];
	}
	if ([[lastSelectedDate description] compare:[selectedDate description]] != NSOrderedSame)	{
		[employeeInfoWindow close];
		[payoutsWindow close];
		[miscellaneousWindow close];
		// or go crazy and have them update themselves
	}
	[self setLastSelectedDate:selectedDate];
}
-(double)getEmployeeInfoForWeekUntilToday:(NSManagedObject *)employee
{
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	int dayOfWeek = [workingDate dayOfWeek];
	day -= dayOfWeek;
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day += dayOfWeek;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];

	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END and employee == %@", employee];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSFetchRequest * employeePettyRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * employeePettyDescription = [NSEntityDescription entityForName:@"EmployeePlusMinus" inManagedObjectContext:moc];
	[employeePettyRequest setEntity:employeePettyDescription];
	[employeePettyRequest setPredicate:predicate];
	
	NSArray * results = [moc executeFetchRequest:employeePettyRequest error:&error];
	NSLog(@"executing Fetch emp+/-");
	double total = 0;
	int i;
	for (i=0; i< [results count]; i++)	{
		NSManagedObject * plusMinus = [results objectAtIndex:i];
		double x = [[plusMinus valueForKey:@"amount"] doubleValue];
		if ([[plusMinus valueForKey:@"isPlus"] boolValue] == YES)	{
			total += x;
		} else	{
			total -=x;
		}
	}
	return total;
}
-(double)getEmployeeInfoForWeek:(NSManagedObject *)employee
{
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	int dayOfWeek = [workingDate dayOfWeek];
	day -= dayOfWeek;
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day += dayOfWeek;
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END and employee == %@", employee];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSFetchRequest * employeePettyRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * employeePettyDescription = [NSEntityDescription entityForName:@"EmployeePlusMinus" inManagedObjectContext:moc];
	[employeePettyRequest setEntity:employeePettyDescription];
	[employeePettyRequest setPredicate:predicate];
	
	NSArray * results = [moc executeFetchRequest:employeePettyRequest error:&error];
	NSLog(@"executing Fetch emp+/-");
	double total = 0;
	int i;
	for (i=0; i< [results count]; i++)	{
		NSManagedObject * plusMinus = [results objectAtIndex:i];
		double x = [[plusMinus valueForKey:@"amount"] doubleValue];
		if ([[plusMinus valueForKey:@"isPlus"] boolValue] == YES)	{
			total += x;
		} else	{
			total -=x;
		}
	}
	return total;
}

-(void)loadEmployeeInfo
{
	NSCalendarDate * selectedDate = [lastSelectedDate dateWithCalendarFormat:@"%a. %b. %d, %Y" timeZone:nil];
	
	
	[employeeInfoWindow setTitle:[NSString stringWithFormat:@"%@'s Info --- %@", [selectedEmployee valueForKey:@"name"], selectedDate]];
	
	// query emp plus minus and load arraycontrollers ...
	
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	int dayOfWeek;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	dayOfWeek = [workingDate dayOfWeek];
	
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day--;
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END AND employee == %@", selectedEmployee];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSFetchRequest * employeePettyRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * employeePettyDescription = [NSEntityDescription entityForName:@"EmployeePlusMinus" inManagedObjectContext:moc];
	[employeePettyRequest setEntity:employeePettyDescription];
	[employeePettyRequest setPredicate:predicate];
	double booking = [dailyReport employeeBookingForDay:selectedEmployee forDate:selectedDate];
	[employeeBookingField setObjectValue:[NSNumber numberWithDouble:booking]];
	NSArray * results = [moc executeFetchRequest:employeePettyRequest error:&error];
	NSLog(@"executing Fetch emp+/-");
	
	predicate = [NSPredicate predicateWithFormat:@"isPlus == YES"];
	NSMutableArray * employeePlus = [NSMutableArray arrayWithArray:results];
	[employeePlus filterUsingPredicate:predicate];
	predicate = [NSPredicate predicateWithFormat:@"isPlus == NO"];
	NSMutableArray * employeeMinus = [NSMutableArray arrayWithArray:results];
	[employeeMinus filterUsingPredicate:predicate];
	
	[employeePlusController setContent:employeePlus];
	[employeeMinusController setContent:employeeMinus];

	NSCalendarDate * beginningOfWeek = [beginningOfDay dateByAddingYears:0 months:0 days:-[beginningOfDay dayOfWeek] hours:0 minutes:0 seconds:0];	
	NSString * hoursDescription = [NSString stringWithFormat:@"%@'s Hours", [selectedEmployee valueForKey:@"name"]]; 
	float hours = 0;
	if ([[selectedEmployee valueForKey:@"tracksHours"] boolValue] == YES)	{

		
		int i;
		
		for(i=0; i<= dayOfWeek; i++)	{
			NSArray * timeCards = [dailyReport timeCardsInfoForDate:beginningOfWeek];
			
			int j;
			for (j=0; j< [timeCards count] ; j++)	{
				NSString * string = [[timeCards objectAtIndex:j] valueForKey:@"description"];
				if ([string compare:hoursDescription] == NSOrderedSame)	{
					hours += [[[timeCards objectAtIndex:j] valueForKey:@"amount"] floatValue];
				}
			}
			beginningOfWeek = [beginningOfWeek dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
		}
										   
		[employeeHousField setFloatValue:hours];
	} else	{
		[employeeHousField setIntValue:0];
	}
	
	[self updateEmployeeInfo];
}
-(void)updateEmployeeInfo
{
	NSArray * employeePlus = [employeePlusController content];
	NSArray * employeeMinus = [employeeMinusController content];
	int i;
	double plus, minus;
	plus = 0;
	minus =0;
	for (i=0; i< [employeePlus count]; i++)	{
		plus += [[[employeePlus objectAtIndex:i] valueForKey:@"amount"] doubleValue];
	}
	for (i=0; i< [employeeMinus count]; i++)	{
		minus += [[[employeeMinus objectAtIndex:i] valueForKey:@"amount"] doubleValue];
	}
	
	[empPlusForDay setDoubleValue:plus];
	[empMinusForDay setDoubleValue:minus];
	double dday = plus - minus;
	[empPlusMinusForDay setDoubleValue:dday];
	double week = [self getEmployeeInfoForWeekUntilToday:selectedEmployee];
	[empPlusMinusForWeek setDoubleValue:week];
	double total = dday + week;
	[empPlusMinusIncludingToday setDoubleValue:total];
}
-(void)loadEmployeeInfo:(NSManagedObject *)employee
{
	selectedEmployee = employee;
	
	[self loadEmployeeInfo];
	[employeeInfoWindow makeKeyAndOrderFront:self];
}

-(IBAction)addEmployeePlus:(id)sender
{
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	if ([[today description] compare:[selectedDate description]] == NSOrderedSame)	{
		NSMutableArray * employeePlus = [NSMutableArray arrayWithArray:[employeePlusController content]];
		NSManagedObject * newPlus = [NSEntityDescription insertNewObjectForEntityForName:@"EmployeePlusMinus" inManagedObjectContext:moc];
		[newPlus setValue:today forKey:@"time"];
		[newPlus setValue:selectedEmployee forKey:@"employee"];
		[newPlus setValue:[NSNumber numberWithBool:YES] forKey:@"isPlus"];
		
		id selectedClient = [pageView selectedBlock];
		if (selectedClient)	{
			selectedClient = [[selectedClient appointment] valueForKey:@"client"];
			if (selectedClient)	{
				[newPlus setValue:[selectedClient valueForKey:@"name"] forKey:@"pettyDescription"];
			} else	{
				[newPlus setValue:@"description" forKey:@"pettyDescription"];
			}
		} else	{
			[newPlus setValue:@"description" forKey:@"pettyDescription"];
		}
		
		[employeePlus addObject:newPlus];
		[employeePlusController setContent:employeePlus];
	}	
}
-(IBAction)removeEmployeePlus:(id)sender
{
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
//	if ([[today description] compare:[selectedDate description]] == NSOrderedSame)	{
	if (YES)	{
		NSManagedObject * removePlus = [[employeePlusController selectedObjects] objectAtIndex:0];
		if (removePlus)	{
			int selectionIndexForPlus = [employeePlusController selectionIndex];
			if (selectionIndexForPlus > 0)	{
				selectionIndexForPlus--;
			}
				
			[moc deleteObject:removePlus];
			NSMutableArray * content = [NSMutableArray arrayWithArray:[employeePlusController content]];
			[content removeObject:removePlus];
			[employeePlusController setContent:content];

			[self updateEmployeeInfo];
			[employeePlusController setSelectionIndex:selectionIndexForPlus];
		}
		
	}
}
-(IBAction)addEmployeeMinus:(id)sender
{
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	if ([[today description] compare:[selectedDate description]] == NSOrderedSame)	{
		NSMutableArray * employeeMinus = [NSMutableArray arrayWithArray:[employeeMinusController content]];
		NSManagedObject * newMinus = [NSEntityDescription insertNewObjectForEntityForName:@"EmployeePlusMinus" inManagedObjectContext:moc];
		[newMinus setValue:today forKey:@"time"];
		[newMinus setValue:selectedEmployee forKey:@"employee"];
		[newMinus setValue:[NSNumber numberWithBool:NO] forKey:@"isPlus"];
		[newMinus setValue:@"description" forKey:@"pettyDescription"];
		
		
		[employeeMinus addObject:newMinus];
		[employeeMinusController setContent:employeeMinus];
	}
	
}
-(IBAction)removeEmployeeMinus:(id)sender
{
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	if ([[today description] compare:[selectedDate description]] == NSOrderedSame)	{
		NSManagedObject * removeMinus = [[employeeMinusController selectedObjects] objectAtIndex:0];
		if (removeMinus)	{
			int selectionIndexForMinus = [employeeMinusController selectionIndex];
			if (selectionIndexForMinus > 0)	{
				selectionIndexForMinus--;
			}
			
			
			[moc deleteObject:removeMinus];
			NSMutableArray * content = [NSMutableArray arrayWithArray:[employeeMinusController content]];
			[content removeObject:removeMinus];
			[employeeMinusController setContent:content];
						
			[self updateEmployeeInfo];
			[employeeMinusController setSelectionIndex:selectionIndexForMinus];
		}
		
	}
}
-(IBAction)addMiscPlus:(id)sender
{
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	if ([[today description] compare:[selectedDate description]] == NSOrderedSame)	{
		NSMutableArray * miscPlus = [NSMutableArray arrayWithArray:[miscPlusController content]];
		NSManagedObject * newPlus = [NSEntityDescription insertNewObjectForEntityForName:@"MiscellaneousPlusMinus" inManagedObjectContext:moc];
		
		[newPlus setValue:today forKey:@"time"];
		[newPlus setValue:[NSNumber numberWithBool:YES] forKey:@"isPlus"];
		[newPlus setValue:@"description" forKey:@"pettyDescription"];
		
		
		[miscPlus addObject:newPlus];
		[miscPlusController setContent:miscPlus];
	}
}
-(IBAction)removeMiscPlus:(id)sender
{
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	if ([[today description] compare:[selectedDate description]] == NSOrderedSame)	{
		NSManagedObject * removePlus = [[miscPlusController selectedObjects] objectAtIndex:0];
		if (removePlus)	{
			int selectionIndexForPlus = [miscPlusController selectionIndex];
			int selectionIndexForMinus = [miscMinusController selectionIndex];
			if (selectionIndexForPlus > 0)	{
				selectionIndexForPlus--;
			}
			
			[moc deleteObject:removePlus];
			error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
			[self loadMiscellaneous];
			[miscPlusController setSelectionIndex:selectionIndexForPlus];
			[miscMinusController setSelectionIndex:selectionIndexForMinus];
			
		}
		
	}
}
-(IBAction)addMiscMinus:(id)sender
{
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	if ([[today description] compare:[selectedDate description]] == NSOrderedSame)	{
		NSMutableArray * miscMinus = [NSMutableArray arrayWithArray:[miscMinusController content]];
		NSManagedObject * newMinus = [NSEntityDescription insertNewObjectForEntityForName:@"MiscellaneousPlusMinus" inManagedObjectContext:moc];
		
		[newMinus setValue:today forKey:@"time"];
		[newMinus setValue:[NSNumber numberWithBool:NO] forKey:@"isPlus"];
		[newMinus setValue:@"description" forKey:@"pettyDescription"];
		
		
		[miscMinus addObject:newMinus];
		[miscMinusController setContent:miscMinus];
	}
}
-(IBAction)removeMiscMinus:(id)sender
{
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	if ([[today description] compare:[selectedDate description]] == NSOrderedSame)	{
		NSManagedObject * removeMinus = [[miscMinusController selectedObjects] objectAtIndex:0];
		if (removeMinus)	{
			int selectionIndexForPlus = [miscPlusController selectionIndex];
			int selectionIndexForMinus = [miscMinusController selectionIndex];
			if (selectionIndexForMinus > 0)	{
				selectionIndexForMinus--;
			}
			
			
			[moc deleteObject:removeMinus];
			error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
			
			[self loadMiscellaneous];
			[miscPlusController setSelectionIndex:selectionIndexForPlus];
			[miscMinusController setSelectionIndex:selectionIndexForMinus];
			
		}
		
	}
}
-(IBAction)addPayout:(id)sender
{
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	if ([[today description] compare:[selectedDate description]] == NSOrderedSame)	{
		NSMutableArray * payouts = [NSMutableArray arrayWithArray:[payoutsController content]];
		NSManagedObject * newMinus = [NSEntityDescription insertNewObjectForEntityForName:@"Payouts" inManagedObjectContext:moc];
		
		[newMinus setValue:today forKey:@"time"];
		[newMinus setValue:@"description" forKey:@"pettyDescription"];
		
		
		[payouts addObject:newMinus];
		[payoutsController setContent:payouts];
	}
}
-(IBAction)removePayout:(id)sender
{
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	if ([[today description] compare:[selectedDate description]] == NSOrderedSame)	{
		NSManagedObject * removeMinus = [[payoutsController selectedObjects] objectAtIndex:0];
		if (removeMinus)	{

			int selectionIndexForMinus = [payoutsController selectionIndex];
			if (selectionIndexForMinus > 0)	{
				selectionIndexForMinus--;
			}
			
			
			[moc deleteObject:removeMinus];
			error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
			
			[self loadPayouts];

			[payoutsController setSelectionIndex:selectionIndexForMinus];
			
		}
		
	}
}

-(IBAction)goToPayouts:(id)sender
{
	moc = [appDelegate managedObjectContext];
	[self loadPayouts];
	[payoutsWindow makeKeyAndOrderFront:self];
}
-(void)updateMiscellaneousInfo
{
	NSArray * miscPlus = [miscPlusController content];
	NSArray * miscMinus = [miscMinusController content];
	
	double plus, minus;
	int i;
	plus = 0;
	minus = 0;
	for (i = 0; i < [miscPlus count]; i++)	{
		plus += [[[miscPlus objectAtIndex:i] valueForKey:@"amount"] doubleValue];
	}
	for (i = 0; i < [miscMinus count]; i++)	{
		minus += [[[miscMinus objectAtIndex:i] valueForKey:@"amount"] doubleValue];
	}
	[miscPlusForDay setDoubleValue:plus];
	[miscMinusForDay setDoubleValue:minus];
	
}
-(void)updatePayoutsInfo
{
	NSArray * payouts = [payoutsController content];
	int i;
	double total = 0;
	for (i=0; i< [payouts count]; i++)	{
		total += [[[payouts objectAtIndex:i] valueForKey:@"amount"] doubleValue];
	}
	[payoutsForDay setDoubleValue:total];
}
-(void)loadPayouts
{
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	if ([[today description] compare:[selectedDate description]] != NSOrderedSame)	{
		int i;
		NSArray * tableColumns = [payoutsTable tableColumns];
		for ( i=0 ; i< [tableColumns count]; i++)	{
			[[tableColumns objectAtIndex:i] setEditable:NO];
			
		}
		
	} else	{
		int i;
		NSArray * tableColumns = [payoutsTable tableColumns];
		for ( i=0 ; i< [tableColumns count]; i++)	{
			[[tableColumns objectAtIndex:i] setEditable:YES];
			
		}
		
	}
	
	NSString * title = [NSString stringWithFormat:@"Payouts --- %@", selectedDate];
	[payoutsWindow setTitle:title];
	
	// query  payouts and load arraycontrollers ...
	
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
	
	NSFetchRequest * payoutsPettyRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * payoutsPettyDescription = [NSEntityDescription entityForName:@"Payouts" inManagedObjectContext:moc];
	[payoutsPettyRequest setEntity:payoutsPettyDescription];
	[payoutsPettyRequest setPredicate:predicate];
	
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:payoutsPettyRequest error:&error]];
	NSLog(@"executing Fetch payouts");
	
	NSSortDescriptor * timeSort = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES] autorelease];
	NSArray * sortArray = [NSArray arrayWithObject:timeSort];
	
	[results sortUsingDescriptors:sortArray];
	[payoutsController setContent:results];
	[self updatePayoutsInfo];
	
}
-(IBAction)goToMiscellaneous:(id)sender
{
	moc = [appDelegate managedObjectContext];
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	if ([[today description] compare:[selectedDate description]] != NSOrderedSame)	{
		int i;
		NSArray * tableColumns = [miscellaneousPlusTable tableColumns];
		for ( i=0 ; i< [tableColumns count]; i++)	{
			[[tableColumns objectAtIndex:i] setEditable:NO];
			
		}
		
		tableColumns = [miscellaneousMinusTable tableColumns];
		for ( i=0 ; i< [tableColumns count]; i++)	{
			[[tableColumns objectAtIndex:i] setEditable:NO];
			
		}
	} else	{
		int i;
		NSArray * tableColumns = [miscellaneousPlusTable tableColumns];
		for ( i=0 ; i< [tableColumns count]; i++)	{
			[[tableColumns objectAtIndex:i] setEditable:YES];
			
		}
		
		tableColumns = [miscellaneousMinusTable tableColumns];
		for ( i=0 ; i< [tableColumns count]; i++)	{
			[[tableColumns objectAtIndex:i] setEditable:YES];
			
		}
	}
	
	[self loadMiscellaneous];
	[miscellaneousWindow makeKeyAndOrderFront:self];
}
-(void)loadMiscellaneous
{
	NSCalendarDate * selectedDate = [lastSelectedDate dateWithCalendarFormat:@"%a. %b. %d, %Y" timeZone:nil];
	NSString * title = [NSString stringWithFormat:@"Miscellaneous (+/-) --- %@", selectedDate];
	[miscellaneousWindow setTitle:title];
	
	
	// query misc plus minus and load arraycontrollers ...
	
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
	
	NSFetchRequest * miscPettyRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * miscPettyDescription = [NSEntityDescription entityForName:@"MiscellaneousPlusMinus" inManagedObjectContext:moc];
	[miscPettyRequest setEntity:miscPettyDescription];
	[miscPettyRequest setPredicate:predicate];
	
	NSArray * results = [moc executeFetchRequest:miscPettyRequest error:&error];
	NSLog(@"executing Fetch misc+/-");
	
	predicate = [NSPredicate predicateWithFormat:@"isPlus == YES"];
	NSMutableArray * miscPlus = [NSMutableArray arrayWithArray:results];
	[miscPlus filterUsingPredicate:predicate];
	predicate = [NSPredicate predicateWithFormat:@"isPlus == NO"];
	NSMutableArray * miscMinus = [NSMutableArray arrayWithArray:results];
	[miscMinus filterUsingPredicate:predicate];
	
	NSSortDescriptor * timeSort = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES] autorelease];
	NSArray * sortArray = [NSArray arrayWithObject:timeSort];
	[miscPlus sortUsingDescriptors:sortArray];
	[miscMinus sortUsingDescriptors:sortArray];
	[miscPlusController setContent:miscPlus];
	[miscMinusController setContent:miscMinus];
	[self updateMiscellaneousInfo];
}
/*-(void)addEmployeePlusWithEmployee:(NSManagedObject *)employee
{
	
		
}
//-(void)removeEmployeePlusWithEmployee:(NSManagedObject *)employee;
-(void)addEmployeeMinusWithEmployee:(NSManagedObject *)employee
{
	
}
//-(void)removeEmployeeMinusWithEmployee:(NSManagedObject *)employee;
-(void)addMiscPlusWithEmployee:(NSManagedObject *)employee
{
	
}
//-(void)removeMiscPlusWithEmployee:(NSManagedObject *)employee;
-(void)addMiscMinusWithEmployee:(NSManagedObject *)employee
{
	
}
//-(void)removeMiscMinusWithEmployee:(NSManagedObject *)employee;
-(void)addPayoutWithEmployee:(NSManagedObject *)employee
{
	
}
//-(void)removePayoutWithEmployee:(NSManagedObject *)employee;

-(void)setSignature:(NSManagedObject *)employee
{
	
}
*/
/*
- (void)windowDidBecomeMain:(NSNotification *)notification
{
	id object = [notification object];
	if (object == employeeInfoWindow)	{
		[self loadEmployeeInfo];
	}
	if (object == payoutsWindow)	{
		[self loadPayouts];
	}
}
*/
- (void)windowDidResignMain:(NSNotification *)notification
{
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
}
-(void)setSignature:(NSManagedObject *)employee
{
	NSString * signature = [employee valueForKey:@"signature"];
	if (signature == nil)	{
		signature = [employee valueForKey:@"name"];
	}
	[[[workingController selectedObjects] objectAtIndex:0] setValue:signature forKey:@"bookedBy"];
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
}
-(void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	
	id object = [aNotification object];
	if (object == employeePlusTable || object == employeeMinusTable)	{
		[self updateEmployeeInfo];
		if (object == employeeMinusTable)	{
/* HARMONY SPECIFIC */
			id select = [[employeeMinusController selectedObjects] objectAtIndex:0];

			if ([[select valueForKey:@"pettyDescription"] hasSuffix:@"!"] == NO)	{
				NSString * description = [NSString stringWithFormat:@"%@!", [select valueForKey:@"pettyDescription"]];
				[select setValue:description forKey:@"pettyDescription"];
			}
/* HARMONY SPECIFIC */				
		}
		
	}
	if (object == miscellaneousPlusTable || object == miscellaneousMinusTable)	{
		[self updateMiscellaneousInfo];
		/* HARMONY SPECIFIC */
		if (object== miscellaneousPlusTable)	{
			id select = [[miscPlusController selectedObjects] objectAtIndex:0];
			
			if ([[select valueForKey:@"pettyDescription"] hasSuffix:@"!"] == NO)	{
				NSString * description = [NSString stringWithFormat:@"%@!", [select valueForKey:@"pettyDescription"]];
				[select setValue:description forKey:@"pettyDescription"];
			}
			
		}
		if (object == miscellaneousMinusTable)	{
			id select = [[miscMinusController selectedObjects] objectAtIndex:0];
			
			if ([[select valueForKey:@"pettyDescription"] hasSuffix:@"!"] == NO)	{
				NSString * description = [NSString stringWithFormat:@"%@!", [select valueForKey:@"pettyDescription"]];
				[select setValue:description forKey:@"pettyDescription"];
				
				
			}
		
		}
		
		/* HARMONY SPECIFIC */				
		
		
		
	}

	if (object == payoutsTable)	{
		[self updatePayoutsInfo];
		/* HARMONY SPECIFIC */
		id select = [[payoutsController selectedObjects] objectAtIndex:0];
		
		if ([[select valueForKey:@"pettyDescription"] hasSuffix:@"!"] == NO)	{
			NSString * description = [NSString stringWithFormat:@"%@!", [select valueForKey:@"pettyDescription"]];
			[select setValue:description forKey:@"pettyDescription"];
		}
		/* HARMONY SPECIFIC */				
		
		
	}
}

-(IBAction)viewEmployeePlusMinusForWeek:(id)sender
{
	
	
	NSArray * employees = [staffController workingStaff:[mainDatePicker dateValue]];
	NSLog(@"executing Fetch employee");
	NSMutableArray * employeeInfo = [NSMutableArray array];
	int i;
	for (i=0; i< [employees count]; i++)	{
		float upOrDown = [self getEmployeeInfoForWeek:[employees objectAtIndex:i]];
		NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
		
		[dictionary setValue:[NSNumber numberWithFloat:upOrDown] forKey:@"plusMinus"];
		[dictionary setValue:[[employees objectAtIndex:i] valueForKey:@"name"] forKey:@"employee"];
		[employeeInfo addObject:dictionary];
	}
	NSCalendarDate * date = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];

	[employeeInfoWeeklyController setContent:employeeInfo];
	NSString * title = [NSString stringWithFormat:@"Employee Info %@", date];
	[weeklyEmployeeInfo setTitle:title];
	[weeklyEmployeeInfo makeKeyAndOrderFront:self];
}
-(IBAction)viewPlusMinusForDay:(id)sender
{
	// set tables to not editable
}
-(void)loadPlusMinusForTheDay
{
	NSMutableArray * miscPlusArray;
	NSMutableArray * miscMinusArray;
	NSMutableArray * payoutArray;
	NSMutableArray * employees;
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	int dayOfWeek;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	dayOfWeek = [workingDate dayOfWeek];
	
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day--;
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END", selectedEmployee];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	
	NSFetchRequest * employeePettyRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * employeePettyDescription = [NSEntityDescription entityForName:@"EmployeePlusMinus" inManagedObjectContext:moc];
	[employeePettyRequest setEntity:employeePettyDescription];
	[employeePettyRequest setPredicate:predicate];
	NSArray * results = [moc executeFetchRequest:employeePettyRequest error:&error];
	NSLog(@"executing Fetch emp+/-");
	
	NSMutableArray * employeesOverview = [NSMutableArray arrayWithArray:[staffController workingStaff:[mainDatePicker dateValue]]];
	NSMutableArray * empInfos = [NSMutableArray array];
	int i;
	for ( i=0; i< [employeesOverview count] ; i++)	{
		predicate = [NSPredicate predicateWithFormat:@"isPlus == YES && employee.name == %@", [[employeesOverview objectAtIndex:i] valueForKey:@"name"]];
		NSMutableArray * employeePlus = [NSMutableArray arrayWithArray:results];
		[employeePlus filterUsingPredicate:predicate];
		predicate = [NSPredicate predicateWithFormat:@"isPlus == NO && employee.name == %@", [[employeesOverview objectAtIndex:i] valueForKey:@"name"]];
		NSMutableArray * employeeMinus = [NSMutableArray arrayWithArray:results];
		[employeeMinus filterUsingPredicate:predicate];
		if ([employeePlus count] == 0 && [employeeMinus count] == 0)	{
			
		} else	{
			[empInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:employeePlus, @"employeePlus", employeeMinus, @"employeeMinus", [employeesOverview objectAtIndex:i], @"employee", nil]];  
		}
			 
		NSMutableArray * subviews = [NSMutableArray array];	
		int dayOfMonth = [workingDate dayOfMonth];
		int i;
		int employeeCount = [empInfos count];
		
		float overviewHeight = 40 + (CHECKBOXHEIGHT* employeeCount) + (CHECKBOXVERTICALSPACING*(employeeCount-1));
		NSRect frame = [employeeInfoOverview frame];
		frame.size.height = overviewHeight;
		[employeeInfoOverview setFrame:frame];
		int j;
		for (j=0; j< [employeesOverview count]; j++)	{
			
		}
		
		
	}
	
	
	
	
}
-(IBAction)editPlusMinusForDay:(id)sender
{
	
}


@end
