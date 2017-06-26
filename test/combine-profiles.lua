#! /usr/bin/env lua

local utils = require("utils")

-- Constants relating to vim's profile output
local COUNT_INDICATION = 5
local TOTAL_START = 9
local TOTAL_END = 16
local SELF_START = 20
local SELF_END = 27
local REAL_LINE_START = 29

--[========================================================================]--
--[ parseargs (args) {{{                                                   ]--
--[========================================================================]--
local function parseargs (args)
	local parsed = {}

	local function addarg (name, elem, uniq)
		if parsed[name] == nil then
			if uniq then
				parsed[name] = elem
			else
				parsed[name] = {elem}
			end
		else
			if uniq then
				error("Multiple instances of unique argument --" .. name)
			else
				local l = parsed[name]
				l[#l+1] = elem
			end
		end
	end

	local STATE_LOCK   = -1
	local STATE_NORM   = 0
	local STATE_OUTPUT = 1
	local state        = STATE_NORM

	local lastarg = nil

	for _, arg in ipairs(args) do
		lastarg = arg
		if state == STATE_LOCK then
			addarg('profiles', arg)
		elseif state == STATE_NORM then
			if arg == '--' then
				state = STATE_LOCK
			elseif arg == '-o' or arg == '--output' then
				state = STATE_OUTPUT
			else
				addarg('profiles', arg)
			end
		elseif state == STATE_OUTPUT then
			addarg('output', arg, true)
			state = STATE_NORM
		else
			error("Programming error in parseargs()")
		end
	end

	if state ~= STATE_NORM and state ~= STATE_LOCK then
		error("Missing mandatory argument to arg: " .. lastarg)
	end

	if not parsed.profiles then
		parsed.profiles = {}
	end

	return parsed
end
--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

--[========================================================================]--
--[ printprofile (profile, tofile) {{{                                     ]--
--[========================================================================]--
local function printprofile (profile, tofile)
	local out
	if tofile then
		out = io.open(tofile, 'w')
	else
		out = io.output()
	end

	for k, v in pairs(profile.scripts) do
		out:write("SCRIPT: " .. k .. "\n")
		for m, n in ipairs(v.lines) do
			out:write(string.format(
				"%+e\t%+e\t%+e\t%s\n",
				(n.callcount or -1),
				(n.total or -1),
				(n.self or -1),
				n.text))
		end
	end

	if tofile then
		out:close()
	end
end
--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

--[========================================================================]--
--[ readprofile (profilefile) {{{                                          ]--
--[========================================================================]--
local function readprofile (profilefile)
	local STATE_NONE           = 0
	local STATE_SCRIPTHEADER   = 1
	local STATE_SCRIPTBODY     = 2
	local STATE_FUNCTIONHEADER = 3
	local STATE_FUNCTIONBODY   = 4
	local STATE_TOTALFUNCTIONS = 5
	local STATE_SELFFUNCTIONS  = 6
	local state = STATE_NONE

	local scripts = {}
	local funcs = {}

	local function newthing (name, thingtype) -- {{{

		local function thingaddline (this, line) -- {{{
			local callcount = 0
			local total = 0.0
			local self = 0.0

			if line:sub(COUNT_INDICATION, COUNT_INDICATION) ~= " " then
				-- there is a call count
				local cc = line:match('^%s*(%d+)')
				callcount = tonumber(cc)
			end

			if line:sub(TOTAL_START, TOTAL_START) ~= " " then
				local cc = line:sub(TOTAL_START, TOTAL_END)
				total = tonumber(cc)
			end

			if line:sub(SELF_START, SELF_START) ~= " " then
				local cc = line:sub(SELF_START, SELF_END)
				self = tonumber(cc)
			end

			local baseline = line:sub(REAL_LINE_START)
			if baseline:match("^%s*$") or baseline:match("^%s*\".*$") or
		   	baseline:match("^%s*end") then
				-- line is a comment
				this.lines[#this.lines+1] = {
					["callcount"] = nil,
					["total"] = nil,
					["self"] = nil,
					["text"] = baseline,
				}
			else
				this.lines[#this.lines+1] = {
					["callcount"] = callcount,
					["total"] = total,
					["self"] = self,
					["text"] = baseline,
				}
			end
		end -- }}}

		local function thingclose (this) -- {{{
			if thingtype == 'script' then
				scripts[name] = this
			elseif thingtype == 'func' then
				if not this.callcount then this.callcount = 0 end
				if not this.self then this.self = 0.0 end
				if not this.total then this.total = 0.0 end
				funcs[name] = this
			end
		end -- }}}

		return {
			["name"] = name,
			["lines"] = {},
			["addline"] = thingaddline,
			["close"] = thingclose,
		}
	end -- }}}

	local function statechange (to) -- {{{
		state = to
	end -- }}}

	-- A 'thing' is either a script or a function that we're currently
	-- processing.
	local thing = newthing('fake', 'nothing')

	for line in io.lines(profilefile) do
		if state == STATE_NONE then
			local scriptname = line:match("^SCRIPT%s+(.*)$")
			if scriptname then
				statechange(STATE_SCRIPTHEADER)
				thing:close()
				thing = newthing(scriptname, 'script')
			elseif line:match("^%s*$") then
				-- blank line, skip
			else
				error("Unexpected line :" .. line)
			end
		elseif state == STATE_SCRIPTHEADER then
			-- STATE: SCRIPTHEADER
			if line == "count  total (s)   self (s)" then
				statechange(STATE_SCRIPTBODY)
			end
		elseif state == STATE_SCRIPTBODY then
			-- STATE: SCRIPTBODY
			local scriptname = line:match("^SCRIPT%s+(.*)$")
			local funcname = line:match("^FUNCTION%s+(.*)$")
			if scriptname then
				statechange(STATE_SCRIPTHEADER)
				thing:close()
				thing = newthing(scriptname, 'script')
			elseif funcname then
				statechange(STATE_FUNCTIONHEADER)
				thing:close()
				thing = newthing(funcname, 'func')
			elseif line == "FUNCTIONS SORTED ON TOTAL TIME" then
				statechange(STATE_TOTALFUNCTIONS)
				thing:close()
			else
				thing:addline(line)
			end
		elseif state == STATE_FUNCTIONHEADER then
			-- STATE: FUNCTIONHEADER
			if line == "count  total (s)   self (s)" then
				statechange(STATE_FUNCTIONBODY)
			else
				local cc = tonumber(line:match("^Called (.*) times$"))
				local self = tonumber(line:match("^%s*Self time:%s*(.*)$"))
				local total = tonumber(line:match("^%s*Total time:%s*(.*)$"))
				if cc then
					thing.callcount = cc
				elseif self then
					thing.self = self
				elseif total then
					thing.total = total
				end
			end
		elseif state == STATE_FUNCTIONBODY then
			-- STATE: FUNCTIONBODY
			local funcname = line:match("^FUNCTION%s+(.*)$")
			if funcname then
				statechange(STATE_FUNCTIONHEADER)
				thing:close()
				thing = newthing(funcname, 'func')
			elseif line == "FUNCTIONS SORTED ON TOTAL TIME" then
				statechange(STATE_TOTALFUNCTIONS)
				thing:close()
			else
				thing:addline(line)
			end
		elseif state == STATE_TOTALFUNCTIONS then
			-- STATE: TOTALFUNCTIONS
			if line == "FUNCTIONS SORTED ON SELF TIME" then
				-- TODO use total functions?
				statechange(STATE_SELFFUNCTIONS)
			end
		elseif state == STATE_SELFFUNCTIONS then
			-- STATE: SELFFUNCTIONS
			-- TODO use self functions?
		else
			error("Programming error, state: " .. state)
		end
	end

	return {
		["scripts"] = scripts,
		["funcs"] = funcs,
	}
end
--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

--[========================================================================]--
--[ mungefunctions (profile) {{{                                           ]--
--[========================================================================]--
local function mungefunctions (profile)
	local _

	local funcs = {
		["global"] = {},
		["byscript"] = {},
	}

	for funcname, func in pairs(profile.funcs) do
		local m, n
		_, _, m, n = funcname:find("^<SNR>(%d*)_(%S*)%(.*$")
		if m then
			-- A byscript function linked to script `m`
			func.name = n
			local entry = { ["name"] = n, ["func"] = func }
			if funcs.byscript[m] then
				funcs.byscript[m][#funcs.byscript[m] + 1] = entry
			else
				funcs.byscript[m] = { entry }
			end
		else
			-- Not a byscript function
			func.name = funcname:match("^(.*)%(.*$")
			funcs.global[func.name] = func
		end
	end

	-- We know which functions are global and which are per script. Now we have
	-- to deduce which functions are defined in which script.
	local scriptsbyglobaldefines = {}
	for _, script in pairs(profile.scripts) do
		local idefine = {}
		for _, line in ipairs(script.lines) do
			local smatch = line.text:match("^%s*function!? s:(%S*)%(.*$")
			if not smatch then
				smatch = line.text:match("^%s*fu!? s:(%S*)%(.*$")
			end

			local fmatch = line.text:match("^%s*function!? (%S*)%(.*$")
			if not fmatch then
				fmatch = line.text:match("^%s*fu!? (%S*)%(.*$")
			end

			if smatch then
				-- This script defines this function
				idefine[smatch] = true
			elseif fmatch then
				scriptsbyglobaldefines[fmatch] = script
			end
		end

		for scriptnum, scriptfuncs in pairs(funcs.byscript) do
			local allmatch = true
			local fentry
			for _, fentry in ipairs(scriptfuncs) do
				if not idefine[fentry.name] then
					allmatch = false
					break
				end
			end

			if allmatch then
				script.number = scriptnum
				break
			end
		end

		if not script.number then
			script.number = -1
		end
	end

	-- All scripts now have a `number`. We now perform the unpleasant operation
	-- of "function unfolding", where we remove the '\' interpretation of vim's
	-- profiling evaluator.

	for _, script in pairs(profile.scripts) do
		-- Make a list of all functions defined in this script
		local globalshere = {}
		local scriptfshere = {}

		for k, v in pairs(scriptsbyglobaldefines) do
			if v.name == script.name then
				globalshere[#globalshere + 1] = funcs.global[k]
			end
		end

		for _, v in ipairs(funcs.byscript[script.number] or {}) do
			scriptfshere[#scriptfshere + 1] = v
		end

		local function findstartandend(func) -- {{{
			local linecount = #script.lines
			local startl = 0
			local endl = 0
			local nesting = 0
			for linenum, line in ipairs(script.lines) do
				if line.text:match("^%s*fu!?%s*" .. func.name) or
				   line.text:match("^%s*function!?%s*" .. func.name) then
					-- finding start
					if startl == 0 then
						startl = linenum
					else
						nesting = nesting + 1
					end
				elseif startl ~= 0 and (line.text:match("^%s*endf%s*$") or
				                        line.text:match("^%s*endfunction")) then
					-- finding end
					if nesting == 0 then
						endl = linenum
					else
						nesting = nesting - 1
					end
				end

				if endl ~= 0 then
					break
				end
			end

			return startl, endl
		end -- }}}

		local function unfold (func) -- {{{
			local sl, el = findstartandend(func)

			script.lines[sl].callcount = func.callcount
			script.lines[sl].self = func.self
			script.lines[sl].total = func.total

			local curlinescript = sl + 1
			local curlinefunc = 1

			while true do
				if curlinescript >= el then break end
				local scriptl = script.lines[curlinescript]
				local funcl = func.lines[curlinefunc]

				if scriptl.text == funcl.text then
					scriptl.callcount = funcl.callcount
					scriptl.self = funcl.self
					scriptl.total = funcl.total
					curlinescript = curlinescript + 1
					curlinefunc = curlinefunc + 1
				elseif funcl.text:match("^" .. utils.patternescape(scriptl.text)) then
					scriptl.callcount = funcl.callcount
					scriptl.self = funcl.self
					scriptl.total = funcl.total

					local function abortwhen ()
						local tomatch = scriptl.text:match("^%s*\\%s*(.*)$")
						local fullmatch = utils.patternescape(tomatch) .. "$"
						return funcl.text:match(fullmatch)
					end

					repeat
						curlinescript = curlinescript + 1
						scriptl = script.lines[curlinescript]
						scriptl.callcount = nil
						scriptl.self = nil
						scriptl.total = nil
					until abortwhen()
					curlinescript = curlinescript + 1
					curlinefunc = curlinefunc + 1
				else
					error("Don't know how to react: " ..
					      "<<" .. curlinefunc .. ":" .. funcl.text .. ">> " ..
					      "<<" .. curlinescript .. ":" .. scriptl.text .. ">>")
				end
			end
		end -- }}}

		-- CC
		for _, v in ipairs(scriptfshere) do
			v.func.name = "s:" .. v.func.name
			unfold(v.func)
		end

		for _, v in ipairs(globalshere) do
			unfold(v)
		end
	end

	return profile
end
--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

--[========================================================================]--
--[ consprofile (profiles, newprofile) {{{                                 ]--
--[========================================================================]--
local function consprofile (profiles, newprofile)

	local newscripts = newprofile.scripts or {}

	for k, v in pairs(newscripts) do
		if profiles.scripts[k] then
			-- Sum the callcounts etc. throughout the script
			local olines = v.lines
			local lines = profiles.scripts[k].lines
			local count = #olines
			for lnum = 1, count do
				local line = lines[lnum]
				local oline = olines[lnum]
				if line.callcount then
					line.callcount = oline.callcount + line.callcount
				else
					line.callcount = oline.callcount
				end

				if line.total then
					line.total = line.total + oline.total
				end

				if line.self then
					line.self = line.self + oline.self
				end
			end
		else
			profiles.scripts[k] = v
		end
	end

	return profiles
end
--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

--[========================================================================]--
--[ main (args) {{{                                                        ]--
--[========================================================================]--
local function main (args)
	local args = parseargs(args)
	local profiles = {["scripts"] = {}, ["funcs"] = {}}

	for _, prof in ipairs(args.profiles) do
		if not utils.isfile(prof) then
			error("Cannot read profile " .. prof)
		else
			profiles = consprofile(profiles, mungefunctions(readprofile(prof)))
		end
	end

	printprofile(profiles, args.output)

	return 0
end
--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

local success, rc = pcall(main, arg)
if success then
	os.exit(rc)
else
	print("Error: " .. rc)
	os.exit(1)
end
