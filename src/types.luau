type Component<ComponentValues = {}, ComponentEvents = {}> = {
	values: ComponentValues,
	events: ComponentEvents,
}

type event<T...> = {
	trigger: (self: event<T...>, T...) -> (),
	connect: (self: event<T...>) -> (callback: (T...) -> ()) -> (),
}

type Value<T> = {
	set: (self: Value<T>, value: T) -> (),
	get: (self: Value<T>) -> T,
}

export type lib = {
	event: <T...>() -> event<T...>,
	value: <T>(initialValue: T) -> Value<T>,

	extends: <T, K, V, S, Props>(
		self: Component<T, K>,
		(base: Component<T, K>, props: Props) -> (V, S)
	) -> {
		new: (props: Props) -> Component<T & V, K & S>,

		identity: Component<T & V, K & S>,
	},
}

local lib: lib = ...

local basicComponent = {
	values = {},
	events = {},
}

local coloredElement = lib.extends(basicComponent, function()
	local rendered = lib.event()

	return {
		color = Color3.fromRGB(0, 0, 0),
	}, {
		rendered = rendered:connect(),
	}
end)

local clock = lib.extends(coloredElement.identity, function(_, props: { initialTimestamp: number })
	local values = {
		timestamp = lib.value(props.initialTimestamp),
	}
	local newTimestamp = lib.event()

	task.spawn(function()
		while true do
			values.timestamp:set(os.clock())
			newTimestamp:trigger(os.clock())

			task.wait(0.1)
		end
	end)

	return values, {
		newTimestamp = newTimestamp:connect(),
	}
end)

local textClock = lib.extends(clock.identity, function(base, props: { is24Hour: boolean })
	local textUpdated = lib.event()
	local values = {
		displayText = lib.value(""),
	}

	base.events.newTimestamp(function(newTime)
		values.displayText:set(tostring(newTime))
		textUpdated:trigger()
	end)

	return values, {
		textUpdated = textUpdated:connect(),
	}
end)

textClock.new({
	is24Hour = true,
})

return nil
