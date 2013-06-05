//
//  TransactionController.m
//  Beautiful Software
//
//  Created by Jesse Black on 1/13/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import "TransactionController.h"
#import "PageView.h"
#import "Beautiful_Software_AppDelegate.h"
#import "BuildingBlock.h"
#import "IndividualTransaction.h"
#import "PasswordConstants.h"
#import "EmployeeSelect.h"
#import "TaxConstants.h"
#import "PasswordController.h"
#import "InterfaceConstants.h"
@implementation TransactionController

@synthesize retailRefundedPath;
@synthesize passwordLevelsPath;

-(void)awakeFromNib
{
	NSMutableString * ppath = [NSMutableString stringWithString:[appDelegate applicationSupportFolder]];
	[ppath appendString:@"/passwordLevelsPath"];
	[self setPasswordLevelsPath:ppath];
	
	NSMutableString * path = [NSMutableString stringWithString:[appDelegate applicationSupportFolder]];
	[path appendString:@"/retailRefunded"];
	self.retailRefundedPath = path;
	moc = [appDelegate managedObjectContext];
	[retailSearchBar setDelegate:self];
}
-(IBAction)checkOutSelectedAppointmentAction:(id)sender
{
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	if ([[selectedDate description] compare:[today description]] == NSOrderedSame)	{
		[self checkOutSelectedAppointment];
	} else	{
		// TODO
		// management can check out appointment
		SEL selector = @selector(managementCheckingOut:);
		[passwordController getPasswordFor:self arguments:nil selector:selector];
	}
	
	
	
}
-(void)managementCheckingOut:(NSManagedObject *)password	{
	if ([password valueForKey:@"passwordLevel"] != nil)	{
		int passwordLevel = [[password valueForKey:@"passwordLevel"] intValue];
		id test = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordLevelsPath];
		
		if (passwordLevel >= [[test valueForKey:@"editTransactionsLevel"] intValue] )	{
			[self checkOutSelectedAppointment];
		}
	}
}

-(void)setUpServices
{
	[clientNameFieldDual setStringValue:[appointmentDual valueForKeyPath:@"client.name"]];
	[self setPriceFieldsDual:[NSMutableArray array]];
	[self setServiceListDual:[NSMutableArray array]];
	NSMutableSet * servicesSet = [appointmentDual valueForKey:@"services"];
	
	[serviceListDual addObjectsFromArray:[servicesSet allObjects]];
	NSSortDescriptor * listOrderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	[serviceListDual sortUsingDescriptors:[NSArray arrayWithObject:listOrderDescriptor]];
	
	NSMutableArray * subviews = [NSMutableArray array];
	float serviceHeight = [serviceViewDual frame].size.height;
	int i;
	
	//	NSTextField * previousField;
	//	int top = [services count];
	//	top --;
	for (i=0; i< [serviceListDual count]; i++)	{
		
		NSTextField * label = [[NSTextField alloc] init];
		[label setBordered:NO];
		[label setStringValue:[[serviceListDual objectAtIndex:i] valueForKey:@"serviceDescription"]];
		[label setEditable:NO];
		[label setBackgroundColor:[clientNameFieldDual backgroundColor]];
		NSRect labelFrame = [label frame];
		labelFrame.origin.x = 20;
		labelFrame.origin.y = serviceHeight - 20 - ((i+1)*TEXTFIELDHEIGHT);
		labelFrame.size.height = TEXTFIELDHEIGHT;
		labelFrame.size.width = TEXTFIELDWIDTH;
		[label setFrame:labelFrame];
		[subviews addObject:label];
		[label release];
		
		
		NSTextField * priceField = [[NSTextField alloc] init];
		NSRect priceFrame = [priceField frame];
		priceFrame.origin.x = labelFrame.origin.x + TEXTFIELDWIDTH + 20;
		priceFrame.origin.y = labelFrame.origin.y;
		priceFrame.size.height = TEXTFIELDHEIGHT;
		priceFrame.size.width = TEXTFIELDWIDTH;
		[priceField setFrame:priceFrame];
		[subviews addObject:priceField];
		[priceFieldsDual addObject:priceField];
		[priceField setDelegate:self];
		if ([[serviceListDual objectAtIndex:i] valueForKey:@"price"])	{
			[priceField setObjectValue:[[serviceListDual objectAtIndex:i] valueForKey:@"price"]];
		}
		//	if (i==0)		{
		//		[serviceView setNextKeyView:priceField];
		//	} if (i== top)	{
		//		[priceField setNextKeyView:barcodeSearchBar];
		//	} else	{
		//		[previousField setNextKeyView:priceField];
		//	}
		//	previousField = priceField;
		[priceField release];
	}
	[[priceFieldsDual lastObject] setNextKeyView:barcodeSearchBarDual];
	int priceFieldsCount = [priceFieldsDual count];
	priceFieldsCount--;
	for (i=0; i< priceFieldsCount; i++)	{
		[[priceFieldsDual objectAtIndex:i] setNextKeyView:[priceFieldsDual objectAtIndex:i+1]];
	}
	
	[serviceViewDual setSubviews:subviews];
	[self updateServiceTotalDual];
	[self updateRetailCartDual];
	[[priceFieldsDual objectAtIndex:0] selectText:self];
	[transactionWindowDual makeKeyAndOrderFront:self];
}
-(int)transactionsForTheDay
{
	NSDate * selectedDate = [[[pageView selectedBlock] appointment] valueForKey:@"time"];
	NSCalendarDate * workingDate = [selectedDate dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	NSFetchRequest * transactionRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *transactionsDescription = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc];
	[transactionRequest setEntity:transactionsDescription];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	[transactionRequest setPredicate:predicate];
	
	NSArray * results = [moc executeFetchRequest:transactionRequest error:&error];
	NSLog(@"executing Fetch transaction");
	return [results count];
}
@synthesize appointmentsInOpenTransactions;
@synthesize transactionController;
@synthesize priceFieldsDual;
@synthesize serviceListDual;
@synthesize retailSaleDual;

