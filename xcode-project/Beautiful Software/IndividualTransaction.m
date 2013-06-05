//
//  IndividualTransaction.m
//  Beautiful Software
//
//  Created by Jesse Black on 1/14/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import "IndividualTransaction.h"
#import "InterfaceConstants.h"
#import "TaxConstants.h"
#import "RetailController.h"
#import "TransactionController.h"

@implementation IndividualTransaction
/*
-(void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	id object = [aNotification object];
	if ([priceFields containsObject:object])	{
		[self updateServiceTotal];
	} else {
		if ([[object className] compare:@"NSTableView"] == NSOrderedSame)	{
			[self updateRetailCart];
		}
	}
	
	
}

-(NSMutableArray *)searchForProductDescription:(NSString *)productDescription
{
	NSMutableArray * results = [NSMutableArray array];
	NSFetchRequest * retailMenuRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * retailDescription = [NSEntityDescription entityForName:@"InventoryItem" inManagedObjectContext:moc];
	[retailMenuRequest setEntity:retailDescription];
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"productDescription contains [cd] %@ && entity.name like %@", productDescription, @"InventoryItem"];

	// next line would allow all retail items sold to pop up in the list
	//	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"productDescription contains [cd] %@", productDescription];
	[retailMenuRequest setPredicate:predicate];
	[results addObjectsFromArray:[moc executeFetchRequest:retailMenuRequest error:&error]];
	NSLog(@"executing Fetch");
	return results;
}
*/
@end
