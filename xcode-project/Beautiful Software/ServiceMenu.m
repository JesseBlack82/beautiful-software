//
//  ServiceMenu.m
//  Beautiful Software
//
//  Created by Jesse Black on 1/3/09.
//  Copyright 2009 Jesse Black. All rights reserved.
//

#import "ServiceMenu.h"
#import "PasswordController.h"
#import "PasswordConstants.h"

@implementation ServiceMenu
@synthesize passwordLevelsPath;

-(void)awakeFromNib
{
	NSMutableString * ppath = [NSMutableString stringWithString:[appDelegate applicationSupportFolder]];
	[ppath appendString:@"/passwordLevelsPath"];
	[self setPasswordLevelsPath:ppath];
 	moc = [appDelegate managedObjectContext];
	[self test];
}
-(void)test
{
	NSFetchRequest * menuRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * menuDescription = [NSEntityDescription entityForName:@"ServiceMenuItem" inManagedObjectContext:moc];
	[menuRequest setEntity:menuDescription];
	NSArray * results = [moc executeFetchRequest:menuRequest error:&error];
	NSLog(@"executing Fetch service menu item");
	if ([results count] == 0)	{
		NSManagedObject * newService = [NSEntityDescription insertNewObjectForEntityForName:@"ServiceMenuItem" inManagedObjectContext:moc];
		[newService setValue:@"Haircut" forKey:@"serviceDescription"];
		[newService setValue:[NSNumber numberWithBool:0] forKey:@"isChemicalService"];
		[newService setValue:[NSNumber numberWithBool:0] forKey:@"listOrder"];
		[newService setValue:[NSNumber numberWithInt:0] forKey:@"price"];
		
		newService = newService = [NSEntityDescription insertNewObjectForEntityForName:@"ServiceMenuItem" inManagedObjectContext:moc];
		[newService setValue:@"Color" forKey:@"serviceDescription"];
		[newService setValue:[NSNumber numberWithBool:1] forKey:@"isChemicalService"];
		[newService setValue:[NSNumber numberWithBool:1] forKey:@"listOrder"];
		[newService setValue:[NSNumber numberWithInt:0] forKey:@"price"];
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	}
	
}
-(IBAction)goToServiceMenuAction:(id)sender
{
	editMode = NO;
	[self goToServiceMenu:nil];
}
-(IBAction)goToServiceMenuEditMode:(id)sender
{
	SEL selector = @selector(goToServiceMenu:);
	[passwordController getPasswordFor:self arguments:nil selector:selector];
}
-(void)goToServiceMenu:(NSManagedObject *)password
{
	if ([password valueForKey:@"passwordLevel"] != nil)	{
		int passwordLevel = [[password valueForKey:@"passwordLevel"] intValue];
		id test = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordLevelsPath];
		
		if (passwordLevel >= [[test valueForKey:@"editServiceMenuLevel"] intValue] )	{
			editMode = YES;
		}
	}
	[self loadServices];
	[serviceMenuWindow makeKeyAndOrderFront:self];
}
-(void)loadServices
{
	NSFetchRequest * menuRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription * menuDescription = [NSEntityDescription entityForName:@"ServiceMenuItem" inManagedObjectContext:moc];
	NSSortDescriptor * listOrderDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"listOrder" ascending:YES] autorelease];
	[menuRequest setSortDescriptors:[NSArray arrayWithObject:listOrderDescriptor]];
	[menuRequest setEntity:menuDescription];
	NSMutableArray * results = [NSMutableArray arrayWithArray:[moc executeFetchRequest:menuRequest error:&error]];
	NSLog(@"executing Fetch service menu item");
	[serviceController setContent:results];
	
}
-(void)controlTextDidChange:(NSNotification *)aNotification
{
	error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
}
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if (editMode)	{
		return YES;
	}
	return NO;
}
-(IBAction)addNewService:(id)sender
{
	if (editMode)	{
		NSEntityDescription * newService = [NSEntityDescription insertNewObjectForEntityForName:@"ServiceMenuItem" inManagedObjectContext:moc];
		[newService setValue:[NSNumber numberWithInt:0] forKey:@"isChemicalService"];
		[newService setValue:[NSNumber numberWithInt:0] forKey:@"price"];
		[newService setValue:@"New Service" forKey:@"serviceDescription"];
		[serviceController addObject:newService];
		[self adjustServiceListOrder];
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
	}
}
-(IBAction)removeService:(id)sender
{
	if (editMode)	{
		int selectionIndex = [serviceController selectionIndex];
		NSManagedObject * selectedService = [[serviceController selectedObjects] objectAtIndex:0];
		[moc deleteObject:selectedService];
		error = nil; [moc save:&error]; NSLog(@"moc saving"); if (error) { NSRunAlertPanel(@"could not save last action", @"please quit and relaunch", @"ok", nil,nil);}
		[self loadServices];
		[serviceController setSelectionIndex:selectionIndex-1];
		[self adjustServiceListOrder];

		
		
	}
}
-(void)adjustServiceListOrder
{
	int i;
	NSArray * services = [serviceController content];
	for (i= 0; i<[services count]; i++)	{
		[[services objectAtIndex:i] setValue:[NSNumber numberWithInt:i] forKey:@"listOrder"];
	}

}

@end
