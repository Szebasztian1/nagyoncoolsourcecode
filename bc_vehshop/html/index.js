const App = Vue.createApp({
	data() {
		return {
			cars: [
				{ model: "t20", price: 20000, label: "T20", category: "Sport", img: "https://cdn.discordapp.com/attachments/1166647182967975956/1291517302092726292/394003474_337738005440189_2383759057440999507_n.jpg?ex=670b9778&is=670a45f8&hm=db9b9b13ae6b6426a844a251f8576bc31b58f5bcce9ae291eefb939e69e313af&" },
				{ model: "t20", price: 20000, label: "T20", category: "Sport", img: "https://cdn.discordapp.com/attachments/1166647182967975956/1291517302092726292/394003474_337738005440189_2383759057440999507_n.jpg?ex=670b9778&is=670a45f8&hm=db9b9b13ae6b6426a844a251f8576bc31b58f5bcce9ae291eefb939e69e313af&" },
				{ model: "t20", price: 20000, label: "T20", category: "Sport", img: "https://cdn.discordapp.com/attachments/1166647182967975956/1291517302092726292/394003474_337738005440189_2383759057440999507_n.jpg?ex=670b9778&is=670a45f8&hm=db9b9b13ae6b6426a844a251f8576bc31b58f5bcce9ae291eefb939e69e313af&" },
				{ model: "t20", price: 20000, label: "T20", category: "Sport", img: "https://cdn.discordapp.com/attachments/1166647182967975956/1291517302092726292/394003474_337738005440189_2383759057440999507_n.jpg?ex=670b9778&is=670a45f8&hm=db9b9b13ae6b6426a844a251f8576bc31b58f5bcce9ae291eefb939e69e313af&" },
				{ model: "t20", price: 20000, label: "T20", category: "Sport", img: "https://cdn.discordapp.com/attachments/1166647182967975956/1291517302092726292/394003474_337738005440189_2383759057440999507_n.jpg?ex=670b9778&is=670a45f8&hm=db9b9b13ae6b6426a844a251f8576bc31b58f5bcce9ae291eefb939e69e313af&" },
				{ model: "t20", price: 20000, label: "T20", category: "Sport", img: "https://cdn.discordapp.com/attachments/1166647182967975956/1291517302092726292/394003474_337738005440189_2383759057440999507_n.jpg?ex=670b9778&is=670a45f8&hm=db9b9b13ae6b6426a844a251f8576bc31b58f5bcce9ae291eefb939e69e313af&" },
			],

			shopdata: {
				money: 200000,
				bank: 10,
				society: 0,
				test: true,
				tuning: true,
			},

			name: "Car Dealership",

			locales: {
				nui_currency: "$",
				nui_search: "Search for car name, category or price",
				nui_cash: "Cash",
				nui_bank: "Bank",
				nui_society: "Faction",
				nui_test: "Test",
				nui_tuning: "Tuning",
				nui_own_tuning: "Own car tuning test",
				nui_own_tuning_hint: "Pick a car by plate and try tuning on it.",
				nui_own_tuning_empty: "You have no cars.",
				nui_own_tuning_search: "Search by plate or name",
				nui_own_tuning_nohit: "No match.",
			},

			search: "",

			opened: false,

			shop: "",
			ownModal: false,
			ownVehicles: [],
			ownSearch: "",
			editModal: false,
			editForm: {
				label: "",
				description: "",
				bannerImage: "",
				logoImage: "",
			},
		};
	},
	computed: {
		filteredOwn() {
			if (!this.ownSearch) return this.ownVehicles;

			const needle = this.ownSearch.toLowerCase();

			return this.ownVehicles.filter((car) => {
				return (car.plate || "").toLowerCase().includes(needle) || (car.label || "").toLowerCase().includes(needle);
			});
		},
		filteredList() {
			if (!this.search || this.search == "") return this.cars;

			const lowsearch = this.search.toLowerCase();

			const ca = this.cars.filter((car) => {
				if (!car.label || !car.category || !car.price) return false;
				return car.label.toLowerCase().includes(lowsearch) || car.category.toLowerCase().includes(lowsearch) || String(car.price) == lowsearch;
			});

			function compare(a, b) {
				if (a.label < b.label) {
					return -1;
				}
				if (a.label > b.label) {
					return 1;
				}
				return 0;
			}

			return ca.sort(compare);
		},
	},
	methods: {
		formatPrice(price) {
			const formated = new Intl.NumberFormat("de-DE").format(price);
			return formated;
		},
		haveMoney(price, moneytype) {
			if (!this.shopdata[moneytype]) return "#5c0000";
			if (this.shopdata[moneytype] >= price) return "#1f1f1f";
			return "#5c0000";
		},
		onMessage(event) {
			if (event.data.type == "show") {
				const appelement = document.getElementById("app");
				if (event.data.enable) {
					appelement.style.display = "flex";
					appelement.style.animation = "hopin 0.7s";
					this.opened = true;
					this.shopdata = event.data.shopdata;
					this.cars = event.data.cars;
					this.name = event.data.name;
					this.shop = event.data.shop || "";
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
		buy(model) {
			fetch(`https://${GetParentResourceName()}/buy`, {
				method: "POST",
				body: JSON.stringify({
					model: model,
				}),
			});
		},
		buybank(model) {
			fetch(`https://${GetParentResourceName()}/buybank`, {
				method: "POST",
				body: JSON.stringify({
					model: model,
				}),
			});
		},
		buyfaction(model) {
			fetch(`https://${GetParentResourceName()}/buyfaction`, {
				method: "POST",
				body: JSON.stringify({
					model: model,
				}),
			});
		},
		test(model) {
			fetch(`https://${GetParentResourceName()}/test`, {
				method: "POST",
				body: JSON.stringify({
					model: model,
				}),
			});
		},
		tuning(model) {
			fetch(`https://${GetParentResourceName()}/tuningpreview`, {
				method: "POST",
				body: JSON.stringify({
					model: model,
				}),
			});
		},
		async openOwnTuning() {
			this.ownVehicles = [];
			this.ownSearch = "";
			this.ownModal = true;

			const response = await fetch(`https://${GetParentResourceName()}/ownvehicles`, {
				method: "POST",
				body: JSON.stringify({}),
			});
			this.ownVehicles = await response.json();
		},
		closeOwnTuning() {
			this.ownModal = false;
		},
		ownTuning(plate) {
			this.ownModal = false;
			fetch(`https://${GetParentResourceName()}/owntuningpreview`, {
				method: "POST",
				body: JSON.stringify({
					plate: plate,
				}),
			});
		},
		openEditModal() {
			this.editForm.label = this.name;
			this.editForm.description = this.shopdata.description || "";
			this.editForm.bannerImage = this.shopdata.bannerImage || "";
			this.editForm.logoImage = this.shopdata.logo || "";
			this.editModal = true;
		},
		closeEditModal() {
			this.editModal = false;
		},
		saveShopInfo() {
			fetch(`https://${GetParentResourceName()}/saveShopInfo`, {
				method: "POST",
				body: JSON.stringify({
					shop: this.shop,
					label: this.editForm.label,
					description: this.editForm.description,
					bannerImage: this.editForm.bannerImage,
					logoImage: this.editForm.logoImage,
				}),
			});
			this.name = this.editForm.label;
			this.shopdata.description = this.editForm.description;
			this.shopdata.bannerImage = this.editForm.bannerImage;
			this.shopdata.logo = this.editForm.logoImage;
			this.editModal = false;
		},
	},
	async mounted() {
		window.addEventListener("message", this.onMessage);
		var response = await fetch(`https://${GetParentResourceName()}/locales`);
		var locales = await response.json();
		this.locales = locales;
	},
}).mount("#app");
