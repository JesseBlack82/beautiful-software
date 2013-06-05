//
//  RetailController.m
//  Beautiful Software
//
//  Created by Jesse Black on 1/8/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import "RetailController.h"
#import "PasswordConstants.h"
#import "Beautiful_Software_AppDelegate.h"

@implementation RetailController
@synthesize invoicePath;
@synthesize invoiceEntries;
@synthesize passwordLevelsPath;

-(void)awakeFromNib
{


	NSMutableString * ppath = [NSMutableString string];
	[ppath setString:[appDelegate applicationSupportFolder]];
	[ppath appendString:@"/Invoices/"];
	[self setInvoicePath:ppath];
 

	moc = [appDelegate managedObjectContext];

	
//	[self test];
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
-(void)test
{
	NSFetchRequest * retailMenuRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * retailDescription = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
	[retailMenuRequest setIncludesSubentities:NO];
	[retailMenuRequest setEntity:retailDescription];
	NSArray * results = [moc executeFetchRequest:retailMenuRequest error:&error];
	NSLog(@"executing Fetch retail menu item");
	if ([results count] ==0)	{
		NSManagedObject * retailItem = [NSEntityDescription insertNewObjectForEntityForName:@"InventoryItem" inManagedObjectContext:moc];
		[retailItem setValue:@"Harmony" forKey:@"company"];
		[retailItem setValue:@"The Best Shampoo" forKey:@"productDescription"];
		[retailItem setValue:[NSNumber numberWithInt:8] forKey:@"salonCost"];
		[retailItem setValue:[NSNumber numberWithInt:16] forKey:@"salonCost"];
		
		retailItem = [NSEntityDescription insertNewObjectForEntityForName:@"InventoryItem" inManagedObjectContext:moc];
		[retailItem setValue:@"Harmony" forKey:@"company"];
		[retailItem setValue:@"The Best Conditioner" forKey:@"productDescription"];
		[retailItem setValue:[NSNumber numberWithInt:8] forKey:@"salonCost"];
		[retailItem setValue:[NSNumber numberWithInt:16] forKey:@"salonCost"];
		
		retailItem = [NSEntityDescription insertNewObjectForEntityForName:@"InventoryItem" inManagedObjectContext:moc];
		[retailItem setValue:@"Harmony" forKey:@"company"];
		[retailItem setValue:@"The Best Paste" forKey:@"productDescription"];
		[retailItem setValue:[NSNumber numberWithInt:7] forKey:@"salonCost"];
		[retailItem setValue:[NSNumber numberWithInt:14] forKey:@"salonCost"];
		
		retailItem = [NSEntityDescription insertNewObjectForEntityForName:@"InventoryItem" inManagedObjectContext:moc];
		[retailItem setValue:@"Harmony" forKey:@"company"];
		[retailItem setValue:@"The Best Gel" forKey:@"productDescription"];
		[retailItem setValue:[NSNumber numberWithInt:6] forKey:@"salonCost"];
		[retailItem setValue:[NSNumber numberWithInt:12] forKey:@"salonCost"];
		
		retailItem = [NSEntityDescription insertNewObjectForEntityForName:@"InventoryItem" inManagedObjectContext:moc];
		[retailItem setValue:@"Harmony" forKey:@"company"];
		[retailItem setValue:@"The Best Hairspray" forKey:@"productDescription"];
		[retailItem setValue:[NSNumber numberWithInt:5] forKey:@"salonCost"];
		[retailItem setValue:[NSNumber numberWithInt:12] forKey:@"salonCost"];
		
		
		
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	}
	
}

-(IBAction)editRetailPriceListAction:(id)sender
{
	SEL selector = @selector(passwordEnteredForRetailEdit:);
	[passwordController getPasswordFor:self arguments:nil selector:selector];
	
}
-(void)passwordEnteredForRetailEdit:(NSManagedObject *)password
{
	NSFetchRequest * retailRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * retailDescription = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
	[retailRequest setIncludesSubentities:NO];
	[retailRequest setEntity:retailDescription];
	NSSortDescriptor * nameSort = [[[NSSortDescriptor alloc] initWithKey:@"productDescription" ascending:YES] autorelease];
	
	[retailRequest setSortDescriptors:[NSArray arrayWithObject:nameSort]];
	NSMutableArray * array = [NSMutableArray array];
	[array setArray:[moc executeFetchRequest:retailRequest error:&error]];
	NSLog(@"executing Fetch retail menu item");
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"entity == %@", retailDescription];
	[array filterUsingPredicate:predicate];
	[allRetailItemsForEdit setContent:array];
	[editRetailPriceListWindow makeKeyAndOrderFront:self];
	
}
-(IBAction)searchProductDescriptionOnBarcodeMode:(id)sender
{
	[matchingProductsBarcodeWindow setContent:[self searchForProductDescription:[productDescriptionBarcodeWindow stringValue]]];
}
-(NSManagedObject *)barcodeEnteredOnSellRetail:(NSString *)barcode;
{
	NSFetchRequest * fr = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * inventoryDescription = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
	[fr setIncludesSubentities:NO];
	[fr setEntity:inventoryDescription];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"barcode == %@", barcode];
	[fr setPredicate:predicate];
	
	NSArray * results = [moc executeFetchRequest:fr error:&error];
	NSLog(@"executing Fetch inventory");
	if ([results count] == 1)	{
		return [results objectAtIndex:0];
	} else return nil;
}
-(void)controlTextDidChange:(NSNotification *)notification
{
	id object = [notification object];
	if (object == backBarEntrySearchField)	{
		NSMutableArray * results = [self searchForProductDescription:[object stringValue]];
		int i;
		NSMutableArray * matches = [NSMutableArray array];
		for (i=0 ; i< [results count]; i++)	{
			NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
			[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"productDescription"] forKey:@"productDescription"];
			[dictionary setObject:[[results objectAtIndex:i] valueForKey:@"barcode"] forKey:@"barcode"];
			[matches addObject:dictionary];
		}
		
		[backBarEntryMatches setContent:matches];
	}
		
}
-(void)controlTextDidEndEditing:(NSNotification *)notification
{
	id object = [notification object];
	if (object == barcodeBarcodeWindow)	{
		
	} else if (object == editRetailTable)	{
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	} if ([[object className] compare:@"NSTableView"] == NSOrderedSame)	{
		[moc save:&error]; NSLog(@"inventory moc saving");
	} else if (object == backBarEntryBarcodField)	{
		NSFetchRequest * fr = [[[NSFetchRequest alloc] init] autorelease];
		NSEntityDescription * inventoryDescription = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
		[fr setIncludesSubentities:NO];
		[fr setEntity:inventoryDescription];
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"barcode == %@", [object stringValue]];
		[fr setPredicate:predicate];
		
		NSArray * results = [moc executeFetchRequest:fr error:&error];
		NSLog(@"executing Fetch inventory");
		if ([results count] == 1)	{
			[backBarEntryController addObject:[results objectAtIndex:0]];
		}
			
	}
}
-(IBAction)removeItemFromPriceList:(id)sender
{
	NSManagedObject * item = [[allRetailItemsForEdit selectedObjects] objectAtIndex:0];
	[allRetailItemsForEdit removeObject:item];
	[moc deleteObject:item];
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
}
-(BOOL)selling:(int)clientOrder ofThisProduct:(NSString *)productDescription
{
	NSFetchRequest * inventoryRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * inventoryDescription = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
	[inventoryRequest setIncludesSubentities:NO];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"productDescription == %@", productDescription];
	[inventoryRequest setEntity:inventoryDescription];
	[inventoryRequest setPredicate:predicate];
	NSArray * results = [moc executeFetchRequest:inventoryRequest error:&error];
	NSLog(@"executing Fetch inventory");
	if ([results count] == 1)	{
		NSManagedObject * match = [results objectAtIndex:0];
		
		int have = [[match valueForKey:@"inStock"] intValue];
		have = have - clientOrder;
		if (have >= 0)	{
			[match setValue:[NSNumber numberWithInt:have] forKey:@"inStock"];
			[moc save:&error]; NSLog(@"inventory moc saving");
			return YES;
			
		}
		return NO;
	} else return NO;
}
-(void)undoSellingFromTransaction:(NSManagedObject *)transaction 
{
	NSArray * retailSale = [[transaction valueForKey:@"retailSaleItems"] allObjects];
	
	
	
	int i; 
	for (i=0; i< [retailSale count]; i++)	{
		NSManagedObject * sale = [retailSale objectAtIndex:i];
		
		
		NSFetchRequest * inventoryRequest = [[[NSFetchRequest alloc] init] autorelease];
		NSEntityDescription * inventoryDescription = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"productDescription == %@", [sale valueForKey:@"productDescription"]];
		[inventoryRequest setIncludesSubentities:NO];
		[inventoryRequest setEntity:inventoryDescription];
		[inventoryRequest setPredicate:predicate];
		NSArray * results = [moc executeFetchRequest:inventoryRequest error:&error];
		NSLog(@"executing Fetch inventory");
		if ([results count] == 1)	{
			NSManagedObject * match = [results objectAtIndex:0];
			int clientOrder = [[sale valueForKey:@"clientOrder"] intValue];
			int have = [[match valueForKey:@"inStock"] intValue];
			have = have + clientOrder;
			[match setValue:[NSNumber numberWithInt:have] forKey:@"inStock"];
			[moc save:&error]; NSLog(@"inventory moc saving");
			
		}
	}
}

