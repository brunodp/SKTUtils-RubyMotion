# Workaround for Rubymotion's GLKit Bugs (RM 3.14 stable)
class GLKVector2
	def x
		v[0]
	end
	
	def y
		v[1]
	end
end