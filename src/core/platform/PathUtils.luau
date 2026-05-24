export type Path = {
	length: number,
	nodes: { Vector3 },
}

local PathUtils = {}

function PathUtils.calcPath(defenseModel: Model & any): Path
	local nonLerpedNodes = {}
	local currentNode = defenseModel.Path.Start
	assert(currentNode, "no start node")

	while true do
		table.insert(nonLerpedNodes, currentNode.Position)
		local nextObj: ObjectValue? = currentNode:FindFirstChild("Next")
		if not nextObj then
			break
		end
		currentNode = nextObj.Value
	end

	local lerpedNodes = { nonLerpedNodes[1] }
	local totalLength = 0
	local cursorPos = nonLerpedNodes[1]
	local carry = 0

	for i = 2, #nonLerpedNodes do
		local goal = nonLerpedNodes[i]
		local segment = goal - cursorPos
		local segmentLen = segment.Magnitude

		if segmentLen <= 1e-8 then
			cursorPos = goal
			continue
		end

		local dir = segment / segmentLen
		totalLength += segmentLen

		local remainingOnSegment = segmentLen

		while remainingOnSegment + carry >= 1 do
			local need = 1 - carry
			cursorPos = cursorPos + dir * need
			table.insert(lerpedNodes, cursorPos)
			remainingOnSegment -= need
			carry = 0
		end

		carry += remainingOnSegment
		cursorPos = goal
	end

	local lastOriginal = nonLerpedNodes[#nonLerpedNodes]
	local lastSample = lerpedNodes[#lerpedNodes]
	if (lastOriginal - lastSample).Magnitude > 1e-4 then
		table.insert(lerpedNodes, lastOriginal)
	end

	return {
		length = totalLength,
		nodes = lerpedNodes,
	}
end

function PathUtils.getPosFromDist(path: Path, dist: number): Vector3
	local currentIndex = 1 + math.floor(dist)
	local currentNode = path.nodes[currentIndex]
	local nextNode = path.nodes[1 + currentIndex]
	if not nextNode then
		return currentNode
	end

	local partialDist = dist - math.floor(dist)
	return currentNode:Lerp(nextNode, partialDist)
end

return PathUtils
