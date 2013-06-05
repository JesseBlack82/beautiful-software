//
//  ClientDatabase.m
//  Beautiful Software
//
//  Created by Jesse Black on 1/6/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import "ClientDatabase.h"
#import "PageView.h"
#import "InterfaceConstants.h"

@implementation ClientDatabase
-(void)awakeFromNib
{
	moc = [appDelegate managedObjectContext];

	NSMutableString * ppath = [NSMutableString string];
	[ppath setString:[appDelegate applicationSupportFolder]];
	[ppath appendString:@"/referralCategoriesDescription"];
	if ([NSKeyedUnarchiver unarchiveObjectWithFile:ppath] == nil)	{
		NSMutableArray * array = [NSMutableArray array];
		NSMutableDictionary * category = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Referred by client", @"categoryDescription", nil];
		[array addObject:category];
		[NSKeyedArchiver archiveRootObject:array toFile:ppath];
	}
	self.categoriesDescriptionPath = [NSMutableString stringWithString:ppath];
	
	[ppath setString:[appDelegate applicationSupportFolder]];
	[ppath appendString:@"/referralEntries"];
	self.referralEntriesPath = [NSMutableString stringWithString:ppath];
	
	[ppath setString:[appDelegate applicationSupportFolder]];
	[ppath appendString:@"/referralCredits"];
	self.referralCreditsPath = [NSMutableString stringWithString:ppath];
	
	
}
-(void)goToCreateCreditCardForClient:(NSManagedObject *)client
{
	clientForCreditCard = client;
	[clientNameForCreditCard setStringValue:[client valueForKey:@"name"]];
	
	NSString * creditCard = [client valueForKey:@"creditCard"];
	if (creditCard)	{
		[cardNumber setStringValue:creditCard];
		NSString * cNotes = [client valueForKey:@"creditNotes"];
		if (cNotes)	{
			[cardNotes setString:cNotes];
		}
			
		
		
	} else {
		[cardNumber setStringValue:@""];
		[cardNotes setString:@""];
	}
	[creditCardWindow makeKeyAndOrderFront:self];

}
-(IBAction)makeEditCreditCardEntry:(id)sender
{
	NSString * creditCard = [cardNumber stringValue];
	if (clientForCreditCard)	{
		
		if (creditCard)	{
			[clientForCreditCard setValue:creditCard forKey:@"creditCard"];
		}
		NSString * cNotes = [cardNotes string];
		if (cNotes)	{
			[clientForCreditCard setValue:cNotes forKey:@"creditNotes"];
		}
		[bookingSchedule creditCardDataEntered:creditCard];
	}
	[creditCardWindow close];
	
}

-(NSMutableArray *)clientsMatchingName:(NSString *)name
{
	NSMutableArray * clients = [NSMutableArray array];
	NSFetchRequest * clientRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * clientDescription = [NSEntityDescription entityForName:@"Client" inManagedObjectContext:moc];
	[clientRequest setEntity:clientDescription];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains %@", name];
	[clientRequest setPredicate:predicate];
	
	[clients setArray:[moc executeFetchRequest:clientRequest error:&error]];
	NSLog(@"executing Fetch client");
	
							   
	return clients;
}
-(NSMutableArray *)clientsMatchingPhone:(NSString *)phone
{	
	NSMutableArray * matchingClients = [NSMutableArray array];
	if ([phone length] > 0)	{
		NSMutableString * phoneNum = [NSMutableString stringWithString:phone];
		if ([phone characterAtIndex:0] == '1')	{
			[phoneNum setString:[phone substringFromIndex:1]];
				
		}
		
		
		NSFetchRequest * fr = [[[NSFetchRequest alloc] init] autorelease];
		NSEntityDescription * ed = [NSEntityDescription entityForName:@"Client" inManagedObjectContext:moc];
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"mobilePhone contains %@ OR homePhone contains %@ OR workPhone contains %@", phoneNum,phoneNum,phoneNum];
		[fr setEntity:ed];
		[fr setPredicate:predicate];
		[matchingClients addObjectsFromArray:[moc executeFetchRequest:fr error:&error]];
		NSLog(@"executing Fetch client");
		
	}	

	return matchingClients;
}
-(IBAction)viewClientDatabase:(id)sender
{
	NSLog(@"viewClientDatabase");
	[clientMatches setContent:[NSMutableArray array]];
	[transactionHistory setContent:[NSMutableArray array]];
	NSString * name = nil;
	if ([[[pageView selectedBlock] appointment] valueForKeyPath:@"client.name"] != nil)	{
		name = [[[pageView selectedBlock] appointment] valueForKeyPath:@"client.name"];
	}
	
	if ([name length] > 0)	{
		[futureAppointments setContent:[NSMutableArray array]];
		[clientHistoryName setStringValue:name];
	} else	{
		[clientHistoryName setStringValue:@"\t"];
	}
	NSLog(@"clientDatabase clientsMatchingName");
	
	NSMutableArray * matches = [self clientsMatchingName:[clientHistoryName stringValue]];
	[clientMatches setContent:matches];
	
	NSManagedObject * client = nil;
	if ([matches count] > 0)	{
		
		client = [matches objectAtIndex:0];
		
		[clientMatches setSelectionIndex:0];
	}

	if ([client valueForKey:@"email"] != nil)	{
		[clientEmail setStringValue:[client valueForKey:@"email"]];
	} else	{
		[clientEmail setStringValue:@""];
	} 
	NSLog(@"updateTransactionHistory");
	[self updateTransactionHistory];
	[clientHistoryWindow makeKeyAndOrderFront:self];
}
-(void)controlTextDidChange:(NSNotification *)aNotification
{
	id sender = [aNotification object];
	if ([aNotification object] == clientHistoryName)	{
		[transactionHistory setContent:[NSMutableArray array]];
		[transactionDescription setString:@""];
		[clientMatches setContent:[self clientsMatchingName:[clientHistoryName stringValue]]];
		if ([[clientMatches selectedObjects] count] > 0)	{
			NSManagedObject * client = [[clientMatches selectedObjects] objectAtIndex:0];
			if ([client valueForKey:@"email"] != nil)	{
				[clientEmail setStringValue:[client valueForKey:@"email"]];
			} else	{
				[clientEmail setStringValue:@""];
			}
		}
		
		
		[self updateTransactionHistory];
		[self updateTransactionDescription];
	} else	if ([aNotification object] == colorFileName)	{
		[clientMatchesForColorFile setContent:[self clientsMatchingName:[colorFileName stringValue]]];
		[self findColorFiles];
	} else	if (sender == referredByField)	{
		if ([[sender stringValue] length] > 0)	{
			[referredByPhoneField setStringValue:@""];
			NSMutableArray * matches = [self clientsMatchingName:[sender stringValue]];
			[referredByMatches setContent:matches];
		}
	} else if (sender == referredByPhoneField)	{
		if ([[sender stringValue] length] > 0)	{
			[referredByField setStringValue:@""];
			NSMutableArray * matches = [self clientsMatchingPhone:[sender stringValue]];
			[referredByMatches setContent:matches];
		}
	} 
}

