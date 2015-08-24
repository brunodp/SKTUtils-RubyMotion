class MyScene < SKScene		
	# These flags enable (1) or disable (0) the various effects that happen when
	# a ball collides with a border, the barrier, or another ball. Turning them
	# all on at the same time might result in sea sickness... ;-)
	FLASH_BALL     = 1
	FLASH_BORDER   = 1
	FLASH_BARRIER  = 1
	SCALE_BALL     = 1
	SCALE_BORDER   = 0
	SCALE_BARRIER  = 1
	SQUASH_BALL    = 1
	STRETCH_BALL   = 1
	SCREEN_SHAKE   = 1
	SCREEN_ZOOM    = 1
	SCREEN_TUMBLE  = 1
	COLOR_GLITCH   = 1
	BARRIER_JELLY  = 1

	# Set this to true to enable debug shapes.
	SKT::DebugDrawEnabled = false
	
	# How fat the borders around the screen are
	BORDER_THICKNESS = 20.0
	
	# Categories for physics collisions
	BALL_CATEGORY 	 = 1 << 0
	BORDER_CATEGORY  = 1 << 1
	BARRIER_CATEGORY = 1 << 2
	
  def initWithSize(size)
    super
		
		setup_scene
		
    self
  end
	
	def setup_scene
		# Preload the font, otherwise there is a small delay when creating the
		# first text label.
		SKLabelNode.labelNodeWithFontNamed('HelveticaNeue-Light')
		
		@scene_background_color = SKColorWithRGB(8, 57, 71)
		@border_color = SKColorWithRGB(160, 160, 160)
		@border_flash_color = SKColor.whiteColor
		@barrier_color = SKColorWithRGB(212, 212, 212)
		@barrier_flash_color = @border_flash_color
		@ball_flash_color = SKColor.redColor
		
		self.scaleMode = SKSceneScaleModeResizeFill
		self.backgroundColor = @scene_background_color
		
		# By placing the scene's anchor point in the center of the screen and the
		# world layer at the scene's origin, you can make the entire scene rotate
		# around its center (for example for the screen tumble effect). You need
		# to set the anchor point before you add the world pivot node.
		self.anchorPoint = [0.5, 0.5]
		
		# For screen zoom and tumble, the world layer must sit in a separate pivot
		# node that centers the world on the screen.
		# The origin of the pivot node must be the center of the screen.
		@world_pivot = SKNode.node
		self.addChild(@world_pivot)
		
		# The layer that contains all the nodes. Having a separate world node is
		# necessary for the screen shake effect because you cannot apply that to
		# an SKScene directly.
		# Create the world layer. This is the only node that is added directly
		# to the pivot node. If you have a HUD layer you would add that directly
		# to the scene and make it sit above the world layer.
		@world_layer = SKNode.node
		@world_layer.position = self.frame.origin
		@world_pivot.addChild(@world_layer)
		
		self.physicsWorld.gravity = [0, 0]
		self.physicsWorld.contactDelegate = self
		
		# Put the game objects into the world. We use delays here to make some
		# objects appear earlier than others, which looks cooler.
		add_borders
		self.skt_performSelector('add_barrier', onTarget: self, afterDelay: 1.5)
		self.skt_performSelector('add_balls', onTarget: self, afterDelay: 2.5)
		self.skt_performSelector('show_label', onTarget: self, afterDelay: 6.0)

		# Make the barrier rotate around its center.
		self.skt_performSelector('animate_barrier', onTarget: self, afterDelay: 4.0)
	end

	# Create four border nodes, one for each screen edge. The nodes all have
	# the same shape -- a rectangle that is taller than it is wide -- but are
	# rotated by different angles.
	def add_borders
		distance = 50.0
		
		left_border = new_border(self.size.height, false)
		left_border.position = [BORDER_THICKNESS / 2.0 - distance, self.size.height / 2.0]
		@world_layer.addChild(left_border)
		
		right_border = new_border(self.size.height, false)
		right_border.position = [self.size.width - BORDER_THICKNESS / 2.0 + distance, self.size.height / 2.0]
		right_border.zRotation = Math::PI
		@world_layer.addChild(right_border)

		top_border = new_border(self.size.width, true)
		top_border.position = [self.size.width / 2.0, self.size.height - BORDER_THICKNESS / 2.0 + distance]
		top_border.zRotation = Math::PI / -2
		@world_layer.addChild(top_border)

		bottom_border = new_border(self.size.width, true)
		bottom_border.position = [self.size.width / 2.0, BORDER_THICKNESS / 2.0 - distance]
		bottom_border.zRotation = Math::PI / 2
		@world_layer.addChild(bottom_border)
		
		# Make the borders appear with a bounce animation.
		add_effect_to_border(left_border, left_border.position, CGPointMake(left_border.position.x + distance, left_border.position.y), 0.5)
		add_effect_to_border(right_border, right_border.position, CGPointMake(right_border.position.x - distance, right_border.position.y), 0.5)
		add_effect_to_border(top_border, top_border.position, CGPointMake(top_border.position.x, top_border.position.y - distance), 1.0)
		add_effect_to_border(bottom_border, bottom_border.position, CGPointMake(bottom_border.position.x, bottom_border.position.y + distance),1.0)
	end
	
	def new_border(length, horizontal = false)
		path = UIBezierPath.bezierPathWithRect([[0.0, 0.0], [BORDER_THICKNESS, length]])
		
		body = SKPhysicsBody.bodyWithPolygonFromPath(path.CGPath)
		body.dynamic = false
		body.friction = 0.0
		body.linearDamping = 0.0
		body.angularDamping = 0.0
		body.restitution = 0.0
		body.categoryBitMask = BORDER_CATEGORY
		body.collisionBitMask = BALL_CATEGORY
		body.contactTestBitMask = BALL_CATEGORY
		
		node = SKShapeNode.node
		node.path = path.CGPath
		node.fillColor = @border_color
		node.strokeColor = SKColor.clearColor
		node.lineWidth = 0.0
		node.glowWidth = 0.0
		node.physicsBody = body
		node.name = horizontal ? 'horizontal_border' : 'vertical_border'
		node.position = [-BORDER_THICKNESS / 2.0, -length / 2.0]
		
		pivot_node = SKNode.node
		pivot_node.addChild(node)
		
		pivot_node
	end

	def add_effect_to_border(border, start_position, end_position, delay)
		move_effect = SKT::MoveEffect.effectWithNode(border, duration: 0.5, startPosition: start_position, endPosition: end_position)
		move_effect.timingFunction = SKT::TimingFunction::BounceEaseOut

		border.runAction(SKAction.skt_afterDelay(delay, perform: SKAction.actionWithEffect(move_effect)))
	end

  # Create a node that sits in the middle of the screen so the balls have
  # something to bump into.
	def add_barrier
		# SKShapeNode does not have an anchorPoint property, so create a pivot
		# node that acts as the anchor point, and place it in the screen center.
		pivot_node = SKNode.node
		pivot_node.name = "barrier"
		pivot_node.position = [self.size.width / 2, self.size.height / 2]
		pivot_node.zRotation = Math::PI / 2
		@world_layer.addChild(pivot_node)
		
		width = BORDER_THICKNESS * 2
		height = 140
		path = UIBezierPath.bezierPathWithRect(CGRectMake(0, 0, width, height))
		
		# Create the shape node that draws the barrier on the screen. This is a
		# child of the pivot node, so it rotates and scales along with the pivot.
		node = SKShapeNode.node
		node.path = path.CGPath
		node.fillColor = @barrier_color
		node.strokeColor = SKColor.clearColor
		node.lineWidth = 0.0
		node.glowWidth = 0.0
		node.position = [-width / 2, -height / 2]
		pivot_node.addChild(node)
		
		# Create the physics body. This has the same shape as the shape node
		# but is attached to the pivot node. (It could also have been attached
		# to the shape node -- it doesn't really matter where it goes.)
		body = SKPhysicsBody.bodyWithRectangleOfSize(CGSizeMake(width, height))
		body.dynamic = false
		body.friction = 0.0
		body.linearDamping = 0.0
		body.angularDamping = 0.0
		body.restitution = 0.0
		body.categoryBitMask = BARRIER_CATEGORY
		body.collisionBitMask = BALL_CATEGORY
		body.contactTestBitMask = body.collisionBitMask
		pivot_node.physicsBody = body
		
	  # Make the barrier shape appear with an animation. We have to run this
	  # action on the pivot node, otherwise it happens from the barrier shape's
	  # bottom-left corner instead of its center.
		pivot_node.xScale = pivot_node.yScale = 0.15
		pivot_node.alpha = 0.0
		
		scale_effect = SKT::ScaleEffect.effectWithNode(pivot_node, duration: 1.0, startScale: pivot_node.skt_scale, endScale: CGPointMake(1.0, 1.0))
		scale_effect.timingFunction = SKT::TimingFunction::BackEaseOut
		
		rotate_effect = SKT::RotateEffect.effectWithNode(pivot_node, duration: 1.0, startAngle: rand() * Math::PI / 4, endAngle: pivot_node.zRotation)
		rotate_effect.timingFunction = SKT::TimingFunction::BackEaseOut
		
		pivot_node.runAction(
			SKAction.group([
				SKAction.fadeInWithDuration(1.0),
				SKAction.actionWithEffect(scale_effect),
				SKAction.actionWithEffect(rotate_effect)
			])
		)
	end
	
  # Rotate the barrier by 45 degrees with a "back ease in-out", which makes
  # it look very mechanical.
	def animate_barrier
		barrier_node = @world_layer.childNodeWithName('barrier')
		barrier_node.runAction(
			SKAction.repeatActionForever(
				SKAction.sequence([
					SKAction.waitForDuration(0.75),
					SKAction.runBlock(
						lambda {
							effect = SKT::RotateEffect.effectWithNode(barrier_node, duration: 0.25, startAngle: barrier_node.zRotation, endAngle: barrier_node.zRotation + Math::PI / 4)
							effect.timingFunction = SKT::TimingFunction::BackEaseInOut
							
							barrier_node.runAction(SKAction.actionWithEffect(effect))
						}
					)
				])
			)
		)
	end
	
	def add_balls
		# Add a ball sprite on the left side of the screen...
		ball_1 = new_ball_node
		ball_1.position = [100, self.size.height / 2.0]
		@world_layer.addChild(ball_1)
		
		# ...and add a ball sprite on the right side of the screen.
		ball_2 = new_ball_node
		ball_2.position = [self.size.width - 100, self.size.height / 2.0]
		@world_layer.addChild(ball_2)
				
		[ball_1, ball_2].each do |ball|
			ball.xScale = ball.yScale = 0.2
			scale_effect = SKT::ScaleEffect.effectWithNode(ball, duration: 0.5, startScale: ball.skt_scale, endScale: CGPointMake(1.0, 1.0))
			scale_effect.timingFunction = SKT::TimingFunction::BackEaseOut
			
			ball.runAction(SKAction.actionWithEffect(scale_effect))
		end
	end
	
	def new_ball_node
		# Create the sprite.
		sprite = SKSpriteNode.spriteNodeWithImageNamed('Ball')
		
		# Attach debug shapes.
		sprite.skt_attachDebugCircleWithRadius(sprite.size.width / 2.0, color: SKColor.yellowColor)
		sprite.skt_attachDebugLineFromPoint(CGPointZero, toPoint: CGPointMake(0, sprite.size.height / 2.0), color: SKColor.yellowColor)
		
		# Assign a random angle to the ball's velocity.
		ball_speed = 200
		angle = DegreesToRadians(rand() * 360)
		velocity = CGVectorMake(Math::cos(angle) * ball_speed, Math::sin(angle) * ball_speed)
		
		# Create a circular physics body. It collides with the borders and
		# with other balls. It is slightly smaller than the sprite.
		body = SKPhysicsBody.bodyWithCircleOfRadius((sprite.size.width / 2) * 0.9)
		body.dynamic = true
		body.velocity = velocity
		body.friction = 0.0
		body.linearDamping = 0.0
		body.angularDamping = 0.0
		body.restitution = 0.9
		body.categoryBitMask = BALL_CATEGORY
		body.collisionBitMask = BORDER_CATEGORY | BARRIER_CATEGORY | BALL_CATEGORY
		body.contactTestBitMask = body.collisionBitMask
		
		# Create a new node to hold the sprite. This is necessary for combining
		# nonuniform scaling effects with rotation. Some of the effects are placed
		# directly on the sprite, some on this pivot node.
		pivot_node = SKNode.node
		pivot_node.name = "ball"
		pivot_node.physicsBody = body
		pivot_node.addChild(sprite)
		
		pivot_node
	end
		
	# Adds a label with instructions.
	def show_label
		label_node = SKLabelNode.labelNodeWithFontNamed("HelveticaNeue-Light")
		label_node.text = "Tap to apply random impulse"
		label_node.fontSize = 12
		self.addChild(label_node)
		
		label_node.position = CGPointOffset(label_node.position, 0.0, 100.0)
		
		move_effect = SKT::MoveEffect.effectWithNode(label_node, duration: 4.0, startPosition: label_node.position, endPosition: CGPointOffset(label_node.position, 0.0, 20.0))
		move_effect.timingFunction = SKT::TimingFunction::Smoothstep
		label_node.runAction(SKAction.actionWithEffect(move_effect))
		
		label_node.alpha = 0.0
		label_node.runAction(SKAction.sequence([
			SKAction.waitForDuration(0.5),
			SKAction.fadeInWithDuration(2.0),
			SKAction.waitForDuration(1.0),
			SKAction.fadeOutWithDuration(1.0)
		]))
	end
	
	# ==================
	# = Touch Handling =
	# ==================
	def touchesBegan(touches, withEvent: event)
		# Add a random impulse to the balls whenever the user taps the screen.
		@world_layer.enumerateChildNodesWithName('ball', 
			usingBlock: lambda {|node, stop|
				max = 50.0
				impulse = CGVectorMake(Random.new.rand(-max..max), Random.new.rand(-max..max))
				node.physicsBody.applyImpulse(impulse)
				
				if STRETCH_BALL == 1
					stretch_ball(node.children[0])
				end
			}
		)
	end
	
	# ==============
	# = GAME LOGIC =
	# ==============
	def update(current_time)
		# do nothing
	end
	
	def didSimulatePhysics
		# Rotate the balls into the direction that they're flying.
		@world_layer.enumerateChildNodesWithName('ball',
			usingBlock: lambda {|node, stop|
				node.skt_rotateToVelocity(node.physicsBody.velocity, rate: 0.1)
			}
		)
	end
	
	def didBeginContact(contact)
		check_contact(contact.bodyA, contact.bodyB, contact.contactPoint)
		check_contact(contact.bodyB, contact.bodyA, contact.contactPoint)
	end
	
	def check_contact(body_1, body_2, contact_point)
		if (body_1.categoryBitMask & BALL_CATEGORY) != 0
			handle_ball_collision(body_1.node)

			if (body_2.categoryBitMask & BORDER_CATEGORY) != 0
				handle_collision_between_ball_and_border(body_1.node, body_2.node, contact_point)
			elsif (body_2.categoryBitMask & BARRIER_CATEGORY) != 0
				handle_collision_between_ball_and_barrier(body_1.node, body_2.node)
				
			end
		end
	end
	
	# This method gets called when a ball hits any other node.
	def handle_ball_collision(ball_node)
		ball_sprite = ball_node.children[0]

		if FLASH_BALL == 1
			flash_sprite_node_with_color(ball_sprite, @ball_flash_color)
		end
		
		if SCALE_BALL == 1
			scale_ball(ball_sprite)
		end
		
		if SQUASH_BALL == 1
			squash_ball(ball_sprite)
		end
		
		if SCREEN_SHAKE == 1
			screen_shake_with_velocity(ball_node.physicsBody.velocity)
		end
		
		if SCREEN_ZOOM == 1
			screen_zoom_with_velocity(ball_node.physicsBody.velocity)
		end
	end
	
	def handle_collision_between_ball_and_border(ball, border, contact_point)
		# Draw the flashing border above the other borders.
		border.skt_bringToFront
		
		if FLASH_BORDER == 1
			flash_shape_node_from_color_to_color(border, @border_flash_color, @border_color)
		end
		
		if BARRIER_JELLY == 1
			jelly(@world_layer.childNodeWithName('barrier'))
		end
		
		if SCREEN_TUMBLE == 1
			screen_tumble_at_contact_point(contact_point, border)
		end
		
		if SCALE_BORDER == 1
			scale_border(border)
		end
	end
	
	def handle_collision_between_ball_and_barrier(ball, barrier)
		if SCALE_BARRIER == 1
			scale_barrier(barrier)
		end
		
		if FLASH_BARRIER == 1
			node = barrier.children[0]
			flash_shape_node_from_color_to_color(node, @barrier_flash_color, @barrier_color)
		end
		
		if COLOR_GLITCH == 1
			self.runAction(SKAction.skt_colorGlitchWithScene(self, originalColor: @scene_background_color, duration: 0.1))
		end
	end
	
	# ======================
	# = Efectos Especiales =
	# ======================
	# Colorizes the node for a brief moment and then fades back to the original color.
	def flash_sprite_node_with_color(node, color)
		node.runAction(SKAction.sequence([
			SKAction.colorizeWithColor(color, colorBlendFactor: 1.0, duration: 0.025),
			SKAction.waitForDuration(0.05),
			SKAction.colorizeWithColorBlendFactor(0.0, duration: 0.1)
		]))
	end
	
	# Changes the fill color of the node for a brief moment and then restores the original color.
	def flash_shape_node_from_color_to_color(node, from_color, to_color)
		node.fillColor = from_color
		
		node.runAction(SKAction.sequence([
			SKAction.waitForDuration(0.15),
			SKAction.runBlock(lambda {node.fillColor = to_color})
		]))
	end
	
	# Scales the ball up and then down again. This effect is cumulative; if
	# the ball collides again while still scaled up, it scales up even more.
	def scale_ball(node)
		current_scale = node.skt_scale
		new_scale = CGPointMultiplyScalar(current_scale, 1.2)
		
		effect = SKT::ScaleEffect.effectWithNode(node, duration: 1.5, startScale: new_scale, endScale: current_scale)
		effect.timingFunction = SKT::TimingFunction::ElasticEaseOut
		
		node.runAction(SKAction.actionWithEffect(effect))
	end
	
	# Makes the ball wider but flatter, keeping the overall volume the same.
	# Squashing is useful for when an object collides with another object
	def squash_ball(node)
		ratio = 1.5
		current_scale = node.skt_scale
		new_scale = CGPointMultiply(current_scale, CGPointMake(ratio, 1.0 / ratio))
		
		effect = SKT::ScaleEffect.effectWithNode(node, duration: 1.5, startScale: new_scale, endScale: current_scale)
		effect.timingFunction = SKT::TimingFunction::ElasticEaseOut
		
		node.runAction(SKAction.actionWithEffect(effect))
	end
	
	# Makes the ball thinner but taller, keeping the overall volume the same.
	# Stretching is useful for when an object accelerates
	def stretch_ball(node)
		ratio = 1.5
		current_scale = node.skt_scale
		new_scale = CGPointMultiply(current_scale, CGPointMake(1.0 / ratio, ratio))
		
		effect = SKT::ScaleEffect.effectWithNode(node, duration: 0.5, startScale: new_scale, endScale: current_scale)
		effect.timingFunction = SKT::TimingFunction::CubicEaseOut
		
		node.runAction(SKAction.actionWithEffect(effect))
	end
	
	# Scale the border in the X direction. Because shape nodes do not have an
	# anchor point, this keeps the bottom-left corner fixed. Because the border
	# nodes are rotated, this makes them grow into the scene, which looks cool.
	def scale_border(node)
		current_scale = node.skt_scale
		new_scale = CGPointMake(current_scale.x * 2.0, current_scale.y)
		
		effect = SKT::ScaleEffect.effectWithNode(node, duration: 1.0, startScale: new_scale, endScale: current_scale)
		effect.timingFunction = SKT::TimingFunction::ElasticEaseOut
		
		node.runAction(SKAction.actionWithEffect(effect))
	end
	
	# Quickly scales the barrier down and up again
	def scale_barrier(node)
		current_scale = node.skt_scale
		new_scale = CGPointMultiplyScalar(current_scale, 0.5)
		
		effect = SKT::ScaleEffect.effectWithNode(node, duration: 0.5, startScale: new_scale, endScale: current_scale)
		effect.timingFunction = SKT::TimingFunction::ElasticEaseOut
		
		node.runAction(SKAction.actionWithEffect(effect))
	end
	
	# Creates a screen shake in the direction of the velocity vector, with
	# an intensity that is proportional to the velocity's magnitude.
  #
	# Note: The velocity is from *after* the collision, so the ball is already
	# travelling in the opposite direction. To find the impact vector we have
	# to negate the velocity. Unfortunately, if the collision is only in the X
	# direction, the Y direction also gets flipped (and vice versa). It would
	# be better if we could get the velocity at exactly the moment of impact,
	# but Sprite Kit doesn't seem to make this easy.
	def screen_shake_with_velocity(velocity)
		inverse_velocity = CGPointMake(-velocity.dx, -velocity.dy)
		hit_vector = CGPointDivideScalar(inverse_velocity, 50.0)
		
		@world_layer.runAction(SKAction.skt_screenShakeWithNode(@world_layer, amount: hit_vector, oscillations: 10, duration: 3.0))
	end
	
	# Magnify the screen by a tiny amount (102%) and bounce back to 100%.
	def screen_zoom_with_velocity(velocity)
		amount = CGPointMake(1.02, 1.02)
		@world_pivot.runAction(SKAction.skt_screenZoomWithNode(@world_pivot, amount: amount, oscillations: 10, duration: 3.0))
	end
	
	# Rotate the scene around its center. The amount of rotation depends on
	# where the ball hit the border (further from the center is a bigger angle).
	def screen_tumble_at_contact_point(point, border)
		length = 0
		
		if border.name == "horizontal_border"
			length = self.size.width / 2.0
		else
			length = self.size.height / 2.0
		end
		
		point = self.convertPoint(point, toNode: border)
		distance_to_center = (point.y - length) / length
		angle = DegreesToRadians(10) * distance_to_center
		
		@world_pivot.runAction(SKAction.skt_screenTumbleWithNode(@world_pivot, angle: angle, oscillations: 1, duration: 1))
	end
	
	# Scales up the node and then scales it back down with "bounce ease out"
	# timing, making it wobble like a jelly
	def jelly(node)
		effect = SKT::ScaleEffect.effectWithNode(node, duration: 0.25, startScale: CGPointMake(1.25, 1.25), endScale: node.skt_scale)
		effect.timingFunction = SKT::TimingFunction::BounceEaseOut
		
		node.runAction(SKAction.actionWithEffect(effect))
	end
	
end