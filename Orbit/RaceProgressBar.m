//
//  ProgressBar.m
//  Orbit
//
//  Created by Christian Ayscue on 8/20/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

#import "RaceProgressBar.h"

@implementation RaceProgressBar
{
    SKSpriteNode *_baseWhiteBar;
    SKSpriteNode *_topWhiteBar;
    SKSpriteNode *_moveWhiteBar1;
    SKSpriteNode *_moveWhiteBar2;
    SKSpriteNode *_mainshipTip;
    SKSpriteNode *_mainshipBar;
    SKSpriteNode *_yellowshipTip;
    SKSpriteNode *_yellowshipBar;
    SKSpriteNode *_redshipTip;
    SKSpriteNode *_redshipBar;
    SKSpriteNode *_greenshipTip;
    SKSpriteNode *_greenshipBar;
    SKSpriteNode *_blueshipTip;
    SKSpriteNode *_blueshipBar;
    BOOL _scaleActionComplete;
}

@synthesize _nextCheckpointPos;
@synthesize _lastCheckpointPos;
@synthesize _beforeLastCheckpointPos;
@synthesize _checkPointNum;


-(instancetype) initWithScreenSize:(CGSize)size
{
    if (self = [super initWithTexture:[SKTexture textureWithImageNamed:@"progress_bar"]])
    {
        
        self.size = CGSizeMake(30, size.height-41);

        self.anchorPoint = CGPointZero;
        self.position = CGPointMake(2, 2);
        _scaleActionComplete = YES;
        _checkPointNum = 0;
        
        CGSize shipBarStartSize = CGSizeMake(2, 20);

        _yellowshipBar = [SKSpriteNode spriteNodeWithImageNamed:@"status_bar"];
        _yellowshipBar.color = [SKColor yellowColor];
        _yellowshipBar.colorBlendFactor = 1;
        _yellowshipBar.anchorPoint = CGPointMake(0.5, 0);
        _yellowshipBar.size = shipBarStartSize;
        _yellowshipBar.position = CGPointMake(5, 0.1*self.size.height);
        [self addChild:_yellowshipBar];
        _yellowshipTip = [SKSpriteNode spriteNodeWithImageNamed:@"status_bar_tip"];
        _yellowshipTip.size = CGSizeMake(4, 5);
        _yellowshipTip.position = CGPointMake(_yellowshipBar.position.x, _yellowshipBar.size.height+_yellowshipBar.position.y);
        _yellowshipTip.color = _yellowshipBar.color;
        _yellowshipTip.colorBlendFactor = 1;
        [self addChild:_yellowshipTip];
        
        //make the same changes as done above
        //make changes to adjustprogressbar method to position the tip with respect to the bar's position and height
        
        _redshipBar = [SKSpriteNode spriteNodeWithImageNamed:@"status_bar"];
        _redshipBar.color = [SKColor redColor];
        _redshipBar.colorBlendFactor = 1;
        _redshipBar.size = shipBarStartSize;
        _redshipBar.anchorPoint = CGPointMake(0.5, 0);
        _redshipBar.position = CGPointMake(10, 0.1*self.size.height);
        [self addChild:_redshipBar];
        _redshipTip = [SKSpriteNode spriteNodeWithImageNamed:@"status_bar_tip"];
        _redshipTip.size = CGSizeMake(4, 5);
        _redshipTip.position = CGPointMake(_redshipBar.position.x, _redshipBar.size.height+_redshipBar.position.y);
        _redshipTip.color = _redshipBar.color;
        _redshipTip.colorBlendFactor = 1;
        [self addChild:_redshipTip];

        
        _mainshipBar = [SKSpriteNode spriteNodeWithImageNamed:@"status_bar"];
        _mainshipBar.size = shipBarStartSize;
        _mainshipBar.anchorPoint = CGPointMake(0.5, 0);
        _mainshipBar.position = CGPointMake(15, 0.1*self.size.height);
        [self addChild:_mainshipBar];
        _mainshipTip = [SKSpriteNode spriteNodeWithImageNamed:@"status_bar_tip"];
        _mainshipTip.size = CGSizeMake(4, 5);
        _mainshipTip.position = CGPointMake(_mainshipBar.position.x, _mainshipBar.size.height+_mainshipBar.position.y);
        //_mainshipTip.color = _mainshipBar.color;
        //_mainshipTip.colorBlendFactor = 1;
        [self addChild:_mainshipTip];
        
        _greenshipBar = [SKSpriteNode spriteNodeWithImageNamed:@"status_bar"];
        _greenshipBar.size = shipBarStartSize;
        _greenshipBar.color = [SKColor greenColor];
        _greenshipBar.colorBlendFactor = 1;
        _greenshipBar.anchorPoint = CGPointMake(0.5, 0);
        _greenshipBar.position = CGPointMake(20, 0.1*self.size.height);
        [self addChild:_greenshipBar];
        _greenshipTip = [SKSpriteNode spriteNodeWithImageNamed:@"status_bar_tip"];
        _greenshipTip.size = CGSizeMake(4, 5);
        _greenshipTip.position = CGPointMake(_greenshipBar.position.x, _greenshipBar.size.height+_greenshipBar.position.y);
        _greenshipTip.color = _greenshipBar.color;
        _greenshipTip.colorBlendFactor = 1;
        [self addChild:_greenshipTip];
        
        _blueshipBar= [SKSpriteNode spriteNodeWithImageNamed:@"status_bar"];
        _blueshipBar.color = [SKColor blueColor];
        _blueshipBar.colorBlendFactor = 1;
        _blueshipBar.size = shipBarStartSize;
        _blueshipBar.anchorPoint = CGPointMake(0.5, 0);
        _blueshipBar.position = CGPointMake(25, 0.1*self.size.height);
        [self addChild:_blueshipBar];
        _blueshipTip = [SKSpriteNode spriteNodeWithImageNamed:@"status_bar_tip"];
        _blueshipTip.size = CGSizeMake(4, 5);
        _blueshipTip.position = CGPointMake(_blueshipBar.position.x, _blueshipBar.size.height+_blueshipBar.position.y);
        _blueshipTip.color = _blueshipBar.color;
        _blueshipTip.colorBlendFactor = 1;
        [self addChild:_blueshipTip];
        
        _baseWhiteBar = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(24, 5)];
        _baseWhiteBar.position = CGPointMake(self.size.width/2, 0.1*self.size.height);
        [self addChild:_baseWhiteBar];
        
        _topWhiteBar = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(24, 5)];
        _topWhiteBar.position = CGPointMake(self.size.width/2, 0.9*self.size.height);
        _topWhiteBar.anchorPoint = CGPointMake(0.5, 0);
        [self addChild:_topWhiteBar];
        
        _moveWhiteBar1 = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(24, 5)];
        _moveWhiteBar1.position = CGPointMake(self.size.width/2, 0.9*self.size.height);
        _moveWhiteBar1.anchorPoint = CGPointMake(0.5, 0);
        [self addChild:_moveWhiteBar1];
        
        _moveWhiteBar2= [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(24, 5)];
        _moveWhiteBar2.position = CGPointMake(self.size.width/2, 0.9*self.size.height);
        _moveWhiteBar2.anchorPoint = CGPointMake(0.5, 0);
        [self addChild:_moveWhiteBar2];
        
        
    }
    return self;
}

