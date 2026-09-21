const App = Vue.createApp({
    data() {
      return {
        cars : [
            {
                stored: true,
                plate:"ABC 123",
                label:"T20",
                img:"https://cdn.discordapp.com/attachments/1166647182967975956/1286010623208980550/polavenks_-_Rendvedelmis_egydi.jpg?ex=66fadab9&is=66f98939&hm=bcba63cafb872d88949ef4aad61f78b49a5e559f4cfccf54d1c6ed2c74c9643e&",
                isImpound:false,
                bodyHealth:300,
                engineHealth:400,
                tankHealth:200,
                fuelLevel:30,
                modEngine:1,
                modBrakes:2,
                modTransmission:2,
                modTurbo:true,
            },
            {
                stored: false,
                plate:"ABC 123",
                label:"T20",
                img:"https://cdn.discordapp.com/attachments/1166647182967975956/1286010623208980550/polavenks_-_Rendvedelmis_egydi.jpg?ex=66fadab9&is=66f98939&hm=bcba63cafb872d88949ef4aad61f78b49a5e559f4cfccf54d1c6ed2c74c9643e&",
                isImpound:false,
                bodyHealth:300,
                engineHealth:400,
                tankHealth:200,
                fuelLevel:30,
                modEngine:1,
                modBrakes:2,
                modTransmission:2,
                modTurbo:true,
            },

        ],

        label : "GARÁZS",

        selected : undefined,

        config: {
            maxFuel : 100
        },

        search : "",
      }
    },
    computed: {
        filteredList() {
            if (this.search == "") return this.cars;

            const lowsearch = this.search.toLowerCase()

            

            return this.cars.filter((car) => {
                return car.label.toLowerCase().includes(lowsearch) || car.plate.toLowerCase().includes(lowsearch);
            });
        }
    },
    methods: {
        onMessage(event) {
            if (event.data.type == "show") {
                document.body.style.display = event.data.enable ? "block" : "none";
                this.selected = undefined;
                if (event.data.enable) {
                    //this.cars = event.data.cars;
                    this.label = event.data.label; 
                    
                    event.data.cars.sort(this.compare)

                    const aktivak = event.data.cars.filter(obj => obj.fav);
                    const nemAktivak = event.data.cars.filter(obj => !obj.fav);
                    this.cars = [...aktivak, ...nemAktivak];

                   
                }
            }
        },
        compare( a, b ) {
            if ( a.label < b.label ){
                return -1;
            }
            if ( a.label > b.label ){
                return 1;
            }
            return 0;
        },
        getFuelLevel(level) {
            if (level == -1) {
                return "?"
            }
            return Math.floor((level / this.config.maxFuel) * 100);
        },
        getHealth(bodyHealth, engineHealth, tankHealth) {
            if (engineHealth < 1) {
                engineHealth = 0
            }
            return Math.floor((((bodyHealth + engineHealth + tankHealth)/3) / 1000) * 100);
        },

        selectCar(car) {
            if (this.selected != car) {
                this.selected = car;
            } else {
                this.selected = undefined;
            }
        },

        close() {
            this.selected = undefined;
            fetch(`https://${GetParentResourceName()}/exit`);
        },
        takeout() {
            fetch(`https://${GetParentResourceName()}/takeout`, {
                method: 'POST',
                body: JSON.stringify({
                    plate : this.selected.plate
                })
            });
        },
        fav() {
            fetch(`https://${GetParentResourceName()}/fav`, {
                method: 'POST',
                body: JSON.stringify({
                    plate : this.selected.plate
                })
            });
        },
        deletecar() {
            fetch(`https://${GetParentResourceName()}/delcar`, {
                method: 'POST',
                body: JSON.stringify({
                    plate : this.selected.plate
                })
            });
        },
        rename() {
            fetch(`https://${GetParentResourceName()}/namecar`, {
                method: 'POST',
                body: JSON.stringify({
                    plate : this.selected.plate
                })
            });
        },
        taxmenu() {
            fetch(`https://${GetParentResourceName()}/taxmenu`, {
                method: 'POST',
                body: JSON.stringify({
                    plate : this.selected.plate
                })
            });
        },
        takeoutimpound() {
            fetch(`https://${GetParentResourceName()}/takeoutimpound`, {
                method: 'POST',
                body: JSON.stringify({
                    plate : this.selected.plate
                })
            });
        },
    }, 
    async mounted() {
        window.addEventListener('message', this.onMessage);
       /* var response = await fetch(`https://${GetParentResourceName()}/getdata`);
        var data = await response.json();
        this.config = data.config;*/
    }
}).mount('#app');