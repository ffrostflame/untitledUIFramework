local component = {}
local metatable = { __index = component }
export type identity = typeof(setmetatable(
	{} :: {
		_internalState: {},
	},
	metatable
))

local function constructor(): identity
	local self = setmetatable({}, metatable)

	self._internalState = {}

	return self
end

return {
	new = constructor,
}
