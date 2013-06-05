//
//  JBService.h
//  Harmony
//
//  Created by Jesse Black on 3/10/07.
//  Jesse Black 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface JBService : NSObject <NSCoding> {
	BOOL cut;
	BOOL color;
	BOOL hilights;
	BOOL lowlights;
	BOOL extensions;
	BOOL blowout;
	BOOL flatiron;
	BOOL washAndSet;
	BOOL perm;
	BOOL relaxer;
	BOOL conditioner;
	BOOL twists;
	BOOL braids;
	BOOL male;
	BOOL walkin;
}
-(BOOL)male;
-(void)setMale:(BOOL)newMale;
-(BOOL)walkin;
-(void)setWalkin:(BOOL)newWalkin;

-(BOOL)cut;
-(void)setCut:(BOOL)newCut;
-(BOOL)color;
-(void)setColor:(BOOL)newColor;
-(BOOL)extensions;
-(void)setExtensions:(BOOL)newExtensions;
-(BOOL)hilights;
-(void)setHilights:(BOOL)newHilights;
-(BOOL)lowlights;
-(void)setLowlights:(BOOL)newLowlights;
-(BOOL)blowout;
-(void)setBlowout:(BOOL)newBlowout;
-(BOOL)flatiron;
-(void)setFlatiron:(BOOL)newFlatiron;
-(BOOL)washAndSet;
-(void)setWashAndSet:(BOOL)newWashAndSet;
-(BOOL)relaxer;
-(void)setRelaxer:(BOOL)newRelaxer;
-(BOOL)perm;
-(void)setPerm:(BOOL)newPerm;
-(BOOL)conditioner;
-(void)setConditioner:(BOOL)newConditioner;
-(BOOL)braids;
-(void)setBraids:(BOOL)newBraids;
-(BOOL)twists;
-(void)setTwists:(BOOL)newTwists;




@end
