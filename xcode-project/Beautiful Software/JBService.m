//
//  JBService.m
//  Harmony
//
//  Created by Jesse Black on 3/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "JBService.h"


@implementation JBService
-(id)init
{
	cut = NO;
	color = NO;
	hilights = NO;
	lowlights = NO;
	extensions = NO;
	blowout = NO;
	flatiron = NO;
	washAndSet = NO;
	relaxer = NO;
	perm = NO;
	conditioner = NO;
	braids = NO;
	twists = NO;
	male = NO;
	walkin = NO;
	return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeBool:male forKey:@"male"];
	[encoder encodeBool:walkin forKey:@"walkin"];
	[encoder encodeBool:cut forKey:@"cut"];
	[encoder encodeBool:color forKey:@"color"];
	[encoder encodeBool:hilights forKey:@"hilights"];
	[encoder encodeBool:lowlights forKey:@"lowlights"];
	[encoder encodeBool:extensions forKey:@"extensions"];
	[encoder encodeBool:blowout forKey:@"blowout"];
	[encoder encodeBool:flatiron forKey:@"flatiron"];
	[encoder encodeBool:washAndSet forKey:@"washAndSet"];
	[encoder encodeBool:relaxer forKey:@"relaxer"];
	[encoder encodeBool:perm forKey:@"perm"];
	[encoder encodeBool:conditioner forKey:@"conditioner"];
	[encoder encodeBool:braids forKey:@"braids"];
	[encoder encodeBool:twists forKey:@"twists"];	
}
-(id)initWithCoder:(NSCoder *)decoder
{
	[self setMale:[decoder decodeBoolForKey:@"male"]];
	[self setWalkin:[decoder decodeBoolForKey:@"walkin"]];
	[self setCut:[decoder decodeBoolForKey:@"cut"]];
	[self setColor:[decoder decodeBoolForKey:@"color"]];
	[self setHilights:[decoder decodeBoolForKey:@"hilights"]];
	[self setLowlights:[decoder decodeBoolForKey:@"lowlights"]];
	[self setExtensions:[decoder decodeBoolForKey:@"extensions"]];
	[self setBlowout:[decoder decodeBoolForKey:@"blowout"]];
	[self setFlatiron:[decoder decodeBoolForKey:@"flatiron"]];
	[self setWashAndSet:[decoder decodeBoolForKey:@"washAndSet"]];
	[self setRelaxer:[decoder decodeBoolForKey:@"relaxer"]];
	[self setPerm:[decoder decodeBoolForKey:@"perm"]];
	[self setConditioner:[decoder decodeBoolForKey:@"conditioner"]];
	[self setBraids:[decoder decodeBoolForKey:@"braids"]];
	[self setTwists:[decoder decodeBoolForKey:@"twists"]];
	return self;
}
-(BOOL)male
{
	return male;
}
-(void)setMale:(BOOL)newMale
{
	male = newMale;
}
-(BOOL)walkin
{
	return walkin;
}
-(void)setWalkin:(BOOL)newWalkin
{
	walkin = newWalkin;
}
-(BOOL)cut
{
	return cut;
}
-(void)setCut:(BOOL)newCut
{
	cut = newCut;
}
-(BOOL)color
{
	return color;
}
-(void)setColor:(BOOL)newColor
{
	color = newColor;
}
-(BOOL)extensions
{
	return extensions;
}
-(void)setExtensions:(BOOL)newExtensions
{
	extensions = newExtensions;
}
-(BOOL)hilights
{
	return hilights;
}
-(void)setHilights:(BOOL)newHilights
{
	hilights = newHilights;
}
-(BOOL)lowlights
{
	return lowlights;
}
-(void)setLowlights:(BOOL)newLowlights
{
	lowlights = newLowlights;
}
-(BOOL)blowout
{
	return blowout;
}
-(void)setBlowout:(BOOL)newBlowout
{
	blowout = newBlowout;
}
-(BOOL)flatiron
{
	return flatiron;
}
-(void)setFlatiron:(BOOL)newFlatiron
{
	flatiron = newFlatiron;
}
-(BOOL)washAndSet
{
	return washAndSet;
}
-(void)setWashAndSet:(BOOL)newWashAndSet
{
	washAndSet = newWashAndSet;
}
-(BOOL)relaxer
{
	return relaxer;
}
-(void)setRelaxer:(BOOL)newRelaxer
{
	relaxer = newRelaxer;
}
-(BOOL)perm
{
	return perm;
}
-(void)setPerm:(BOOL)newPerm
{
	perm = newPerm;
}
-(BOOL)conditioner
{
	return conditioner;
}
-(void)setConditioner:(BOOL)newConditioner
{
	conditioner = newConditioner;
}
-(BOOL)braids
{
	return braids;
}
-(void)setBraids:(BOOL)newBraids
{
	braids = newBraids;
}
-(BOOL)twists
{
	return twists;
}
-(void)setTwists:(BOOL)newTwists
{
	twists = newTwists;
}

@end