-(void)controlTextDidEndEditing:(NSNotification *)aNotification
{	
	id sender = [aNotification object];
	if (sender == newClientField)	{
		if ([[sender stringValue] length] > 0)	{
			NSMutableArray * matches = [self clientsMatchingName:[sender stringValue]];
			if ([matches count] > 0)	{
				[nameWarning setHidden:NO];
			} else {
				[nameWarning setHidden:YES];
			}

		}
	}
}

-(void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	id object = [aNotification object];
	
	if (object == clientMatchTable)	{
		if ([[clientMatches selectedObjects] count] >0)	{
			NSManagedObject * client = [[clientMatches selectedObjects] objectAtIndex:0];
			if ([client valueForKey:@"email"] != nil)	{
				[clientEmail setStringValue:[client valueForKey:@"email"]];
			} else	{
				[clientEmail setStringValue:@""];
			}
			[self updateTransactionHistory];
		} else {
			[transactionHistory setContent:[NSMutableArray array]];
		}

		
	  	
		
	} else
	if (object == transactionHistoryTable)	{
		[self updateTransactionDescription];
	} else if (object == clientMatchTableForColorFile)	{
		[self findColorFiles];
	} else if (object == cleanUpTable)	{
		[correctSpelling setStringValue:[[[cleanUpController selectedObjects] objectAtIndex:0] valueForKey:@"name"]];
	}
}
-(void)updateTransactionDescription
{
	if ([[transactionHistory selectedObjects] count] > 0)	{
		NSManagedObject * transaction = [[transactionHistory selectedObjects] objectAtIndex:0];
		

		NSManagedObject * appointment = [transaction valueForKey:@"appointment"];
		NSString * description;
		if ([[appointment valueForKey:@"specialNote"] length] > 0)	{
			description = [NSString stringWithFormat:@"%@\nSpecial Note: %@", [bookingSchedule appointmentDescription:appointment], [appointment valueForKey:@"specialNote"]];
		} else	{
			description = [NSString stringWithString:[bookingSchedule appointmentDescription:appointment]];
		}
		[appointmentDescription setString:description];
		
		[transactionDescription setString:[self transactionDescription]];
	} else	{
		[transactionDescription setString:@""];
		[appointmentDescription setString:@""];
	}
}
-(NSString * )transactionDescription
{
	NSManagedObject * transaction = [[transactionHistory selectedObjects] objectAtIndex:0];
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
		[description appendFormat:@"%@: %1.2f\nBought %d\n", [retailSale valueForKey:@"productDescription"], [[retailSale valueForKey:@"retailPrice"] floatValue], [[retailSale valueForKeyPath:@"clientOrder"] intValue]];
	}
	if (retailCount > 0)	{
		[description appendFormat:@"\nRetail Total: %1.2f\n\n", [[transaction valueForKey:@"retailSubtotal"] floatValue]];
	}
	[description appendFormat:@"\nTransaction Total: %1.2f\n", [[transaction valueForKey:@"transactionTotal"] floatValue]];
	if ([[transaction valueForKey:@"paidCash"] boolValue] == YES)	{
		[description appendString:@"\nPayment Type: Cash\n\n"];
	} else if ([[transaction valueForKey:@"paidByCheck"] boolValue] == YES)	{
		[description appendString:@"\nPayment Type: Credit Card\n\n"];
	} else if ([[transaction valueForKey:@"paidByCharge"] boolValue] == YES)	{
		[description appendString:@"\nPayment Type: Check\n\n"];
	}
	
	[description appendFormat:@"CollectedBy: %@", [transaction valueForKey:@"collectedBy"]];
	
	return description;
}
-(void)updateTransactionHistory
{
	if ([[clientMatches selectedObjects] count] > 0)	{
		NSManagedObject * client = [[clientMatches selectedObjects] objectAtIndex:0];
		NSSet * appointments = [client valueForKey:@"appointments"];
		NSMutableArray * transactions = [NSMutableArray array];
		NSMutableArray * appointmentArray = [NSMutableArray arrayWithArray:[appointments allObjects]];
		NSSortDescriptor * timeSort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
		[appointmentArray sortUsingDescriptors:[NSArray arrayWithObject:timeSort]];
		[timeSort release];
		int i;
		for (i = 0 ; i < [appointmentArray count] ; i++)	{
			if ([[appointmentArray objectAtIndex:i] valueForKeyPath:@"transaction.transactionTotal"] != nil)	{
				[transactions addObject:[[appointmentArray objectAtIndex:i] valueForKey:@"transaction"]];
			}
		}
		[transactionHistory setContent:transactions];
		if ([transactions count] > 0)	{
			[self updateTransactionDescription];
		}
			
		NSMutableArray * futureAppointmentsArray = [NSMutableArray array];
		int j;
		for (i=0; i < [appointmentArray count] ; i++)	{
			if ([[[appointmentArray objectAtIndex:i] valueForKey:@"time"] timeIntervalSinceDate:[NSDate date]] > 0)	{
				NSArray * services = [[[appointmentArray objectAtIndex:i] valueForKey:@"services"] allObjects]; 
				NSMutableString * serviceDescription = [NSMutableString string];
				for (j=0 ; j < [services count]; j++)	{
					[serviceDescription appendFormat:@"%@, ", [[services objectAtIndex:j] valueForKey:@"serviceDescription"]];
				}
				NSManagedObject * appointment = [appointmentArray objectAtIndex:i];
				NSDictionary * entry = [NSDictionary dictionaryWithObjectsAndKeys:[appointment valueForKey:@"time"], @"time", [appointment valueForKeyPath:@"stylist.name"], @"stylist", serviceDescription, @"serviceDescription", nil];
				[futureAppointmentsArray addObject:entry];
			}
		}
		[futureAppointments setContent:futureAppointmentsArray];
		
	
	}
}
-(IBAction)viewColorFile:(id)sender
{
	id appointment = [[pageView selectedBlock] appointment];
		[colorFiles setString:@""];
	
	if ([appointment valueForKey:@"client"] != nil)	{
		[colorFileName setStringValue:[appointment valueForKeyPath:@"client.name"]];
		[clientMatchesForColorFile setContent:[self clientsMatchingName:[colorFileName stringValue]]];
		[self findColorFiles];
	} else	{
		[colorFileName setStringValue:@""];
		[clientMatchesForColorFile setContent:[NSMutableArray array]];
	}
	[colorFileWindow makeKeyAndOrderFront:self];

}
-(void)findColorFiles
{
	NSManagedObject * client = [[clientMatchesForColorFile selectedObjects] objectAtIndex:0];
/*	NSFetchRequest * colorRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * colorDescription = [NSEntityDescription entityForName:@"ColorFile" inManagedObjectContext:moc];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"client == %@", client];
	[colorRequest setEntity:colorDescription];
	[colorRequest setPredicate:predicate];
	NSSortDescriptor * timeSort = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO] autorelease];
	[colorRequest setSortDescriptors:[NSArray arrayWithObject:timeSort]];
	
	NSArray * results = [moc executeFetchRequest:colorRequest error:&error];
 NSLog(@"executing Fetch");
*/
	NSSet * colorSet = [client valueForKey:@"colorFiles"];
	NSMutableArray * results = [NSMutableArray array];;
	if ([colorSet count] > 0)	{
		[results addObjectsFromArray:[colorSet allObjects]];
	}
	
	[colorFiles setString:@"still need to load data in the code"];
	NSMutableString * colorFileString = [NSMutableString string];
	int i;
	for (i=0; i< [results count]; i++)	{
		NSManagedObject * colorFile = [results objectAtIndex:i];
		NSCalendarDate * date= [[colorFile valueForKey:@"date"] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
		NSString * string = [NSString stringWithFormat:@"%@\n%@\n\n", date, [colorFile valueForKey:@"formula"]];
		[colorFileString appendString:string];
		
	}
	[colorFiles setString:colorFileString];
	
}
-(IBAction)goToCleanUpWindow:(id)sender
{
	NSFetchRequest * clientRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * clientDescription = [NSEntityDescription entityForName:@"Client" inManagedObjectContext:moc];
	[clientRequest setEntity:clientDescription];
	NSSortDescriptor * nameSort = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
	[clientRequest setSortDescriptors:[NSArray arrayWithObject:nameSort]];
	[cleanUpController setContent:[moc executeFetchRequest:clientRequest error:&error]];
	NSLog(@"executing Fetch client");
	[cleanUpWindow makeKeyAndOrderFront:self];
}
-(IBAction)narrowClientsByString:(id)sender
{
	if ([[narrowByString stringValue] length] == 0)	{
		NSFetchRequest * clientRequest = [[[NSFetchRequest alloc] init] autorelease];
		NSEntityDescription * clientDescription = [NSEntityDescription entityForName:@"Client" inManagedObjectContext:moc];
		[clientRequest setEntity:clientDescription];
		NSSortDescriptor * nameSort = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
		[clientRequest setSortDescriptors:[NSArray arrayWithObject:nameSort]];
		[cleanUpController setContent:[moc executeFetchRequest:clientRequest error:&error]];
		NSLog(@"executing Fetch client");
	} else	{
		NSFetchRequest * clientRequest = [[[NSFetchRequest alloc] init] autorelease];
		NSEntityDescription * clientDescription = [NSEntityDescription entityForName:@"Client" inManagedObjectContext:moc];
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name contains [c] %@", [narrowByString stringValue]];
		[clientRequest setPredicate:predicate];
		[clientRequest setEntity:clientDescription];
		NSSortDescriptor * nameSort = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
		[clientRequest setSortDescriptors:[NSArray arrayWithObject:nameSort]];
		[cleanUpController setContent:[moc executeFetchRequest:clientRequest error:&error]];
		NSLog(@"executing Fetch client");
	}	
}
-(IBAction)combineClients:(id)sender
{
	NSArray * selectedClients = [cleanUpController selectedObjects];
	
	NSMutableString * message = [NSMutableString string];
	int i;
	NSString * work, *mobile, *home, *email;
	work = nil;
	mobile = nil;
	home = nil;
	email = nil;
	BOOL isMale = NO;
	BOOL isFemale = YES;
	for (i=0; i < [selectedClients count] ; i++)	{
		NSManagedObject * client = [selectedClients objectAtIndex:i];
		[message appendFormat:@"%@\n", [client valueForKey:@"name"]];
		if (mobile == nil && [client valueForKey:@"mobilePhone"] != nil)	{
			mobile = [client valueForKey:@"mobilePhone"];
		}
		if (home == nil && [client valueForKey:@"homePhone"] != nil)	{
			home = [client valueForKey:@"homePhone"];
		}
		if (work == nil && [client valueForKey:@"workPhone"] != nil)	{
			work = [client valueForKey:@"workPhone"];
		}
		if ([[client valueForKey:@"isMale"] boolValue])	{
			isMale = YES;
			isFemale = NO;
		}
		if ([[client valueForKey:@"isMale"] boolValue])	{
			isMale = NO;
			isFemale = YES;
		}
		if ([[client valueForKey:@"email"] length] >0)	{
			email = [client valueForKey:@"email"];
		}
		
	}
	
	[message appendFormat:@"Using * %@ *\nMobile: %@\nHome: %@\nWork: %@\n", [correctSpelling stringValue], mobile, home, work];
	int choice = NSRunAlertPanel(@"Combine Selected Clients", message, @"OK", @"Cancel", nil);
	if (choice == 1)	{
		NSMutableSet * appointments = [NSMutableSet set];
		NSMutableSet * colorFilesSet = [NSMutableSet set];
		for (i=0; i< [selectedClients count]; i++)	{
			NSManagedObject * client = [selectedClients objectAtIndex:i];
			[appointments addObjectsFromArray:[[client valueForKey:@"appointments"] allObjects]];
			[colorFilesSet addObjectsFromArray:[[client valueForKey:@"colorFiles"] allObjects]];
			
		}
		NSManagedObject * newClient = [NSEntityDescription insertNewObjectForEntityForName:@"Client" inManagedObjectContext:moc];
		NSArray * appointmentsArray = [appointments allObjects];
		NSArray * colorFilesArray = [colorFilesSet allObjects];
		[newClient setValue:[correctSpelling stringValue] forKey:@"name"];
		[newClient setValue:mobile forKey:@"mobilePhone"];
		[newClient setValue:home forKey:@"homePhone"];
		[newClient setValue:work forKey:@"workPhone"];
		[newClient setValue:email forKey:@"email"];
		[newClient setValue:[NSNumber numberWithBool:isMale] forKey:@"isMale"];
		[newClient setValue:[NSNumber numberWithBool:isFemale] forKey:@"isFemale"];
		for (i = 0 ; i< [appointmentsArray count]; i++)	{
			[[appointmentsArray objectAtIndex:i] setValue:newClient forKey:@"client"];
		}
		for (i = 0 ; i< [colorFilesArray count]; i++)	{
			[[colorFilesArray objectAtIndex:i] setValue:newClient forKey:@"client"];
		}
		[newClient setValue:appointments forKey:@"appointments"];
		[newClient setValue:colorFilesSet forKey:@"colorFiles"];
		for (i=0; i< [selectedClients count]; i++)	{
			[moc deleteObject:[selectedClients objectAtIndex:i]];
			
		}
		[self narrowClientsByString:self];
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	}
	
}
-(IBAction)fixGenderForClients:(id)sender
{
	NSFetchRequest * clientRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * clientDescription = [NSEntityDescription entityForName:@"Client" inManagedObjectContext:moc];
	[clientRequest setEntity:clientDescription];
	NSSortDescriptor * nameSort = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
	[clientRequest setSortDescriptors:[NSArray arrayWithObject:nameSort]];
	NSArray * results = [moc executeFetchRequest:clientRequest error:&error];
	NSLog(@"executing Fetch client");
	
	BOOL cont = YES;
	int index = 0;
	while (cont == YES)	{
		if ([[[results objectAtIndex:index] valueForKey:@"isMale"] boolValue] == NO  && [[[results objectAtIndex:index] valueForKey:@"isFemale"] boolValue] == NO)	{
			NSString * message = [NSString stringWithFormat:@"Choose a gender for %@", [[results objectAtIndex:index] valueForKey:@"name"]];
			int choice = NSRunAlertPanel(@"Male or Female?", message, @"Male",  @"Cancel",@"Female");
			if (choice == 1)	{
				[[results objectAtIndex:index] setValue:[NSNumber numberWithBool:1] forKey:@"isMale"];
				[[results objectAtIndex:index] setValue:[NSNumber numberWithBool:0] forKey:@"isFemale"];
			} else if (choice == -1)	{
				[[results objectAtIndex:index] setValue:[NSNumber numberWithBool:1] forKey:@"isFemale"];
				[[results objectAtIndex:index] setValue:[NSNumber numberWithBool:0] forKey:@"isMale"];
			} else	{
				cont = NO;
			}
		}
		index++;
		
	}
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	
}
-(IBAction)generateEmailList:(id)sender
{
	SEL selector = @selector(passwordEnteredForEmailList:);
	[passwordController getPasswordFor:self arguments:nil selector:selector];
}
-(void)passwordEnteredForEmailList:(NSManagedObject *)passwordController
{
	NSFetchRequest * clientRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * clientDescription = [NSEntityDescription entityForName:@"Client" inManagedObjectContext:moc];
	[clientRequest setEntity:clientDescription];
	NSArray * results = [moc executeFetchRequest:clientRequest error:&error];
	NSLog(@"executing Fetch client");
	
	int i;
	NSMutableString * emailsOnlyString = [NSMutableString string];
	NSMutableString * emailsWithNamesString = [NSMutableString string];
	NSMutableSet * emailAddresses = [NSMutableSet set];
	for (i=0; i< [results count] ; i++)	{
		NSManagedObject * client = [results objectAtIndex:i];
		NSString * email;
		NSString * name = [client valueForKey:@"name"];
		if ([client valueForKey:@"email"] == nil)	{
			[emailsWithNamesString appendFormat:@"%@ does not have an email in the system\n", name];
		} else	{
			email = [client valueForKey:@"email"];
			
			if ([email length] > 0)	{
				[emailsOnlyString appendFormat:@"%@, ", email];
				[emailsWithNamesString appendFormat:@"%@ --- %@\n", name, email];
				[emailAddresses addObject:email];
			} else	{
				[emailsWithNamesString appendFormat:@"%@ does not have an email in the system\n", name];
			}
		}
			
		
	}
	[emailsOnly setString:emailsOnlyString];
	[emailsWithNames setString:emailsWithNamesString];
	NSLog(@"emails %d", [emailAddresses count]);
	[emailListWindow makeKeyAndOrderFront:self];
}
-(IBAction)goToClienteleByStylist:(id)sender
{
	[clienteleByStylistResults setString:@""];
	NSArray * staff = [staffController workingStaff:[NSDate date]];
	[chooseStylistPopUp removeAllItems];
	
	int i;
	for (i=0; i < [staff count]; i++)	{
		[chooseStylistPopUp addItemWithTitle:[[staff objectAtIndex:i] valueForKey:@"name"]];
	}
	
	[clienteleByStylistStartDate setDateValue:[NSDate date]];
	[clienteleByStylistEndDate setDateValue:[NSDate date]];
	[clienteleByStylistWindow makeKeyAndOrderFront:self];
}
-(IBAction)clienteleByStylistStartDateEntered:(id)sender
{
	NSArray * staff = [staffController workingStaff:[sender dateValue]];
	[chooseStylistPopUp removeAllItems];
	
	int i;
	for (i=0; i < [staff count]; i++)	{
		[chooseStylistPopUp addItemWithTitle:[[staff objectAtIndex:i] valueForKey:@"name"]];
	}
	
}
-(IBAction)reportClienteleByStylist:(id)sender
{
	NSCalendarDate * startDate = [[clienteleByStylistStartDate dateValue] dateWithCalendarFormat:@"" timeZone:nil];
	NSCalendarDate * endDate = [[clienteleByStylistEndDate dateValue] dateWithCalendarFormat:@"" timeZone:nil];
	int month, day, year;
	month = [startDate monthOfYear];
	day = [startDate dayOfMonth];
	year = [startDate yearOfCommonEra];
	startDate = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:0];
	month = [endDate monthOfYear];
	day = [endDate dayOfMonth];
	year = [endDate yearOfCommonEra];
	endDate = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:0];
	endDate = [endDate dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
	
	// removing vcr check
	NSString * stylistName = [[chooseStylistPopUp selectedItem] title];
	NSFetchRequest * fr = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * ed = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"appointment.stylist.name == %@ && time < %@", stylistName, endDate];

	[fr setEntity:ed];
	[fr setPredicate:predicate];
	
	NSArray * results = [moc executeFetchRequest:fr error:&error];


	NSMutableArray * clientNames = [NSMutableArray array];
	int i;
	for (i=0; i < [results count]; i++)	{
		[clientNames addObject:[results valueForKeyPath:@"appointment.client.name"]];
	}
	NSMutableArray * filteredArray = [NSMutableArray arrayWithArray:results];
	predicate = [NSPredicate predicateWithFormat:@"time < %@ && time > %@", endDate, startDate];
	
	[filteredArray filterUsingPredicate:predicate];
	NSSortDescriptor * alphabb = [[[NSSortDescriptor alloc] initWithKey:@"appointment.client.name" ascending:YES] autorelease];
	[filteredArray sortUsingDescriptors:[NSArray arrayWithObject:alphabb]];
	NSMutableArray * displayEntries = [NSMutableArray array];
	
	
	NSMutableString * mstring = [NSMutableString string];
	[mstring appendFormat:@"Transactions in this time period: %d\n", [filteredArray count]];
	for (i=0; i< [filteredArray count]; i++)	{
		NSMutableArray * filterForCount = [NSMutableArray arrayWithArray:results];
		NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
		NSManagedObject * client = [[filteredArray objectAtIndex:i] valueForKeyPath:@"appointment.client"];
		NSLog(@"client %@", client);
		id workingVariable;
		workingVariable = [client valueForKey:@"name"];
		if (workingVariable != nil)	{
			[dictionary setObject:workingVariable forKey:@"name"];
			[mstring appendFormat:@"%@\n", workingVariable];
		}
		
		predicate = [NSPredicate predicateWithFormat:@"appointment.client.name == %@", workingVariable];
		[filterForCount filterUsingPredicate:predicate];
		workingVariable = [client valueForKey:@"homePhone"];
		if (workingVariable != nil)	{
			[dictionary setObject:workingVariable forKey:@"homePhone"];
			if ([workingVariable length] > 0)	{
				[mstring appendFormat:@"\tHome: %@", workingVariable];
			}
		}
		workingVariable = [client valueForKey:@"workPhone"];
		if (workingVariable != nil)	{
			[dictionary setObject:workingVariable forKey:@"workPhone"];
			if ([workingVariable length] > 0)	{
			[mstring appendFormat:@"\tWork: %@", workingVariable];
			}
		}
		workingVariable = [client valueForKey:@"mobilePhone"];
		if (workingVariable != nil)	{
			[dictionary setObject:workingVariable forKey:@"mobilePhone"];
			if ([workingVariable length] > 0)	{
			[mstring appendFormat:@"\tMobile: %@", workingVariable];
			}
		}
		workingVariable = [client valueForKey:@"email"];
		if (workingVariable != nil)	{
			[dictionary setObject:workingVariable forKey:@"email"];
			if ([workingVariable length] > 0)	{
			[mstring appendFormat:@"\tEmail: %@", workingVariable];
			}
		}
		workingVariable = [NSNumber numberWithInt:[filterForCount count]];
//		workingVariable = [NSNumber numberWithInt:[countedSet countForObject:[NSString stringWithString:[client valueForKey:@"name"]]]];
		if (workingVariable != nil)	{
			[dictionary setObject:workingVariable forKey:@"visits"];
			[mstring appendFormat:@"\tVisits: %@", workingVariable];
		}

		[mstring appendFormat:@"\n"];
		[displayEntries addObject:dictionary];
	}
	
	[clienteleByStylistResults setString:mstring];
}
-(IBAction)viewCompleteDatabase:(id)sender
{
	
}
-(void)forAnotherThread:(id)sender
{
	//	NSAutoreleasePool *pool= [[NSAutoreleasePool alloc] init];
	NSEntityDescription * ed = [NSEntityDescription entityForName:@"Client" inManagedObjectContext:moc];
	
	NSFetchRequest * fr = [[[NSFetchRequest alloc] init] autorelease];
	[fr setEntity:ed];
	NSMutableArray * listOfClients = [NSMutableArray arrayWithArray:[moc executeFetchRequest:fr error:&error]];
	int i=0;
	NSMutableArray * duplicateClientArrays = [NSMutableArray array];
	while ([listOfClients count]>0) {
		NSManagedObject * thisClient = [listOfClients objectAtIndex:0];
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name == %@ && mobilePhone == %@ && workPhone == %@ && homePhone == %@", [thisClient valueForKey:@"name"], [thisClient valueForKey:@"mobilePhone"], [thisClient valueForKey:@"workPhone"], [thisClient valueForKey:@"homePhone"]];
		[fr setPredicate:predicate];
		NSMutableArray * cleanUpClients = [NSMutableArray arrayWithArray:[moc executeFetchRequest:fr error:&error]];
		if ([cleanUpClients count] > 0)	{
			
			
			
			NSMutableSet * appointments = [NSMutableSet set];
			NSMutableSet * colorFilesSet = [NSMutableSet set];
			NSString * name = nil;
			NSString * work= nil;
			NSString * mobile= nil;
			NSString * home= nil;
			NSString * email = nil;
			BOOL isMale = NO;
			BOOL isFemale = NO;
			for (i=0; i < [cleanUpClients count]; i++)	{
				NSManagedObject * client = [cleanUpClients objectAtIndex:i];
				[appointments addObjectsFromArray:[[client valueForKey:@"appointments"] allObjects]];
				[colorFilesSet addObjectsFromArray:[[client valueForKey:@"colorFiles"] allObjects]];
				name = [client valueForKey:@"name"];
				mobile = [client valueForKey:@"mobilePhone"];
				work = [client valueForKey:@"workPhone"];
				home = [client valueForKey:@"homePhone"];
				if ([[client valueForKey:@"email"] length] >0)	{
					email = [client valueForKey:@"email"];
				}
				isMale = [[client valueForKey:@"isMale"] boolValue];
				isFemale = [[client valueForKey:@"isFemale"] boolValue];
			}
			NSManagedObject * newClient = [NSEntityDescription insertNewObjectForEntityForName:@"Client" inManagedObjectContext:moc];
			NSArray * appointmentsArray = [appointments allObjects];
			NSArray * colorFilesArray = [colorFilesSet allObjects];
			[newClient setValue:name forKey:@"name"];
			[newClient setValue:mobile forKey:@"mobilePhone"];
			[newClient setValue:home forKey:@"homePhone"];
			[newClient setValue:work forKey:@"workPhone"];
			[newClient setValue:email forKey:@"email"];
			[newClient setValue:[NSNumber numberWithBool:isMale] forKey:@"isMale"];
			[newClient setValue:[NSNumber numberWithBool:isFemale] forKey:@"isFemale"];
			for (i = 0 ; i< [appointmentsArray count]; i++)	{
				[[appointmentsArray objectAtIndex:i] setValue:newClient forKey:@"client"];
			}
			for (i = 0 ; i< [colorFilesArray count]; i++)	{
				[[colorFilesArray objectAtIndex:i] setValue:newClient forKey:@"client"];
			}
			[newClient setValue:appointments forKey:@"appointments"];
			[newClient setValue:colorFilesSet forKey:@"colorFiles"];
			for (i=0; i< [cleanUpClients count]; i++)	{
				[moc deleteObject:[cleanUpClients objectAtIndex:i]];
				
			}
			

			
			[listOfClients removeObjectsInArray:cleanUpClients];
			
			 
		}
		else	{
			[listOfClients removeObjectAtIndex:0];
			
		}
		
		
		
		
	}
	
//	[pool release];
}
-(IBAction)attemptAutoCleanUp:(id)sender
{
//	SEL selector = @selector(forAnotherThread:);

//	NSAutoreleasePool *pool= [[NSAutoreleasePool alloc] init];

//	[NSThread detachNewThreadSelector:selector toTarget:self withObject:[NSMutableArray array]];

//	[pool release];
	// changed my mind, the prep the thread could do is repeated in the actual database cleanup
	[self forAnotherThread:self];
}