-(void)checkOutSelectedAppointment
{
	if (!appointmentsInOpenTransactions) {
		self.appointmentsInOpenTransactions = [NSMutableArray array];
	}
	if (!transactionController)	{
		self.transactionController = [NSMutableArray array];
	}
/*	NSTextField * label = [[NSTextField alloc] initWithFrame:NSMakeRect(20,20, 130, 17)];
	[label setBordered:NO];
	[label setStringValue:@"new label"];
	[label setEditable:NO];
	[label setBackgroundColor:[clientNameField backgroundColor]];
	NSMutableArray * newViews = [NSMutableArray arrayWithArray:[[transactionWindow contentView] subviews]];
	[newViews addObject:label];
	[label release];
	[[transactionWindow contentView] setSubviews:newViews];*/
	id appointment = [[pageView selectedBlock] appointment];
	if ([appointment valueForKey:@"checkoutTime"] == nil)	{
		if ([[appointment valueForKey:@"services"] count] != 0)	{
			appointmentDual = appointment;
			[matchesControllerDual setContent:[NSMutableArray array]];
			[retailCartControllerDual setContent:[NSMutableArray array]];
			[retailSearchBarDual setStringValue:@""];
			[barcodeSearchBarDual setStringValue:@""];
			[self setUpServices];
			
			// have makeEditWindow open if client does not have a email address
			NSMutableString * ppath = [NSMutableString string];
			[ppath setString:[appDelegate applicationSupportFolder]];
			[ppath appendString:@"/Preferences"];
			NSMutableDictionary * preferences = [NSKeyedUnarchiver unarchiveObjectWithFile:ppath];
			if ([preferences valueForKey:@"collectEmail"])	{
			NSString * email = nil;
			email = [appointment valueForKeyPath:@"client.email"];
			if ([email length] == 0 || email == nil)	{
				[bookingSchedule goToMakeEditAppointmentAction:self];
			}
			}
			
			
			[transactionWindowDual makeKeyAndOrderFront:self];
			[barcodeSearchBarDual selectText:self];
			
			
		} else	{
			NSRunAlertPanel(@"Not Ready For Check Out", @"Appointment must have selected services to proceed to check out", @"OK", nil, nil);
		}
	}
	
	
	
}
-(IBAction)closeOutDualByCharge:(id)sender
{
	cashTransaction = 0;
	checkTransaction = 0;
	creditTransaction = 1;
	
	// get signature
	SEL selector = @selector(setCollectedBy:);
	[employeeSelect selectEmployeeFor:self selector:selector windowTitle:@"Who Are You?"];
}
-(IBAction)closeOutDualByCheck:(id)sender
{
	cashTransaction = 0;
	checkTransaction = 1;
	creditTransaction = 0;
	
	// get signature
	SEL selector = @selector(setCollectedBy:);
	[employeeSelect selectEmployeeFor:self selector:selector windowTitle:@"Who Are You?"];
}
-(IBAction)closeOutRetailByCharge:(id)sender
{
	cashTransaction = 0;
	checkTransaction = 0;
	creditTransaction = 1;
	
	// get signature
	SEL selector = @selector(setCollectedByForRetail:);
	[employeeSelect selectEmployeeFor:self selector:selector windowTitle:@"Who Are You?"];
}
-(IBAction)closeOutRetailByCheck:(id)sender
{
	cashTransaction = 0;
	checkTransaction = 1;
	creditTransaction = 0;
	
	// get signature
	SEL selector = @selector(setCollectedByForRetail:);
	[employeeSelect selectEmployeeFor:self selector:selector windowTitle:@"Who Are You?"];
}

-(IBAction)closeTransactionDual:(id)sender
{
	cashTransaction = 1;
	checkTransaction = 0;
	creditTransaction = 0;
	
	// get signature
	SEL selector = @selector(setCollectedBy:);
	[employeeSelect selectEmployeeFor:self selector:selector windowTitle:@"Who Are You?"];
}

-(IBAction)closeRetailOnlyAction:(id)sender
{
	cashTransaction = 1;
	checkTransaction = 0;
	creditTransaction = 0;
	SEL selector = @selector(setCollectedByForRetail:);
	[employeeSelect selectEmployeeFor:self selector:selector windowTitle:@"Who Are You?"];
}

