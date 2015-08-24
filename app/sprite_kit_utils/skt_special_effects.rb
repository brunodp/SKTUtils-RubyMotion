# Copyright (c) 2013 Razeware LLC
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

class SKAction
	
	# Creates a screen shake animation.
	#
	# amount: The vector by which the node is displaced.
	# oscillations: The number of oscillations. 10 is a good value.
	#
	# You cannot apply this to an SKScene.
	def self.skt_screenShakeWithNode(node, amount: amount, oscillations: oscillations, duration: duration)
		old_position = node.position
		new_position = CGPointAdd(old_position, amount)
		
		effect = SKT::MoveEffect.alloc.initWithNode(node, duration: duration, startPosition: new_position, endPosition: old_position)
		effect.timingFunction = SKT::CreateShakeFunction(oscillations)
		
		SKAction.actionWithEffect(effect)
	end
	
	#	Creates a screen rotation animation.
	#
	# angle: The angle in radians.
	# oscillations: The number of oscillations. 10 is a good value.
	#
	# You cannot apply this to an SKScene. You usually want to apply this to a pivot node that is centered in the scene.
	def self.skt_screenTumbleWithNode(node, angle: angle, oscillations: oscillations, duration: duration)
		old_angle = node.zRotation
		new_angle = old_angle + angle
		
		effect = SKT::RotateEffect.alloc.initWithNode(node, duration: duration, startAngle: new_angle, endAngle: old_angle)
		effect.timingFunction = SKT::CreateShakeFunction(oscillations)
		
		SKAction.actionWithEffect(effect)
	end
	
	# Creates a screen zoom animation.
	#
	# amount: How much to scale the node in the X and Y directions.
	# oscillations: The number of oscillations. 10 is a good value.
	#
	# You cannot apply this to an SKScene. You usually want to apply this to a pivot node that is centered in the scene.
	def self.skt_screenZoomWithNode(node, amount: amount, oscillations: oscillations, duration: duration)
		old_scale = CGPointMake(node.xScale, node.yScale)
		new_scale = CGPointMultiply(old_scale, amount)
		
		effect = SKT::ScaleEffect.alloc.initWithNode(node, duration: duration, startScale: new_scale, endScale: old_scale)
		effect.timingFunction = SKT::CreateShakeFunction(oscillations)
		
		SKAction.actionWithEffect(effect)
	end
	
	# Causes the scene background to flash for duration seconds.
	def self.skt_colorGlitchWithScene(scene, originalColor: original_color, duration: duration)
		self.customActionWithDuration(duration, 
			actionBlock: lambda { |node, elapsed_time|
				if elapsed_time < duration
					scene.backgroundColor = SKColorWithRGB(rand(255), rand(255), rand(255))
				else
					scene.backgroundColor = original_color
				end
			}
		)
	end
end