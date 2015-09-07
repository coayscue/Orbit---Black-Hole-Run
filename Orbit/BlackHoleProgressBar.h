//
//  BlackHoleProgressBar.h
//  Orbit
//
//  Created by Christian Ayscue on 8/28/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BlackHoleProgressBar : SKSpriteNode

-(instancetype) initWithScreenSize:(CGSize) size _recordPos:(CGFloat)recordPos;

-(void) resizeWithScreenSize:(CGSize) size;

-(void)adjustBlackHoleProgressBar_mainShipPos:(CGPoint)mainShipPos _blackHolePos:(CGPoint)blackHolePos;

-(void) killShip;

@end