-(void)setCollectedBy:(NSManagedObject *)employee;
{
	NSDate * closeDate = [mainDatePicker dateValue];
	NSManagedObject * appointment = appointmentDual;
	NSManagedObject * newTransaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:moc];
	[newTransaction setValue:appointment forKey:@"Appointment"];
	[newTransaction setValue:[NSNumber numberWithDouble:[self serviceSubtotalDual]] forKey:@"serviceSubtotal"];
	[newTransaction setValue:[NSNumber numberWithDouble:[self serviceTaxDual]] forKey:@"serviceTax"];
	[newTransaction setValue:[NSNumber numberWithDouble:[self retailSubtotalDual]] forKey:@"retailSubtotal"];
	[newTransaction setValue:[NSNumber numberWithDouble:[self retailTaxDual]] forKey:@"retailTax"];
	[newTransaction setValue:[NSNumber numberWithDouble:[self transactionTotalDual]] forKey:@"transactionTotal"];
	
	
	[newTransaction setValue:[appointment valueForKey:@"services"] forKey:@"services"];
	
	
	int i;
	NSArray * retailSale = [retailCartControllerDual content];
	for (i=0; i< [retailSale count]; i++)	{
		NSDictionary * sale = [retailSale objectAtIndex:i];
		NSManagedObject * retailSaleItem = [NSEntityDescription insertNewObjectForEntityForName:@"RetailSaleItem" inManagedObjectContext:moc];
		[retailSaleItem setValue:newTransaction forKey:@"transaction"];
		[retailSaleItem setValue:[sale valueForKey:@"salonCost"] forKey:@"salonCost"];
		[retailSaleItem setValue:[sale valueForKey:@"company"] forKey:@"company"];
		[retailSaleItem setValue:[sale valueForKey:@"isColorItem"] forKey:@"isColorItem"];
		[retailSaleItem setValue:[sale valueForKey:@"productDescription"] forKey:@"productDescription"];
		[retailSaleItem setValue:[sale valueForKey:@"salonCost"] forKey:@"salonCost"];
		NSString * clientOrder = [sale valueForKey:@"clientOrder"];
		[retailSaleItem setValue:[NSNumber numberWithDouble:[clientOrder doubleValue]] forKey:@"clientOrder"];
		
		// check to see if we have product in the inventory ...
		[retailController selling:[clientOrder intValue] ofThisProduct:[sale valueForKey:@"productDescription"]];
	}
	NSString * signature = [employee valueForKey:@"signature"];
	if (signature == nil)	{

		signature = [employee valueForKey:@"name"];
	}
	
	if (creditTransaction == 1)	{
		[newTransaction setValue:[NSNumber numberWithBool:YES] forKey:@"paidByCharge"];
	} else if (checkTransaction == 1) {
		[newTransaction setValue:[NSNumber numberWithBool:YES] forKey:@"paidByCheck"];
	} else if (cashTransaction == 1)	{
		[newTransaction setValue:[NSNumber numberWithBool:YES] forKey:@"paidCash"];
	}

	
	[newTransaction setValue:signature forKey:@"collectedBy"];
	[appointment setValue:closeDate forKey:@"checkoutTime"];
	[newTransaction setValue:closeDate forKey:@"time"];
	[pageView refreshBlockForAppointment:appointment];
	[transactionWindowDual close];
	[clientDatabase giveReferralCredit:newTransaction];
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	
}
-(IBAction)removeTransaction:(id)sender
{
	NSManagedObject * transaction = [[allTransactionsController selectedObjects] objectAtIndex:0];
	NSManagedObject * appointment = [transaction valueForKey:@"appointment"];
	[retailController undoSellingFromTransaction:transaction];
	[appointment setValue:nil forKey:@"checkoutTime"];
	[transaction setValue:nil forKey:@"time"];
	[transaction setValue:nil forKey:@"collectedBy"];
	NSMutableArray * transactions = [NSMutableArray arrayWithArray:[allTransactionsController content]];
	[transactions removeObject:transaction];
	[allTransactionsController setContent:transactions];
	[pageView refreshBlocks];
}
-(IBAction)goToSellRetail:(id)sender
{
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	if ([[selectedDate description] compare:[today description]] == NSOrderedSame)	{
		[retailSearchBar setStringValue:@""];
		[barcodeFieldForSellRetailOnly setStringValue:@""];
		[retailCartController setContent:[NSMutableArray array]];
		[matchesController setContent:[NSMutableArray array]];
		[self updateRetailCart];
		[sellRetailWindow makeKeyAndOrderFront:self];
	} else	{
		// TODO
		// management can check out appointment
		SEL selector = @selector(managementSellingRetail:);
		[passwordController getPasswordFor:self arguments:nil selector:selector];
	}
	
	// blank out fields and arrays
	
	
}
-(void)managementSellingRetail:(NSManagedObject*)password
{
	if ([password valueForKey:@"passwordLevel"] != nil)	{
		int passwordLevel = [[password valueForKey:@"passwordLevel"] intValue];
		id test = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordLevelsPath];
		
		if (passwordLevel >= [[test valueForKey:@"editTransactionsLevel"] intValue] )	{
			[retailSearchBar setStringValue:@""];
			[barcodeFieldForSellRetailOnly setStringValue:@""];
			[retailCartController setContent:[NSMutableArray array]];
			[matchesController setContent:[NSMutableArray array]];
			[self updateRetailCart];
			[sellRetailWindow makeKeyAndOrderFront:self];
		}
	}
}
-(NSMutableArray *)searchForProductDescriptionExact:(NSString *)productDescription
{
	NSMutableArray * results = [NSMutableArray array];
	NSFetchRequest * retailMenuRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * retailDescription = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
	[retailMenuRequest setIncludesSubentities:NO];
	[retailMenuRequest setEntity:retailDescription];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"productDescription == [cd] %@", productDescription];
	// next line would allow all retail items sold to pop up in the list
	//	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"productDescription contains [cd] %@", productDescription];
	[retailMenuRequest setPredicate:predicate];
	[results addObjectsFromArray:[moc executeFetchRequest:retailMenuRequest error:&error]];
	NSLog(@"executing Fetch retail menu item");
	return results;
}

