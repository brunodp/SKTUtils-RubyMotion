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

# =======================
# = SKAction Open Class =
# =======================
class SKAction

	# Shorthand for:
	# SKAction.sequence([SKAction.waitForDuration(duration), action])
	def self.skt_afterDelay(duration, perform: action)
		SKAction.sequence([SKAction.waitForDuration(duration), action])
	end

	# Shorthand for:
	# SKAction.sequence([SKAction.waitForDuration(duration), SKAction.runBloc: lambda { ... }])
	def self.skt_afterDelay(duration, runBlock: block)
		self.skt_afterDelay(duration, perform: SKAction.runBlock(block))
	end
	
	# Shorthand for:
	# SKAction.sequence([SKAction.waitForDuration(duratio), SKAction.removeFromParent])
	def self.skt_removeFromParentAfterDelay(duration)
		self.skt_afterDelay(duration, perform: SKAction.removeFromParent)
	end
	
	# Creates an action to perform a parabolic jump.
	def self.skt_jumpWithHeight(height, duration: duration, originalPosition: original_position)
		SKAction.customActionWithDuration(duration,
			actionBlock: lambda { |node, elapsed_time|
				fraction = elapsed_time / duration
				y_off = height * 4 * fraction * (1 - fraction)
				node.position = [original_position.x, original_position.y + y_off]
			}
		)
	end
	
end

# ============================
# = SKEmitterNode Open Class =
# ============================
class SKEmitterNode
	
	# Convenience methods for loading an SKEmitterNode from a .sks file in the application bundle.
	def self.skt_emitterNamed(name)
		NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle.pathForResource(name, ofType: 'sks'))
	end
	
end

# =====================
# = SKNode Open Class =
# =====================
class SKNode

	# Lets you treat the node's scale as a CGPoint value.
	def skt_scale
		CGPointMake(self.xScale, self.yScale)
	end
	
	def skt_scale=(scale)
		self.xScale = scale.x
		self.yScale = scale.y
	end

	# Runs an action on the node that performs a selector after a given time.
	def skt_performSelector(selector, onTarget: target, afterDelay: delay)
		self.runAction(SKAction.sequence([
			SKAction.waitForDuration(delay),
			SKAction.performSelector(selector, onTarget: target)
		]))
	end
	
	# Makes this node the frontmost node in its parent.
	def skt_bringToFront
		parent = self.parent
		self.removeFromParent
		parent.addChild(self)
	end
	
	# Orients the node in the direction that it is moving by tweening its rotation
	# angle. This assumes that at 0 degrees the node is facing up.
	#
	# rate: How fast the node rotates. Must have a value between 0.0 and 1.0, 
	# where smaller means slower; 1.0 is instantaneous.
	def skt_rotateToVelocity(velocity, rate: rate)
	  # Determine what the rotation angle of the node ought to be based on the
	  # current velocity of its physics body. This assumes that at 0 degrees the
	  # node is pointed up, not to the right, so to compensate we subtract π/4
	  # (90 degrees) from the calculated angle.
		new_angle = Math::atan2(velocity.dy, velocity.dx) - Math::PI / 2
		
	  # This always makes the node rotate over the shortest possible distance.
	  # Because the range of atan2() is -180 to 180 degrees, a rotation from,
	  # -170 to -190 would otherwise be from -170 to 170, which makes the node
	  # rotate the wrong way (and the long way) around. We adjust the angle to
	  # go from 190 to 170 instead, which is equivalent to -170 to -190.
		if new_angle - self.zRotation > Math::PI
			self.zRotation += Math::PI * 2.0
		elsif self.zRotation - new_angle > Math::PI
			self.zRotation -= Math::PI * 2.0
		end
		
	  # Use the "standard exponential slide" to slowly tween zRotation to the
	  # new angle. The greater the value of rate, the faster this goes.
	  self.zRotation += (new_angle - self.zRotation) * rate
		
	end
	
end