//
//  PasswordController.m
//  Beautiful Software
//
//  Created by Jesse Black on 2/1/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import "PasswordController.h"


@implementation PasswordController
@synthesize arguments;
@synthesize requestedFrom;

@synthesize passwordLevelsPath;
@synthesize lastPassword;
@synthesize employeeChangingPassword;

-(void)awakeFromNib
{
	NSMutableString * ppath = [NSMutableString stringWithString:[appDelegate applicationSupportFolder]];
	[ppath appendString:@"/passwordLevelsPath"];
	[self setPasswordLevelsPath:ppath];
	
	moc = [appDelegate managedObjectContext];
	
	NSMutableDictionary * passwordLevels;
	id test = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordLevelsPath];
	if (test == nil)	{
		passwordLevels = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   [NSNumber numberWithInt:1], @"editStaffLevel",
						  [NSNumber numberWithInt:2], @"changePasswordLevel", 
						  [NSNumber numberWithInt:1], @"changeScheduleLevel", 
						  [NSNumber numberWithInt:0], @"editServiceMenuLevel", 
						  [NSNumber numberWithInt:1], @"editRetailMenuLevel", 
						  [NSNumber numberWithInt:1], @"editTransactionsLevel",
						  [NSNumber numberWithInt:0], @"viewReportsLevel",  nil];
		[NSKeyedArchiver archiveRootObject:passwordLevels toFile:passwordLevelsPath];
	} 
	
	
	 
	
	[password setTarget:self];
	[password setAction:@selector(passwordEntered:)];
}
-(void)getPasswordFor:(id)newRequestedFrom arguments:(NSMutableArray *)newArguments selector:(SEL)newSelector
{
	[self setArguments:newArguments];
	[self setRequestedFrom:newRequestedFrom];
	selector = newSelector;
	[self loadPasswordEntry];
}
-(void)loadPasswordEntry
{
	[password setObjectValue:nil];

	[passwordEntryWindow makeKeyAndOrderFront:self];
	
}
-(void)passwordEntered:(id)sender
{
	
	NSFetchRequest * passwordRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * passwordDescription = [NSEntityDescription entityForName:@"Password" inManagedObjectContext:moc];
	[passwordRequest setEntity:passwordDescription];
	NSArray * results = [moc executeFetchRequest:passwordRequest error:&error];
	NSLog(@"executing Fetch password");
	NSString * pass = [password stringValue];
	NSManagedObject * returnPassword = [[[NSManagedObject alloc] init] autorelease];
	int i;
	for (i=0; i<[results count]; i++)	{
		if ([[[results objectAtIndex:i] valueForKey:@"password"] compare:pass] == NSOrderedSame)	{
			returnPassword = [results objectAtIndex:i];
		}
	}
	if ([returnPassword entity])	{
		[requestedFrom performSelector:selector withObject:returnPassword];
	}
	[self setLastPassword:returnPassword];
	[passwordEntryWindow close];
	
}
-(void)closeWindow
{
	[passwordEntryWindow close];
}
-(NSMutableArray *)fetchStaff
{
	NSFetchRequest * employeeRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * employeeDescription = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:moc];
	[employeeRequest setEntity:employeeDescription];
	
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:employeeRequest error:&error]];
	NSLog(@"executing Fetch employee");
	NSSortDescriptor * listOrderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	[results sortUsingDescriptors:[NSArray arrayWithObject:listOrderDescriptor]];
	
	
	return results;
	
}
-(void)sortPasswordTrustLevels
{
	id test = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordLevelsPath];
	
	NSArray * keys = [test allKeys];
	int i;
	NSMutableArray * highTrust = [NSMutableArray array];
	NSMutableArray * mediumTrust = [NSMutableArray array];
	NSMutableArray * lowTrust = [NSMutableArray array];
	for (i=0; i< [keys count]; i++)	{
		if ([[test valueForKey:[keys objectAtIndex:i]] intValue] == 0)	{
			[lowTrust addObject:[keys objectAtIndex:i]];
		} else if ([[test valueForKey:[keys objectAtIndex:i]] intValue] == 1)	{
			[mediumTrust addObject:[keys objectAtIndex:i]];
		} else if ([[test valueForKey:[keys objectAtIndex:i]] intValue] == 2)	{
			[highTrust addObject:[keys objectAtIndex:i]];
		}
	}
	[lowTrustController setContent:lowTrust];
	[mediumTrustController setContent:mediumTrust];
	[highTrustController setContent:highTrust];
}
-(void)passwordEnteredForEdit:(NSManagedObject*)passwordEntered
{
	
	if ([passwordEntered valueForKey:@"passwordLevel"] != nil)	{
		int passwordLevel = [[passwordEntered valueForKey:@"passwordLevel"] intValue];
		id test = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordLevelsPath];
		if (passwordLevel >= [[test valueForKey:@"changePasswordLevel"] intValue] )	{
			[self sortPasswordTrustLevels];
			NSArray * staff = [self fetchStaff];
			[employeeController setContent:staff];
			
			
			[passwordControllerWindow makeKeyAndOrderFront:self];
		}
	}
	
}
-(IBAction)goToPasswordController:(id)sender
{
	SEL selector = @selector(passwordEnteredForEdit:);
	[self getPasswordFor:self arguments:nil selector:selector];
	
	
}
-(IBAction)makeEmployeeLevel3:(id)sender
{
	NSManagedObject * employee = [[employeeController selectedObjects] objectAtIndex:0];
	[[employee valueForKey:@"password"] setValue:[NSNumber numberWithInt:2] forKey:@"passwordLevel"];
	[lowTrustButton setState:0];
	[mediumTrustButton setState:0];
	[highTrustButton setState:1];
	[moc save:&error];
	
}
-(IBAction)makeEmployeeLevel2:(id)sender
{
	NSManagedObject * employee = [[employeeController selectedObjects] objectAtIndex:0];
	if ([[employee valueForKeyPath:@"password.passwordLevel"] intValue] < 2)	{
		[[employee valueForKey:@"password"] setValue:[NSNumber numberWithInt:1] forKey:@"passwordLevel"];
		[lowTrustButton setState:0];
		[mediumTrustButton setState:1];
		[highTrustButton setState:0];
		[moc save:&error];
		
	} 
}
-(IBAction)makeEmployeeLevel1:(id)sender
{
	NSManagedObject * employee = [[employeeController selectedObjects] objectAtIndex:0];
	if ([[lastPassword valueForKey:@"passwordLevel"] intValue] > [[employee valueForKeyPath:@"password.passwordLevel"] intValue])	{
		[[employee valueForKey:@"password"] setValue:[NSNumber numberWithInt:0] forKey:@"passwordLevel"];
		[lowTrustButton setState:1];
		[mediumTrustButton setState:0];
		[highTrustButton setState:0];
		[moc save:&error];
	} else	{
		if (lastPassword == [employee valueForKey:@"password"])	{
			[[employee valueForKey:@"password"] setValue:[NSNumber numberWithInt:0] forKey:@"passwordLevel"];
			[lowTrustButton setState:1];
			[mediumTrustButton setState:0];
			[highTrustButton setState:0];
			[moc save:&error];
		}
	}
}
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSTableView * tableView = [aNotification object];
	if (tableView == employeeTable)	{
		NSManagedObject * employee = nil;
		if ([[employeeController selectedObjects] count] > 0)	{
			employee = [[employeeController selectedObjects] objectAtIndex:0];
		}
		
		if (employee != nil)	{
			if ([employee valueForKey:@"password"] == nil)	{
			NSManagedObject * newPassword = [NSEntityDescription insertNewObjectForEntityForName:@"Password" inManagedObjectContext:moc];
			[employee setValue:newPassword forKey:@"password"];
			[newPassword setValue:[employee valueForKey:@"name"] forKey:@"password"];
			[newPassword setValue:[NSNumber numberWithInt:0] forKey:@"passwordLevel"];
			}
		}
		
		int passwordLevel = [[employee valueForKeyPath:@"password.passwordLevel"] intValue];
		if (passwordLevel >= 2)	{
			[lowTrustButton setState:0];
			[mediumTrustButton setState:0];
			[highTrustButton setState:1];
			

		}
		if (passwordLevel == 1)	{
			[lowTrustButton setState:0];
			[mediumTrustButton setState:1];
			[highTrustButton setState:0];
			
			
		}
		if (passwordLevel == 0)	{
			[lowTrustButton setState:1];
			[mediumTrustButton setState:0];
			[highTrustButton setState:0];
			
			
		}
	}
}
-(IBAction)moveLevel3CategoryToLevel2:(id)sender
{
	if ([[highTrustController selectedObjects] count] > 0)	{
		NSString * key = [[highTrustController selectedObjects] objectAtIndex:0];
		id test = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordLevelsPath];
		[test setValue:[NSNumber numberWithInt:1] forKey:key];
		[NSKeyedArchiver archiveRootObject:test toFile:passwordLevelsPath];
		[self sortPasswordTrustLevels];
	}
	
}
-(IBAction)moveLevel2CategoryToLevel3:(id)sender
{
	if ([[mediumTrustController selectedObjects] count] > 0)	{
		NSString * key = [[mediumTrustController selectedObjects] objectAtIndex:0];
		id test = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordLevelsPath];
		[test setValue:[NSNumber numberWithInt:2] forKey:key];
		
		[NSKeyedArchiver archiveRootObject:test toFile:passwordLevelsPath];
		
		[self sortPasswordTrustLevels];
	}
}

