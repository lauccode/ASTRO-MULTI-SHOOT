local MegaBomb = {}
MegaBomb.list = {}

function MegaBomb.new(x, y)
	local self = setmetatable({}, { __index = MegaBomb })
	self.x = x or 0
	self.y = y or 0
	self.l = 0.08
	self.maxL = 1.5
	self.growthSpeed = 0.028
	self.img = nil
	if Assets and Assets.images and Assets.images.megabomb then
		self.img = Assets.images.megabomb
	elseif love.graphics and love.graphics.newImage then
		self.img = love.graphics.newImage("sprites/mega_bomb.png")
	end

	-- shaders
	-- table.insert(MegaBomb.list, self)
	self.ls = 0.15
	self.canvas = love.graphics.newCanvas()
	-- self.img = love.graphics.newImage("media/boom.png")
	-- self.img:setFilter("linear", "linear")
	self.shader = love.graphics.newShader([[
	uniform sampler2D bump;
	vec4 effect(vec4 color, sampler2D tex, vec2 tex_pos, vec2 screen_pos) {
		vec2 d = vec2(6.0, 6.0) / love_ScreenSize.xy;
		float h  = texture2D(bump, tex_pos).r;
		float h2 = texture2D(bump, tex_pos + d * vec2(1.0, 0.0)).r;
		float h3 = texture2D(bump, tex_pos + d * vec2(0.0, 1.0)).r;
		return texture2D(tex, tex_pos + vec2(h - h2, h - h3) * 0.04);
	}]])

	if self.img then
		self.img:setFilter("linear", "linear")
	end

	table.insert(MegaBomb.list, self)
	return self
end

function MegaBomb:update(dt)
	self.l = self.l + self.growthSpeed
	if self.l >= self.maxL then
		return "kill"
	end

	-- shaders
	self.ls = self.ls + 0.015
	if self.ls >= 1 then return "kill" end
end

function MegaBomb:draw()
	if not self.img then
		return
	end

	-- shaders
	love.graphics.setColor(1, 1, 1, (1 - self.l) ^ 3)
	local s = self.l * 16
	local o = self.img:getWidth() / 2
	love.graphics.draw(self.img, self.x, self.y, 0, s, s, o, o)
	love.graphics.setColor(1, 1, 1, 1)

	local alpha = math.max(0, 1 - (self.l / self.maxL))
	love.graphics.setColor(1, 1, 1, alpha ^ 1.2)
	local s = self.l * 24
	local o = self.img:getWidth() / 2
	love.graphics.draw(self.img, self.x, self.y, 0, s, s, o, o)

	love.graphics.setColor(1, 1, 1, alpha ^ 2 * 0.5)
	local s2 = self.l * 16
	love.graphics.draw(self.img, self.x, self.y, 0, s2, s2, o, o)
	love.graphics.setColor(1, 1, 1, 1)

end

return MegaBomb


