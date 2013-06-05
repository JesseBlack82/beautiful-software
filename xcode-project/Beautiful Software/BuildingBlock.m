//
//  BuildingBlock.m
//  Beautiful Software
//
//  Created by Jesse Black on 12/19/08.
//  Copyright 2008 Jesse Black. All rights reserved.
//

#import "BuildingBlock.h"
#import "InterfaceConstants.h"
#import "ClientDatabase.h"
#import "BuildingTextField.h"

@implementation BuildingBlock
@synthesize backgroundColor;
@synthesize pageView;
-(id)appointment
{
	return appointment;
}
-(void)setAppointment:(id)newAppointment
{
	[newAppointment retain];
	[appointment release];
	appointment = newAppointment;

}

-(id)initWithAppointment:(id)aAppointment forPageView:(PageView *)newPageView;
{
	self = [super init];
	self.pageView = newPageView;
	self.backgroundColor = [NSColor whiteColor];
	[self setAppointment:aAppointment];
	return self;
}
-(void)selectBlock
{
	
	int i;
	BOOL isWhite = YES;
	BOOL isBrown = NO;
	BOOL isRed = NO;
	BOOL isOrange = NO;
	if (appointment != nil)	{
		if ([[appointment className] compare:@"NSManagedObject"] == NSOrderedSame)	{
			if ([appointment valueForKey:@"parentAppointment"] == nil)	{
				NSString * vcr = [appointment valueForKey:@"vcr"];
				NSRange range = [vcr rangeOfString:@"v" options:1]; // 1 for case insensitive compare
				if (range.length > 0)	{
					if ([appointment valueForKey:@"checkoutTime"] != nil)	{
						self.backgroundColor = [NSColor brownColor];
						isBrown = YES;
					} else if ([appointment valueForKey:@"checkinTime"] != nil)	{
						self.backgroundColor = [NSColor redColor];
						isRed = YES;

					} else	{
						self.backgroundColor = [NSColor orangeColor];
						isOrange = YES;
					}
					
					isWhite = NO;
				} else if ([appointment valueForKey:@"checkoutTime"] != nil)	{
					self.backgroundColor = [NSColor yellowColor];
					isWhite = NO;
				} else if ([appointment valueForKey:@"checkinTime"] != nil)	{
					self.backgroundColor = [NSColor redColor];
					isRed = YES;
					isWhite = NO;
					
				} 
				
				
				
				
			} else	{
				id parent = [appointment valueForKey:@"parentAppointment"];
				NSString * vcr = [parent valueForKey:@"vcr"];
				NSRange range = [vcr rangeOfString:@"v" options:1]; // 1 for case insensitive compare
				
				if (range.length > 0)	{
					if ([parent valueForKey:@"checkoutTime"] != nil)	{
						self.backgroundColor = [NSColor brownColor];
						isBrown = YES;
					} else if ([parent valueForKey:@"checkinTime"] != nil)	{
						self.backgroundColor = [NSColor redColor];
						isRed = YES;

					} else	{
						self.backgroundColor = [NSColor orangeColor];
						isOrange = YES;
					}
					
					isWhite = NO;
				} else if ([parent valueForKey:@"checkoutTime"] != nil)	{
					self.backgroundColor = [NSColor yellowColor];
					isWhite = NO;
				} else if ([parent valueForKey:@"checkinTime"] != nil)	{
					self.backgroundColor = [NSColor redColor];
					isWhite = NO;
					isRed = YES;
					
				} 
				
			}
		}
	}
	
	if (isWhite)	{
		self.backgroundColor = [NSColor keyboardFocusIndicatorColor];
	}
	
	
	NSArray * mySubviews = [self subviews];
	for (i=0; i < [mySubviews count]; i++)	{
		[[mySubviews objectAtIndex:i] setBackgroundColor:backgroundColor];
		if (!isWhite)	{
			if (isBrown || isRed || isOrange)	{
				[[mySubviews objectAtIndex:i] setTextColor:[NSColor whiteColor]];				
			}
			else	{
				[[mySubviews objectAtIndex:i] setTextColor:[NSColor redColor]];
			}
			
			
		}
	}
	[self setSubviews:mySubviews];
	[self setNeedsDisplay:YES];
}
-(void)unselectBlock
{
	int i;
	BOOL isWhite = YES;
	if (appointment != nil)	{
		if ([[appointment className] compare:@"NSManagedObject"] == NSOrderedSame)	{
			if ([appointment valueForKey:@"parentAppointment"] == nil)	{
				NSString * vcr = [appointment valueForKey:@"vcr"];
				NSRange range = [vcr rangeOfString:@"v" options:1]; // 1 for case insensitive compare
				if (range.length > 0)	{
					if ([appointment valueForKey:@"checkoutTime"] != nil)	{
						self.backgroundColor = [NSColor brownColor];
					} else if ([appointment valueForKey:@"checkinTime"] != nil)	{
						self.backgroundColor = [NSColor redColor];
					} else	{
						self.backgroundColor = [NSColor orangeColor];
					}
					
					isWhite = NO;
				} else if ([appointment valueForKey:@"checkoutTime"] != nil)	{
					self.backgroundColor = [NSColor yellowColor];
					isWhite = NO;
				} else if ([appointment valueForKey:@"checkinTime"] != nil)	{
					self.backgroundColor = [NSColor redColor];
					isWhite = NO;
					
				}  else if ([appointment valueForKey:@"dateBooked"] != nil)	{
					self.backgroundColor = [NSColor controlShadowColor];
					isWhite = NO;
				}
				
				
				
				
			} else	{
				id parent = [appointment valueForKey:@"parentAppointment"];
				NSString * vcr = [parent valueForKey:@"vcr"];
				NSRange range = [vcr rangeOfString:@"v" options:1]; // 1 for case insensitive compare
				
				if (range.length > 0)	{
					if ([parent valueForKey:@"checkoutTime"] != nil)	{
						self.backgroundColor = [NSColor brownColor];
					} else if ([parent valueForKey:@"checkinTime"] != nil)	{
						self.backgroundColor = [NSColor redColor];
					} else	{
						self.backgroundColor = [NSColor orangeColor];
					}
					
					isWhite = NO;
				} else if ([parent valueForKey:@"checkoutTime"] != nil)	{
					self.backgroundColor = [NSColor yellowColor];
					isWhite = NO;
				} else if ([parent valueForKey:@"checkinTime"] != nil)	{
					self.backgroundColor = [NSColor redColor];
					isWhite = NO;
					
				}  else if ([parent valueForKey:@"dateBooked"] != nil)	{
					self.backgroundColor = [NSColor controlShadowColor];
					isWhite = NO;
				}
						
			}
		}
	}
	
	if (isWhite)	{
		self.backgroundColor = [NSColor whiteColor];	
	}
	NSArray * mySubviews = [self subviews];
	for (i=0; i < [mySubviews count]; i++)	{
		[[mySubviews objectAtIndex:i] setBackgroundColor:backgroundColor];
		[[mySubviews objectAtIndex:i] setTextColor:[NSColor blackColor]];
	
	}
	[self setSubviews:mySubviews];
	[self setNeedsDisplay:YES];
}
-(void)setSubviewAlphaValue:(float)alpha
{
	NSArray * mySubviews = [self subviews];
	int i;
	for (i=0; i<[mySubviews count]; i++)	{
		[[mySubviews objectAtIndex:i] setAlphaValue:alpha];
	}
}
-(void)drawRect:(NSRect)aRect
{
	
	[backgroundColor setFill]; 
		
	[NSBezierPath fillRect:aRect];
	
	[super drawRect:aRect];

	[[NSColor blackColor] setStroke];
	NSRect strokeRect = [self bounds];
	NSBezierPath * rectPath = [NSBezierPath bezierPathWithRect:strokeRect];
	[rectPath setLineWidth:1];
	
	[rectPath stroke];
	[backgroundColor setStroke];
	
}
-(BOOL)hasHit:(NSView *)hit
{
	if (hit == self)	{
		return YES;
	} 
	int i;
	NSArray * mySubviews = [self subviews];
	for (i=0; i < [mySubviews count]; i++)	{
		if ([mySubviews objectAtIndex:i] == hit)	{
			return YES;
		}
	}
	return NO;
}
-(void)updateDisplay
{
	
	// forget myTextFields, give each textField a tag, and use the subviews for building block.........
	int i;
	NSMutableArray * mySubviews = [NSMutableArray arrayWithArray:[self subviews]];
	int copiesInt;
	if ([mySubviews count] == 0)	{
	 	// find out how many fit,
		float maxHeight = [self frame].size.height;
		float maxWidth = [self frame].size.width;
		float copies = maxHeight / TEXTFIELDHEIGHT;
		copiesInt = copies;

		for (i = 0; i < copiesInt; i++)	{
			NSTextField * textField = [[BuildingTextField alloc] initWithBuildingBlock:self];
			[textField setBordered:NO];
			[[textField cell] setWraps:NO];
			[textField setSelectable:NO];
			[textField setEditable:NO];
			[textField setAlignment:NSCenterTextAlignment];
			[textField setTag:i];
			
			NSRect frame = [textField frame];
			frame.size.width = maxWidth-2;
			frame.size.height = TEXTFIELDHEIGHT;
			frame.origin.x = 1;
			frame.origin.y = maxHeight - (TEXTFIELDHEIGHT * (i+1));
			[textField setFrame:frame];
			[mySubviews addObject:textField];
			[textField release];
		}
		
	} else	{
		// do more fit???
		
		
		
	}
	
	for (i=0 ; i < [mySubviews count]; i++)	{
		[[mySubviews objectAtIndex:i] setStringValue:@""];
	}
	NSManagedObject * client = [appointment valueForKey:@"client"];
	int counter = 0;
	if (client != nil)	{
		if ([appointment valueForKeyPath:@"client.name"] == nil)	{
			[client setValue:@"Shouldn't be blank" forKey:@"name"];
		}
		if ([mySubviews count] > counter)	{
			[[mySubviews objectAtIndex:counter] setStringValue:[appointment valueForKeyPath:@"client.name"]];
			counter++;
		}
	}
	int test = counter+1;
	if ([mySubviews count] >= test)	{
		if ([mySubviews count] > counter)	{
			NSCalendarDate * time = [[appointment valueForKey:@"time"] dateWithCalendarFormat:@"%I:%M %p" timeZone:nil];
			[[mySubviews objectAtIndex:counter] setStringValue:[time description]];
			counter++;
		}
	}
	
	
	BOOL isWhite = YES;
	if (appointment != nil)	{
		if ([[appointment className] compare:@"NSManagedObject"] == NSOrderedSame)	{
			if ([appointment valueForKey:@"parentAppointment"] == nil)	{
				NSString * vcr = [appointment valueForKey:@"vcr"];
				NSRange range = [vcr rangeOfString:@"v" options:1]; // 1 for case insensitive compare
				if (range.length > 0)	{
					if ([appointment valueForKey:@"checkoutTime"] != nil)	{
						self.backgroundColor = [NSColor brownColor];
					} else if ([appointment valueForKey:@"checkinTime"] != nil)	{
						self.backgroundColor = [NSColor redColor];
					} else	{
						self.backgroundColor = [NSColor orangeColor];
					}
					isWhite = NO;
				} else if ([appointment valueForKey:@"checkoutTime"] != nil)	{
					self.backgroundColor = [NSColor yellowColor];
					isWhite = NO;
				} else if ([appointment valueForKey:@"checkinTime"] != nil)	{
					self.backgroundColor = [NSColor redColor];
					isWhite = NO;
					
				} else if ([appointment valueForKey:@"dateBooked"] != nil)	{
					
					self.backgroundColor = [NSColor controlShadowColor];
					isWhite = NO;
				}
				
				
				
				
			} else	{
				id parent = [appointment valueForKey:@"parentAppointment"];
				NSString * vcr = [parent valueForKey:@"vcr"];
				NSRange range = [vcr rangeOfString:@"v" options:1]; // 1 for case insensitive compare
				
				if (range.length > 0)	{
					if ([parent valueForKey:@"checkoutTime"] != nil)	{
						self.backgroundColor = [NSColor brownColor];
					} else if ([parent valueForKey:@"checkinTime"] != nil)	{
						self.backgroundColor = [NSColor redColor];
					} else	{
						self.backgroundColor = [NSColor orangeColor];
					}
					isWhite = NO;
				} else if ([parent valueForKey:@"checkoutTime"] != nil)	{
					self.backgroundColor = [NSColor yellowColor];
					isWhite = NO;
				} else if ([parent valueForKey:@"checkinTime"] != nil)	{
					self.backgroundColor = [NSColor redColor];
					isWhite = NO;
					
				} else if ([parent valueForKey:@"dateBooked"] != nil)	{
					self.backgroundColor = [NSColor controlShadowColor];
					isWhite = NO;
				}
				
				
			}
		}
	}
	
	if (isWhite)	{
		self.backgroundColor = [NSColor whiteColor];
	} 
	for (i=0 ; i < [mySubviews count]; i++)	{
		[[mySubviews objectAtIndex:i] setBackgroundColor:backgroundColor];
	}

	[self setNeedsDisplay:YES];
	[self setSubviews:mySubviews];
	
}
-(IBAction)neverConfirmForThisClient:(id)sender
{
	
}
-(void)goToMakeEditAppointmentAction:(id)sender
{
	[pageView goToMakeEditAppointmentAction:sender];
}
-(NSMenu *)menuForEvent:(NSEvent *)event
{
	NSMenu * aMenu = [NSMenu new];
	NSMenuItem * mI;
	
	mI = [[NSMenuItem alloc] initWithTitle:@"Check Out Appointment" action:@selector(checkOutSelectedAppointment) keyEquivalent:@"c"];
	

	
	
	[aMenu addItem:mI];
	[mI autorelease];
	
	mI = [[NSMenuItem alloc] initWithTitle:@"Client History" action:@selector(viewClientHistory) keyEquivalent:@"h"];
	
	
	
	[aMenu addItem:mI];
	[mI autorelease];
	
	mI = [[NSMenuItem alloc] initWithTitle:@"Make/Edit Appointment" action:@selector(goToMakeEditAppointmentAction:) keyEquivalent:@"m"];
	[mI setTarget:pageView];
	
	[aMenu addItem:mI];
	[mI autorelease];
	
	
	[pageView selectBlock:self];
	return aMenu;
}

@end