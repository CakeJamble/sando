local T = require('libs.knife.test')

local function getTests(path)
	local files = {}
	if not love.filesystem.getInfo(path, "directory") then
		return files
	end

	for _,file in ipairs(love.filesystem.getDirectoryItems(path)) do
		local fp = path .. "/" .. file
		local info = love.filesystem.getInfo(fp)
		if info then
			if info.type == 'file' and file:match("%.lua$") then
				table.insert(files, fp)
			elseif info.type == 'directory' then
				local subFiles = getTests(fp)
				for _,f in ipairs(subFiles) do
					table.insert(files, f)
				end
			end
		end
	end

	table.sort(files)
	return files
end;

local function runTestFile(file)
	local env = setmetatable({}, {__index=_G})
	local f = assert(love.filesystem.load(file))
	f()
end;

local function loadTests(args)
	local files = {}

	if #args == 0 or args[1] == "all" then
		files = getTests("test")
	else
		for _,a in ipairs(args) do
			local info = love.filesystem.getInfo(a)
			if info then
				if info.type == 'directory' then
					local subFiles = getTests(a)
					for _,f in ipairs(subFiles) do table.insert(files, f) end
				elseif info.type == 'file' then
					table.insert(files, a)
				end
			else
				print("File not found", a)
				love.event.quit()
			end
		end
	end

	for _,file in ipairs(files) do
		print("Running test: ", file)
		runTestFile(file)
	end

	print("All tests finished")
	love.event.quit()
end;

return loadTests