-(NSMutableArray *)searchForProductDescription:(NSString *)productDescription
{
	NSMutableArray * results = [NSMutableArray array];
	NSFetchRequest * retailMenuRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * retailDescription = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
	
	[retailMenuRequest setEntity:retailDescription];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"productDescription contains [cd] %@", productDescription];
	[retailMenuRequest setIncludesSubentities:NO];
	
	// next line would allow all retail items sold to pop up in the list
	//	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"productDescription contains [cd] %@", productDescription];
	[retailMenuRequest setPredicate:predicate];
	[results addObjectsFromArray:[moc executeFetchRequest:retailMenuRequest error:&error]];
	NSLog(@"executing Fetch retail menu item");
	return results;
}
-(void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	id object = [aNotification object];
	if ([priceFieldsDual containsObject:object])	{
		[self updateServiceTotalDual];
	} else {
		if ([[object className] compare:@"NSTableView"] == NSOrderedSame)	{
			[self updateRetailCartDual];
			[self updateRetailCart];
		}
	}
	
	
}

-(void)controlTextDidChange:(NSNotification *)aNotification
{
	id object = [aNotification object];
	if (object == retailSearchBar)	{
		NSMutableArray * results = [self searchForProductDescription:[object stringValue]];
		int i;
		NSMutableArray * matches = [NSMutableArray array];
		for (i=0 ; i< [results count]; i++)	{
			NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
			id workingVariable;
			
			[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"productDescription"] forKey:@"productDescription"];
			workingVariable = [[results objectAtIndex:i] valueForKey:@"salonCost"];
			if (workingVariable)	{
				[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"salonCost"] forKey:@"salonCost"];
			}
			workingVariable = [[results objectAtIndex:i] valueForKey:@"isColorItem"];
			if (workingVariable)	{
				[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"isColorItem"] forKey:@"isColorItem"];
			}
			workingVariable = [[results objectAtIndex:i] valueForKey:@"salonCost"];
			if (workingVariable)	{
				[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"salonCost"] forKey:@"salonCost"];
			}
			workingVariable = [[results objectAtIndex:i] valueForKey:@"company"];
			if (workingVariable)	{
				[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"company"] forKey:@"company"];
			}
			workingVariable = [[results objectAtIndex:i] valueForKey:@"retailPrice"];
			if (workingVariable)	{
				[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"retailPrice"] forKey:@"retailPrice"];
			}
			
			[matches addObject:dictionary];
		}
		
		[matchesController setContent:matches];
	} else if (object == retailSearchBarDual)	{
		NSMutableArray * results = [self searchForProductDescription:[object stringValue]];
		int i;
		NSMutableArray * matches = [NSMutableArray array];
		for (i=0 ; i< [results count]; i++)	{
			NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
			id workingVariable;
			[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"productDescription"] forKey:@"productDescription"];
			workingVariable = [[results objectAtIndex:i] valueForKey:@"salonCost"];
			if (workingVariable)	{
				[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"salonCost"] forKey:@"salonCost"];
			}
			workingVariable = [[results objectAtIndex:i] valueForKey:@"isColorItem"];
			if (workingVariable)	{
				[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"isColorItem"] forKey:@"isColorItem"];
			}
			workingVariable = [[results objectAtIndex:i] valueForKey:@"salonCost"];
			if (workingVariable)	{
				[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"salonCost"] forKey:@"salonCost"];
			}
			workingVariable = [[results objectAtIndex:i] valueForKey:@"company"];
			if (workingVariable)	{
				[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"company"] forKey:@"company"];
			}
			workingVariable = [[results objectAtIndex:i] valueForKey:@"retailPrice"];
			if (workingVariable)	{
				[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"retailPrice"] forKey:@"retailPrice"];
			}
			
			[matches addObject:dictionary];
		}
		[matchesControllerDual setContent:matches];
	} else if (object == retailSearchBarRefund)	{
		NSMutableArray * results = [self searchForProductDescription:[object stringValue]];
		int i;
		NSMutableArray * matches = [NSMutableArray array];
		for (i=0 ; i< [results count]; i++)	{
			NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
			id workingVariable;
			
			[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"productDescription"] forKey:@"productDescription"];
			workingVariable = [[results objectAtIndex:i] valueForKey:@"salonCost"];
			if (workingVariable)	{
				[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"salonCost"] forKey:@"salonCost"];
			}
			workingVariable = [[results objectAtIndex:i] valueForKey:@"isColorItem"];
			if (workingVariable)	{
				[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"isColorItem"] forKey:@"isColorItem"];
			}
			workingVariable = [[results objectAtIndex:i] valueForKey:@"retailPrice"];
			if (workingVariable)	{
				[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"retailPrice"] forKey:@"retailPrice"];
			}
			workingVariable = [[results objectAtIndex:i] valueForKey:@"company"];
			if (workingVariable)	{
				[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"company"] forKey:@"company"];
			}
			[matches addObject:dictionary];
		}
		[refundMatches setContent:matches];
	}
	
	
	
}
-(IBAction)barcodeEnteredOnRetailOnly:(id)sender
{
	NSManagedObject * product = [retailController barcodeEnteredOnSellRetail:[barcodeFieldForSellRetailOnly stringValue]];
	if ([[product valueForKey:@"productDescription"] length] > 0)	{
		NSMutableArray * results = [self searchForProductDescriptionExact:[product valueForKey:@"productDescription"]];
		NSMutableDictionary * dictionary;
		if ([results count] == 1)	{
			NSMutableArray * cart = [NSMutableArray arrayWithArray:[retailCartController content]];
			int i;
			BOOL match = NO;
			for (i=0; i< [cart count]; i++)	{
				if ([[[cart objectAtIndex:i] valueForKey:@"productDescription"] compare:[product valueForKey:@"productDescription"]] == NSOrderedSame)	{
					int order = [[[cart objectAtIndex:i] valueForKey:@"clientOrder"] intValue];
					order++;
					[[cart objectAtIndex:i] setValue:[NSNumber numberWithInt:order] forKey:@"clientOrder"];
					dictionary = [cart objectAtIndex:i];
					match  = YES;
				}
				
			} 
			if (match == NO)	{
				dictionary = [NSMutableDictionary dictionary];
				[dictionary setObject:[[results objectAtIndex:0] valueForKey:@"productDescription"] forKey:@"productDescription"];
				[dictionary setObject:[[results objectAtIndex:0] valueForKey:@"retailPrice"] forKey:@"retailPrice"];
				[dictionary setObject:[[results objectAtIndex:0] valueForKey:@"isColorItem"] forKey:@"isColorItem"];
				[dictionary setObject:[[results objectAtIndex:0] valueForKey:@"salonCost"] forKey:@"salonCost"];
				[dictionary setObject:[[results objectAtIndex:0] valueForKey:@"company"] forKey:@"company"];
				[dictionary setObject:[NSNumber numberWithInt:1] forKey:@"clientOrder"];
				[cart addObject:dictionary];
				[retailCartController setContent:cart];
				
			}
			double total = [[dictionary valueForKey:@"retailPrice"] doubleValue];
			total *= [[dictionary valueForKey:@"clientOrder"] intValue];
			[dictionary setValue:[NSNumber numberWithFloat:total] forKey:@"clientTotal"];
			[self updateRetailCart];
			[barcodeFieldForSellRetailOnly setStringValue:@""];
		}
	}
}
-(IBAction)addRetailToShoppingCart:(id)sender
{
	NSArray * matches = [matchesController content];
	int i;
	NSMutableArray * cart = [NSMutableArray arrayWithArray:[retailCartController content]];
	for (i=0; i< [matches count] ; i++)	{
		NSMutableDictionary * matchAtIndex = [matches objectAtIndex:i];
		if ([[matchAtIndex valueForKey:@"clientOrder"] intValue] > 0)	{
			NSMutableDictionary * copy = [NSMutableDictionary dictionaryWithDictionary:matchAtIndex];
			double total = [[matchAtIndex valueForKey:@"retailPrice"] doubleValue];
			total *= [[matchAtIndex valueForKey:@"clientOrder"] intValue];
			[copy setValue:[NSNumber numberWithDouble:total] forKey:@"clientTotal"];
			[cart addObject:copy];
		}
	}
	[retailCartController setContent:cart];
	[self updateRetailCart];	
}
-(void)updateRetailCart
{
	NSArray * retailCart = [retailCartController content];
	int i;
	double total = 0;
	for (i=0; i< [retailCart count]; i++)	{
		NSMutableDictionary * cartAtIndex = [retailCart objectAtIndex:i];
		double clientTotal = [[cartAtIndex valueForKey:@"retailPrice"] doubleValue];
		clientTotal *= [[cartAtIndex valueForKey:@"clientOrder"] intValue];
		total += clientTotal;
		[cartAtIndex setValue:[NSNumber numberWithFloat:clientTotal] forKey:@"clientTotal"];
	}
	[retailTotal setDoubleValue:total];
	
	total *= (NEWYORKRETAILTAX);
	[retailTax setDoubleValue:total];
	
	total = [retailTotal doubleValue];
	total += [retailTax doubleValue];
	
	int ttotal = total;
	total -= ttotal;
	if (total >= ROUNDUP)	{
		ttotal++;
	}
	
	[amountDue setDoubleValue:ttotal];
}
-(void)setCollectedByForRetail:(NSManagedObject *)employee
{
	NSDate * closeDate = [mainDatePicker dateValue];
	
	
	NSManagedObject * newTransaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:moc];
	
	
	
	
	
	int i;
	NSArray * retailSales = [retailCartController content];
	for (i=0; i< [retailSales count]; i++)	{
		NSDictionary * sale = [retailSales objectAtIndex:i];
		NSManagedObject * retailSaleItem = [NSEntityDescription insertNewObjectForEntityForName:@"RetailSaleItem" inManagedObjectContext:moc];
		[retailSaleItem setValue:newTransaction forKey:@"transaction"];
		[retailSaleItem setValue:[sale valueForKey:@"salonCost"] forKey:@"salonCost"];
		[retailSaleItem setValue:[sale valueForKey:@"company"] forKey:@"company"];
		[retailSaleItem setValue:[sale valueForKey:@"isColorItem"] forKey:@"isColorItem"];
		[retailSaleItem setValue:[sale valueForKey:@"productDescription"] forKey:@"productDescription"];
		[retailSaleItem setValue:[sale valueForKey:@"salonCost"] forKey:@"salonCost"];
		NSString * clientOrder = [sale valueForKey:@"clientOrder"];
		[retailSaleItem setValue:[NSNumber numberWithDouble:[clientOrder doubleValue]] forKey:@"clientOrder"];
		
		[retailController selling:[clientOrder intValue] ofThisProduct:[sale valueForKey:@"productDescription"]];
	}
	NSString * signature = [employee valueForKey:@"signature"];
	if (signature == nil)	{
		signature = [employee valueForKey:@"name"];
	}
	if (creditTransaction == 1)	{
		[newTransaction setValue:[NSNumber numberWithBool:YES] forKey:@"paidByCharge"];
	} else if (checkTransaction == 1) {
		[newTransaction setValue:[NSNumber numberWithBool:YES] forKey:@"paidByCheck"];
	} else if (cashTransaction == 1)	{
		[newTransaction setValue:[NSNumber numberWithBool:YES] forKey:@"paidCash"];
	}
	
	[newTransaction setValue:[NSNumber numberWithDouble:[retailTotal doubleValue]] forKey:@"retailSubtotal"];
	[newTransaction setValue:[NSNumber numberWithDouble:[retailTax doubleValue]] forKey:@"retailTax"];
	[newTransaction setValue:[NSNumber numberWithDouble:[amountDue doubleValue]] forKey:@"transactionTotal"];
	
	[newTransaction setValue:signature forKey:@"collectedBy"];
	[newTransaction setValue:closeDate forKey:@"time"];
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	
	[sellRetailWindow close];
}
-(NSMutableArray *)fetchTransactionsForSelectedDate
{
	int month,day,year;
	NSCalendarDate * selectedDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	month = [selectedDate monthOfYear];
	day = [selectedDate dayOfMonth];
	year = [selectedDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	NSFetchRequest * transactionRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * tranDescription = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc];
	[transactionRequest setEntity:tranDescription];
	NSSortDescriptor * timeSort = [[[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES] autorelease];
	[transactionRequest setSortDescriptors:[NSArray arrayWithObject:timeSort]];
	[transactionRequest setPredicate:predicate];
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:transactionRequest error:&error]];
	NSLog(@"executing Fetch transaction");
	
	return results;
}
-(IBAction)viewTransactions:(id)sender
{	
	[removeTransactionButton setEnabled:NO];
	canEditTransactions = NO;
	[self loadTransactions];
}
-(void)loadTransactions
{
	[transactionsTable setDelegate:self];
	NSCalendarDate * workingDate = [[mainDatePicker dateValue] dateWithCalendarFormat:@"%m/%d/%y" timeZone:nil];
	int month, day, year;
	month = [workingDate monthOfYear];
	day = [workingDate dayOfMonth];
	year = [workingDate yearOfCommonEra];
	NSCalendarDate * beginningOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	day++;
	NSCalendarDate * endOfDay = [NSCalendarDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 timeZone:nil];
	NSFetchRequest * transactionRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *transactionsDescription = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc];
	[transactionRequest setEntity:transactionsDescription];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"time > $BEGINNING AND time < $END"];
	predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:beginningOfDay , @"BEGINNING",endOfDay, @"END", nil]];
	[transactionRequest setPredicate:predicate];
	NSSortDescriptor * timeSort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
	[transactionRequest setSortDescriptors:[NSArray arrayWithObject:timeSort]];
	[timeSort release];
	NSArray * transactions = [moc executeFetchRequest:transactionRequest error:&error];
	NSLog(@"executing Fetch transaction");
	
	[allTransactionsController setContent:[NSMutableArray arrayWithArray:transactions]];
	
	[transactionsDate setObjectValue:[mainDatePicker dateValue]];
	[transactionsWindow makeKeyAndOrderFront:self];
	[self updateTransactionDescription];
}
-(IBAction)goToEditTransactions:(id)sender
{
	SEL selector = @selector(editTransactions:);
	[passwordController getPasswordFor:self arguments:nil selector:selector];
}
-(void)editTransactions:(NSManagedObject *)password
{
	if ([password valueForKey:@"passwordLevel"] != nil)	{
		int passwordLevel = [[password valueForKey:@"passwordLevel"] intValue];
		id test = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordLevelsPath];
		
		if (passwordLevel >= [[test valueForKey:@"editTransactionsLevel"] intValue] )	{
			canEditTransactions = YES;
			[removeTransactionButton setEnabled:YES];
			[self loadTransactions];
		}		
	}
}
-(void)updateTransactionDescription
{
	
	NSManagedObject * transaction = [[allTransactionsController selectedObjects] objectAtIndex:0];
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
		[description appendString:@"\nPayment Type: Check\n\n"];
	} else if ([[transaction valueForKey:@"paidByCharge"] boolValue] == YES)	{
		[description appendString:@"\nPayment Type: Credit Card\n\n"];
	}
	[description appendFormat:@"CollectedBy: %@", [transaction valueForKey:@"collectedBy"]];

	[transactionDescription setString:description];


