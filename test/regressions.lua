#! /usr/bin/env lua

local suites = require("suites")
local utils = require("utils")

--[========================================================================]--
--[ Colours {{{                                                            ]--
--[                                                                        ]--
--[ ANSI terminal colours for pretty output.                               ]--
--[========================================================================]--

local escape      = string.char(27)
local ansi_red    = escape .. '[31m' .. escape .. '[1m'
local ansi_green  = escape .. '[32m' .. escape .. '[1m'
local ansi_yellow = escape .. '[33m' .. escape .. '[1m'
local ansi_blue   = escape .. '[34m' .. escape .. '[1m'
local ansi_end    = escape .. '[m'

local function remove_colours ()
	ansi_red    = ''
	ansi_green  = ''
	ansi_yellow = ''
	ansi_blue   = ''
	ansi_end    = ''
end

--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

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

	local STATE_LOCK     = -1
	local STATE_NORM     = 0
	local STATE_SUITE    = 1
	local STATE_TESTDIR  = 2
	local STATE_VIMRC    = 3
	local STATE_READFILE = 4
	local STATE_VIMBIN   = 5
	local state          = STATE_NORM

	local lastarg = nil

	for _, arg in ipairs(args) do
		lastarg = arg
		if     state == STATE_LOCK      then
			addarg('tests', arg)
		elseif state == STATE_NORM      then
			if     arg == '-s' or arg == '--suite'     then
				state = STATE_SUITE
			elseif arg == '-d' or arg == '--testdir'   then
				state = STATE_TESTDIR
			elseif arg == '-v' or arg == '--vimrc'     then
				state = STATE_VIMRC
			elseif                arg == '--fromfile'  then
				state = STATE_READFILE
			elseif arg == '-b' or arg == '--vimbinary' then
				state = STATE_VIMBIN
			elseif arg == '-r' or arg == '--resolve'   then
				addarg('resolve_only', true, true)
			elseif arg == '-c' or arg == '--colours'   then
				addarg('use_colours', true, true)
			elseif arg == '-q' or arg == '--quiet'     then
				addarg('quiet', true, true)
			elseif arg == '-p' or arg == '--profiling' then
				addarg('profiling', true, true)
			elseif arg == '--'                         then
				state = STATE_LOCK
			else
				addarg('tests', arg)
			end
		elseif state == STATE_SUITE     then
			addarg('suites', arg)
			state = STATE_NORM
		elseif state == STATE_TESTDIR   then
			addarg('testdir', arg, true)
			state = STATE_NORM
		elseif state == STATE_VIMRC     then
			addarg('vimrc', arg, true)
			state = STATE_NORM
		elseif state == STATE_READFILE  then
			addarg('readfile', arg, true)
			state = STATE_NORM
		elseif state == STATE_VIMBIN    then
			addarg('vimbin', arg, true)
			state = STATE_NORM
		else
			error("Programming error in parseargs()")
		end
	end

	if state ~= STATE_NORM and state ~= STATE_LOCK then
		error("Missing mandatory argument to arg: " .. lastarg)
	elseif not parsed.testdir then
		parsed.testdir = os.getenv("PWD")
	end

	if not parsed.suites then
		parsed.suites = {}
	end

	if not parsed.tests then
		parsed.tests = {}
	end

	return parsed
end
--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

--[========================================================================]--
--[ assertfilesexist (args) {{{                                            ]--
--[                                                                        ]--
--[ Description:                                                           ]--
--[   Assert that the files given by command line argements exist.         ]--
--[                                                                        ]--
--[ Params:                                                                ]--
--[   1) args - The command line arguments.                                ]--
--[                                                                        ]--
--[ Returns:                                                               ]--
--[   1) The same arguments as passed in. Errors if any of the required    ]--
--[      files do not exist.                                               ]--
--[========================================================================]--
local function assertfilesexist (args)
	if not utils.isdir(args.testdir) then
		error("Could not find directory: " .. args.testdir)
	elseif args.vimrc and
	       not utils.isfile(args.vimrc) then
		error("Could not find file: " .. args.vimrc)
	elseif args.readfile and
	       args.readfile ~= '-' and
	       not utils.isfile(args.readfile) then
		error("Could not find file: " .. args.readfile)
	end
	return(args)
end
--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

--[========================================================================]--
--[ runsingletest (name, args) {{{                                         ]--
--[========================================================================]--
local function runsingletest (name, args)
	local profilename = "output/" .. name .. ".profile"
	local profilenameext = args.testdir .. "/" .. profilename
	local vimbin
	if args.vimbin then
		vimbin = args.vimbin
	else
		vimbin = 'vim'
	end

	local vimcmd = vimbin .. " -E -n -N -s"

	if args.vimrc then
		local curdir = os.getenv("PWD")
		vimcmd = vimcmd .. " -u '" .. curdir .. '/' .. args.vimrc .. "'"
	end

	if args.profiling then
		local profscript = "profile start " .. profilename .. "\n"
		profscript = profscript .. "profile! file */plugin/*.vim\n"
		profscript = profscript .. "profile! file */autoload/*.vim\n"
		profscript = profscript .. "silent source scripts/" .. name .. '.vim'

		-- for some reason travis doesn't like it if we don't give each one a
		-- new name.
		instructionfile = "prof-instruction-" .. name .. ".vim"

		proffile = io.open(args.testdir .. "/" .. instructionfile, 'w')
		proffile:write(profscript)
		proffile:close()
		vimcmd = vimcmd .. ' -c "silent source ' .. instructionfile .. '"'
	else
		vimcmd = vimcmd .. ' -c "silent source scripts/' .. name .. '.vim"'
	end

	local mstfilename = args.testdir .. "/output/" .. name .. ".mst"
	local outfilename = args.testdir .. "/output/" .. name .. ".out"
	local diffilename = args.testdir .. "/output/" .. name .. ".diff"

	os.execute("( cd " .. args.testdir .. " && " .. vimcmd .. " )")

	local passed
	if utils.isfile(mstfilename) and utils.isfile(outfilename) then
		passed = os.execute("diff " .. outfilename .. " " .. mstfilename ..
		                    " >" .. diffilename .. " 2>/dev/null")
	else
		passed = false
	end

	if passed == true or passed == 0 then
		passed = true
	else
		passed = false
	end

	if passed then
		os.execute("rm -rf '" .. diffilename .. "' &>/dev/null")
	end

	if args.profiling then
		os.execute("rm '" .. args.testdir .. "/"
		                  .. instructionfile .. "' &>/dev/null")
	end

	return passed
end
--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

--[========================================================================]--
--[ testlistfromargs (args) {{{                                            ]--
--[                                                                        ]--
--[ Description:                                                           ]--
--[   Create a list of tests to run from the command line arguments passed ]--
--[   in. This involves parsing the suite file and resolving any families  ]--
--[   given recursively.                                                   ]--
--[                                                                        ]--
--[ Params:                                                                ]--
--[   1) args - command line args.                                         ]--
--[                                                                        ]--
--[ Returns:                                                               ]--
--[   1) A list of test file names.                                        ]--
--[========================================================================]--
local function testlistfromargs (args)
	local testlist = {}
	local testset = {}
	local _, test, suite, suiteresolver
	for _, test in ipairs(args.tests) do
		if not testset[test] then
			testset[test] = true
			testlist[#testlist+1] = test
		end
	end
	for _, suite in ipairs(args.suites) do
		for test in suites(suite) do
			if not testset[test] then
				testset[test] = true
				testlist[#testlist+1] = test
			end
		end
	end
	return testlist
end
--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

--[========================================================================]--
--[ main (args) {{{                                                        ]--
--[========================================================================]--
local function main (args)
	local args = assertfilesexist(parseargs(args))

	if args.readfile then
		if args.readfile == '-' then
			args.readfile = '/dev/stdin'
		end

		for line in io.lines(args.readfile) do
			if line:sub(1, 1) == '@' then
				args.suites[#args.suites+1] = line:sub(2)
			else
				args.tests[#args.tests+1] = line
			end
		end
	end

	local mprint = function (toprint)
		if not args.quiet then
			print(toprint)
		end
	end

	if not args.use_colours then
		remove_colours()
	end

	if args.resolve_only then
		for _, test in ipairs(testlistfromargs(args)) do
			print(test)
		end
		return 0
	end

	mprint(ansi_yellow .. "===== START OF TESTS =====" .. ansi_end)

	local successcount = 0
	local failurecount = 0
	local failures = {}
	local notfoundcount = 0
	local notfound = {}
	local _, test
	for _, test in ipairs(testlistfromargs(args)) do
		if not utils.isfile(args.testdir .. "/scripts/" .. test .. ".vim") then
			print(test .. "... " .. ansi_red .. "NOTFOUND" .. ansi_end)
			notfoundcount = notfoundcount + 1
			notfound[#notfound+1] = test
		else
			local passed = runsingletest(test, args)
			if passed then
				print(test .. "... " .. ansi_green .. "PASSED" .. ansi_end)
				successcount = successcount + 1
			else
				print(test .. "... " .. ansi_red .. "FAILED" .. ansi_end)
				failurecount = failurecount + 1
				failures[#failures+1] = test
			end
		end
	end

	mprint(ansi_yellow .. "===== END OF TESTS =====" .. ansi_end)

	mprint(ansi_blue .. "TOTAL" .. ansi_end .. ":\t" .. (successcount + failurecount))
	mprint(ansi_blue .. "SUCCESSES" .. ansi_end .. ":\t" .. successcount)

	if failurecount ~= 0 then
		mprint(ansi_red .. "FAILURES" .. ansi_end .. ":\t" .. failurecount)
	end

	if notfoundcount ~= 0 then
		mprint(ansi_red .. "NOTFOUND" .. ansi_end .. ":\t" .. notfoundcount)
	end

	if failurecount == 0 and notfoundcount == 0 then
		return 0
	else
		return 1
	end
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
