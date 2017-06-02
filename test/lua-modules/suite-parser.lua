local M = {}

local utils = require("utils")

--[========================================================================]--
--[ getsuiteresolver (filename) {{{                                        ]--
--[========================================================================]--
M.getsuiteresolver = function (filename)
	local TYPE_TEST = 0
	local TYPE_SUITE = 1

	-- resolvesuites (unresolved) -- {{{
	local function resolvesuites (unresolved)
		resolved = {}
		local resolving, entries
		for resolving, entries in pairs(unresolved) do

			-- Recursively reduce a suite down to a list of tests.
			local function resolvesinglesuite(suitename)
				if suitename == resolving then
					error("Circular reference to suite: " .. suitename)
				elseif resolved[suitename] then
					return resolved[suitename]
				elseif not unresolved[suitename] then
					error("Reference to undefined suite: " .. suitename)
				end

				local single = {}
				local _, entry
				for _, entry in ipairs(unresolved[suitename]) do
					if entry.type == TYPE_TEST then
						single[#single+1] = entry.name
					elseif entry.type == TYPE_SUITE then
						utils.extendtable(single, resolvesinglesuite(entry.name))
					end
				end
				return single
			end

			resolved[resolving] = {}
			local t = resolved[resolving]
			local _, entry
			for _,entry in ipairs(entries) do
				if entry.type == TYPE_TEST then
					t[#t+1] = entry.name
				elseif entry.type == TYPE_SUITE then
					utils.extendtable(t, resolvesinglesuite(entry.name))
				end
			end
		end
		return resolved
	end -- }}}

	-- readlines (filename) {{{
	local function readlines(filename)
		local read = {}
		local current, line
		for line in io.lines(filename) do
			if not string.match(line, "^[ \t]*#") and
			   not string.match(line, "^[ \t]*$") then
				local newsuite = line:match('^%[([a-zA-Z0-9_]*)%].*$')
				local suiteref = line:match('^%.%[([a-zA-Z0-9_]*)%].*$')
				local testname = line:match('^[ \t]*([a-zA-Z0-9_]*)[ \t]*$')
				if not (newsuite or suiteref or testname) then
					error("Invalid line in file " .. filename .. ":\n" ..
					      "  " .. line)
				elseif not (newsuite or current) then
					error("Definition outside of suite in line:\n" ..
					      "  " .. line)
				elseif newsuite then
					if read[newsuite] then
						error("Multiple definitions of suite " .. newsuite)
					else
						read[newsuite] = {}
						current = newsuite
					end
				elseif suiteref then
					local s = read[current]
					s[#s+1] = {
						["type"] = TYPE_SUITE,
						["name"] = suiteref,
					}
				elseif testname then
					local s = read[current]
					s[#s+1] = {
						["type"] = TYPE_TEST,
						["name"] = testname,
					}
				else
					error("Unreadable line at line:\n" ..
					      "  " .. line)
				end
			end
		end
		return read
	end -- }}}

	-- produceaccessor (filetable) {{{
	local function produceaccessor (filetable)
		return function (suitename)
			return filetable[suitename] or error("No such suite: " .. suitename)
		end
	end -- }}}

	return produceaccessor(resolvesuites(readlines(filename)))
end
--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

return M
