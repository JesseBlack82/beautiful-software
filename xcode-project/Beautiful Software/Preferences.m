//
//  Preferences.m
//  Beautiful Software
//
//  Created by Jesse Black on 2/3/10.
//  Copyright 2010 Jesse Black. All rights reserved.
//

#import "Preferences.h"


@implementation Preferences


-(IBAction)openPreferencesWindow:(id)sender
{
	NSMutableString * ppath = [NSMutableString string];
	[ppath setString:[appDelegate applicationSupportFolder]];
	[ppath appendString:@"/Preferences"];
	
	NSMutableDictionary * preferences = [NSKeyedUnarchiver unarchiveObjectWithFile:ppath];
	if (preferences != nil)	{
		if ([[preferences valueForKey:@"phoneFormat"] compare:@"phoneDash"] == NSOrderedSame)	{
			[phoneDash setState:1];
			[phoneSpaces setState:0];
			[phoneNoSpaces setState:0];
			[phoneNoFormat setState:0];
		}
		if ([[preferences valueForKey:@"phoneFormat"] compare:@"phoneSpaces"] == NSOrderedSame)	{
			[phoneDash setState:0];
			[phoneSpaces setState:1];
			[phoneNoSpaces setState:0];
			[phoneNoFormat setState:0];
		}
		if ([[preferences valueForKey:@"phoneFormat"] compare:@"phoneNoSpaces"] == NSOrderedSame)	{
			[phoneDash setState:0];
			[phoneSpaces setState:0];
			[phoneNoSpaces setState:1];
			[phoneNoFormat setState:0];
		}
		if ([[preferences valueForKey:@"phoneFormat"] compare:@"phoneNoFormat"] == NSOrderedSame)	{
			[phoneDash setState:0];
			[phoneSpaces setState:0];
			[phoneNoSpaces setState:0];
			[phoneNoFormat setState:1];
		}
		if ([preferences valueForKey:@"emailSender"] != nil)	{
			[emailSenderField setStringValue:[preferences valueForKey:@"emailSender"]];
		} if ([preferences valueForKey:@"collectEmail"] == nil)	{
			[reminderToCollectEmail setState:0];
		} else {
			[reminderToCollectEmail setState:1];
		}

			  
			 
	}
	[preferencesWindow makeKeyAndOrderFront:self];
}
-(IBAction)phonePreferenceChecked:(id)sender
{
	if (phoneDash != sender)	{
		[phoneDash setState:0];
	}
	if (phoneSpaces != sender)	{
		[phoneSpaces setState:0];
	}
	if (phoneNoSpaces != sender)	{
		[phoneNoSpaces setState:0];
	}
	if (phoneNoFormat != sender)	{
		[phoneNoFormat setState:0];
	}
	if ([sender state] == 0)	{
		[phoneNoFormat setState:1];
	}
	
}

-(IBAction)applyChangesTaxAndPhoneFormat:(id)sender
{
	NSMutableDictionary * preferenceEntry = [NSMutableDictionary dictionary];
	if ([phoneDash state] == 1)	{
		[preferenceEntry setObject:@"phoneDash" forKey:@"phoneFormat"];
	} else if ([phoneSpaces state] == 1)	{
		[preferenceEntry setObject:@"phoneSpaces" forKey:@"phoneFormat"];
	} else if ([phoneNoSpaces state] == 1)	{
		[preferenceEntry setObject:@"phoneNoSpaces" forKey:@"phoneFormat"];
	} else if ([phoneNoFormat state] == 1)	{
		[preferenceEntry setObject:@"phoneNoFormat" forKey:@"phoneFormat"];
	} 
	
	if ([emailSenderField stringValue] != nil)	{
		[preferenceEntry setObject:[emailSenderField stringValue] forKey:@"emailSender"];
	}
	
	if ([reminderToCollectEmail state] == 1)	{
		[preferenceEntry setObject:[NSNumber numberWithBool:1] forKey:@"collectEmail"];
	}
	
	NSMutableString * ppath = [NSMutableString string];
	[ppath setString:[appDelegate applicationSupportFolder]];
	[ppath appendString:@"/Preferences"];
	[NSKeyedArchiver archiveRootObject:preferenceEntry toFile:ppath];
				
	[preferencesWindow close];
}
@end
