local M = {}

local function maybe_require (modname)
	local mod = nil
	pcall(function () mod = require(modname) end)
	return mod
end

local lfs = maybe_require('lfs')

--[========================================================================]--
--[ extendtable (first, second) {{{                                        ]--
--[                                                                        ]--
--[ Description:                                                           ]--
--[   Extend the first table with all the elements of the second.          ]--
--[                                                                        ]--
--[ Returns nothing.                                                       ]--
--[========================================================================]--
M.extendtable = function (first, second)
	local _, e
	for _, e in ipairs(second) do
		first[#first+1] = e
	end
end
--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

--[========================================================================]--
--[ isdir (dirname) {{{                                                    ]--
--[                                                                        ]--
--[ Description:                                                           ]--
--[   Does the specified directory exist, and is it a directory?           ]--
--[                                                                        ]--
--[ Params:                                                                ]--
--[   1) dirname - dir to check                                            ]--
--[                                                                        ]--
--[ Returns:                                                               ]--
--[   1) true/false                                                        ]--
--[========================================================================]--
M.isdir = function (dirname)
	local isdir = false
	local diratts

	if lfs then
		diratts = lfs.attributes(dirname)
		isdir = diratts and diratts.mode == 'directory'
	elseif os.execute('[ -d "' .. dirname .. '" ]') then
		isdir = true
	end

	return isdir
end
--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

--[========================================================================]--
--[ isfile (filename) {{{                                                  ]--
--[                                                                        ]--
--[ Description:                                                           ]--
--[   Does the specified file exist, and is it a normal file?              ]--
--[                                                                        ]--
--[ Params:                                                                ]--
--[   1) filename - file to check                                          ]--
--[                                                                        ]--
--[ Returns:                                                               ]--
--[   1) true/false                                                        ]--
--[========================================================================]--
M.isfile = function (filename)
	local isfile = false
	local fileatts

	if lfs then
		fileatts = lfs.attributes(filename)
		isfile = fileatts and fileatts.mode == 'file'
	elseif os.execute('[ -f "' .. filename .. '" ]') then
		isfile = true
	end

	return isfile
end
--[========================================================================]--
--[ }}}                                                                    ]--
--[========================================================================]--

return M
