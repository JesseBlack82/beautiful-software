//
//  BuildingTextField.m
//  Beautiful Software
//
//  Created by Jesse Black on 4/6/10.
//  Copyright 2010 Jesse Black. All rights reserved.
//

#import "BuildingTextField.h"


@implementation BuildingTextField

@synthesize buildingBlock;
-(id)initWithBuildingBlock:(BuildingBlock *)newBuildingBlock
{
	self = [super init];
	self.buildingBlock = newBuildingBlock;
	return self;
}



-(NSMenu *)menuForEvent:(NSEvent *)event
{
	NSMenu * aMenu = [NSMenu new];
	NSMenuItem * mI;
	
	mI = [[NSMenuItem alloc] initWithTitle:@"Check Out Appointment" action:@selector(checkOutSelectedAppointment) keyEquivalent:@"c"];
	
	
	
	[aMenu addItem:mI];
	[mI autorelease];
	
	mI = [[NSMenuItem alloc] initWithTitle:@"Client History" action:@selector(viewClientHistory) keyEquivalent:@"h"];
	
	[mI setTarget:[buildingBlock pageView]];
	
	
	[aMenu addItem:mI];
	[mI autorelease];
	mI = [[NSMenuItem alloc] initWithTitle:@"Make/Edit Appointment" action:@selector(goToMakeEditAppointmentAction:) keyEquivalent:@"m"];
	
	
	
	[aMenu addItem:mI];
	[mI autorelease];
	
	
	
	[[buildingBlock pageView] selectBlock:buildingBlock];
	
	
	
	return aMenu;
	
}


@end
