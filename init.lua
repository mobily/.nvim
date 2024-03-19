require("options")
require("lazy.install")
require("lazy").setup({
	import = "plugins",
	dev = {
		path = "~/Projects/nvim-plugins",
		patterns = {
			"nui-components",
		},
		fallback = false,
	},
})
require("sandbox")
require("mappings")
require("hls")
