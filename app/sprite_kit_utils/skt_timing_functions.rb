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
	
	def self.CreateShakeFunction(oscillations)
		lambda { |t|
			-(2.0 ** (-10.0 * t)) * Math::sin(t * M_PI * oscillations * 2.0) + 1.0
		}
	end

	module TimingFunction
		
		M_PI = Math::PI unless defined? M_PI
		M_PI_2 = Math::PI / 2 unless defined? M_PI_2
	
		Linear = lambda { |t| t }
	
		QuadraticEaseIn = lambda { |t| t * t }
		QuadraticEaseOut = lambda { |t| t * (2.0 - t) }
		QuadraticEaseInOut = lambda { |t| (t < 0.5) ? 2.0 * t * t : 1.0 - 2.0 * (t - 1.0) ** 2 }	
	
		CubicEaseIn = lambda { |t| t ** 3 }
		CubicEaseOut = lambda { |t| 1.0 + (t - 1.0) ** 3 }
		CubicEaseInOut = lambda { |t| (t < 0.5) ? 4.0 * t ** 3 : 1.0 + 4.0 * (t - 1.0) ** 3 }
		
		QuarticEaseIn = lambda { |t| t ** 4 }
		QuarticEaseOut = lambda { |t| 1.0 - (t - 1.0) ** 4 }
		QuarticEaseInOut = lambda { |t| (t < 0.5) ? 8.0 * t ** 4 : 1.0 - 8.0 * (t - 1.0) ** 4 }
	
		QuinticEaseIn = lambda { |t| t ** 5 }
		QuinticEaseOut = lambda { |t| 1.0 + (t - 1.0) ** 5 }
		QuinticEaseInOut = lambda { |t| (t < 0.5) ? 16.0 * t ** 5 : 1.0 + 16.0 * (t - 1.0) ** 5 }
	
		SineEaseIn = lambda { |t| Math::sin((t - 1.0) * M_PI_2) + 1.0 }
		SineEaseOut = lambda { |t| Math::sin(t * M_PI_2) }
		SineEaseInOut = lambda { |t| 0.5 * (1.0 - Math::cos(t * M_PI)) }

		CircularEaseIn = lambda { |t| 1.0 - Math::sqrt(1.0 - t * t) }
		CircularEaseOut = lambda { |t| Math::sqrt((2.0 - t) * t) }
		CircularEaseInOut = lambda { |t| 
			if t < 0.5
				0.5 * (1.0 - Math::sqrt(1.0 - 4.0 * t * t))
			else
				0.5 * Math::sqrt(-4.0 * t * t + 8.0 * t - 3.0) + 0.5
			end
		}

		ExponentialEaseIn = lambda { |t| (t == 0.0) ? t : 2.0 ** (10 * (t - 1.0)) }
		ExponentialEaseOut = lambda { |t| (t == 1.0) ? t : 1.0 - 2.0 ** (-10.0 * t) }
		ExponentialEaseInOut = lambda { |t|  
			if t == 0.0 or t == 1.0
				t
			elsif t < 0.5
				0.5 * 2.0 ** (20.0 * t - 10.0)
			else
				1.0 - 0.5 * 2.0 ** (-20.0 * t + 10.0)
			end
		}

		ElasticEaseIn = lambda { |t| Math::sin(13.0 * M_PI_2 * t) * 2.0 ** (10 * (t - 1.0)) }
		ElasticEaseOut = lambda { |t| Math::sin(-13.0 * M_PI_2 * (t + 1.0)) * 2.0 ** (-10.0 * t) + 1.0 }
		ElasticEaseInOut = lambda { |t|
			if t < 0.5
				0.5 * Math::sin(13.0 * M_PI * t) * 2.0 ** (20.0 * t - 10.0)
			else
				0.5 * Math::sin(-13.0 * M_PI * t) * 2.0 ** (-20.0 * t + 10.0) + 1.0
			end
		}
	
		BackEaseIn = lambda { |t| ((1.70158 + 1.0) * t - 1.70158) * t * t }
		BackEaseOut = lambda { |t| 1.0 - ((1.70158 + 1.0) * (1.0 - t) - 1.70158) * (1.0 - t) ** 2 }
		BackEaseInOut = lambda { |t|
			if t < 0.5
				0.5 * ((1.70158 + 1.0) * (2.0 * t) - 1.70158) * (2.0 * t) ** 2
			else
				1.0 - 0.5 * ((1.70158 + 1.0) * (2.0 * (1.0 - t)) - 1.70158) * (2.0 * (1.0 - t)) ** 2
			end	
		}

		ExtremeBackEaseIn = lambda { |t| (t * t - Math::sin(t * M_PI)) * t }
		ExtremeBackEaseOut = lambda { |t| 1.0 - ((1.0 - t) ** 2 - Math::sin((1.0 - t) * M_PI)) * (1.0 - t) }
		ExtremeBackEaseInOut = lambda { |t|
			if t < 0.5
				0.5 * ((2.0 * t) ** 2 - Math::sin((2.0 * t) * M_PI)) * (2.0 * t)
			else
				1.0 - 0.5 * ((2.0 * (1.0 - t)) ** 2 - Math::sin((2.0 * (1.0 - t)) * M_PI)) * (2.0 * (1.0 - t))
			end
		}

		BounceEaseIn = lambda { |t| 1.0 - BounceEaseOut[1.0 - t] }
		BounceEaseOut = lambda { |t|
			if t < 1.0 / 2.75
				7.5625 * t * t
			elsif t < 2.0 / 2.75
				t -= 1.5 / 2.75
				7.5625 * t * t + 0.75
			elsif t < 2.5 / 2.75
				t -= 2.25 / 2.75
				7.5625 * t * t + 0.9375
			else
		    t -= 2.625 / 2.75
		    return 7.5625 * t * t + 0.984375
			end
		}
		BounceEaseInOut = lambda { |t| (t < 0.5) ? 0.5 * BounceEaseIn[t * 2.0] : 0.5 * BounceEaseOut[t * 2.0 - 1.0] + 0.5 }	

		Smoothstep = lambda { |t| t * t * (3 - 2 * t) }
	
	end
	
end