/* bc_tasksystem — outline icon set (24x24, stroke = currentColor).
   Injected once as an SVG sprite; everything references it with <use href="#i-name">. */

window.Ach = window.Ach || {};

(function (A) {
	'use strict';

	const ICONS = {
		// interface
		x: '<path d="M18 6 6 18M6 6l12 12"/>',
		check: '<path d="m5 12 5 5L20 7"/>',
		// task pages (Tabler, as the former bc_tasksystem panel)
		sun: '<path d="M12 12m-4 0a4 4 0 1 0 8 0a4 4 0 1 0 -8 0"/><path d="M3 12h1m8 -9v1m8 8h1m-9 8v1m-6.4 -15.4l.7 .7m12.1 -.7l-.7 .7m0 11.4l.7 .7m-12.1 -.7l-.7 .7"/>',
		calendarWeek: '<path d="M4 7a2 2 0 0 1 2 -2h12a2 2 0 0 1 2 2v12a2 2 0 0 1 -2 2h-12a2 2 0 0 1 -2 -2v-12z"/><path d="M16 3v4"/><path d="M8 3v4"/><path d="M4 11h16"/><path d="M7 14h.013"/><path d="M10.01 14h.005"/><path d="M13.01 14h.005"/><path d="M16.015 14h.005"/><path d="M13.015 17h.005"/><path d="M7.01 17h.005"/><path d="M10.01 17h.005"/>',
		target: '<path d="M12 12m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0"/><path d="M12 12m-5 0a5 5 0 1 0 10 0a5 5 0 1 0 -10 0"/><path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0"/>',
		gift: '<path d="M3 8m0 1a1 1 0 0 1 1 -1h16a1 1 0 0 1 1 1v2a1 1 0 0 1 -1 1h-16a1 1 0 0 1 -1 -1z"/><path d="M12 8l0 13"/><path d="M19 12v7a2 2 0 0 1 -2 2h-10a2 2 0 0 1 -2 -2v-7"/><path d="M7.5 8a2.5 2.5 0 0 1 0 -5a4.8 8 0 0 1 4.5 5a4.8 8 0 0 1 4.5 -5a2.5 2.5 0 0 1 0 5"/>',
		circleCheck: '<path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0"/><path d="M9 12l2 2l4 -4"/>',
		inbox: '<path d="M4 4m0 2a2 2 0 0 1 2 -2h12a2 2 0 0 1 2 2v12a2 2 0 0 1 -2 2h-12a2 2 0 0 1 -2 -2z"/><path d="M4 13h3l3 3h4l3 -3h3"/>',
		fuel: '<path d="M14 11h1a2 2 0 0 1 2 2v3a1.5 1.5 0 0 0 3 0v-7l-3 -3"/><path d="M4 20v-14a2 2 0 0 1 2 -2h6a2 2 0 0 1 2 2v14"/><path d="M3 20l12 0"/><path d="M18 7v1a1 1 0 0 0 1 1h1"/><path d="M4 11l10 0"/>',
		lock: '<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V7a4 4 0 1 1 8 0v4"/><circle cx="12" cy="16" r="1"/>',
		search: '<circle cx="10" cy="10" r="7"/><path d="m21 21-6-6"/>',
		question: '<path d="M8 8a3.5 3 0 0 1 3.5-3h1A3.5 3 0 0 1 16 8a3 3 0 0 1-2 3 3 4 0 0 0-2 4"/><path d="M12 19v.01"/>',
		dashboard: '<rect x="4" y="4" width="6" height="8" rx="1"/><rect x="4" y="16" width="6" height="4" rx="1"/><rect x="14" y="12" width="6" height="8" rx="1"/><rect x="14" y="4" width="6" height="4" rx="1"/>',
		grid: '<rect x="4" y="4" width="6" height="6" rx="1"/><rect x="14" y="4" width="6" height="6" rx="1"/><rect x="4" y="14" width="6" height="6" rx="1"/><rect x="14" y="14" width="6" height="6" rx="1"/>',
		podium: '<path d="M3 21h18"/><path d="M9 21V8h6v13"/><path d="M3 21v-7h6"/><path d="M21 21v-10h-6"/><path d="m12 3 .9 1.8 2 .3-1.45 1.4.35 2-1.8-.95-1.8.95.35-2L9.1 5.1l2-.3z"/>',
		chart: '<rect x="3" y="12" width="6" height="8" rx="1"/><rect x="9" y="8" width="6" height="12" rx="1"/><rect x="15" y="4" width="6" height="16" rx="1"/><path d="M4 20h16"/>',
		user: '<circle cx="12" cy="7" r="4"/><path d="M6 21v-2a4 4 0 0 1 4-4h4a4 4 0 0 1 4 4v2"/>',
		navigation: '<path d="m12 18.5 7.27 2.46a.55.55 0 0 0 .7-.69L12 3 4.03 20.27a.55.55 0 0 0 .7.69z"/>',
		here: '<circle cx="12" cy="12" r="2"/><circle cx="12" cy="12" r="6"/><path d="M12 2v4M12 18v4M2 12h4M18 12h4"/>',
		sparkles: '<path d="M16 18a2 2 0 0 1 2 2 2 2 0 0 1 2-2 2 2 0 0 1-2-2 2 2 0 0 1-2 2zm0-12a2 2 0 0 1 2 2 2 2 0 0 1 2-2 2 2 0 0 1-2-2 2 2 0 0 1-2 2zM9 18a6 6 0 0 1 6-6 6 6 0 0 1-6-6 6 6 0 0 1-6 6 6 6 0 0 1 6 6z"/>',
		eye: '<circle cx="12" cy="12" r="2"/><path d="M22 12c-2.67 4.67-6 7-10 7s-7.33-2.33-10-7c2.67-4.67 6-7 10-7s7.33 2.33 10 7"/>',

		// trophies and rank
		trophy: '<path d="M8 21h8M12 17v4M7 4h10"/><path d="M17 4v8a5 5 0 0 1-10 0V4"/><circle cx="5" cy="9" r="2"/><circle cx="19" cy="9" r="2"/>',
		crown: '<path d="m12 6 4 6 5-4-2 10H5L3 8l5 4z"/>',
		star: '<path d="m12 17.75-6.17 3.25 1.18-6.88-5-4.87 6.9-1L12 2l3.09 6.25 6.9 1-5 4.87 1.18 6.88z"/>',
		medal: '<path d="M12 4v3M8 4v6M16 4v6"/><path d="m12 18.5-3 1.5.5-3.5-2-2 3-.5 1.5-3 1.5 3 3 .5-2 2 .5 3.5z"/>',
		flag: '<path d="M5 5a5 5 0 0 1 7 0 5 5 0 0 0 7 0v9a5 5 0 0 1-7 0 5 5 0 0 0-7 0z"/><path d="M5 21v-7"/>',

		// categories and achievements
		door: '<path d="M14 12v.01M3 21h18"/><path d="M6 21V5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v16"/>',
		car: '<circle cx="7" cy="17" r="2"/><circle cx="17" cy="17" r="2"/><path d="M5 17H3v-6l2-5h9l4 5h1a2 2 0 0 1 2 2v4h-2m-4 0H9m-6-6h15m-6 0V6"/>',
		walk: '<circle cx="13" cy="4" r="1"/><path d="m7 21 3-4M16 21l-2-4-3-3 1-6"/><path d="m6 12 2-3 4-1 3 3 3 1"/>',
		steering: '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="2"/><path d="M12 14v7M10 12 3.25 10M14 12l6.75-2"/>',
		users: '<circle cx="9" cy="7" r="4"/><path d="M3 21v-2a4 4 0 0 1 4-4h4a4 4 0 0 1 4 4v2M16 3.13a4 4 0 0 1 0 7.75M21 21v-2a4 4 0 0 0-3-3.85"/>',
		briefcase: '<rect x="3" y="7" width="18" height="13" rx="2"/><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2M12 12v.01M3 13a20 20 0 0 0 18 0"/>',
		cash: '<rect x="7" y="9" width="14" height="10" rx="2"/><circle cx="14" cy="14" r="2"/><path d="M17 9V7a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h2"/>',
		skull: '<path d="M12 4c4.42 0 8 3.36 8 7.5 0 1.9-.76 3.64-2 4.96V19a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1v-2.54c-1.25-1.32-2-3.06-2-4.96C4 7.36 7.58 4 12 4z"/><path d="M10 17v3M14 17v3"/><circle cx="9" cy="11" r="1"/><circle cx="15" cy="11" r="1"/>',
		pin: '<circle cx="12" cy="11" r="3"/><path d="m17.66 16.66-4.25 4.24a2 2 0 0 1-2.82 0l-4.25-4.24a8 8 0 1 1 11.32 0z"/>',
		road: '<path d="M4 19 8 5M16 5l4 14M12 8V6M12 13v-2M12 18v-2"/>',
		moto: '<circle cx="5" cy="16" r="3"/><circle cx="19" cy="16" r="3"/><path d="M7.5 14h5l4-4H6m1.5 4 4-4"/><path d="M13 6h2l1.5 3 2 4"/>',
		bike: '<circle cx="5" cy="18" r="3"/><circle cx="19" cy="18" r="3"/><path d="M12 19v-4l-3-3 5-4 2 3h3"/><circle cx="17" cy="5" r="1"/>',
		ship: '<path d="M2 20a2.4 2.4 0 0 0 2 1 2.4 2.4 0 0 0 2-1 2.4 2.4 0 0 1 2-1 2.4 2.4 0 0 1 2 1 2.4 2.4 0 0 0 2 1 2.4 2.4 0 0 0 2-1 2.4 2.4 0 0 1 2-1 2.4 2.4 0 0 1 2 1 2.4 2.4 0 0 0 2 1 2.4 2.4 0 0 0 2-1"/><path d="m4 18-1-5h18l-2 4M5 13V7h8l4 6M7 7V3H6"/>',
		heli: '<path d="m3 10 1 2h6"/><path d="M12 9a2 2 0 0 0-2 2v3a2 2 0 0 0 2 2h7a2 2 0 0 0 2-2c0-3.31-3.13-5-7-5z"/><path d="M13 9V6M5 6h15M15 9.1V13h5.5M15 19v-3M19 19h-8"/>',
		plane: '<path d="M16 10h4a2 2 0 0 1 0 4h-4l-4 7H9l2-7H7l-2 2H2l2-4-2-4h3l2 2h4L9 3h3z"/>',
		gauge: '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="1"/><path d="M13.41 10.59 16 8M7 12a5 5 0 0 1 5-5"/>',
		rocket: '<path d="M4 13a8 8 0 0 1 7 7 6 6 0 0 0 3-5 9 9 0 0 0 6-8 3 3 0 0 0-3-3 9 9 0 0 0-8 6 6 6 0 0 0-5 3"/><path d="M7 14a6 6 0 0 0-3 6 6 6 0 0 0 6-3"/><circle cx="15" cy="9" r="1"/>',
		moon: '<path d="M12 3h.39A7.5 7.5 0 0 0 20.31 15.45 9 9 0 1 1 12 3z"/>',
		moonstar: '<path d="M12 3h.39A7.5 7.5 0 0 0 20.31 15.45 9 9 0 1 1 12 3z"/><path d="M17 4a2 2 0 0 0 2 2 2 2 0 0 0-2 2 2 2 0 0 0-2-2 2 2 0 0 0 2-2M19 11h2m-1-1v2"/>',
		mountain: '<path d="M3 20h18L14.08 5.39a2.3 2.3 0 0 0-4.16 0z"/><path d="m7.5 11 2 2.5L12 11l2 3 2.5-2"/>',
		truck: '<circle cx="7" cy="17" r="2"/><circle cx="17" cy="17" r="2"/><path d="M5 17H3V6a1 1 0 0 1 1-1h9v12m-4 0h6m4 0h2v-6h-8m0-5h5l3 5"/>',
		siren: '<path d="M8 16v-4a4 4 0 0 1 8 0v4M3 12h1m8-9v1m8 8h1M5.6 5.6l.7.7m12.1-.7-.7.7"/><rect x="6" y="16" width="12" height="4" rx="1"/>',
		key: '<circle cx="15.5" cy="8.5" r="4.5"/><path d="m12.3 11.7-8.3 8.3v2h3v-2h2v-2h2l1.3-1.3"/><path d="M16 8h.01"/>',
		shoe: '<path d="M4 6h5.43a1 1 0 0 1 .86.5l1.06 1.82a3 3 0 0 0 1.9 1.4l4.68 1.12A4 4 0 0 1 21 14.73V17a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1z"/><path d="m14 13 1-2M8 18v-1a4 4 0 0 0-4-4H3M10 12l1.5-3"/>',
		route: '<circle cx="6" cy="19" r="2"/><circle cx="18" cy="5" r="2"/><path d="M12 19h4.5a3.5 3.5 0 0 0 0-7h-8a3.5 3.5 0 0 1 0-7H12"/>',
		rain: '<path d="M7 18a4.6 4.4 0 0 1 0-9 5 4.5 0 0 1 11 2h1a3.5 3.5 0 0 1 0 7"/><path d="M11 13v2m0 3v2m4-5v2m0 3v2"/>',
		binoculars: '<circle cx="6.5" cy="16" r="3.5"/><circle cx="17.5" cy="16" r="3.5"/><path d="M10 16h4M3.5 14.5 6 6h3l1 8.5M20.5 14.5 18 6h-3l-1 8.5"/>',
		map: '<path d="m3 7 6-3 6 3 6-3v13l-6 3-6-3-6 3z"/><path d="M9 4v13M15 7v13"/>',
		compass: '<path d="m8 16 2-6 6-2-2 6z"/><circle cx="12" cy="12" r="9"/>',
		telescope: '<path d="m6 21 6-5 6 5M12 13v8"/><path d="m3.29 13.68.17.28c.52.88 1.62 1.27 2.6.91l14.25-5.17a1.02 1.02 0 0 0 .56-1.45l-2.62-4.71a1.09 1.09 0 0 0-1.5-.39L4.05 10.78c-1.02.61-1.36 1.9-.76 2.9z"/><path d="m14 5 3 5.5"/>',
		ferris: '<circle cx="12" cy="10" r="7"/><circle cx="12" cy="10" r="1.5"/><path d="M12 3v14M5 10h14M7.05 5.05l9.9 9.9M16.95 5.05l-9.9 9.9M8 21l4-4 4 4"/>',
		letters: '<path d="m3 19 4-12 4 12M4.5 15h5"/><path d="M14 7h3.5a3 3 0 0 1 0 6H14zM14 13h4.5a3 3 0 0 1 0 6H14z"/>',
		building: '<path d="M3 21h18M5 21V7l8-4v18M19 21V11l-6-4"/><path d="M9 9v.01M9 12v.01M9 15v.01M9 18v.01"/>',
		ufo: '<path d="M16.95 9.01C19.97 9.75 22 11.13 22 12.72 22 15.1 17.52 17 12 17S2 15.1 2 12.72c0-1.59 2.04-2.98 5.07-3.72"/><path d="M7 9c0 1.1 2.24 2 5 2s5-.9 5-2v-.04C17 6.22 14.76 4 12 4S7 6.22 7 8.97z"/><path d="m15 17 2 3M8.5 17 7 20M12 14h.01M6 13h.01M18 13h.01"/>',
		swim: '<circle cx="16" cy="9" r="1"/><path d="m6 11 4-2 3.5 3-1.5 2"/><path d="M3 16.75a2.4 2.4 0 0 0 1 .25 2.4 2.4 0 0 0 2-1 2.4 2.4 0 0 1 2-1 2.4 2.4 0 0 1 2 1 2.4 2.4 0 0 0 2 1 2.4 2.4 0 0 0 2-1 2.4 2.4 0 0 1 2-1 2.4 2.4 0 0 1 2 1 2.4 2.4 0 0 0 2 1 2.4 2.4 0 0 0 1-.25"/>',
		anchor: '<path d="M12 9v12m-8-8a8 8 0 0 0 16 0m1 0h-2M5 13H3"/><circle cx="12" cy="6" r="3"/>',
		parachute: '<path d="M22 12a10 10 0 1 0-20 0"/><path d="M22 12c0-1.66-1.46-3-3.25-3S15.5 10.34 15.5 12c0-1.66-1.57-3-3.5-3s-3.5 1.34-3.5 3c0-1.66-1.46-3-3.25-3S2 10.34 2 12"/><path d="m2 12 10 10-3.5-10M15.5 12 12 22l10-10"/>',
		jump: '<path d="M12 3v11M8 7l4-4 4 4M5 21h14M8 17h8"/>',
		ghost: '<path d="M5 11a7 7 0 0 1 14 0v7a1.78 1.78 0 0 1-3.1 1.4 1.65 1.65 0 0 0-2.6 0 1.65 1.65 0 0 1-2.6 0 1.65 1.65 0 0 0-2.6 0A1.78 1.78 0 0 1 5 18z"/><path d="M10 10h.01M14 10h.01M10 14a3.5 3.5 0 0 0 4 0"/>',
		hourglass: '<path d="M6.5 7h11M6.5 17h11"/><path d="M6 20v-2a6 6 0 1 1 12 0v2a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1zM6 4v2a6 6 0 1 0 12 0V4a1 1 0 0 0-1-1H7a1 1 0 0 0-1 1z"/>',
		clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 3"/>',
		coffee: '<path d="M3 10h14v5a6 6 0 0 1-6 6H9a6 6 0 0 1-6-6z"/><path d="M16.75 16.73a3 3 0 1 0 .25-5.56M8 3a2.4 2.4 0 0 0-1 2 2.4 2.4 0 0 0 1 2M12 3a2.4 2.4 0 0 0-1 2 2.4 2.4 0 0 0 1 2"/>',
		calendar: '<rect x="4" y="5" width="16" height="16" rx="2"/><path d="M16 3v4M8 3v4M4 11h16M11 15h1v3"/>',
		flame: '<path d="M12 12c2-2.96 0-7-1-8 0 3.04-1.77 4.74-3 6-1.23 1.26-2 3.24-2 5a6 6 0 1 0 12 0c0-1.53-1.06-3.94-2-5-1.79 3-2.79 3-4 2z"/>',
		sunrise: '<path d="M3 17h1m16 0h1M5.6 10.6l.7.7m12.1-.7-.7.7M8 17a4 4 0 0 1 8 0M3 21h18M12 9V3l3 3M9 6l3-3"/>',
		confetti: '<path d="M4 5h2M5 4v2M11.5 4 11 6M18 5h2M19 4v2M15 9l-1 1M18 13l2-.5M18 19h2M19 18v2"/><path d="M14 16.52 7.48 10l-4.39 9.58a1 1 0 0 0 1.33 1.33z"/>',
		wrench: '<path d="M7 10h3V7L6.5 3.5a6 6 0 0 1 8 8l6 6a2 2 0 0 1-3 3l-6-6a6 6 0 0 1-8-8z"/>',
		shield: '<path d="M12 3a12 12 0 0 0 8.5 3A12 12 0 0 1 12 21 12 12 0 0 1 3.5 6 12 12 0 0 0 12 3"/><path d="m9 12 2 2 4-4"/>',
		medkit: '<path d="M8 8V6a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><rect x="4" y="8" width="16" height="12" rx="2"/><path d="M10 14h4M12 12v4"/>',
		gavel: '<path d="m13 10 7.38 7.42a2.1 2.1 0 0 1-2.97 2.97L10 13M6 9l4 4M13 10 9 6M3 21h7"/><path d="M6.79 15.79 3.2 12.2a1 1 0 0 1 0-1.41L5.5 8.5l.5.5 3-3-.5-.5 2.3-2.3a1 1 0 0 1 1.4 0l3.6 3.6a1 1 0 0 1 0 1.4l-2.3 2.3-.5-.5-3 3 .5.5-2.3 2.3a1 1 0 0 1-1.4 0z"/>',
		coins: '<path d="M9 14c0 1.66 2.69 3 6 3s6-1.34 6-3-2.69-3-6-3-6 1.34-6 3z"/><path d="M9 14v4c0 1.66 2.69 3 6 3s6-1.34 6-3v-4M3 6c0 1.07 1.14 2.06 3 2.6s4.14.54 6 0 3-1.53 3-2.6-1.14-2.06-3-2.6-4.14-.54-6 0S3 4.93 3 6z"/><path d="M3 6v10c0 .89.77 1.45 2 2M3 11c0 .89.77 1.45 2 2"/>',
		piggy: '<path d="M15 11v.01M5.17 8.38a3 3 0 1 1 4.66-1.38"/><path d="M16 4v3.8A6.02 6.02 0 0 1 18.66 11H20a1 1 0 0 1 1 1v2a1 1 0 0 1-1 1h-1.34c-.34.95-.91 1.8-1.66 2.47v2.03a1.5 1.5 0 0 1-3 0v-.58a6 6 0 0 1-1 .08h-4a6 6 0 0 1-1-.08v.58a1.5 1.5 0 0 1-3 0v-2.03A6 6 0 0 1 9 7h2.5z"/>',
		diamond: '<path d="M6 5h12l3 5-8.5 9.5a.7.7 0 0 1-1 0L3 10z"/><path d="m10 12-2-2.2.6-1"/>',
		bank: '<path d="M3 21h18M3 10h18M5 6l7-3 7 3M4 10v11M20 10v11M8 14v3M12 14v3M16 14v3"/>',
	};

	A.ICON_NAMES = Object.keys(ICONS);

	A.icon = function (name, cls) {
		const id = ICONS[name] ? name : 'trophy';
		return `<svg class="i${cls ? ' ' + cls : ''}" aria-hidden="true"><use href="#i-${id}"/></svg>`;
	};

	function injectSprite() {
		const symbols = Object.entries(ICONS)
			.map(([name, body]) => `<symbol id="i-${name}" viewBox="0 0 24 24">${body}</symbol>`)
			.join('');
		const holder = document.createElement('div');
		holder.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" style="position:absolute;width:0;height:0;overflow:hidden">${symbols}</svg>`;
		document.body.prepend(holder.firstChild);
	}

	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', injectSprite);
	} else {
		injectSprite();
	}
})(window.Ach);
