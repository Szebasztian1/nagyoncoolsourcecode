/* bc_tax - Műszaki Terminál NUI (Vue 3 global build) */
(function () {
  const { createApp } = Vue;

  // FiveM's CEF injects these globals; a plain browser has neither. Sniffing the
  // hostname ('cfx-nui-') was unreliable across builds and let the mock panel
  // open in-game — this is the robust check.
  const IN_GAME = typeof window.invokeNative !== 'undefined' || typeof window.GetParentResourceName === 'function';
  const RES = (typeof window.GetParentResourceName === 'function' && window.GetParentResourceName())
    || (location.hostname.indexOf('cfx-nui-') === 0 ? location.hostname.replace('cfx-nui-', '') : 'bc_tax');

  async function post(name, data) {
    if (!IN_GAME) return {};
    try {
      const r = await fetch(`https://${RES}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data || {}),
      });
      return await r.json().catch(() => ({}));
    } catch (e) {
      return {};
    }
  }

  const HEADS = {
    single:  { k: 'Egyedi vizsgálat',   ttl: 'Műszaki <b>kiállítása</b>' },
    mass:    { k: 'Tömeges vizsgálat',  ttl: 'Ügyfél <b>flottája</b>' },
    faction: { k: 'Frakciós vizsgálat', ttl: 'Frakció <b>járművei</b>' },
  };
  const VERB = { single: 'Vizsga kiállítása', mass: 'Flotta műszakiztatása', faction: 'Frakció flottája' };

  // Browser-preview sample data (game sends the real payload via SendNUIMessage).
  const MOCK = {
    action: 'open', mechanic: 'Kovács Béla', job: 'Szerelő', fee: 750000, validDays: 60,
    checklist: ['Fékrendszer', 'Világítás', 'Futómű', 'Kipufogó / emisszió', 'Karosszéria'],
  };
  const MOCK_TARGET = { ok: true, id: 27, name: 'Nagy András', job: 'LSPD',
    count: 4, plates: ['KLM 114', 'ZR8 220', 'PP 7781', 'AA 0092'], total: 3000000 };
  const MOCK_EXAM = {
    cost: 7000000, chance: 70, retryHours: 10,
    eyebrow: 'Fegyver-alkalmassági', title: 'Fegyvertartási', titleAccent: 'vizsga',
    questions: [
      { q: 'Hol tarthatod jogszerűen a fegyvered a városban?', answers: ['Szabadon, a kezedben', 'Elrejtve, a hozzá tartozó tokban', 'A jármű motorháztetején'] },
      { q: 'Mit teszel, ha rendvédelmi igazoltat és fegyver van nálad?', answers: ['Szólsz róla és felmutatod az engedélyt', 'Azonnal előveszed', 'Letagadod'] },
      { q: 'Kinek adhatod át a fegyvered?', answers: ['Bárkinek, aki kéri', 'Csak a barátaidnak', 'Csak érvényes engedéllyel rendelkezőnek'] },
      { q: 'Mikor használhatod jogszerűen a fegyvered?', answers: ['Jogos védelmi helyzetben', 'Ha valaki felidegesít', 'Vita eldöntésére'] },
      { q: 'Mi a biztonságos fegyverkezelés alapszabálya?', answers: ['Minden fegyvert töltöttnek tekintünk', 'Csak a töltött fegyver veszélyes', 'Tár nélkül nincs kockázat'] },
    ],
  };

  // ---- Üzembehelyezési engedély (panel, job-tagoknak) ----
  const UZEMBE_HEADS = {
    single:  { k: 'Egyedi kiállítás',   ttl: 'Engedély <b>kiállítása</b>' },
    mass:    { k: 'Tömeges kiállítás',  ttl: 'Ügyfél <b>flottája</b>' },
    faction: { k: 'Frakciós kiállítás', ttl: 'Frakció <b>járművei</b>' },
  };
  const UZEMBE_VERB = { single: 'Engedély kiállítása', mass: 'Flotta kiállítása', faction: 'Frakció flottája' };
  const UZEMBE_PLATE_ERRORS = {
    no_vehicle:     'Ilyen rendszámú autó nem létezik.',
    owner_offline:  'A tulajdonos nincs fent, nem lehet levonni tőle.',
    invalid_plate:  'Érvénytelen rendszám.',
    already_valid:  'Erre az autóra már van legalább egy hétig érvényes üzembehelyezési engedély.',
    already_added:  'Ez a rendszám már szerepel a listában.',
  };

  const MOCK_UZEMBE = {
    action: 'openUzembe', issuer: 'Tóth Gábor', job: 'Hivatalnok', validDays: 30,
    minFee: 1000000, maxFee: 15000000, feeRatePercent: 0.3, discountChance: 15, discountPercent: 10,
  };
  const MOCK_UZEMBE_PLATE_INFO = { ok: true, plate: 'ABC 123', ownerName: 'Nagy András', job: 'civ', fee: 2400000 };
  const MOCK_UZEMBE_TARGET = { ok: true, id: 27, name: 'Nagy András', job: 'LSPD',
    count: 3, plates: ['KLM 114', 'ZR8 220', 'PP 7781'], fee: 2400000, subtotal: 7200000,
    discountChance: 15, discountPercent: 10 };

  createApp({
    data() {
      return {
        visible: false,
        mode: 'single',
        mechanic: 'Szerelő', job: '-', fee: 750000, validDays: 60,
        checklist: [],
        diag: {},
        plate: '',
        target: null, loadingTarget: false, targetError: '',
        // firearms exam (clearance NPC)
        screen: 'terminal',
        examQuestions: [], examStep: 0, examAnswers: {}, examResult: null,
        examCost: 0, examChance: 70, examRetryHours: 10, examSending: false,
        examEyebrow: '', examTitle: '', examTitleAccent: '',
        // üzembehelyezési engedély (panel)
        uzembeIssuer: 'Ügyintéző', uzembeJob: '-', uzembeValidDays: 30,
        uzembeMinFee: 1000000, uzembeMaxFee: 15000000, uzembeFeeRatePercent: 0.3,
        uzembeDiscountChance: 15, uzembeDiscountPercent: 10,
        uzembeMode: 'single', uzembePlate: '', uzembePlateInfo: null, uzembePlateList: [],
        uzembeTarget: null, uzembeLoadingTarget: false, uzembeTargetError: '',
      };
    },
    computed: {
      head() { return HEADS[this.mode]; },
      hasFail() {
        for (let i = 0; i < this.checklist.length; i++) if (this.diag[i] === 'fail') return true;
        return false;
      },
      allPassed() {
        if (!this.checklist.length) return false;
        for (let i = 0; i < this.checklist.length; i++) if (this.diag[i] !== 'pass') return false;
        return true;
      },
      showChecklist() { return this.mode === 'single' || (this.target && this.target.count > 0); },
      showSummary() { return this.mode === 'single' || (this.target && this.target.count > 0); },
      totalFee() {
        if (this.mode === 'single') return this.fee;
        return this.target ? this.fee * this.target.count : 0;
      },
      canIssue() {
        if (!this.allPassed) return false;
        if (this.mode === 'single') return this.plate.trim().length > 0;
        return !!(this.target && this.target.count > 0);
      },
      issueLabel() { return VERB[this.mode] + ' · ' + this.money(this.totalFee); },
      diagClass() { return this.allPassed ? 'good' : (this.hasFail ? 'bad' : 'wait'); },
      diagMessage() {
        if (this.allPassed) return 'Minden pont megfelelt — a vizsga kiállítható.';
        if (this.hasFail) return 'Van bukott tétel — a műszaki nem állítható ki.';
        return 'Jelöld be minden pont eredményét.';
      },
      currentQuestion() { return this.examQuestions[this.examStep] || { q: '', answers: [] }; },
      allAnswered() {
        for (let i = 0; i < this.examQuestions.length; i++) if (!this.examAnswers[i]) return false;
        return this.examQuestions.length > 0;
      },
      // "Szerelési" / "Fegyvertartási" -> "szerelési engedély" / "fegyvertartási engedély"
      licenceName() { return (this.examTitle || 'Engedély').toLowerCase() + ' engedély'; },
      // Shown on every question screen: a perfect test is not enough on its own,
      // and players kept reporting the rejection as a bug.
      examNotice() {
        return 'A hibátlan vizsga sem elég önmagában: a hatóság a hibátlan vizsgáknak is csak '
          + this.examChance + '%-át hagyja jóvá. Elutasításnál a vizsgadíj nem jár vissza, és '
          + this.examRetryHours + ' óra múlva próbálkozhatsz újra.';
      },
      resultTitle() {
        if (!this.examResult) return '';
        if (this.examResult.granted) return 'Megkaptad az engedélyt';
        return this.examResult.perfect ? 'Hibátlan vizsga, elutasított kérelem' : 'Nem feleltél meg';
      },
      resultText() {
        const r = this.examResult;
        if (!r) return '';
        if (r.granted) return 'A ' + this.licenceName + 'ed érvénybe lépett.';
        const back = ' ' + (r.retryHours || this.examRetryHours) + ' óra múlva próbálkozhatsz újra.';
        return (r.perfect
          ? 'Minden kérdésre helyesen válaszoltál, a hatóság mégsem hagyta jóvá a kérelmet — '
            + 'hibátlan vizsga esetén is csak ' + this.examChance + '% az esély az engedélyre. '
            + 'Ez nem hiba: a vizsgád rendben volt, csak az elbírálás ment ellened.'
          : 'Nem minden kérdésre válaszoltál helyesen.') + back;
      },
      // üzembehelyezési engedély (panel)
      uzembeHead() { return UZEMBE_HEADS[this.uzembeMode]; },
      uzembeBatchEligible() {
        if (this.uzembeMode === 'single') return this.uzembePlateList.length > 1;
        return this.uzembeTarget && this.uzembeTarget.count > 1;
      },
      uzembeShowSummary() {
        if (this.uzembeMode === 'single') return this.uzembePlateList.length > 0;
        return !!(this.uzembeTarget && this.uzembeTarget.count > 0);
      },
      uzembeTotalFee() {
        if (this.uzembeMode === 'single') {
          return this.uzembePlateList.reduce((sum, p) => sum + p.fee, 0);
        }
        return this.uzembeTarget ? this.uzembeTarget.fee * this.uzembeTarget.count : 0;
      },
      uzembeCanIssue() {
        if (this.uzembeMode === 'single') return this.uzembePlateList.length > 0;
        return !!(this.uzembeTarget && this.uzembeTarget.count > 0);
      },
      uzembeIssueLabel() {
        const count = this.uzembeMode === 'single' ? this.uzembePlateList.length : (this.uzembeTarget ? this.uzembeTarget.count : 0);
        return UZEMBE_VERB[this.uzembeMode] + (count > 1 ? ' (' + count + ' db)' : '') + ' · ' + this.money(this.uzembeTotalFee);
      },
      uzembePlateErrorText() {
        const r = this.uzembePlateInfo && this.uzembePlateInfo.reason;
        return UZEMBE_PLATE_ERRORS[r] || 'A rendszám nem kereshető le.';
      },
    },
    methods: {
      money(n) { return '$' + Math.round(n || 0).toLocaleString('de-DE'); },
      two(n) { return n < 10 ? '0' + n : '' + n; },
      initials(name) {
        const p = (name || '').trim().split(/\s+/);
        return ((p[0] || '?')[0] + (p[1] ? p[1][0] : '')).toUpperCase();
      },
      resetWork() { this.diag = {}; this.plate = ''; this.target = null; this.targetError = ''; },
      setMode(m) { if (m === this.mode) return; this.mode = m; this.resetWork(); },
      setDiag(i, val) { this.diag = Object.assign({}, this.diag, { [i]: val }); },
      passAll() {
        const d = {};
        for (let i = 0; i < this.checklist.length; i++) d[i] = 'pass';
        this.diag = d;
      },
      onPlate() { this.plate = this.plate.toUpperCase(); },
      refreshTarget() {
        if (this.loadingTarget) return;
        this.loadingTarget = true;
        this.targetError = '';
        if (!IN_GAME) {
          setTimeout(() => { this.target = MOCK_TARGET; this.diag = {}; this.loadingTarget = false; }, 300);
          return;
        }
        post('getTarget', { mode: this.mode }).then((res) => {
          this.loadingTarget = false;
          if (res && res.ok) {
            this.target = res;
            this.diag = {};
          } else {
            this.target = null;
            this.targetError = (res && res.reason === 'no_target')
              ? 'Nincs ügyfél a közeledben (3 m).'
              : 'Érvénytelen cél.';
          }
        });
      },
      issue() {
        if (!this.canIssue) return;
        post('issue', {
          mode: this.mode,
          plate: this.plate.trim().toUpperCase(),
          diagPassed: this.allPassed,
        });
        this.visible = false;
      },
      open(p) {
        this.mechanic = p.mechanic || 'Szerelő';
        this.job = p.job || '-';
        this.fee = typeof p.fee === 'number' ? p.fee : 750000;
        this.validDays = typeof p.validDays === 'number' ? p.validDays : 60;
        this.checklist = p.checklist || [];
        this.mode = 'single';
        this.resetWork();
        this.screen = 'terminal'; // a previous exam must never leak into this view
        this.visible = true;
      },
      close() {
        if (!this.visible) return;
        this.visible = false;
        this.screen = 'terminal';
        post('close');
      },
      letter(i) { return 'ABCDEFGH'[i] || '?'; },
      openExam(p) {
        this.examQuestions = p.questions || [];
        this.examCost = typeof p.cost === 'number' ? p.cost : 0;
        this.examChance = typeof p.chance === 'number' ? p.chance : 70;
        this.examRetryHours = typeof p.retryHours === 'number' ? p.retryHours : 10;
        this.examEyebrow = p.eyebrow || 'Hatósági vizsga';
        this.examTitle = p.title || 'Engedély';
        this.examTitleAccent = p.titleAccent || 'vizsga';
        this.examStep = 0;
        this.examAnswers = {};
        this.examResult = null;
        this.examSending = false;
        this.screen = 'exam';
        this.visible = true;
      },
      pickAnswer(n) { this.examAnswers = Object.assign({}, this.examAnswers, { [this.examStep]: n }); },
      submitExam() {
        if (!this.allAnswered || this.examSending) return;
        this.examSending = true;

        // 1-based answer indices, in question order (Lua reads them 1-based).
        const answers = [];
        for (let i = 0; i < this.examQuestions.length; i++) answers[i] = this.examAnswers[i];

        if (!IN_GAME) {
          setTimeout(() => {
            this.examResult = { granted: false, perfect: true, correct: this.examQuestions.length,
              total: this.examQuestions.length, retryHours: 10, retryAt: '2026-07-20 04:12' };
            this.examSending = false;
          }, 350);
          return;
        }

        post('submitExam', { answers: answers }).then((res) => {
          this.examSending = false;
          if (res && res.ok) this.examResult = res;
        });
      },
      // üzembehelyezési engedély (panel)
      resetUzembeWork() {
        this.uzembePlate = ''; this.uzembePlateInfo = null; this.uzembePlateList = [];
        this.uzembeTarget = null; this.uzembeTargetError = '';
      },
      setUzembeMode(m) { if (m === this.uzembeMode) return; this.uzembeMode = m; this.resetUzembeWork(); },
      onUzembePlate() { this.uzembePlate = this.uzembePlate.toUpperCase(); this.uzembePlateInfo = null; },
      addUzembePlate() {
        const plate = this.uzembePlate.trim();
        if (!plate) return;
        if (this.uzembePlateList.some((p) => p.plate === plate)) {
          this.uzembePlateInfo = { ok: false, reason: 'already_added' };
          return;
        }
        if (!IN_GAME) {
          const info = Object.assign({}, MOCK_UZEMBE_PLATE_INFO, { plate: plate });
          this.uzembePlateList.push(info);
          this.uzembePlateInfo = null;
          this.uzembePlate = '';
          return;
        }
        post('uzembeGetPlateInfo', { plate: plate }).then((res) => {
          if (res && res.ok) {
            this.uzembePlateList.push(res);
            this.uzembePlateInfo = null;
            this.uzembePlate = '';
          } else {
            this.uzembePlateInfo = res || { ok: false };
          }
        });
      },
      removeUzembePlate(plate) {
        this.uzembePlateList = this.uzembePlateList.filter((p) => p.plate !== plate);
      },
      refreshUzembeTarget() {
        if (this.uzembeLoadingTarget) return;
        this.uzembeLoadingTarget = true;
        this.uzembeTargetError = '';
        if (!IN_GAME) {
          setTimeout(() => { this.uzembeTarget = MOCK_UZEMBE_TARGET; this.uzembeLoadingTarget = false; }, 300);
          return;
        }
        post('uzembeGetTarget', { mode: this.uzembeMode }).then((res) => {
          this.uzembeLoadingTarget = false;
          if (res && res.ok) {
            this.uzembeTarget = res;
          } else {
            this.uzembeTarget = null;
            this.uzembeTargetError = (res && res.reason === 'no_target')
              ? 'Nincs ügyfél a közeledben (3 m).'
              : 'Érvénytelen cél.';
          }
        });
      },
      issueUzembe() {
        if (!this.uzembeCanIssue) return;
        post('uzembeIssue', {
          mode: this.uzembeMode,
          plates: this.uzembePlateList.map((p) => p.plate),
        });
        this.visible = false;
      },
      openUzembe(p) {
        this.uzembeIssuer = p.issuer || 'Ügyintéző';
        this.uzembeJob = p.job || '-';
        this.uzembeValidDays = typeof p.validDays === 'number' ? p.validDays : 30;
        this.uzembeMinFee = typeof p.minFee === 'number' ? p.minFee : 1000000;
        this.uzembeMaxFee = typeof p.maxFee === 'number' ? p.maxFee : 15000000;
        this.uzembeFeeRatePercent = typeof p.feeRatePercent === 'number' ? p.feeRatePercent : 0.3;
        this.uzembeDiscountChance = typeof p.discountChance === 'number' ? p.discountChance : 15;
        this.uzembeDiscountPercent = typeof p.discountPercent === 'number' ? p.discountPercent : 10;
        this.uzembeMode = 'single';
        this.resetUzembeWork();
        this.screen = 'uzembe';
        this.visible = true;
      },
    },
    mounted() {
      window.addEventListener('message', (e) => {
        const d = e.data || {};
        if (d.action === 'open') this.open(d);
        else if (d.action === 'openExam') this.openExam(d);
        else if (d.action === 'openUzembe') this.openUzembe(d);
        else if (d.action === 'close') this.visible = false;
      });
      window.addEventListener('keydown', (e) => {
        if (this.visible && e.key === 'Escape') this.close();
      });
      if (!IN_GAME) {
        // Browser preview: ?exam shows the firearms exam, ?uzembe the
        // üzembehelyezés panel, otherwise the terminal.
        if (location.search.indexOf('exam') !== -1) this.openExam(MOCK_EXAM);
        else if (location.search.indexOf('uzembe') !== -1) this.openUzembe(MOCK_UZEMBE);
        else this.open(MOCK);
      }
    },
  }).mount('#app');
})();