-(BOOL) adjustProgressBars_nextCheckPoint:(CGFloat)nextCheckP yellowPos:(CGFloat)yellowPos redPos:(CGFloat)redPos mainPos:(CGFloat)mainPos greenPos:(CGFloat)greenPos bluePos:(CGFloat)bluePos
{
    if (_checkPointNum == 0){
        
        _yellowshipBar.size = CGSizeMake(2, (.8*self.size.height)*(yellowPos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos));
        _redshipBar.size = CGSizeMake(2, (.8*self.size.height)*(redPos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos));
        _mainshipBar.size = CGSizeMake(2, (.8*self.size.height)*(mainPos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos));
        _greenshipBar.size = CGSizeMake(2, (.8*self.size.height)*(greenPos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos));
        _blueshipBar.size = CGSizeMake(2, (.8*self.size.height)*(bluePos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos));
        
    }else{
        
        NSLog(@"in else case");
        
        if (yellowPos > _lastCheckpointPos && yellowPos < _nextCheckpointPos)
            _yellowshipBar.size = CGSizeMake(2, self.size.height*.2+(.7*self.size.height)*(yellowPos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos));
        else if (yellowPos < _lastCheckpointPos && _scaleActionComplete)
            _yellowshipBar.size = CGSizeMake(2, (self.size.height*.1)*(redPos-_beforeLastCheckpointPos)/(_lastCheckpointPos-_beforeLastCheckpointPos));
        
        if (redPos > _lastCheckpointPos && redPos <_nextCheckpointPos)
            _redshipBar.size = CGSizeMake(2, self.size.height*.1+(.7*self.size.height)*(redPos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos));
        else if (redPos < _lastCheckpointPos && _scaleActionComplete)
            _redshipBar.size = CGSizeMake(2, (self.size.height*.1)*(redPos-_beforeLastCheckpointPos)/(_lastCheckpointPos-_beforeLastCheckpointPos));
        
        if (mainPos > _lastCheckpointPos && mainPos <_nextCheckpointPos)
            _mainshipBar.size = CGSizeMake(2, self.size.height*.1+(.7*self.size.height)*(mainPos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos));
        else if (mainPos < _lastCheckpointPos && _scaleActionComplete)
            _mainshipBar.size = CGSizeMake(2, (self.size.height*.1)*(mainPos-_beforeLastCheckpointPos)/(_lastCheckpointPos-_beforeLastCheckpointPos));
        
        if (greenPos > _lastCheckpointPos && greenPos <_nextCheckpointPos)
            _greenshipBar.size = CGSizeMake(2, self.size.height*.1+(.7*self.size.height)*(greenPos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos));
        else if (greenPos < _lastCheckpointPos && _scaleActionComplete)
            _greenshipBar.size = CGSizeMake(2, (self.size.height*.1)*(greenPos-_beforeLastCheckpointPos)/(_lastCheckpointPos-_beforeLastCheckpointPos));
        
        if (bluePos > _lastCheckpointPos && bluePos <_nextCheckpointPos)
            _blueshipBar.size = CGSizeMake(2, self.size.height*.1+(self.size.height-.3*self.size.height)*(bluePos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos));
        else if (bluePos < _lastCheckpointPos && _scaleActionComplete)
            _blueshipBar.size = CGSizeMake(2, (self.size.height*.1)*(bluePos-_beforeLastCheckpointPos)/(_lastCheckpointPos-_beforeLastCheckpointPos));
    }
    
    _yellowshipTip.position = CGPointMake(_yellowshipBar.position.x, _yellowshipBar.size.height+_yellowshipBar.position.y+1.5);
    _redshipTip.position = CGPointMake(_redshipBar.position.x, _redshipBar.size.height+_redshipBar.position.y+1.5);
    _mainshipTip.position = CGPointMake(_mainshipBar.position.x, _mainshipBar.size.height+_mainshipBar.position.y+1.5);
    _greenshipTip.position = CGPointMake(_greenshipBar.position.x, _greenshipBar.size.height+_greenshipBar.position.y+1.5);
    _blueshipTip.position = CGPointMake(_blueshipBar.position.x, _blueshipBar.size.height+_blueshipBar.position.y+1.5);
    
    if (mainPos > _nextCheckpointPos){
        
        _scaleActionComplete = NO;
        
        SKAction *slideDown = [SKAction moveToY:.2*self.size.height duration:1];
        slideDown.timingMode = SKActionTimingEaseOut;
        
        SKAction *slideOff = [SKAction moveToY:.1*self.size.height duration:1];
        slideOff.timingMode = SKActionTimingEaseOut;
        
        SKAction *moveDownMainTip = [SKAction moveToY:self.size.height*.1 +(self.size.height*.1)*(mainPos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos) duration:1];
        moveDownMainTip.timingMode = SKActionTimingEaseOut;
        
        SKAction *moveDownYellowTip = [SKAction moveToY:self.size.height*.1 +(self.size.height*.1)*(yellowPos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos) duration:1];
        moveDownYellowTip.timingMode = SKActionTimingEaseOut;
        
        SKAction *moveDownRedTip = [SKAction moveToY:self.size.height*.1 +(self.size.height*.1)*(redPos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos) duration:1];
        moveDownRedTip.timingMode = SKActionTimingEaseOut;
        
        SKAction *moveDownGreenTip = [SKAction moveToY:self.size.height*.1 +(self.size.height*.1)*(greenPos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos) duration:1];
        moveDownGreenTip.timingMode = SKActionTimingEaseOut;
        
        SKAction *moveDownBlueTip = [SKAction moveToY:self.size.height*.1 +(self.size.height*.1)*(bluePos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos) duration:1];
        moveDownBlueTip.timingMode = SKActionTimingEaseOut;
        
        SKAction *scaleDownMain = [SKAction resizeToHeight: (self.size.height*.1)*(mainPos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos) duration:1];
        scaleDownMain.timingMode = SKActionTimingEaseOut;
        
        SKAction *scaleDownYellow = [SKAction resizeToHeight:(self.size.height*.1)*(yellowPos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos) duration:1];
        scaleDownYellow.timingMode = SKActionTimingEaseOut;
        
        SKAction *scaleDownRed = [SKAction resizeToHeight:(self.size.height*.1)*(redPos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos) duration:1];
        scaleDownRed.timingMode = SKActionTimingEaseOut;
        
        SKAction *scaleDownGreen = [SKAction resizeToHeight:(self.size.height*.1)*(greenPos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos) duration:1];
        scaleDownGreen.timingMode = SKActionTimingEaseOut;
        
        SKAction *scaleDownBlue = [SKAction resizeToHeight:(self.size.height*.1)*(bluePos-_lastCheckpointPos)/(_nextCheckpointPos - _lastCheckpointPos) duration:1];
        scaleDownBlue.timingMode = SKActionTimingEaseOut;
        
        if (_checkPointNum == 0){
            [_moveWhiteBar1 runAction:slideDown];
            [_mainshipBar runAction:scaleDownMain];
            [_yellowshipBar runAction:scaleDownYellow];
            [_redshipBar runAction:scaleDownRed];
            [_greenshipBar runAction:scaleDownGreen];
            [_mainshipTip runAction:moveDownMainTip];
            [_yellowshipTip runAction:moveDownYellowTip];
            [_redshipTip runAction:moveDownRedTip];
            [_greenshipTip runAction:moveDownGreenTip];
            [_blueshipTip runAction:moveDownBlueTip];
            [_blueshipBar runAction:scaleDownBlue completion:^{
                _scaleActionComplete = YES;
                _beforeLastCheckpointPos = _lastCheckpointPos;
                _lastCheckpointPos = _nextCheckpointPos;
                _nextCheckpointPos = nextCheckP;
                
                _checkPointNum++;
            }];
            
        }else if (_checkPointNum % 2 == 1){
            [_moveWhiteBar2 runAction:slideDown];
            [_moveWhiteBar1 runAction:slideOff completion:^{
                _moveWhiteBar1.position = CGPointMake(self.size.width/2, 0.9*self.size.height);
                _scaleActionComplete = YES;
                _beforeLastCheckpointPos = _lastCheckpointPos;
                _lastCheckpointPos = _nextCheckpointPos;
                _nextCheckpointPos = nextCheckP;
                
                _checkPointNum++;
            }];
            [_mainshipTip runAction:moveDownMainTip];
            [_yellowshipTip runAction:moveDownYellowTip];
            [_redshipTip runAction:moveDownRedTip];
            [_greenshipTip runAction:moveDownGreenTip];
            [_blueshipTip runAction:moveDownBlueTip];
            [_mainshipBar runAction:scaleDownMain];
            [_yellowshipBar runAction:scaleDownYellow];
            [_redshipBar runAction:scaleDownRed];
            [_greenshipBar runAction:scaleDownGreen];
            [_blueshipBar runAction:scaleDownBlue];
            
        }else if (_checkPointNum % 2 == 0){
            [_moveWhiteBar1 runAction:slideDown];
            [_moveWhiteBar2 runAction:slideOff completion:^{
                _moveWhiteBar2.position = CGPointMake(self.size.width/2, 0.9*self.size.height);
                _scaleActionComplete = YES;
                _beforeLastCheckpointPos = _lastCheckpointPos;
                _lastCheckpointPos = _nextCheckpointPos;
                _nextCheckpointPos = nextCheckP;
                
                _checkPointNum++;
            }];
            [_mainshipTip runAction:moveDownMainTip];
            [_yellowshipTip runAction:moveDownYellowTip];
            [_redshipTip runAction:moveDownRedTip];
            [_greenshipTip runAction:moveDownGreenTip];
            [_blueshipTip runAction:moveDownBlueTip];
            [_mainshipBar runAction:scaleDownMain];
            [_yellowshipBar runAction:scaleDownYellow];
            [_redshipBar runAction:scaleDownRed];
            [_greenshipBar runAction:scaleDownGreen];
            [_blueshipBar runAction:scaleDownBlue];
        }
        
        
        return YES;
    }
    
    return NO;
}

@end