-(IBAction)goToAllInventory:(id)sender
{
	SEL selector = @selector(passwordEnteredOnAllInventory:);
	[passwordController getPasswordFor:self arguments:nil selector:selector];
}
-(void)passwordEnteredOnAllInventory:(NSManagedObject*)password
{
	if ([password valueForKey:@"passwordLevel"] != nil)	{
		int passwordLevel = [[password valueForKey:@"passwordLevel"] intValue];
		id test = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordLevelsPath];
		
		if (passwordLevel >= [[test valueForKey:@"editRetailMenuLevel"] intValue] )	{
			NSFetchRequest * inventoryRequest = [[[NSFetchRequest alloc] init] autorelease];
			NSEntityDescription * inventoryDescription = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
			NSSortDescriptor * sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"productDescription" ascending:YES] autorelease];
			[inventoryRequest setEntity:inventoryDescription];
					[inventoryRequest setIncludesSubentities:NO];
			[inventoryRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
			NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:inventoryRequest error:&error]];
			NSLog(@"executing Fetch inventory");
		/*	int i;
			NSFetchRequest *fr = [[[NSFetchRequest alloc] init] autorelease];
			NSEntityDescription *ed = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
			
			[fr setEntity:ed];
			
			NSArray * mocResults = [moc executeFetchRequest:fr error:&error];
			NSLog(@"executing Fetch");
		 
			for (i=0; i< [results count]; i++)	{
				NSManagedObject * entry =[results objectAtIndex:i];
				if ([entry valueForKey:@"quantity"] == nil)	{
					[entry setValue:[NSNumber numberWithInt:0] forKey:@"quantity"];
				}
				if ([entry valueForKey:@"salonCost"] == nil)	{
					NSPredicate * p = [NSPredicate predicateWithFormat:@"productDescription == %@", [entry valueForKey:@"productDescription"]];
					NSMutableArray * filter = [NSMutableArray arrayWithArray:mocResults];
					[filter filterUsingPredicate:p];
					NSManagedObject * product= [filter objectAtIndex:0];
					if ([product valueForKey:@"salonCost"] != nil)	{
						[entry setValue:[product valueForKey:@"salonCost"] forKey:@"salonCost"];
					}
					if ([product valueForKey:@"company"] != nil)	{
						[entry setValue:[product valueForKey:@"company"] forKey:@"company"];
					}
				}
			}
			[moc save:&error]; NSLog(@"inventory moc saving");*/
			[allInventoryController setContent:results];
		}
	}		
	[allInventoryWindow makeKeyAndOrderFront:self];
}

