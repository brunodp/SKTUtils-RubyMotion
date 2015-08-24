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

# Converts a CGPoint into a GLKVector2 so you can use it with the GLKMath
# functions from GL Kit.

M_PI = Math::PI unless defined? M_PI
M_PI_2 = Math::PI / 2 unless defined? M_PI_2

def GLKVector2FromCGPoint(point)
	# GLKVector2Make(point.x, point.y)
	GLKVector2.new([point.x, point.y])
end

# Converts a GLKVector2 into a CGPoint.
def CGPointFromGLKVector2(vector)
	CGPointMake(vector.x, vector.y)
end

# Converts a CGPoint into a CGVector.
def CGVectorFromCGPoint(point)
	CGVectorMake(point.x, point.y)
end

# Converts a CGVector into a CGPoint.
def CGPointFromCGVector(vector)
	CGPointMake(vector.dx, vector.dy)
end

# Adds (dx, dy) to the point.
def CGPointOffset(point, dx, dy)
	CGPointMake(point.x + dx, point.y + dy)
end

# Adds two CGPoint values and returns the result as a new CGPoint.
def CGPointAdd(point1, point2)
	CGPointMake(point1.x + point2.x, point1.y + point2.y)
end

# Subtracts point2 from point1 and returns the result as a new CGPoint.
def CGPointSubtract(point1, point2)
	CGPointMake(point1.x - point2.x, point1.y - point2.y)
end

# Multiplies two CGPoint values and returns the result as a new CGPoint.
def CGPointMultiply(point1, point2)
	CGPointMake(point1.x * point2.x, point1.y * point2.y)
end

# Divides point1 by point2 and returns the result as a new CGPoint.
def CGPointDivide(point1, point2)
	CGPointMake(point1.x / point2.x, point1.y / point2.y)
end

# Multiplies the x and y fields of a CGPoint with the same scalar value and
# returns the result as a new CGPoint.
def CGPointMultiplyScalar(point, value)
	# CGPointFromGLKVector2(GLKVector2MultiplyScalar(GLKVector2FromCGPoint(point), value))
	
	# We avoid GLKVector2MultiplyScalar due to Rubymotion's GLKit Bugs (RM 3.14 stable)
	vector = GLKVector2FromCGPoint(point)
	vector.v[0] *= value
	vector.v[1] *= value
	CGPointFromGLKVector2(vector)
end

# Divides the x and y fields of a CGPoint by the same scalar value and returns
# the result as a new CGPoint.
def CGPointDivideScalar(point, value)
	# CGPointFromGLKVector2(GLKVector2DivideScalar(GLKVector2FromCGPoint(point), value))
	
	# We avoid GLKVector2DivideScalar due to Rubymotion's GLKit Bugs (RM 3.14 stable)
	vector = GLKVector2FromCGPoint(point)
	vector.v[0] /= value
	vector.v[1] /= value
	CGPointFromGLKVector2(vector)
end

# Returns the length (magnitude) of the vector described by a CGPoint.
def CGPointLength(point)
	GLKVector2Length(GLKVector2FromCGPoint(point))
end

# Normalizes the vector described by a CGPoint to length 1.0 and returns the
# result as a new CGPoint.
def CGPointNormalize(point)
	CGPointFromGLKVector2(GLKVector2Normalize(GLKVector2FromCGPoint(point)))
end

# Calculates the distance between two CGPoints. Pythagoras!
def CGPointDistance(point1, point2)
	CGPointLength(CGPointSubtract(point1, point2))
end

# Returns the angle in radians of the vector described by a CGPoint. The range
# of the angle is -M_PI to M_PI; an angle of 0 points to the right.
def CGPointToAngle(point)
	Math::atan2(point.y, point.x)
end

# Given an angle in radians, creates a vector of length 1.0 and returns the
# result as a new CGPoint. An angle of 0 is assumed to point to the right.
def CGPointForAngle(angle)
	CGPointMake(Math::cos(angle), Math::sin(angle))
end

# Performs a linear interpolation between two CGPoint values.
def CGPointLerp(start_point, end_point, t)
	CGPointMake(start_point.x + (end_point.x - start_point.x) * t, start_point.y + (end_point.y - start_point.y) * t)
end

# Ensures that a scalar value stays with the range [min..max], inclusive.
def Clamp(value, min, max)
	(value < min) ? min : ((value > max) ? max : value)
end

# Returns 1.0 if a floating point value is positive; -1.0 if it is negative.
def ScalarSign(value)
	(value >= 0.0) ? 1.0 : -1.0
end

# Returns the shortest angle between two angles. The result is always between
# -M_PI and M_PI.
def ScalarShortestAngleBetween(angle1, angle2)
	angle = (angle1 - angle2).modulo(M_PI * 2.0)
	if angle >= M_PI
		angle -= M_PI * 2.0
	end
	if angle <= -M_PI
		angle += M_PI * 2.0
	end
	
	angle
end

# Converts an angle in degrees to radians.
def DegreesToRadians(degrees)
	M_PI * degrees / 180.0
end

# Converts an angle in radians to degrees.
def RadiansToDegrees(radians)
	radians * 180.0 / M_PI
end

# Returns a random floating point number between 0.0 and 1.0, inclusive.
def RandomFloat
	rand
end

# Returns a random floating point number in the range [min..max], inclusive.
def RandomFloatRange(min, max)
	Random.new.rand(min..max)
end

# Randomly returns either 1.0 or -1.0.
def RandomSign
	[-1.0, 1.0].sample
end

# Creates and returns a new SKColor object using RGB components specified as
# values from 0 to 255.
def SKColorWithRGB(r, g, b)
	SKColor.colorWithRed(r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
end

# Creates and returns a new SKColor object using RGBA components specified as
# values from 0 to 255.
def SKColorWithRGBA(r, g, b, a)
	SKColor.colorWithRed(r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a / 255.0)
end