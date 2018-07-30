--[========================================================================]--
--[ Set test suites                                                        ]--
--[========================================================================]--
local suites = {}

suites.create_simple = {
	'create_block_indented',
	'create_block_multiline',
	'create_block_single_line',
	'create_block_single_mapping',
	'create_block_commentstring',
}

suites.create_config = {
	'create_block_config_column',
	'create_block_config_style',
	'create_block_config_width',
	'create_block_indented_column',
	'create_block_indented_style',
	'create_block_indented_width',
}

suites.create_join = {
	'simple_join',
	'multilevel_join',
}

suites.reformat_simple = {
	'reformat_command',
	'reformat_mapping',
	'reformat_5_lines',
	'redo_ends',
	'reformat_column',
	'multilevel_reformat',
	'unicode_formatting',
	'reformat_empty',
}

suites.reformat_config = {
	'reformat_indented_width',
	'reformat_indented_column',
	'reformat_styles',
	'reformat_indented_style',
	'lisp_comments',
}

suites.errors = {
	'create_block_config_errs',
	'create_block_style_errs',
	'create_too_short',
}

suites.paragraph = {
	'preserve_list_simple',
}

suites.other = {
	'check_comment',
}

suites.create = {
	suites.create_simple,
	suites.create_config,
	suites.create_join,
}

suites.reformat = {
	suites.reformat_simple,
	suites.reformat_config,
}

suites.all = {
	suites.create,
	suites.reformat,
	suites.errors,
	suites.paragraph,
	suites.other,
}

--[========================================================================]--
--[ Suite resolver/iterator - module return                                ]--
--[========================================================================]--
return function (name)
	local stack = {
		{
			cursor = 1,
			suite = suites[name],
		}
	}

	local function iter ()
		if #stack == 0 then
			return nil
		end

		local state = stack[#stack]
		local toret = state.suite[state.cursor]
		if toret then

			if type(toret) == 'string' then
				state.cursor = state.cursor + 1
				return toret
			else
				state.cursor = state.cursor + 1
				stack[#stack+1] = {
					cursor = 1,
					suite = toret,
				}
				return iter()
			end
		end

		-- Clean the current state
		stack[#stack] = nil
		return iter()
	end

	return iter
end