-(IBAction)removeEntry:(id)sender
{
	NSManagedObject * selected = [[allInventoryController selectedObjects] objectAtIndex:0];
	if (selected != nil)	{
		[allInventoryController removeObject:selected];
		[moc deleteObject:selected];
	}
}
-(IBAction)squeezeEntry:(id)sender
{
	int selectedIndex = [allInventoryController selectionIndex];
	NSManagedObject * newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"InventoryItem" inManagedObjectContext:moc];
	[newEntry setValue:@"description" forKey:@"invoiceDescription"];
	[newEntry setValue:[NSNumber numberWithInt:0] forKey:@"inStock"];
	if (selectedIndex + 1 <= [[allInventoryController content] count])	{
		[allInventoryController insertObject:newEntry atArrangedObjectIndex:selectedIndex+1];
	} else	{
		[allInventoryController addObject:newEntry];
	}
}
-(IBAction)newEntry:(id)sender
{
	NSManagedObject * newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"InventoryItem" inManagedObjectContext:moc];
	[newEntry setValue:@"description" forKey:@"invoiceDescription"];
	[newEntry setValue:[NSNumber numberWithInt:0] forKey:@"inStock"];
	[allInventoryController addObject:newEntry];
}
-(IBAction)sortByName:(id)sender
{
	NSMutableArray * inventory = [NSMutableArray arrayWithArray:[allInventoryController content]];
	
	NSSortDescriptor * sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"invoiceDescription" ascending:YES] autorelease];
	[inventory sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[allInventoryController setContent:inventory];
}
-(IBAction)goToCreateInventoryFromBarcodeMode:(id)sender
{
	[barcodeBarcodeWindow setStringValue:@""];
	[productDescriptionBarcodeWindow setStringValue:@""];
	[companyBarcodeWindow setStringValue:@""];
	[itemCodeBarcodeWindow setStringValue:@""];
	[invoiceDescriptionBarcodeWindow setStringValue:@""];
	[unitPriceBarcodeWindow setStringValue:@""];
	[quantityBarcodeWindow setStringValue:@""];
	
	
	[createInventoryFromBarcodeWindow makeKeyAndOrderFront:self];
}
-(IBAction)barcodeEnteredOnBarcodeWindow:(id)sender
{
	NSFetchRequest * fr = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * inventoryDescription = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
			[fr setIncludesSubentities:NO];
	[fr setEntity:inventoryDescription];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"barcode == %@", [barcodeBarcodeWindow stringValue]];
	[fr setPredicate:predicate];
	
	NSArray * results = [moc executeFetchRequest:fr error:&error];
	NSLog(@"executing Fetch inventory");
	if ([results count] == 1)	{
		NSManagedObject * entry = [results objectAtIndex:0];
		
		if ([entry valueForKey:@"company"] != nil)	{
			[companyBarcodeWindow setStringValue:[entry valueForKey:@"company"]];
		} else	{
			[companyBarcodeWindow setStringValue:@""];
		}
		if ([entry valueForKey:@"itemCode"] != nil)	{
			[itemCodeBarcodeWindow setStringValue:[entry valueForKey:@"itemCode"]];
		} else	{
			[itemCodeBarcodeWindow setStringValue:@""];
		}
		if ([entry valueForKey:@"invoiceDescription"] != nil)	{
			[invoiceDescriptionBarcodeWindow setStringValue:[entry valueForKey:@"invoiceDescription"]];
		} else	{
			[invoiceDescriptionBarcodeWindow setStringValue:@""];
		}
		if ([entry valueForKey:@"salonCost"] != nil)	{
			[unitPriceBarcodeWindow setStringValue:[entry valueForKey:@"salonCost"]];
		} else	{
			[unitPriceBarcodeWindow setStringValue:@""];
		}
		if ([entry valueForKey:@"productDescription"] != nil)	{
			[productDescriptionBarcodeWindow setStringValue:[entry valueForKey:@"productDescription"]];
		} else	{
			[productDescriptionBarcodeWindow setStringValue:@""];
		}
		[createAdjustInventoryItem setTitle:@"Adjust / Add Stock To Inventory Entry"];
	} else	{
		[productDescriptionBarcodeWindow setStringValue:@""];
		[companyBarcodeWindow setStringValue:@""];
		[itemCodeBarcodeWindow setStringValue:@""];
		[invoiceDescriptionBarcodeWindow setStringValue:@""];
		[unitPriceBarcodeWindow setStringValue:@""];
		[quantityBarcodeWindow setStringValue:@""];
		[matchingProductsBarcodeWindow setContent:[NSMutableArray array]];
		[createAdjustInventoryItem setTitle:@"Create Inventory Entry"];
	}
}
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSString * productDescription = [[[matchingProductsBarcodeWindow selectedObjects] objectAtIndex:0] valueForKey:@"productDescription"];
	[productDescriptionBarcodeWindow setStringValue:productDescription];
}
-(IBAction)createInventoryFromBarcodeWindow:(id)sender
{
	NSString * barcode = [barcodeBarcodeWindow stringValue];
	NSString * pd = [productDescriptionBarcodeWindow stringValue];
	NSString * itemCode = [itemCodeBarcodeWindow stringValue];
	NSString * invoiceDescription = [invoiceDescriptionBarcodeWindow stringValue];
	NSString * unitPrice = [unitPriceBarcodeWindow stringValue];
	NSString * company = [companyBarcodeWindow stringValue];
	int addingToInventory = [quantityBarcodeWindow intValue];
	
	NSManagedObject * inventoryEntry;
	if ([[createAdjustInventoryItem title] compare:@"Create Inventory Entry"] == NSOrderedSame)	{
		inventoryEntry = [NSEntityDescription insertNewObjectForEntityForName:@"InventoryItem" inManagedObjectContext:moc];
	} else	{
		NSFetchRequest * fr = [[[NSFetchRequest alloc] init] autorelease];
		NSEntityDescription * inventoryDescription = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
		[fr setEntity:inventoryDescription];
				[fr setIncludesSubentities:NO];
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"barcode == %@", barcode];
		[fr setPredicate:predicate];
		
		NSArray * results = [moc executeFetchRequest:fr error:&error];
		NSLog(@"executing Fetch inventory");
		inventoryEntry = [results objectAtIndex:0];
	}

	if (barcode)	{
		[inventoryEntry setValue:barcode forKey:@"barcode"];
	}
	if ([pd length] > 0)	{
		[inventoryEntry setValue:pd forKey:@"productDescription"];
	} else	{
		[inventoryEntry setValue:@"N/A" forKey:@"productDescription"];
	}
	
	if (company)	{
		[inventoryEntry setValue:company forKey:@"company"];
	}
	if (itemCode)	{
		[inventoryEntry setValue:itemCode forKey:@"itemCode"];
	}
	if (invoiceDescription)	{
		[inventoryEntry setValue:invoiceDescription forKey:@"invoiceDescription"];
	}
	if (unitPrice)	{
		[inventoryEntry setValue:[NSNumber numberWithFloat:[unitPrice floatValue]] forKey:@"salonCost"];
	}
	int quantity = [[inventoryEntry valueForKey:@"inStock"] intValue];
	quantity += addingToInventory;
	[inventoryEntry setValue:[NSNumber numberWithInt:quantity] forKey:@"inStock"];
	
	[moc save:&error]; NSLog(@"inventory moc saving");

	
	[productDescriptionBarcodeWindow setStringValue:@""];
	[companyBarcodeWindow setStringValue:@""];
	[itemCodeBarcodeWindow setStringValue:@""];
	[invoiceDescriptionBarcodeWindow setStringValue:@""];
	[unitPriceBarcodeWindow setStringValue:@""];
	[quantityBarcodeWindow setStringValue:@""];
	
	[barcodeBarcodeWindow setStringValue:@""];
	[barcodeBarcodeWindow selectText:self];
	
	
	
}
-(IBAction)goToAddToRetailPriceList:(id)sender
{
	[addCompany setStringValue:@""];
	[addProductDescription setStringValue:@""];
	[addRetailPrice setStringValue:@""];
	[addSalonCost setStringValue:@""];
	[addColorBool setState:0];
	
	[addRetailWindow makeKeyAndOrderFront:self];
	[addCompany selectText:self];

	NSFetchRequest * retailRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * retailDescription = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
	[retailRequest setEntity:retailDescription];
			[retailRequest setIncludesSubentities:NO];
	NSSortDescriptor * nameSort = [[[NSSortDescriptor alloc] initWithKey:@"productDescription" ascending:YES] autorelease];
	
	[retailRequest setSortDescriptors:[NSArray arrayWithObject:nameSort]];
	NSMutableArray * array = [NSMutableArray array];
	[array setArray:[moc executeFetchRequest:retailRequest error:&error]];
	NSLog(@"executing Fetch retail menu item");
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"entity == %@", retailDescription];
	[array filterUsingPredicate:predicate];
	
	[allRetailItems setContent:array];
}
-(IBAction)addToRetailPriceList:(id)sender
{
	NSFetchRequest * fr = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * retailDescription = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"productDescription == %@", [addProductDescription stringValue]];
	[fr setEntity:retailDescription];
	[fr setPredicate:predicate];
	[fr setIncludesSubentities:NO];

	NSArray * results = [moc executeFetchRequest:fr error:&error];
	NSLog(@"executing Fetch retail menu item");
	if ([results count] == 0)	{
		NSString * pd = [addProductDescription stringValue];
		NSString * company  = [addCompany stringValue];
		float  salon = [addSalonCost floatValue];
		float price = [addRetailPrice floatValue];
		NSManagedObject * newItem = [NSEntityDescription insertNewObjectForEntityForName:@"InventoryItem" inManagedObjectContext:moc];
		[newItem setValue:pd forKey:@"productDescription"];
		[newItem setValue:company forKey:@"company"];
		[newItem setValue:[NSNumber numberWithFloat:salon] forKey:@"salonCost"];
		[newItem setValue:[NSNumber numberWithFloat:price] forKey:@"salonCost"];
		[allRetailItems addObject:newItem];
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	} else	{
		NSRunAlertPanel(@"Warning", @"Product Description Exists", @"OK", nil, nil);
	}
	
	[addRetailPrice setStringValue:@""];
	[addSalonCost setStringValue:@""];
	[addColorBool setState:0];
	
}
-(IBAction)salonPriceEnteredOnAddRetailItem:(id)sender
{
	float salon = [addSalonCost floatValue];
	salon *= 2;
	[addRetailPrice setFloatValue:salon];
}

