function setColor(color) 
	color = color or "github_dark_tritanopia"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(1, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(1, "NormalFloat", { bg = "none" })
	
end


setColor()