-(IBAction)moveLevel2CategoryToLevel1:(id)sender
{
	
}
-(IBAction)moveLevel1CategoryToLevel2:(id)sender
{
	
}
-(IBAction)changeMyPassword:(id)sender
{
	SEL sselector = @selector(employeeChosenForChangePassword:);
	[employeeSelect selectEmployeeFor:self selector:sselector windowTitle:@"Change Password"];
}

-(void)employeeChosenForChangePassword:(NSManagedObject *)employee
{
	self.employeeChangingPassword = employee;
	[oldPassword setStringValue:@""];
	[newPassword setStringValue:@""];
	[confirmPassword setStringValue:@""];
	[oldPassword selectText:self];
	[changePasswordWindow makeKeyAndOrderFront:self];
}
-(IBAction)changePassword:(id)sender
{
	NSString * empOldPassword = [employeeChangingPassword valueForKeyPath:@"password.password"];
	if ([empOldPassword compare:[oldPassword stringValue]] == NSOrderedSame)	{
		if ([[newPassword stringValue] length] > 3)	{
			if ([[newPassword stringValue] compare:[confirmPassword stringValue]] == NSOrderedSame)	{
				[employeeChangingPassword setValue:[newPassword stringValue] forKeyPath:@"password.password"];
				[changePasswordWindow close];
				[moc save:&error];
			}
		}
	}

}
@end