/*
 Referrals system 
 A referral is only for clients that have never been to the salon ,this is verified by the staff upon
 referred clients visit to the salon
 
 The Referral can be created on the phone when booking, and confirmed upon transaction
 The referral can also be created upon transaction
 
 

 
 
 keys for entries in referrals are as follows
 
 referredBy- name of salon client who recommended the new client
 clientName- name of new client
 isOfficial- BOOL used here, if value is nil or NO then the referral is pending
 categoryDescription- one of many custom categories
 
 keys for entries in credits are as follows

 referralNames- mutableArray of new clients recommended by 
 clientName- client who has credit for recommendations
 totalReferrals-
 usedCredits-
 availableCredits-
 
 */
@synthesize categoriesDescriptionPath;
@synthesize referralEntriesPath;
@synthesize referralCreditsPath;

-(IBAction)goToCreateNewClientEntryAction:(id)sender
{
	
	[self goToCreateNewClientEntry];
}
-(void)goToCreateNewClientEntry
{
	// used to open create new client
	// set selector for makeClientEntry button
	SEL selector = @selector(linkClientReferral:);
	[makeClientButton setAction:selector];
	[makeClientButton setTitle:@"Link Client Referral"];

	
	[newClientField setStringValue:@""];
	[referredByField setStringValue:@""];
	[self loadReferralCategories];
	[addClientWindow makeKeyAndOrderFront:self];
	
}
-(void)loadReferralCategories
{
	NSMutableArray * subviews = [NSMutableArray array];
	//calculate the size of the view, then align it so the top corner of view matches the corner of scroller
	//...
	
	NSMutableArray * results = [NSKeyedUnarchiver unarchiveObjectWithFile:categoriesDescriptionPath];
	int resultsCount = [results count];
	double serviceHeight;
	double serviceWidth = (CHECKBOXWIDTH*2) + 40;
	if (resultsCount > 0)	{
		serviceHeight = (CHECKBOXHEIGHT + CHECKBOXVERTICALSPACING) * resultsCount - CHECKBOXVERTICALSPACING + 40;
		NSRect serviceFrame = [referralCategoriesHolder frame];
		double gap = serviceHeight - serviceFrame.size.height;
		if (gap > 0)	{
			serviceFrame.size.height = serviceHeight;
			serviceFrame.size.width = serviceWidth;
			[referralCategoriesHolder setFrame:serviceFrame];
		}
		else serviceHeight = serviceFrame.size.height;  //<<---initializing height variable for later use...
	} 
	
	int i;
	int j;
	for (i=0; i< resultsCount; i++)	{
		NSButton * newButton = [[[NSButton alloc] init] autorelease];
		[newButton setTitle:[[results objectAtIndex:i] valueForKey:@"categoryDescription"]];
		[newButton setButtonType:NSSwitchButton];
		
		double originX, originY;
		originX = 20;
		originY = serviceHeight - 20 - (CHECKBOXHEIGHT * (i+1)) - (CHECKBOXVERTICALSPACING * i);
		[newButton setFrame:NSMakeRect(originX, originY, (CHECKBOXWIDTH*2), CHECKBOXHEIGHT)];
		
		[subviews addObject:newButton];
	}
	[referralCategoriesHolder setSubviews:subviews];
	[referralCategoriesHolder scrollPoint:NSMakePoint(0, serviceHeight)];
}
-(IBAction)goToAddReferralCategory:(id)sender
{
	[newCategoryField setStringValue:@"New Category"];
	[newCategoryField setHidden:NO];
	SEL selector = @selector(addReferralCategory:);
	[addCategoryButton setAction:selector];
}
-(IBAction)addReferralCategory:(id)sender
{
	if ([[newCategoryField stringValue] compare:@"New Category"])	{
		NSString * newCategory = [newCategoryField stringValue];
		NSMutableArray * results = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:categoriesDescriptionPath]];
		int i;
		BOOL shouldAdd = YES;
		for (i=0; i< [results count]; i++)	{
			if ([[[results objectAtIndex:i] valueForKey:@"categoryDescription"] compare:newCategory] == NSOrderedSame)	{
				shouldAdd = NO;
			}
		}
		
		if (shouldAdd)	{
			[newCategoryField setHidden:YES];
			SEL selector = @selector(goToAddReferralCategory:);	
			[results addObject:[NSMutableDictionary dictionaryWithObject:newCategory forKey:@"categoryDescription"]];
			[NSKeyedArchiver archiveRootObject:results toFile:categoriesDescriptionPath];
			[self loadReferralCategories];
			[addCategoryButton setAction:selector];
		}
	}
	
}
-(IBAction)linkClientReferral:(id)sender
{
	// used when linking Referrals
	// 
	
	
	[self makeReferralEntryForNewClient];
	[addClientWindow close];

}
-(NSManagedObject*)createNewClient
{
	if ([nameWarning isHidden])	{
	if ([[newClientField stringValue] length] > 0)	{
		id workingVariable;
		NSManagedObject * client = [NSEntityDescription insertNewObjectForEntityForName:@"Client" inManagedObjectContext:moc];
		workingVariable = [newClientField objectValue];
		if ([workingVariable length] > 0)	{
			[client setValue:workingVariable forKey:@"name"];
		}
		workingVariable = [newHomePhoneField objectValue];
		if ([workingVariable length] > 0)	{
			[client setValue:workingVariable forKey:@"homePhone"];
		}
		workingVariable = [newWorkPhoneField objectValue];
		if ([workingVariable length] > 0)	{
			[client setValue:workingVariable forKey:@"workPhone"];
		}
		workingVariable = [newMobilePhoneField objectValue];
		if ([workingVariable length] > 0)	{
			[client setValue:workingVariable forKey:@"mobilePhone"];
		}
		workingVariable = [newEmailField objectValue];
		if ([workingVariable length] > 0)	{
			[client setValue:workingVariable forKey:@"email"];
		}
		workingVariable = [newCreditField objectValue];
		if ([workingVariable length] > 0)	{
			[client setValue:workingVariable forKey:@"creditCard"];
		}
		
		if ([femaleButton state] == 1)	{
			[client setValue:[NSNumber numberWithBool:YES] forKey:@"isFemale"];
			[client setValue:[NSNumber numberWithBool:NO] forKey:@"isMale"];
		} 
		if ([maleButton state] == 1)	{
			[client setValue:[NSNumber numberWithBool:NO] forKey:@"isFemale"];
			[client setValue:[NSNumber numberWithBool:YES] forKey:@"isMale"];
		} 
		
		
		return client;
	}	
	}
	return nil;
}
-(IBAction)goToLinkClientReferral:(id)sender
{
	[self goToCreateNewClientEntry];
}
-(IBAction)goToCreateNewClientForBooking:(id)sender
{
	// used to open create new client
	// set selector for makeClientEntry button
	SEL selector = @selector(createNewClientForBooking:);
	[makeClientButton setAction:selector];
	[makeClientButton setTitle:@"Create Client For Appointment"];
	 
	[newClientField setStringValue:@""];
	[newMobilePhoneField setStringValue:@""];
	[newEmailField setStringValue:@""];
	[newHomePhoneField setStringValue:@""];
	[newWorkPhoneField setStringValue:@""];
	
	[referredByField setStringValue:@""];
	[self loadReferralCategories];
	[addClientWindow makeKeyAndOrderFront:self];
	
	
}
-(IBAction)createNewClientForBooking:(id)sender
{
	// used when creating new client for booking purposes
	
	NSManagedObject * client = [self createNewClient];
	
	if (client != nil) {
		[self makeReferralEntryForNewClient];
		[addClientWindow close];
		// call method in bookingSchedule that sets this client to the currently selected appointment
		[bookingSchedule bookSelectedAppointmentWithClient:client];
	}
}
-(void)makeReferralEntryForNewClient
{
	//TODO make clients referral entry
	if ([nameWarning isHidden] == YES)	{
		NSMutableArray * categories = [NSMutableArray arrayWithArray:[NSUnarchiver unarchiveObjectWithFile:categoriesDescriptionPath]];
		NSArray * subviews = [referralCategoriesHolder subviews];
		int i;
		int j;
		NSMutableDictionary * referral = [NSMutableDictionary dictionary];
		for(i=0; i < [subviews count]; i++)	{
			if ([[subviews objectAtIndex:i] state] == 1)	{
				for(j=0; j< [categories count]; j++)	{
					if ([[[subviews objectAtIndex:i] title] compare:[[categories objectAtIndex:j] valueForKey:@"categoryDescription"]] == NSOrderedSame)	{
						[referral setValue:[NSDate date] forKey:"date"];	
						[referral setValue:[newClientField stringValue] forKey:@"clientName"];
						if ([[[subviews objectAtIndex:i] title] compare:@"Referred By Client"] == NSOrderedSame)	{
							if ([[referredByMatches selectedObjects] count])	{
								[referral setValue:[[[referredByMatches selectedObjects] objectAtIndex:0] valueForKey:@"name"] forKey:@"referredBy"];
								
							
							}
							
						} else {
							[referral setObject:[categories objectAtIndex:j forKey:@"categoryDescription"]];
						}

						
							
					}
				}
			}													  
		}
	
		[self writeReferralEntryToDisk:referral];
		
	}
}
							 
