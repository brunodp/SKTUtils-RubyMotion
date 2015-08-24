Rubymotion port of https://github.com/raywenderlich/SKTUtils

# Sprite Kit Utils

A collection of Sprite Kit helper classes and functions. The most interesting of these is **SKT::Effects**, which allows you to make your games much more [juicy](http://bitly.com/juice-it). 

Sprite Kit has a handy feature named *actions* that make it really easy to move, rotate and scale your sprites. However, a big downside is the omission of timing functions beyond the standard *ease in* and *ease out*. The `SKT::Effects` classes from this package add support for many more easing functions to Sprite Kit.

It lets you do things like this with just a few lines of code:

![The demo app](Examples/Effects/Demo.gif)

This code was originally written for the book [iOS Games by Tutorials](http://raywenderlich.com/store/ios-games-by-tutorials), which is published through [raywenderlich.com](http://raywenderlich.com).

![iOS Games by Tutorials](http://cdn4.raywenderlich.com/wp-content/uploads/2013/10/iGT_PDFonly_280@2x.png "iOS Games by Tutorials")

## Using SKT::Effects

The only reason `SKT::Effects` exists is because `SKAction` does not allow arbitrary timing functions, only standard ease-in and ease-out. The `SKT::Effect` subclasses are re-implementations of what `SKAction` already does but with the addition of custom timing functions. It's a bit of a roundabout way of achieving something that really should have been built into Sprite Kit.

There are currently three `SKT::Effect` subclasses:

- `SKT::MoveEffect`
- `SKT::RotateEffect`
- `SKT::ScaleEffect`

You use them like this:

    move_effect = SKT::MoveEffect.effectWithNode(
                    node, 
                    duration: 1.0,
                    startPosition: start_position,
                    endPosition: end_position
                  )
                  
    move_effect.timingFunction = SKT::TimingFunction::BounceEaseOut
    
    node.runAction(SKAction.actionWithEffect: move_effect)
  

First you create the `SKT::MoveEffect` object and pass it the node that it should animate, the duration of the animation in seconds, and the starting and ending position of the node.

Then you (optionally) set the timing function on the effect object. You can use the supplied timing functions -- for example, elastic, bounce, and many others -- or create your own. See **skt_timing_functions.rb** for a complete list.

Finally, you wrap the effect object inside a regular `SKAction` and run that action on the node.

The process for `SKT::RotateEffect` and `SKT::ScaleEffect` is identical, but you specify rotation angles and scale vectors, respectively.

You can combine multiple effects at the same time, e.g. have more than one scale effect going at once on the same node.

## Caveats

Currently there is no "relative" version of the effects. You always have to supply an absolute starting and ending position, rotation angle, or scale. Most of the time this is no big deal, but it does mean you cannot put them into repeating actions.

For example, the demo project does the following to rotate a node every second by 45 degrees:

		barrier_node.runAction(
			SKAction.repeatActionForever(
				SKAction.sequence([
					SKAction.waitForDuration(0.75),
					SKAction.runBlock(
						lambda {
							effect = SKT::RotateEffect.effectWithNode(
                        barrier_node, duration: 0.25, startAngle: barrier_node.zRotation, 
                        endAngle: barrier_node.zRotation + Math::PI / 4
                       )
							effect.timingFunction = SKT::TimingFunction::BackEaseInOut
							
							barrier_node.runAction(SKAction.actionWithEffect(effect))
						}
					)
				])
			)
		)

If the effects had a relative version, this could have simply been written as:

    effect = SKT::RotateEffect.effectWithNode(barrier_node, duration: 0.25, byAngle: Math::PI / 4)
    effect.timingFunction = SKT::TimingFunction::BackEaseInOut
    
    barrier_node.runAction(SKAction.repeatActionForever(SKAction.sequence([
        SKAction.waitForDuration(0.75),
        SKAction.actionWithEffect: effect
    ])))

Not only is this simpler to read, it also saves you from having to create a new effect instance for every repetition. However, this doesn't work in the current version of the library.

Effects keep state (unlike `SKActions`), so you should not reuse the same effect instance in multiple actions.

If you use a lot of effects over a long period of time, you may run into memory fragmentation problems, because you need to allocate a new object for every effect. Currently, effects cannot be reset, so it's tricky to put them into an object pool and reuse them.

Because actions keep state, you cannot put them into an action after a delay if the node also moves in the mean time. In other words, doing the following may or may not work:

    effect = SKT::MoveEffect ...
    
    action = SKAction.sequence([
               SKAction.waitForDuration(5.0),
               SKAction.actionWithEffect(effect)
             ])

If the node has moved during the delay, either through another `SKAction`, physics, or the app changing the node's `position` property, then the effect will start in the wrong place.

## The demo app

The **Examples/Effects** folder contains a little demo project that shows how to do animations with more interesting timing functions. This app uses physics to move the balls and detect collisions.

It has the following special effects:

- The objects appear with an animation when the game starts
- Screen shake on collisions
- Screen rotate on collisions, for extra shaky goodness!
- Screen zoom on collisions
- Color glitch (flashing background color)
- Ball scales up on collisions
- Ball smoothly rotates in the direction it is flying
- "Jelly" effect on the obstacles on collisions
- And more...

Most of these effects are cumulative; i.e. if there are several collisions in quick succession, then the screen shake movement is the sum of these hits.

All the fun happens in **my_scene.rb**. There are several constants at the top that let you turn effects on or off.

Tap the screen to add a random impulse to the balls.

## Let's get this included in Sprite Kit!

If you think custom timing functions are an important feature to have built into Sprite Kit, then go to [bugreport.apple.com](http://bugreport.apple.com]) and file the following feature request. The more they receive, the better! Thanks! :)

---

	Title: SKActionTimingModes are insufficient

	The SKAction class from Sprite Kit allows you to specify a timing mode, using an enum with the following values: Linear, Ease In, Ease Out, Ease In + Out. 

	Unfortunately, a lot of the common timing modes that are used in games are missing (bounce, elastic, etc). More importantly, there is no easy way to add your own timing modes.
	
	This is an example of what I'd like to see. You define a block that takes a float and returns a float: 

	  typedef float (^SKActionTimingFunction)(float t);

	The value of t is always between 0 and 1 and describes how far along the animation is. The block returns a modified value of t that curves the timing. 
	
	Some examples:

	  SKActionTimingFunction SKActionTimingFunctionLinear = ^(float t) {
	  	return t;
	  };

	  SKActionTimingFunction SKActionTimingFunctionQuadraticEaseIn = ^(float t) {
	  	return t * t;
	  };

	  SKActionTimingFunction SKActionTimingFunctionQuadraticEaseOut = ^(float t) {
	  	return t * (2.0f - t);
	  };

	  SKActionTimingFunction SKActionTimingFunctionQuadraticEaseInOut = ^(float t) {
	  	if (t < 0.5f) {
		  return 2.0f * t * t;
		} else {
		  const float f = t - 1.0f;
		  return 1.0f - 2.0f * f * f;
		}
  	  };

	But beyond the standard ease in & out, it easily allows users of Sprite Kit to extend this with more interesting effects, such as:

	  SKActionTimingFunction SKActionTimingFunctionBackEaseInOut = ^(float t) {
	    const float s = 1.70158f;
	    if (t < 0.5f) {
	      const float f = 2.0f * t;
	      return 0.5f * ((s + 1.0f) * f - s) * f * f;
	    } else {
	      const float f = 2.0f * (1.0f - t);
	      return 1.0f - 0.5f * ((s + 1.0f) * f - s) * f * f;
	    }
	  };
	
	These kinds of timing curves are available in many other gaming toolkits. Not having this kind of flexibility makes Sprite Kit a lot less useful. Users of Sprite Kit need to be able to supply their own timing functions.
	
	Note: Core Animation allows you to specify a timing function using a bezier path and 4 control points. That would be useful but by itself it is not enough. Having a block that takes a t value between 0 and 1, and can do any custom transformation on that, is a must.

---
