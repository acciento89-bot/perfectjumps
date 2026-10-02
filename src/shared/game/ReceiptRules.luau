--!strict

local ReceiptRules = {}

function ReceiptRules.key(purchaseId: any): string
	return tostring(purchaseId)
end

function ReceiptRules.contains(receipts: { [string]: boolean }, purchaseId: string): boolean
	return receipts[purchaseId] == true
end

function ReceiptRules.trim(receipts: { [string]: boolean }, maximum: number): { [string]: boolean }
	local keys = {}
	for key, processed in receipts do
		if processed == true then
			table.insert(keys, key)
		end
	end
	table.sort(keys)
	local result = {}
	local first = math.max(1, #keys - math.max(1, maximum) + 1)
	for index = first, #keys do
		result[keys[index]] = true
	end
	return result
end

return table.freeze(ReceiptRules)