-(void)writeReferralEntryToDisk:(NSMutableDictionary*)referral
{
	NSMutableArray * referralEntries = [NSKeyedUnarchiver unarchiveObjectWithFile:referralEntriesPath];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"clientName == %@", [referral valueForKey:@"clientName"]];
	NSMutableArray * filterArray = [NSMutableArray arrayWithArray:referralEntries];
	[filterArray filterUsingPredicate:predicate];
	if ([filterArray count] > 0)	{
		NSLog(@"already an entry");
	} else {
		[referralEntries addObject:referral];
		[NSKeyedArchiver archiveRootObject:referralEntries toFile:referralEntriesPath]; 
	}

}
-(IBAction)selectGenderOnNewClient:(id)sender
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
-(IBAction)goToPendingReferrals:(id)sender
{
	NSMutableArray * referralEntries = [NSKeyedUnarchiver unarchiveObjectWithFile:referralEntriesPath];
	NSMutableArray * pendingReferralEntries = [NSMutableArray array];
	int i;
	for (i=0; i< [referralEntries count]; i++)	{
		if ([[referralEntries objectAtIndex:i] valueForKey:@"isOfficial"])	{
			
		} else	{
			[pendingReferralEntries addObject:[referralEntries objectAtIndex:i]];
			[referralEntries removeObjectAtIndex:i];
			i--;
		}
	}
	[referralsController setContent:referralEntries];
	[pendingReferralsController setContent:pendingReferralEntries];
	[pendingReferralsWindow makeKeyAndOrderFront:self];
}
-(void)giveReferralCredit:(NSManagedObject *)transaction
{
	
}
@end

