#! /usr/bin/env lua

local utils = require("utils")

-- Constants relating to vim's profile output
local COUNT_INDICATION = 5
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
		out:write("nothing\n")
		out:close()
	else
		print("nothing")
	end
end
--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

--[========================================================================]--
--[ readprofile (profilefile) {{{                                          ]--
--[========================================================================]--
local function readprofile (profilefile)
	local file, profile

	profile = {}

	local STATE_NONE           = 0
	local STATE_SCRIPTHEADER   = 1
	local STATE_SCRIPTBODY     = 2
	local STATE_FUNCTIONHEADER = 3
	local STATE_FUNCTIONBODY   = 4
	local STATE_TOTALFUNCTIONS = 5
	local STATE_SELFFUNCTIONS  = 6
	local state = STATE_NONE

	local scripts = {}
	local script = nil

	local function newscript (name)
		if script then
			scripts[script.name] = script
		elseif func then
			funcs[func.name] = func
		end
		func = nil
		script = {
			["name"] = name,
			["lines"] = {},
		}
	end

	local function scriptaddline (line)
		local callcount = 0
		if line:sub(COUNT_INDICATION, COUNT_INDICATION) ~= " " then
			-- there is a call count
			local cc = line:match('^%s*(%d+)')
			callcount = tonumber(cc)
		end

		local baseline = line:sub(REAL_LINE_START)
		if baseline:match("^%s*$") or baseline:match("^%s*\".*$") then
			-- line is a comment, don't add
		else
			local joinmatch = baseline:match("^%s*\\(.*)$")
			if joinmatch then
				-- Have to combine line joins
				local prevline = script.lines[#script.lines]
				local newline = {
					["callcount"] = prevline.callcount,
					["text"] = prevline.text .. joinmatch,
				}
				script.lines[script.lines] = newline
			else
				script.lines[#script.lines+1] = {
					["callcount"] = callcount,
					["text"] = baseline,
				}
			end
		end
	end

	local funcs = {}
	local func = nil

	local function newfunc (name)
		if script then
			scripts[script.name] = script
		elseif func then
			funcs[func.name] = func
		end
		script = nil
		func = {
			["name"] = name,
			["lines"] = {},
		}
	end

	local function funcaddline (line)
		local callcount = 0
		if line:sub(COUNT_INDICATION, COUNT_INDICATION) ~= " " then
			-- there is a call count
			local cc = line:match('^%s*(%d+)')
			callcount = tonumber(cc)
		end

		local baseline = line:sub(REAL_LINE_START)
		if baseline:match("^%s*$") or baseline:match("^%s*\".*$") then
			-- line is a comment, don't add
		else
			local joinmatch = baseline:match("^%s*\\(.*)$")
			if joinmatch then
				-- Have to combine line joins
				local prevline = func.lines[#func.lines]
				local newline = {
					["callcount"] = prevline.callcount,
					["text"] = prevline.text .. joinmatch,
				}
				func.lines[func.lines] = newline
			else
				func.lines[#func.lines+1] = {
					["callcount"] = callcount,
					["text"] = baseline,
				}
			end
		end
	end

	local function nomorefuncs ()
		if script then
			scripts[script.name] = script
		elseif func then
			funcs[func.name] = func
		end
		script = nil
		func = nil
	end

	local function statechange (to)
		state = to
	end

	for line in io.lines(profilefile) do
		if state == STATE_NONE then
			local scriptname = line:match("^SCRIPT%s+(.*)$")
			if scriptname then
				statechange(STATE_SCRIPTHEADER)
				newscript(scriptname)
			elseif line:match("^%s*$") then
				-- blank line, skip
			else
				error("Unexpected line :" .. line)
			end
		elseif state == STATE_SCRIPTHEADER then
			if line == "count  total (s)   self (s)" then
				statechange(STATE_SCRIPTBODY)
			end
		elseif state == STATE_SCRIPTBODY then
			local scriptname = line:match("^SCRIPT%s+(.*)$")
			local funcname = line:match("^FUNCTION%s+(.*)$")
			if scriptname then
				statechange(STATE_SCRIPTHEADER)
				newscript(scriptname)
			elseif funcname then
				statechange(STATE_FUNCTIONHEADER)
				newfunc(funcname)
			elseif line == "FUNCTIONS SORTED ON TOTAL TIME" then
				statechange(STATE_TOTALFUNCTIONS)
				nomorefuncs()
			else
				scriptaddline(line)
			end
		elseif state == STATE_FUNCTIONHEADER then
			if line == "count  total (s)   self (s)" then
				statechange(STATE_FUNCTIONBODY)
			end
		elseif state == STATE_FUNCTIONBODY then
			local funcname = line:match("^FUNCTION%s+(.*)$")
			if funcname then
				statechange(STATE_FUNCTIONHEADER)
				newfunc(funcname)
			elseif line == "FUNCTIONS SORTED ON TOTAL TIME" then
				statechange(STATE_TOTALFUNCTIONS)
				func = nil
			else
				funcaddline(line)
			end
		elseif state == STATE_TOTALFUNCTIONS then
			if line == "FUNCTIONS SORTED ON SELF TIME" then
				-- TODO use total functions
				statechange(STATE_SELFFUNCTIONS)
			end
		elseif state == STATE_SELFFUNCTIONS then
			-- TODO use self functions
		else
			error("Programming error, state: " .. state)
		end
	end

	profile.scripts = scripts
	profile.funcs = funcs

	return profile
end
--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

--[========================================================================]--
--[ consprofile (profiles, newprofile) {{{                                 ]--
--[========================================================================]--
local function consprofile (profiles, newprofile)
	local newprofile = {}
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
	local profiles = {}

	for _, prof in ipairs(args.profiles) do
		if not utils.isfile(prof) then
			error("Cannot read profile " .. prof)
		else
			profiles = consprofile(profiles, readprofile(prof))
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
