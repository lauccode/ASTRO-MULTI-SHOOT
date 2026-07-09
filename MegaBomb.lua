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
end

function MegaBomb:draw()
	if not self.img then
		return
	end

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