//	NSManagedObject * appointment = [transaction valueForKey:@"appointment"];
//	[transactionDescription setString:[bookingSchedule appointmentDescription:appointment]];
}
-(IBAction)removeSelectedObjectsFromShoppingCart:(id)sender
{
	NSArray * selection = [retailCartController selectedObjects];
	NSMutableArray * cart = [NSMutableArray arrayWithArray:[retailCartController content]];

	[cart removeObjectsInArray:selection];
	
	[retailCartController setContent:cart];
		
	[self updateRetailCart];
}
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	if ([aNotification object] == transactionsTable)	{
		[self updateTransactionDescription];
	}
}
-(BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if (aTableView == transactionsTable)	{
		return canEditTransactions;
	}
	else return YES;
}

-(double)transactionTotalDual
{
	double total = 0;
	total += [self retailSubtotalDual];
	total += [self retailTaxDual];
	total += [self serviceSubtotalDual];
	total += [self serviceTaxDual];
	
	int ttotal = total;
	total -= ttotal;
	if (total >= ROUNDUP)	{
		ttotal++;
	}
	
	return ttotal;
}
-(double)retailSubtotalDual
{
	return [retailTotalDual doubleValue];
}
-(double)retailTaxDual
{
	return [retailTaxDual doubleValue];
}
-(double)serviceSubtotalDual
{
	return [serviceTotalDual doubleValue];
}
-(double)serviceTaxDual
{
	return [serviceTaxDual doubleValue];
}
-(void)updateServiceTotalDual
{
	int i; 
	double total = 0;
	for (i=0; i < [priceFieldsDual count]; i++)	{
		total += [[priceFieldsDual objectAtIndex:i] doubleValue];
		[[serviceListDual objectAtIndex:i] setValue:[NSNumber numberWithDouble:[[priceFieldsDual objectAtIndex:i] doubleValue]] forKey:@"price"];
	}
	[serviceTotalDual setDoubleValue:total];
	
	total *= NEWYORKSERVICETAX;
	[serviceTaxDual setDoubleValue:total];
	
	total = [serviceTotalDual doubleValue];
	total += [serviceTaxDual doubleValue];
	total += [retailTotalDual doubleValue];
	total += [retailTaxDual doubleValue];
	int ttotal = total;
	total -= ttotal;
	if (total >= ROUNDUP)	{
		ttotal++;
	}
	
	[amountDueDual setDoubleValue:ttotal];
	

	
}

