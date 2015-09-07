//
//  BlackHoleProgressBar.m
//  Orbit
//
//  Created by Christian Ayscue on 8/28/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

#import "BlackHoleProgressBar.h"

@implementation BlackHoleProgressBar
{
    SKSpriteNode *_blackHoleTrail;
    SKSpriteNode *_ship;
    SKSpriteNode *_blackHole;
    SKSpriteNode *_recordMark;
    CGFloat _recordPos;
}

-(instancetype)initWithScreenSize:(CGSize) size _recordPos:(CGFloat)recordPos
{
    if(self = [super initWithTexture:[SKTexture textureWithImageNamed:@"status_bar2"]])
    {
        self.size = CGSizeMake(size.width*0.09, size.height*0.923-size.width*0.01);
        
        self.anchorPoint = CGPointZero;
        self.position = CGPointMake(size.width*0.01, size.width*0.01);
        self.zPosition = 150;
        
        _recordPos = recordPos;
        
        _blackHoleTrail = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"black_hole_pbar_trail"]];
        _blackHoleTrail.anchorPoint = CGPointMake(0.5, 0.0);
        _blackHoleTrail.position = CGPointMake(self.size.width/2, self.size.height*0.04);
        _blackHoleTrail.size = CGSizeMake(self.size.width*0.767, 0);
        _ship = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"main_ship_outlined"] size:CGSizeMake(self.size.width*0.55, self.size.width)];
        _ship.anchorPoint = CGPointMake(0.5, 0.85);
        _blackHole = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"black_hole_outlined"] size:CGSizeMake(self.size.width*0.767, self.size.width*0.55)];
        _blackHole.position = CGPointMake(self.size.width/2, self.size.height*0.04 + _blackHoleTrail.size.height);
        _recordMark = [SKSpriteNode spriteNodeWithImageNamed:@"record_mark"];
        _recordMark.size = CGSizeMake(self.size.width*0.767, 8);
        _recordMark.anchorPoint = CGPointMake(0.5, 0);
        _recordMark.position = CGPointMake(self.size.width/2, self.size.height*0.92);
        
        [self addChild:_blackHoleTrail];
        [self addChild:_blackHole];
        [self addChild:_recordMark];
        [self addChild:_ship];
        
    }
    return self;
}

-(void) resizeWithScreenSize:(CGSize)size
{
    self.size = CGSizeMake(size.width*0.09, size.height*0.923-size.width*0.01);
    
    _blackHoleTrail.position = CGPointMake(self.size.width/2, self.size.height*0.04);
    _recordMark.position = CGPointMake(self.size.width/2, self.size.height*0.92);
}

-(void)adjustBlackHoleProgressBar_mainShipPos:(CGPoint)mainShipPos _blackHolePos:(CGPoint)blackHolePos
{
    
    float distanceBetween = (mainShipPos.y - blackHolePos.y)/1000*(self.size.height*0.5);

    if (mainShipPos.y/_recordPos <= 1){
    _ship.position = CGPointMake(self.size.width/2, self.size.height*0.4+0.52*self.size.height*(mainShipPos.y/_recordPos));
    }else if(mainShipPos.y/_recordPos > 1){
        _recordMark.position = CGPointMake(self.size.width/2, self.size.height*0.92-0.52*self.size.height*(mainShipPos.y/_recordPos-1));
        _recordMark.alpha = (_recordMark.position.y - self.size.height*0.7)/(self.size.height*0.22);
        if (_recordMark.alpha < 0)
            [_recordMark removeFromParent];
                                           
    }
    
    if (_ship.position.y-_ship.size.height - distanceBetween > 0)
    {
        _blackHoleTrail.size = CGSizeMake(self.size.width*0.767, _ship.position.y-_ship.size.height - distanceBetween + self.size.height*0.01);
        _blackHole.position = CGPointMake(self.size.width/2, self.size.height*0.04 + _blackHoleTrail.size.height);
    }

}
-(void) killShip
{
    [_ship runAction:[SKAction fadeAlphaTo:0 duration:1]];
}

@end
