table.insert(default_access.rules, {
	matches = {
		{
			{ "application.process.binary", "=", "Chromium" },
			{ "application.process.binary", "=", "vivaldi-bin" },
			{ "application.process.binary", "=", "vivaldi" },
			{ "application.process.binary", "=", "Chromium input" },
			{ "application.process.binary", "=", "electron" },
			{ "application.process.binary", "=", "ferdium" },
			{ "application.process.binary", "=", "webcord" },
		},
	},
	default_permissions = "rx",
})
