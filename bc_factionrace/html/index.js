const App = Vue.createApp({
    data() {
      return {
        /*mydata:{
            place:"3",
            name:"Bloods",
            score:1004,
            level:3,
            nextscore:"1200",
            unlocked:"+5% loot bizonyos rablások esetén"
        },
        factionlist:[
            {name:"???", value:"police", score:1202},
            {name:"???", value:"crips", score:1133},
            {name:"Bloods", value:"bloods", score:1004, isme:true},
            {name:"???", value:"ballas", score:976},
            {name:"???", value:"groove", score:800},
        ],*/

        mydata:false,
        factionlist:[],

        config:{
            infos:"Pontot szerezve a rablásokból, a szinted nőni fog. Minél magasabb a szinted, annál több előnyt kapsz a rablások során. Az előnyök között lehet például a gyorsabb rablás, vagy több pénz rablás közben. <br>Mindez csak a következő rablásoknál érvényes: ",
        }
      }
    },
    computed: {
        standings() {
            if (!this.factionlist) {
                return [];
            }
            if (this.factionlist.length < 3) {
                return [];
            }
            return this.factionlist.slice(3);
        }
    },
    methods: {
        onMessage(event) {
            if (event.data.type == "show") {
                document.body.style.display = event.data.enable ? "block" : "none";
                if (event.data.enable) {
                    this.mydata = event.data.mydata;
                    this.factionlist = event.data.factionlist;
                    return this.factionlist.sort((a, b) => b.score - a.score);
                }
            }
        },

        getAtPlace(place) {
            place = place - 1;
            if (this.factionlist.length < place) {
                return {name:"???", value:"none", score:0};
            }
            if (!this.factionlist[place]) {
                return {name:"???", value:"none", score:0};
            }
            return this.factionlist[place];
        },
       
        close() {
            this.selected = undefined;
            fetch(`https://${GetParentResourceName()}/exit`);
        },
       
    }, 
    async mounted() {
        window.addEventListener('message', this.onMessage);
        var response = await fetch(`https://${GetParentResourceName()}/getdata`);
        var data = await response.json();
        this.config = data.config;
    }
}).mount('#app');