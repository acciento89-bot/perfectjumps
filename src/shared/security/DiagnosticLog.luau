--!strict

local DiagnosticLog = {}

local function quoted(value: any): string
	local text = tostring(value):gsub("[%c]", " ")
	return string.format("%q", text)
end

local function encoded(value: any): string
	local kind = type(value)
	if kind == "number" or kind == "boolean" then
		return tostring(value)
	end
	return quoted(value)
end

function DiagnosticLog.format(eventName: string, severity: string, fields: { [string]: any }?): string
	local parts = {
		"PJ_DIAG",
		"event=" .. quoted(eventName),
		"severity=" .. quoted(severity),
	}
	if fields then
		local keys = {}
		for key in fields do
			table.insert(keys, key)
		end
		table.sort(keys)
		for _, key in keys do
			table.insert(parts, key .. "=" .. encoded(fields[key]))
		end
	end
	return table.concat(parts, " ")
end

return table.freeze(DiagnosticLog)
