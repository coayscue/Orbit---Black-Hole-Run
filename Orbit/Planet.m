//
//  Planet.m
//  Orbit
//
//  Created by Christian Ayscue on 8/8/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

#import "Planet.h"
#import "SKTTimingFunctions.h"
#import "SKTEffects.h"

@implementation Planet
{
    CGPoint _position;
    NSString *_planetName;
}

@synthesize _size;
@synthesize _gravZone;
@synthesize _gravPath;
@synthesize _radius;
@synthesize _gravZoneImage;
@synthesize _entrancePath;
@synthesize _pulseAction;
@synthesize _planetBody;

-(instancetype) initWithSize:(CGSize) size andPosition:(CGPoint) position andImage:(NSString*) planetName
{
    if(self = [super init]){
        _planetName = planetName;
        _size = size;
        _radius = _size.width/2;
        
        self.position = position;
        
        [self addGravImage];
        
        [self addGravZone];

        [self addHardPlanet];
    }
    return self;
}

-(void) addHardPlanet
{
//node properties
    _planetBody = [SKSpriteNode spriteNodeWithImageNamed:_planetName];
    _planetBody.size = _size;
    _planetBody.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_size.width/2-3];
    _planetBody.physicsBody.linearDamping = 0;
    _planetBody.physicsBody.angularDamping = 0;
    _planetBody.physicsBody.allowsRotation = NO;
    _planetBody.physicsBody.categoryBitMask = CNPhysicsCategoryPlanetBody;
    _planetBody.physicsBody.collisionBitMask = 0;
    
//add to parrent
    [self addChild:_planetBody];
}

-(void) addGravImage
{
    _gravZoneImage = [SKSpriteNode spriteNodeWithImageNamed:@"gravzone"];
    _gravZoneImage.size = CGSizeMake(_size.width*1.6, _size.height*1.6);
    _gravZoneImage.alpha = 0.5;
    
    //scaling actions
    SKAction *pulseUp = [ SKAction scaleBy:1.1 duration:0.5 ];
    pulseUp.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *pulseDown = [ pulseUp reversedAction ];
    pulseDown.timingMode = SKActionTimingEaseInEaseOut;
    _pulseAction = [ SKAction repeatActionForever: [ SKAction sequence:@[pulseUp, pulseDown]]];
    
    [self addChild:_gravZoneImage];
    
    [_gravZoneImage runAction: _pulseAction];

}

-(void) addGravZone
{
//node properties
    _gravZone = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite: 1 alpha:0] size:CGSizeMake(_size.width*1.6, _size.height*1.6)];
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
    _gravZone.physicsBody.categoryBitMask = CNPhysicsCategoryMainshipGravityZone;
    _gravZone.physicsBody.collisionBitMask = 0;
    
//add to parrent
    [self addChild:_gravZone];
}

-(void)popPlanet
{
    SKAction *scaleUp = [SKAction scaleTo:1.05 duration:.1];
    scaleUp.timingMode = SKActionTimingEaseOut;
    SKAction *scaleDown = [SKAction scaleTo:1 duration:.3];
    scaleDown.timingMode = SKActionTimingEaseInEaseOut;
    [_planetBody runAction:[SKAction sequence:@[scaleUp, scaleDown]]];
}
@end
