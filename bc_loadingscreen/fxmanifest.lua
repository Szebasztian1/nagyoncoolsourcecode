fx_version 'cerulean'
game 'gta5'

version '1.5.0'

loadscreen 'html/index.html'
-- No cursor: a loadscreen mouse-cursor holds NUI focus that can desync on
-- alt-tab/minimize and leave the spawn menu unclickable. Music = SPACE,
-- slides = arrow keys, so no mouse is needed here.
loadscreen_cursor 'no'

files {
	-- Load Index Page
	'html/index.html',
	-- Load Bootstrap & Custom Styles
	'html/css/bootstrap.min.css',
	'html/css/custom.css',
	'html/css/morphext.css',
	-- Load jQuery, Bootstrap and JavaScript 
	'html/js/jquery.min.js',
	'html/js/bootstrap.min.js',
	'html/js/popper.min.js',
	'html/js/app.js',
	'html/js/morphext.min.js',
	-- Load Image Resources
	--'html/img/logo.png',
	--'html/img/back.png',
	-- Load Audio Sources (song.mp3, song1.mp3 ... song4.mp3)
	'html/song*.mp3',
	'html/betolto.webm',
	--'html/video.js',
	'html/*.webp'
}