const App = Vue.createApp({
	data() {
		return {
			jobs: [
				{ name: "unemployed", label: "Unemployed", text: "I don't want to work" },
				{ name: "unemployed", label: "Unemployed", text: "I don't want to work" },
				{ name: "unemployed", label: "Unemployed", text: "I don't want to work" },
				{ name: "unemployed", label: "Unemployed", text: "I don't want to work" },
				{ name: "unemployed", label: "Unemployed", text: "I don't want to work" },
				{ name: "unemployed", label: "Unemployed", text: "I don't want to work" },
				{ name: "unemployed", label: "Unemployed", text: "I don't want to work" },
			],

			locales: {
				nui_label: "Jobcenter",
				nui_choosejob: "Choose job",
				nui_search: "Search for job name",
			},

			search: "",

			opened: false,
		};
	},
	computed: {
		filteredList() {
			if (this.search == "") return this.jobs;

			const lowsearch = this.search.toLowerCase();

			return this.jobs.filter((job) => {
				return job.label.toLowerCase().includes(lowsearch) || job.text.toLowerCase().includes(lowsearch);
			});
		},
	},
	methods: {
		onMessage(event) {
			if (event.data.type == "show") {
				const appelement = document.getElementById("app");
				if (event.data.enable) {
					appelement.style.display = "block";
					appelement.style.animation = "hopin 0.7s";
					this.opened = true;
				} else {
					appelement.style.animation = "hopout 0.6s";
					this.opened = false;
					setTimeout(() => {
						if (!this.opened) appelement.style.display = "none";
					}, 500);
				}
			}
		},
		close() {
			fetch(`https://${GetParentResourceName()}/exit`);
		},
		setjob(job) {
			fetch(`https://${GetParentResourceName()}/setjob`, {
				method: "POST",
				body: JSON.stringify({
					job: job,
				}),
			});
		},
	},
	async mounted() {
		window.addEventListener("message", this.onMessage);
		var response = await fetch(`https://${GetParentResourceName()}/data`);
		var data = await response.json();
		this.locales = data.locales;
		this.jobs = data.jobs;
	},
}).mount("#app");
