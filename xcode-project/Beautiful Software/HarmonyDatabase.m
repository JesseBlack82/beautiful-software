//
//  HarmonyDatabase.m
//  Beautiful Software
//
//  Created by Jesse Black on 3/7/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import "HarmonyDatabase.h"
#import "PageView.h"
#import "BuildingBlock.h"

@implementation HarmonyDatabase
-(id)init
{
	self = [super init];
//	apptFormat = [[JBApptFormat alloc] init];
	matchingDates = [[NSMutableArray alloc] init];
	databaseStem = [[NSString alloc] initWithString:@"/Users/harmony/Harmony/Database/"];
//	[firstField setCell:[[[JBFieldCell alloc] init] autorelease]];
	//	[lastField setParent:self];
	//	[lastField setIsFirst:NO];
	//	[lastField setIsLast:YES];
	
	return self;
}
-(void)awakeFromNib
{
	[firstField setDelegate:self];
	[lastField setDelegate:self];
}
-(void)dealloc
{
//	[apptFormat release];
	[matchingDates release];
	[databaseStem release];
	[super dealloc];
}
-(IBAction)updateDatabaseAction:(id)sender
{
	
//	[passwordController password:self];
}
-(IBAction)viewDatabase:(id)sender
{
	[databaseWindow makeKeyAndOrderFront:self];

	id appointment = [[pageView selectedBlock] appointment];
	NSString * first;
	NSString * last;
	
	NSArray * substrings = [[appointment valueForKeyPath:@"client.name"] componentsSeparatedByString:@" "];
	first = [substrings objectAtIndex:0];
	last = [substrings objectAtIndex:1];
	[firstField setStringValue:first];
	[lastField setStringValue:last];
	[self search];
	
}
-(void)searchClientFromAppointment:(id)appointment
{
	[databaseWindow makeKeyAndOrderFront:self];
	NSString * first;
	NSString * last;
	NSArray * substrings = [[appointment valueForKey:@"client"] componentsSeparatedByString:@" "];
	first = [substrings objectAtIndex:0];
	last = [substrings objectAtIndex:1];
	[firstField setStringValue:first];
	[lastField setStringValue:last];
	[self search];
	
	
}
-(IBAction)searchAction:(id)sender
{
	[self search];
}
-(void)search
{
	NSMutableString * firstFirstString = [NSMutableString stringWithString:[firstField stringValue]];
	NSMutableString * lastFirstString = [NSMutableString stringWithString:[lastField stringValue]];
	firstFirstString = [firstFirstString uppercaseString];
	if ([firstFirstString length] > 0)	{
		firstFirstString = [NSString stringWithFormat:@"%c",[firstFirstString characterAtIndex:0]];
	}
	if ([lastFirstString length] > 0)	{
		lastFirstString = [NSString stringWithFormat:@"%c", [lastFirstString characterAtIndex:0]];
	}
	
	
	lastFirstString = [lastFirstString uppercaseString];
	NSMutableSet * firstSet = [NSMutableSet setWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%@FIRST%@", databaseStem, firstFirstString]]];
	NSMutableSet * lastSet = [NSMutableSet setWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%@LAST%@", databaseStem, lastFirstString]]];
	NSPredicate *firstPredicate = [NSPredicate predicateWithFormat:@"client contains %@", [firstField stringValue]];
	NSPredicate *lastPredicate = [NSPredicate predicateWithFormat:@"client contains %@", [lastField stringValue]];
	
	[firstSet filterUsingPredicate:firstPredicate];
	[lastSet filterUsingPredicate:lastPredicate];
	int i;
	NSMutableSet * bestSet = [NSMutableSet set];
	[bestSet addObjectsFromArray:[firstSet allObjects]];
	
	if ([lastField stringValue] != @"")	{
		[bestSet filterUsingPredicate:lastPredicate];
	}
	
	
	NSMutableString * firstDescriptionString = [NSMutableString string];
	NSMutableString * lastDescriptionString = [NSMutableString string];
	NSArray * lastArray = [lastSet allObjects];
	NSArray * firstArray = [firstSet allObjects];
	id firstDescription;
	id lastDescription;
	for (i=0; i < [lastArray count]; i++)	{
//		if ((lastDescription = [apptFormat formatAppt:[lastArray objectAtIndex:i]]) != nil)	{
//			[lastDescriptionString appendFormat:@"{\n%@}\n\n",lastDescription];
//		}
	}
	for (i=0; i < [firstArray count]; i++)	{
//		if ((firstDescription = [apptFormat formatAppt:[firstArray objectAtIndex:i]]) != nil)	{
//			[firstDescriptionString appendFormat:@"{\n%@}\n\n",firstDescription];
			
//		}
	}
	[matchingDates removeAllObjects];
	NSArray * bestArray = [bestSet allObjects];
	id bestAppt;
	for (i=0; i< [bestArray count]; i++)	{
		if ((bestAppt = [bestArray objectAtIndex:i]) != nil)	{
			[matchingDates addObject:bestAppt];
		}
	}
	NSSortDescriptor * sortByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	[matchingDates sortUsingDescriptors:[NSArray arrayWithObject:sortByDate]];
	[sortByDate release];
	[matchingController setContent:matchingDates];
	NSString * resultsString = [NSString stringWithFormat:@"Results by last name---\n%@\nResults by first name---\n%@", lastDescriptionString, firstDescriptionString];
	[resultsField setString:resultsString];
}
-(NSMutableArray *)matchingDates
{
	return matchingDates;
}
-(void)newLetterInFirstName
{
	
}
-(NSMutableArray *)searchNames:(NSString *)name
{
	NSMutableArray * possibleResults = [NSMutableArray array];
	
	if ([name length] > 0)	{
		char firstLetter = [name characterAtIndex:0];
		NSMutableSet * firstSet = [NSMutableSet setWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%@FIRST%c", databaseStem, firstLetter]]];
		NSPredicate *firstPredicate = [NSPredicate predicateWithFormat:@"client contains %@", name];
		[firstSet filterUsingPredicate:firstPredicate];
		
		
		
		[possibleResults addObjectsFromArray:[firstSet allObjects]];
		
		
		
	}
	return possibleResults;
}
-(void)newLetterInLastName
{
	
}
-(void)controlTextDidChange:(NSNotification *)aNotification
{
	id button = [aNotification object];
	NSRange thisRange = NSMakeRange(0, 1);
	NSMutableString * mstring = [NSMutableString stringWithString:[button stringValue]];
	[mstring replaceCharactersInRange:thisRange withString:[[mstring substringWithRange:thisRange] uppercaseString]];
	[button setStringValue:mstring];
	
	[self search];
}
-(void)password:(NSString *)employee
{
	
	if (([employee compare:@"Joseph"] == NSOrderedSame) ||
		([employee compare:@"Louis"] == NSOrderedSame) ||
		([employee compare:@"Jesse"] == NSOrderedSame)	||
		([employee compare:@"Maritza"] == NSOrderedSame) ||
		([employee compare:@"Corey"] == NSOrderedSame))	{
		
		[self updateDatabase];
		
		
		
	}
	
}

-(void)updateDatabase
{
//	dateController = [[JBDateController alloc] init];
	
	
	NSOpenPanel * openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel runModal];
	NSArray * filenames = [openPanel filenames];
	int counter;
	for (counter = 0 ; counter < [[openPanel filenames] count]; counter++)	{
		id newTest = [NSMutableDictionary dictionary];
		id test = [NSKeyedUnarchiver unarchiveObjectWithFile:[filenames objectAtIndex:counter]];
		int i,j,k;
		id keys = [test allKeys];
		for (i=0; i< [keys count]; i++)	{
			[newTest setObject:[NSMutableDictionary dictionary] forKey:[keys objectAtIndex:i]];
			////////////////////////////////////////////////////////
			id dayKeys = [[test objectForKey:[keys objectAtIndex:i]] allKeys];
			for (j=0; j< [dayKeys count]; j++)	{
				[[newTest objectForKey:[keys objectAtIndex:i]] setObject:[NSMutableArray array] forKey:[dayKeys objectAtIndex:j]];
				id apptArray = [[test objectForKey:[keys objectAtIndex:i]] objectForKey:[dayKeys objectAtIndex:j]];
				for (k=0; k < [apptArray count]; k++)	{
					[self checkAppointment:[apptArray objectAtIndex:k]];
				}
			}
		}
	}
}
-(void)checkAppointment:(NSMutableDictionary *)appointment
{
	NSString * client = [appointment objectForKey:@"client"];
	if ([appointment objectForKey:@"collectedBy"] != nil)	{
		if ([appointment objectForKey:@"price"] != nil || [[appointment objectForKey:@"price"] intValue] > 0)	{
			
			NSArray * separatedName = [client componentsSeparatedByString:@" "];
			int i;
			NSMutableString * firstName = [NSMutableString string];
			NSMutableString * lastName = [NSMutableString string];
			if ([separatedName objectAtIndex:0] != nil)	{
				[firstName appendString:[separatedName objectAtIndex:0]];
				[appointment setObject:firstName forKey:@"first"];
			}
			for ( i= 1 ; i< [separatedName count]; i++)	{
				[lastName appendFormat:@"%@", [separatedName objectAtIndex:i]];
			}
			if ([lastName length] >0)	{
				[appointment setObject:lastName forKey:@"last"];
			}
			NSString * firstPath;
			NSString * lastPath;
			if ([firstName length] > 0)	{
				firstPath = [NSString stringWithFormat:@"%@FIRST%c", databaseStem, [firstName characterAtIndex:0]];
			} else	{
				firstPath = [NSString stringWithFormat:@"%@FIRSTblank", databaseStem];
			}
			
			
			
			if ([lastName length] > 0)	{
				lastPath = [NSString stringWithFormat:@"%@LAST%c", databaseStem, [lastName characterAtIndex:0]];
			} else lastPath = [NSString stringWithFormat:@"%@LASTblank", databaseStem];
			
			NSMutableArray * firstTest = [NSKeyedUnarchiver unarchiveObjectWithFile:firstPath];
			NSMutableArray * lastTest = [NSKeyedUnarchiver unarchiveObjectWithFile:lastPath];
			if (firstTest != nil)	{
				[firstTest addObject:appointment];
			}
			else firstTest = [NSMutableArray arrayWithObject:appointment];
			if (lastTest != nil)	{
				[lastTest addObject:appointment];
			}
			
			else lastTest = [NSMutableArray arrayWithObject:appointment];
			
			[NSKeyedArchiver archiveRootObject:firstTest toFile:firstPath];
			[NSKeyedArchiver archiveRootObject:lastTest toFile:lastPath];
		}
		
		
	}
}

@end