-(void)updateRetailCartDual
{
	NSArray * retailCart = [retailCartControllerDual content];
	int i;
	double total = 0;
	for (i=0; i< [retailCart count]; i++)	{
		NSMutableDictionary * cartAtIndex = [retailCart objectAtIndex:i];
		double clientTotal = [[cartAtIndex valueForKey:@"retailPrice"] doubleValue];
		clientTotal *= [[cartAtIndex valueForKey:@"clientOrder"] intValue];
		total += clientTotal;
		[cartAtIndex setValue:[NSNumber numberWithFloat:clientTotal] forKey:@"clientTotal"];
	}
	[retailTotalDual setDoubleValue:total];
	
	total *= NEWYORKRETAILTAX;
	[retailTaxDual setDoubleValue:total];
	
	total = [serviceTotalDual doubleValue];
	total += [serviceTaxDual doubleValue];
	total += [retailTotalDual doubleValue];
	total += [retailTaxDual doubleValue];
	int ttotal = total;
	total -= ttotal;
	if (total >= ROUNDUP)	{
		ttotal++;
	}
	
	[amountDueDual setDoubleValue:ttotal];
}

-(IBAction)barcodeEntered:(id)sender
{
	NSManagedObject * product = [retailController barcodeEnteredOnSellRetail:[barcodeSearchBarDual stringValue]];
	if ([[product valueForKey:@"productDescription"] length] > 0)	{
		NSMutableArray * results = [self searchForProductDescriptionExact:[product valueForKey:@"productDescription"]];
		NSMutableDictionary * dictionary;
		if ([results count] == 1)	{
			NSMutableArray * cart = [NSMutableArray arrayWithArray:[retailCartControllerDual content]];
			int i;
			BOOL match = NO;
			for (i=0; i< [cart count]; i++)	{
				if ([[[cart objectAtIndex:i] valueForKey:@"productDescription"] compare:[product valueForKey:@"productDescription"]] == NSOrderedSame)	{
					int order = [[[cart objectAtIndex:i] valueForKey:@"clientOrder"] intValue];
					order++;
					[[cart objectAtIndex:i] setValue:[NSNumber numberWithInt:order] forKey:@"clientOrder"];
					dictionary = [cart objectAtIndex:i];
					match  = YES;
				}
				
			} 
			if (match == NO)	{
				dictionary = [NSMutableDictionary dictionary];
				[dictionary setObject:[[results objectAtIndex:0] valueForKey:@"productDescription"] forKey:@"productDescription"];
				[dictionary setObject:[[results objectAtIndex:0] valueForKey:@"retailPrice"] forKey:@"retailPrice"];
				[dictionary setObject:[[results objectAtIndex:0] valueForKey:@"isColorItem"] forKey:@"isColorItem"];
				[dictionary setObject:[[results objectAtIndex:0] valueForKey:@"salonCost"] forKey:@"salonCost"];
				[dictionary setObject:[[results objectAtIndex:0] valueForKey:@"company"] forKey:@"company"];
				[dictionary setObject:[NSNumber numberWithInt:1] forKey:@"clientOrder"];
				[cart addObject:dictionary];

				[retailCartControllerDual setContent:cart];
				
			}
			double total = [[dictionary valueForKey:@"retailPrice"] doubleValue];
			total *= [[dictionary valueForKey:@"clientOrder"] intValue];
			[dictionary setValue:[NSNumber numberWithFloat:total] forKey:@"clientTotal"];
			[self updateRetailCartDual];
			[barcodeSearchBarDual setStringValue:@""];
		}
	}
}

