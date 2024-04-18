local library = ...

local component = library.from("TextLabel")

function component.hooks.onRender(props)
	props.renderCount += 1

	return props
end

return component
