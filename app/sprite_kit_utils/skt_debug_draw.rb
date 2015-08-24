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
	@@debug_draw_enabled = true

	def self.DebugDrawEnabled
		@@debug_draw_enabled
	end
		
	def self.DebugDrawEnabled=(value)
		@@debug_draw_enabled = value
	end
end

class SKNode
	
	# Draws a stroked path on top of this node.
	# Returns the debug shape.
	def skt_attachDebugFrameFromPath(path, color: color)
		if SKT::DebugDrawEnabled
			shape = SKShapeNode.node
			shape.path = path
			shape.strokeColor = color
			shape.lineWidth = 1.0
			shape.glowWidth = 0.0
			shape.antialiased = false
			self.addChild(shape)
			
			shape
		end
	end
	
	# Draws a stroked rectangle on top of this node.
	# Returns the debug shape.
	def skt_attachDebugRectWithSize(size, color: color)
		if SKT::DebugDrawEnabled
			body_path = CGPathCreateWithRect([[-size.width / 2.0, -size.height / 2.0], [size, width, size.height]], nil)
			shape = self.skt_attachDebugFrameFromPath(body_path, color: color)
			CGPathRelease(body_path)
			
			shape
		end
	end
	
	# Draws a stroked circle on top of this node.
	# Returns the debug shape.
	def skt_attachDebugCircleWithRadius(radius, color: color)
		if SKT::DebugDrawEnabled
			path = UIBezierPath.bezierPathWithOvalInRect([[-radius, -radius], [radius * 2.0, radius * 2.0]])
			shape = self.skt_attachDebugFrameFromPath(path.CGPath, color: color)
			
			shape
		end		
	end
	
	# Draws a line on top of this node.
	# Returns the debug shape.
	def skt_attachDebugLineFromPoint(start_point, toPoint: end_point, color: color)
		if SKT::DebugDrawEnabled
			path = UIBezierPath.alloc.init
			path.moveToPoint(start_point)
			path.addLineToPoint(end_point)

			self.skt_attachDebugFrameFromPath(path.CGPath, color: color)
		end
	end
	
end