-(IBAction)removeSelectedObjectsFromShoppingCartDual:(id)sender
{
	NSArray * selection = [retailCartControllerDual selectedObjects];
	NSMutableArray * cart = [NSMutableArray arrayWithArray:[retailCartControllerDual content]];
	
	[cart removeObjectsInArray:selection];
	
	[retailCartControllerDual setContent:cart];
	
	[self updateRetailCartDual];
}
-(IBAction)addToShoppingCartDual:(id)sender
{
	NSArray * matches = [matchesControllerDual content];
	int i;
	NSMutableArray * cart = [NSMutableArray arrayWithArray:[retailCartControllerDual content]];
	for (i=0; i< [matches count] ; i++)	{
		NSMutableDictionary * matchAtIndex = [matches objectAtIndex:i];
		if ([[matchAtIndex valueForKey:@"clientOrder"] intValue] > 0)	{
			NSMutableDictionary * copy = [NSMutableDictionary dictionaryWithDictionary:matchAtIndex];
			double total = [[matchAtIndex valueForKey:@"retailPrice"] doubleValue];
			total *= [[matchAtIndex valueForKey:@"clientOrder"] intValue];
			[copy setValue:[NSNumber numberWithDouble:total] forKey:@"clientTotal"];
			[cart addObject:copy];
		}
	}
	[retailCartControllerDual setContent:cart];
	[retailSaleDual setArray:cart];
	[self updateRetailCartDual];
}
-(IBAction)goToRefundProductPurchase:(id)sender
{
	
	[retailSearchBarRefund setStringValue:@""];
	[barcodeSearchBarRefund setStringValue:@""];
	[barcodeSearchBarRefund selectText:self];
	[refundProductPurchaseWindow makeKeyAndOrderFront:self];
}
-(IBAction)removeSelectedItemsFromRefund:(id)sender
{
	NSArray * selectedObjects = [refundController selectedObjects];
	[refundController removeObjects:selectedObjects];
}
-(IBAction)addItemToRefund:(id)sender
{
	NSArray * matches = [refundMatches content];
	int i;
	NSMutableArray * cart = [NSMutableArray arrayWithArray:[retailCartController content]];
	for (i=0; i< [matches count] ; i++)	{
		NSMutableDictionary * matchAtIndex = [matches objectAtIndex:i];
		if ([[matchAtIndex valueForKey:@"clientOrder"] intValue] > 0)	{
			NSMutableDictionary * copy = [NSMutableDictionary dictionaryWithDictionary:matchAtIndex];
			double total = [[matchAtIndex valueForKey:@"salonCost"] doubleValue];
			total *= [[matchAtIndex valueForKey:@"clientOrder"] intValue];
			[copy setValue:[NSNumber numberWithFloat:total] forKey:@"clientTotal"];
			[cart addObject:copy];
		}
	}
	[refundMatches setContent:cart];
	[self updateRetailRefund];	
	
}
-(IBAction)completeRefund:(id)sender
{
	// get signature
	SEL selector = @selector(setCollectedByForRefund:);
	[employeeSelect selectEmployeeFor:self selector:selector windowTitle:@"Who Are You?"];
}
-(void)setCollectedByForRefund:(NSManagedObject *)employee
{
	NSMutableArray * retailRefunded = [NSKeyedUnarchiver unarchiveObjectWithFile:retailRefundedPath];
	NSArray * toBeRefunded = [refundController content];
	int i;
	for (i=0; i < [toBeRefunded count]; i++)	{
		[[toBeRefunded objectAtIndex:i] setValue:[NSDate date] forKey:@"date"];
	}
	[retailRefunded addObjectsFromArray:toBeRefunded];
	
	[NSKeyedArchiver archiveRootObject:retailRefunded toFile:retailRefundedPath];
}
-(IBAction)barcodeEnteredForRefund:(id)sender
{
	NSManagedObject * product = [retailController barcodeEnteredOnSellRetail:[barcodeSearchBarRefund stringValue]];
	if ([[product valueForKey:@"productDescription"] length] > 0)	{
		NSMutableArray * results = [self searchForProductDescriptionExact:[product valueForKey:@"productDescription"]];
		NSMutableDictionary * dictionary;
		if ([results count] == 1)	{
			NSMutableArray * cart = [NSMutableArray arrayWithArray:[refundController content]];
			int i;
			BOOL match = NO;
			for (i=0; i< [cart count]; i++)	{
				if ([[[cart objectAtIndex:i] valueForKey:@"productDescription"] compare:[product valueForKey:@"productDescription"]] == NSOrderedSame)	{
					int order = [[[cart objectAtIndex:i] valueForKey:@"clientOrder"] intValue];
					order++;
					[[cart objectAtIndex:i] setValue:[NSNumber numberWithInt:order] forKey:@"clientOrder"];
					dictionary = [cart objectAtIndex:i];
					match  = YES;
				}
				
			} 
			if (match == NO)	{
				dictionary = [NSMutableDictionary dictionary];
				[dictionary setObject:[[results objectAtIndex:0] valueForKey:@"productDescription"] forKey:@"productDescription"];
				[dictionary setObject:[[results objectAtIndex:0] valueForKey:@"salonCost"] forKey:@"salonCost"];
				[dictionary setObject:[[results objectAtIndex:0] valueForKey:@"isColorItem"] forKey:@"isColorItem"];
				[dictionary setObject:[[results objectAtIndex:0] valueForKey:@"salonCost"] forKey:@"salonCost"];
				[dictionary setObject:[[results objectAtIndex:0] valueForKey:@"company"] forKey:@"company"];
				[dictionary setObject:[NSNumber numberWithInt:1] forKey:@"clientOrder"];
				[cart addObject:dictionary];
				
				[refundController setContent:cart];
				
			}
			double total = [[dictionary valueForKey:@"salonCost"] doubleValue];
			total *= [[dictionary valueForKey:@"clientOrder"] intValue];
			[dictionary setValue:[NSNumber numberWithFloat:total] forKey:@"clientTotal"];
			[self updateRetailRefund];
			[barcodeSearchBarRefund setStringValue:@""];
		}
	}
}
-(void)updateRetailRefund
{
	NSArray * retailCart = [refundController content];
	int i;
	double total = 0;
	for (i=0; i< [retailCart count]; i++)	{
		NSMutableDictionary * cartAtIndex = [retailCart objectAtIndex:i];
		double clientTotal = [[cartAtIndex valueForKey:@"salonCost"] doubleValue];
		clientTotal *= [[cartAtIndex valueForKey:@"clientOrder"] intValue];
		total += clientTotal;
		[cartAtIndex setValue:[NSNumber numberWithFloat:clientTotal] forKey:@"clientTotal"];
	}
	[refundSubtotal setDoubleValue:total];
	
	total *= (NEWYORKRETAILTAX);
	[refundTax setDoubleValue:total];
	
	total = [refundSubtotal doubleValue];
	total += [refundTax doubleValue];
	
	int ttotal = total;
	total -= ttotal;
	if (total >= ROUNDUP)	{
		ttotal++;
	}
	
	[refundTotal setDoubleValue:ttotal];
}
-(IBAction)viewTransactionsDetails:(id)sender
{
	
}

@end
