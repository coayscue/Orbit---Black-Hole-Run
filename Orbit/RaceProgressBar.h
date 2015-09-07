//
//  RaceProgressBar.h
//  Orbit
//
//  Created by Christian Ayscue on 8/20/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface RaceProgressBar : SKSpriteNode

@property CGFloat _nextCheckpointPos;
@property CGFloat _lastCheckpointPos;
@property CGFloat _beforeLastCheckpointPos;
@property int _checkPointNum;

-(instancetype) initWithScreenSize:(CGSize) size;
-(BOOL) adjustProgressBars_nextCheckPoint:(CGFloat)nextCheckP yellowPos:(CGFloat)yellowPos redPos:(CGFloat)redPos mainPos:(CGFloat)mainPos greenPos:(CGFloat)greenPos bluePos:(CGFloat)bluePos;
@end