-(IBAction)goToCreateInvoice:(id)sender
{
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	
	id test = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%@%@", invoicePath, today]];
	if ([test count] > 0)	{
		[self setInvoiceEntries:[NSMutableArray arrayWithArray:test]];
	} else	{
		[self setInvoiceEntries:[NSMutableArray array]];
	}
	[invoiceWindow makeKeyAndOrderFront:self];
}
-(IBAction)barcodeEnteredOnInvoiceWindow:(id)sender
{
	NSMutableDictionary * invoiceEntry;
	if ([invoiceEntries count] > 0)	{
		
		NSMutableSet * invoiceSet = [NSMutableSet setWithArray:invoiceEntries];
		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"barcode == %@", [barcodeInvoiceWindow stringValue]];
		[invoiceSet filterUsingPredicate:predicate];
		if ([invoiceSet count] > 0)	{
			invoiceEntry = [invoiceSet anyObject];
			int quantity = [[invoiceEntry valueForKey:@"inStock"] intValue];
			quantity ++;
			[invoiceEntry setObject:[NSNumber numberWithInt:quantity] forKey:@"inStock"];
			[quantitySoFar setIntValue:quantity];
			if ([[invoiceEntry valueForKey:@"productDescription"] compare:@"N/A"] != NSOrderedSame)	{
				[lastScannedInvoice setStringValue:[invoiceEntry valueForKey:@"productDescription"]];
			} else {
				[lastScannedInvoice setStringValue:[invoiceEntry valueForKey:@"invoiceDescription"]];
			}
		} else		{
			NSFetchRequest * fr = [[[NSFetchRequest alloc] init] autorelease];
			NSEntityDescription * inventoryDescription = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
			[fr setEntity:inventoryDescription];
			[fr setIncludesSubentities:NO];

			NSPredicate * predicate = [NSPredicate predicateWithFormat:@"barcode == %@", [barcodeInvoiceWindow stringValue]];
			[fr setPredicate:predicate];
			
			NSArray * results = [moc executeFetchRequest:fr error:&error];
			NSLog(@"executing Fetch inventory");
			if ([results count] == 1)	{
				NSManagedObject * entry = [results objectAtIndex:0];
				invoiceEntry = [NSMutableDictionary dictionary];
				[invoiceEntry setValue:[entry valueForKey:@"barcode"] forKey:@"barcode"];
				[invoiceEntry setValue:[entry valueForKey:@"company"] forKey:@"company"];
				[invoiceEntry setValue:[entry valueForKey:@"productDescription"] forKey:@"productDescription"];
				[invoiceEntry setValue:[entry valueForKey:@"invoiceDescription"] forKey:@"invoiceDescription"];
				[invoiceEntry setValue:[entry valueForKey:@"salonCost"] forKey:@"salonCost"];
				[invoiceEntry setValue:[NSNumber numberWithInt:1] forKey:@"inStock"];
				[invoiceEntries addObject:invoiceEntry];
				[quantitySoFar setIntValue:1];
				if ([[invoiceEntry valueForKey:@"productDescription"] compare:@"N/A"] != NSOrderedSame)	{
					[lastScannedInvoice setStringValue:[invoiceEntry valueForKey:@"productDescription"]];
				} else {
					[lastScannedInvoice setStringValue:[invoiceEntry valueForKey:@"invoiceDescription"]];
				}
			} else	{
				NSRunAlertPanel(@"Warning", @"Barcode Not In System. Please create entry on add to inventory (barcode mode).", @"OK", nil, nil);
			}
		}
	} else	{
	
		NSFetchRequest * fr = [[[NSFetchRequest alloc] init] autorelease];
		NSEntityDescription * inventoryDescription = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
		[fr setEntity:inventoryDescription];
		[fr setIncludesSubentities:NO];

		NSPredicate * predicate = [NSPredicate predicateWithFormat:@"barcode == %@", [barcodeInvoiceWindow stringValue]];
		[fr setPredicate:predicate];
	
		NSArray * results = [moc executeFetchRequest:fr error:&error];
		NSLog(@"executing Fetch inventory");
		if ([results count] == 1)	{
			NSManagedObject * entry = [results objectAtIndex:0];
			invoiceEntry = [NSMutableDictionary dictionary];
			[invoiceEntry setValue:[entry valueForKey:@"barcode"] forKey:@"barcode"];
			[invoiceEntry setValue:[entry valueForKey:@"company"] forKey:@"company"];
			[invoiceEntry setValue:[entry valueForKey:@"productDescription"] forKey:@"productDescription"];
			[invoiceEntry setValue:[entry valueForKey:@"invoiceDescription"] forKey:@"invoiceDescription"];
			[invoiceEntry setValue:[entry valueForKey:@"salonCost"] forKey:@"salonCost"];
			[invoiceEntry setValue:[NSNumber numberWithInt:1] forKey:@"inStock"];
			[invoiceEntries addObject:invoiceEntry];
			[quantitySoFar setIntValue:1];
			if ([[invoiceEntry valueForKey:@"productDescription"] compare:@"N/A"] != NSOrderedSame)	{
				[lastScannedInvoice setStringValue:[invoiceEntry valueForKey:@"productDescription"]];
			} else {
				[lastScannedInvoice setStringValue:[invoiceEntry valueForKey:@"invoiceDescription"]];
			}
		} else	{
			NSRunAlertPanel(@"Warning", @"Barcode Not In System. Please create entry on add to inventory (barcode mode).", @"OK", nil, nil);
		}
	}
	
	
	NSCalendarDate * today = [[NSDate date] dateWithCalendarFormat:@"%m%d%y" timeZone:nil];
	NSString * string  = [NSString stringWithFormat:@"%@%@", invoicePath, today];
	[NSKeyedArchiver archiveRootObject:invoiceEntries toFile:string];
	
	[barcodeInvoiceWindow setStringValue:@""];
	[barcodeInvoiceWindow selectText:self];
	
}
-(IBAction)viewInvoiceSummary:(id)sender
{
	
	NSDictionary* errorDict;
	NSAppleEventDescriptor* returnDescriptor = NULL;
	NSMutableString * string = [NSMutableString string];
	
	NSMutableString * ppath = [NSMutableString stringWithString:[[NSBundle mainBundle] bundlePath]];
	
	NSLog(@"invoice entries %@", invoiceEntries);
	[ppath appendString:@"/Contents/Resources/retailOriginal.cwk"];
	ppath = [ppath stringByReplacingOccurrencesOfString:@"/Users" withString:@"Macintosh HD:Users"];
	ppath = [ppath stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
	ppath = [ppath stringByReplacingOccurrencesOfString:@"/" withString:@":"];
	
	[string appendFormat:@"tell application \"Finder\"\n\ 
	 open file \"%@\"\n\
	 tell application \"AppleWorks 6\"\n\
	 tell document 1\n\
	 set cell 1 of row 1 to \"\%@\"\n\
	 set cell 2 of row 1 to \"\%@\"\n\
	 set cell 3 of row 1 to \"\%@\"\n\
	 set cell 4 of row 1 to \"\%@\"\n", ppath , @"Barcode"  ,@"Product Description", @"Unit Price", @"Shipped"];
	int i;
	for (i = 0; i < [invoiceEntries count]; i++)	{
		NSMutableDictionary * sale = [invoiceEntries objectAtIndex:i];
		int row = i+2;
		[string appendFormat:@"set cell 1 of row %d to \"\%@\"\n", row, [sale valueForKey:@"barcode"]];
		if ([sale valueForKey:@"productDescription"] == nil || [[sale valueForKey:@"productDescription"] compare:@"N/A"] == NSOrderedSame || [[sale valueForKey:@"productDescription"] compare:@""] == NSOrderedSame)	{
			[string appendFormat:@"set cell 2 of row %d to \"\%@\"\n", row, [sale valueForKey:@"invoiceDescription"]];
		} else	{
			[string appendFormat:@"set cell 2 of row %d to \"\%@\"\n", row, [sale valueForKey:@"productDescription"]];
		}
		
		[string appendFormat:@"set cell 3 of row %d to %.2f\n", row, [[sale valueForKey:@"salonCost"] floatValue]];
		[string appendFormat:@"set cell 4 of row %d to %d\n", row, [[sale valueForKey:@"inStock"] intValue]];
	}
	
	[string appendString:@"end tell\n\
	 end tell\n\
	 end tell"];
	NSAppleScript * scriptObject = [[NSAppleScript alloc] initWithSource:[NSString stringWithString:string]];
	returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
	[scriptObject release];

	
}
-(IBAction)goToUseBackbarItemWindow:(id)sender
{
	[backBarEntrySearchField setStringValue:@""];
	[backBarEntryBarcodField setStringValue:@""];
	[backBarEntryWindow makeKeyAndOrderFront:self];
}
-(IBAction)recordBackbarUsage:(id)sender
{
	
	
	[backBarEntryWindow close];
	
	// decrement item in inventory by the count
}
-(IBAction)removeEntryFromBackbarTable:(id)sender
{
	[backBarEntryController remove:[backBarEntryController selectedObjects]];
}



@end
