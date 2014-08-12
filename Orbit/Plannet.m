//
//  Plannet.m
//  Orbit
//
//  Created by Christian Ayscue on 8/8/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

#import "Plannet.h"
#import "SKTTimingFunctions.h"
#import "SKTEffects.h"

@implementation Plannet
{
    SKSpriteNode *_plannetBody;
    CGPoint _position;
    NSString *_plannetName;
}

@synthesize _size;
@synthesize _gravZone;
@synthesize _gravPath;
@synthesize _radius;
@synthesize _gravZoneImage;
@synthesize _entrancePath;

-(instancetype) initWithSize:(CGSize) size andPosition:(CGPoint) position andImage:(NSString*) plannetName
{
    if(self = [super init]){
        _plannetName = plannetName;
        _size = size;
        _radius = _size.width/2;
        
        self.position = position;
        
        [self addGravImage];
        
        [self addGravZone];

        [self addHardPlannet];
    }
    return self;
}

-(void) addHardPlannet
{
//node properties
    _plannetBody = [SKSpriteNode spriteNodeWithImageNamed:_plannetName];
    _plannetBody.size = _size;
    //_plannetBody.color = [SKColor redColor];
    //_plannetBody.colorBlendFactor = 1.0;

    
//add to parrent
    [self addChild:_plannetBody];
}

-(void) addGravImage
{
    _gravZoneImage = [SKSpriteNode spriteNodeWithImageNamed:@"gravzone"];
    _gravZoneImage.size = CGSizeMake(_size.width*1.4, _size.height*1.4);
    _gravZoneImage.alpha = 0.5;
    
    //scaling actions
    SKAction *pulseUp = [ SKAction scaleXBy: 1.1 y: 1.1 duration: 0.5 ];
    pulseUp.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *pulseDown = [ pulseUp reversedAction ];
    pulseDown.timingMode = SKActionTimingEaseInEaseOut;
    [_gravZoneImage runAction:[SKAction repeatActionForever: [ SKAction sequence:@[pulseUp, pulseDown]]]];
    
    [self addChild:_gravZoneImage];

}

-(void) addGravZone
{
//node properties
    _gravZone = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite: 1 alpha:0] size:CGSizeMake(_size.width*1.65, _size.height*1.65)];
    _gravZone.alpha = 0.0;
    
//gravity path
    //CGRect pathRect = CGRectMake(_gravZone.position.x-_gravZone.size.width*0.9/2, _gravZone.position.y-_gravZone.size.height*0.9/2, _gravZone.size.width*0.9 , _gravZone.size.height*0.9);
    //_gravPath = [UIBezierPath bezierPathWithOvalInRect: pathRect];
    
//physics body
    //CGPathRef physBodPath = [ UIBezierPath bezierPathWithOvalInRect: CGRectMake( _gravZone.position.x -_gravZone.size.width/2, _gravZone.position.y - _gravZone.size.height/2, _gravZone.size.width, _gravZone.size.height ) ].CGPath;
    //_gravZone.physicsBody = [ SKPhysicsBody bodyWithBodies: @[ [ SKPhysicsBody bodyWithEdgeLoopFromPath: physBodPath], [ SKPhysicsBody bodyWithEdgeLoopFromPath: _gravPath.CGPath ] ] ];
    _gravZone.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_gravZone.size.width/2];
    _gravZone.physicsBody.linearDamping = 0;
    _gravZone.physicsBody.angularDamping = 0;
    _gravZone.physicsBody.allowsRotation = NO;
    _gravZone.physicsBody.categoryBitMask = CNPhysicsCategoryGravityZone;
    _gravZone.physicsBody.contactTestBitMask = CNPhysicsCategoryShip;
    _gravZone.physicsBody.collisionBitMask = 0;
    
//add to parrent
    [self addChild:_gravZone];
}
@end
