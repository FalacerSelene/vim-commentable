#! /usr/bin/env lua

local utils = require("utils")

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

	for line in io.lines(profilefile) do
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
