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

module SKT

	# Allows you to perform actions with custom timing functions.
	# Unfortunately, SKAction does not have a concept of a timing function, so
	# we need to replicate the actions using SKT::Effect subclasses.
	class Effect
		attr_accessor :timingFunction, :duration
	
		def self.effectWithNode(node, duration: duration)
			self.alloc.initWithNode(node, duration: duration)
		end
	
		def initWithNode(node, duration: duration)
			init
		
			@node = node
			@duration = duration
			@timingFunction = SKT::TimingFunction::Linear
		
			self		
		end
	
		def dealloc
			# NSLog('dealloc %@', self)
		end
	
		def update(t)
			# Subclass should implement this
		end
	
	end
	
	# Moves a node from its current position to a new position.
	class MoveEffect < SKT::Effect
	
		def self.effectWithNode(node, duration: duration, startPosition: start_position, endPosition: end_position)
			self.alloc.initWithNode(node, duration: duration, startPosition: start_position, endPosition: end_position)
		end

		def initWithNode(node, duration: duration, startPosition: start_position, endPosition: end_position)
			self.initWithNode(node, duration: duration)

			if self
				@previous_position = node.position
				@start_position = start_position
				@delta = CGPointSubtract(end_position, @start_position)
			end

			self
		end
	
		def update(t)
		  # This allows multiple SKTMoveEffect objects to modify the same node
		  # at the same time.
			new_position = CGPointAdd(@start_position, CGPointMultiplyScalar(@delta, t))
			diff = CGPointSubtract(new_position, @previous_position)
			@previous_position = new_position

			@node.position = CGPointAdd(@node.position, diff)
		end
	
	end

	# Scales a node to a certain scale factor.
	class ScaleEffect < SKT::Effect
	
		def self.effectWithNode(node, duration: duration, startScale: start_scale, endScale: end_scale)
			self.alloc.initWithNode(node, duration: duration, startScale: start_scale, endScale: end_scale)
		end
	
		def initWithNode(node, duration: duration, startScale: start_scale, endScale: end_scale)
			self.initWithNode(node, duration: duration)

			if self
				@previous_scale = CGPointMake(node.xScale, node.yScale)
				@start_scale = start_scale
				@delta = CGPointSubtract(end_scale, @start_scale)
			end
		
			self		
		end
	
		def update(t)
			new_scale = CGPointAdd(@start_scale, CGPointMultiplyScalar(@delta, t))
			diff = CGPointDivide(new_scale, @previous_scale)
			@previous_scale = new_scale
			@node.xScale *= diff.x
			@node.yScale *= diff.y
		end

	end	
	
	# Rotates a node to a certain angle.
	class RotateEffect < SKT::Effect
	
		def self.effectWithNode(node, duration: duration, startAngle: start_angle, endAngle: end_angle)
			self.alloc.initWithNode(node, duration: duration, startAngle: start_angle, endAngle: end_angle)
		end
	
		def initWithNode(node, duration: duration, startAngle: start_angle, endAngle: end_angle)
			self.initWithNode(node, duration: duration)
		
			if self
				@previous_angle = node.zRotation
				@start_angle = start_angle
				@delta = end_angle - @start_angle
			end
		
			self
		end
	
		def update(t)
			new_angle = @start_angle + @delta * t
			diff = new_angle - @previous_angle
			@previous_angle = new_angle
			@node.zRotation += diff
		end

	end
	
end

# Wrapper that allows you to use SKT::Effect objects as regular SKActions.
class SKAction
	
	def self.actionWithEffect(effect)
		self.customActionWithDuration(effect.duration,
			actionBlock: lambda { |node, elapsed_time|
				t = elapsed_time / effect.duration
				if not effect.timingFunction.nil?
					t = effect.timingFunction[t] # the magic happens here
				end

				effect.update(t)
			}
		)
	end
	
end