import Foundation

// MARK: - Models

struct Exercise: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let sets: String
    let hint: String
}

struct TrainingSection: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let exercises: [Exercise]
}

struct TrainingDay: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let short: String
    let tags: [String]
    let dots: [String]
    let sub: String
    let weekNote: Bool
    let sections: [TrainingSection]
    let tip: String?
    let isRest: Bool

    init(
        name: String,
        short: String,
        tags: [String],
        dots: [String],
        sub: String,
        weekNote: Bool = false,
        sections: [TrainingSection] = [],
        tip: String? = nil,
        isRest: Bool = false
    ) {
        self.name = name
        self.short = short
        self.tags = tags
        self.dots = dots
        self.sub = sub
        self.weekNote = weekNote
        self.sections = sections
        self.tip = tip
        self.isRest = isRest
    }
}

struct WeekType: Identifiable, Hashable {
    let id: String
    let label: String
    let note: String
}

// MARK: - Static data (mirrors the React source)

enum TrainingPlan {
    static let weekTypes: [WeekType] = [
        WeekType(
            id: "strength",
            label: "Strength week",
            note: "5×3 at ~100–105 kg squat. Hang clean 5×3 heavy. Lower reps, heavier weights. Builds raw power."
        ),
        WeekType(
            id: "hypertrophy",
            label: "Hypertrophy week",
            note: "4×6 at ~85–90 kg squat. More reps, moderate weight. More muscle stimulus. Alternate every week."
        ),
    ]

    static let days: [TrainingDay] = [
        // MARK: Monday
        TrainingDay(
            name: "Monday",
            short: "Mon",
            tags: ["med", "vball"],
            dots: ["gym", "vball"],
            sub: "Morning: upper body. Afternoon: volleyball",
            sections: [
                TrainingSection(label: "Morning gym — upper body (45 min)", exercises: [
                    Exercise(name: "Overhead press", sets: "4 × 5",
                             hint: "Intermediate load — push close to your 6-rep max. Strict form, no leg drive. Direct spike power builder."),
                    Exercise(name: "Weighted pull-ups", sets: "4 × 5",
                             hint: "Add 5–10 kg if bodyweight is easy. Slow on the way down (3 sec). Lat strength drives your arm swing."),
                    Exercise(name: "Dumbbell row", sets: "3 × 8 each",
                             hint: "Heavy. Elbow drives back, not flared. Builds the pulling side of your arm swing."),
                    Exercise(name: "Face pulls", sets: "3 × 15",
                             hint: "Rotator cuff health. Keep this in every upper day forever — it prevents the shoulder injuries that end careers."),
                    Exercise(name: "Pallof press", sets: "3 × 10 each",
                             hint: "Anti-rotation core. Resist the cable pulling you sideways. Transfers directly to spiking stability."),
                ]),
                TrainingSection(label: "Afternoon — volleyball training", exercises: [
                    Exercise(name: "Team training", sets: "Coach-led",
                             hint: "Focus: passing under fatigue. You're slightly tired from gym — that's intentional. Train your passing when tired."),
                ]),
            ],
            tip: "Keep gym volume controlled on Mon/Wed/Thu. Volleyball in the afternoon is the priority — arrive fresh enough to train properly."
        ),

        // MARK: Tuesday
        TrainingDay(
            name: "Tuesday",
            short: "Tue",
            tags: ["high"],
            dots: ["gym"],
            sub: "Morning: heaviest session of the week",
            weekNote: true,
            sections: [
                TrainingSection(label: "Warm-up (12 min)", exercises: [
                    Exercise(name: "Jump rope", sets: "3 min",
                             hint: "Light and rhythmic. Activates ankles and calves specifically."),
                    Exercise(name: "Hip mobility circuit", sets: "5 min",
                             hint: "Leg swings, hip 90/90 stretch, world's greatest stretch. Non-negotiable before heavy squats."),
                    Exercise(name: "Glute activation", sets: "2 × 15",
                             hint: "Banded clamshells or bridges. Wakes up your posterior chain before loading."),
                ]),
                TrainingSection(label: "Strength block", exercises: [
                    Exercise(name: "Back squat", sets: "5×3 / 4×6 ↗️",
                             hint: "STRENGTH WEEK: 5×3 at ~100–105 kg. HYPERTROPHY WEEK: 4×6 at ~85–90 kg. You're at 110 kg max so these are working weights, not max effort."),
                    Exercise(name: "Romanian deadlift", sets: "4 × 6",
                             hint: "Push hips back, slight knee bend, bar close to legs. Feel the hamstring stretch at the bottom."),
                    Exercise(name: "Bulgarian split squat", sets: "3 × 6 each",
                             hint: "Add weight — goblet hold or dumbbells. Single-leg power transfers directly to your approach jump takeoff."),
                ]),
                TrainingSection(label: "Plyometric block", exercises: [
                    Exercise(name: "Box jumps — max height", sets: "5 × 4",
                             hint: "Full reset between reps. These are about max effort, not speed. Land soft, step down carefully."),
                    Exercise(name: "Depth jumps", sets: "4 × 4",
                             hint: "Step off 40–50 cm box, explode immediately on landing. Ground contact under 0.2 sec. Most important exercise for spike height."),
                    Exercise(name: "Broad jumps", sets: "3 × 5",
                             hint: "Horizontal power. Stick the landing for 2 sec before next rep."),
                ]),
                TrainingSection(label: "Court — solo session (45 min)", exercises: [
                    Exercise(name: "Jump serves", sets: "10 min / 50+ reps",
                             hint: "One variable only: toss height today. Same spot, same swing. Count your in/out ratio."),
                    Exercise(name: "Approach jumps + touch target", sets: "3 × 10",
                             hint: "Full 4-step approach, max jump, touch a target above the net. This is where Tuesday's squats pay off."),
                    Exercise(name: "Safe shot drilling — cross court", sets: "15 min / 50+ reps",
                             hint: "Sharp cross-court only. Building muscle memory so this shot is automatic under pressure."),
                    Exercise(name: "Tipping practice", sets: "10 min",
                             hint: "Tip deliberately — feel what your body telegraphs. This is how you learn to read tips defensively."),
                ]),
            ],
            tip: "Tuesday is your most important day. Protect your sleep the night before. Eat a proper breakfast. This is where your vertical jump actually improves."
        ),

        // MARK: Wednesday
        TrainingDay(
            name: "Wednesday",
            short: "Wed",
            tags: ["med", "vball"],
            dots: ["gym", "vball"],
            sub: "Morning: upper body. Afternoon: volleyball",
            sections: [
                TrainingSection(label: "Morning gym — upper body (45 min)", exercises: [
                    Exercise(name: "Hang clean", sets: "5 × 3",
                             hint: "Reset after each rep. Focus on hip extension and elbow speed — not how much weight. Add weight slowly over weeks."),
                    Exercise(name: "Incline dumbbell press", sets: "4 × 8",
                             hint: "Upper chest and front shoulder. Different angle to Monday's overhead press. Medium weight, controlled."),
                    Exercise(name: "Cable row", sets: "4 × 8",
                             hint: "Full range — stretch at the front, squeeze shoulder blades at the back. Builds arm swing pulling power."),
                    Exercise(name: "Tricep pushdown", sets: "3 × 12",
                             hint: "Elbow extension strength for the snap at ball contact. Keep elbows fixed at your sides."),
                    Exercise(name: "Hollow body hold", sets: "3 × 30 sec",
                             hint: "Lower back presses into floor, arms and legs extended and raised. Transfers to body tension when jumping."),
                ]),
                TrainingSection(label: "Afternoon — volleyball training", exercises: [
                    Exercise(name: "Team training", sets: "Coach-led",
                             hint: "Focus: attack consistency and shot selection. Work your safe shot every chance you get in drills."),
                ]),
            ],
            tip: nil
        ),

        // MARK: Thursday
        TrainingDay(
            name: "Thursday",
            short: "Thu",
            tags: ["low", "vball"],
            dots: ["gym", "vball"],
            sub: "Morning: mobility only. Afternoon: volleyball",
            sections: [
                TrainingSection(label: "Morning — mobility + activation (25 min max)", exercises: [
                    Exercise(name: "Foam rolling", sets: "8 min",
                             hint: "Quads, hamstrings, calves, thoracic spine. Slow — 30 sec on each tight spot. Thursday is about arriving at volleyball feeling good."),
                    Exercise(name: "Hip flexor stretch", sets: "3 × 45 sec each",
                             hint: "Kneeling lunge stretch. Hip flexors are chronically tight in volleyball players and directly limit jump height."),
                    Exercise(name: "Band pull-aparts", sets: "3 × 20",
                             hint: "Light band. Pulls shoulder blades together — counteracts all the pressing movements earlier in the week."),
                    Exercise(name: "Ankle circles + calf stretch", sets: "2 min",
                             hint: "Jump athletes put huge stress on ankles. Spend 2 min here every Thursday without fail."),
                ]),
                TrainingSection(label: "Afternoon — volleyball training", exercises: [
                    Exercise(name: "Team training", sets: "Coach-led",
                             hint: "Focus: serve and defense. Thursday is your third volleyball session — arrive mentally sharp even if slightly tired."),
                ]),
            ],
            tip: "Thursday morning is not a gym day. No lifting. The only goal is arriving at afternoon volleyball with mobile hips and activated shoulders."
        ),

        // MARK: Friday
        TrainingDay(
            name: "Friday",
            short: "Fri",
            tags: ["high"],
            dots: ["gym"],
            sub: "Morning: second power session + court",
            weekNote: true,
            sections: [
                TrainingSection(label: "Warm-up (10 min)", exercises: [
                    Exercise(name: "Dynamic leg swings", sets: "2 × 15 each",
                             hint: "Front/back and lateral. Gets hip joints through full range before loading."),
                    Exercise(name: "Jump rope", sets: "3 min",
                             hint: "Slightly faster than Tuesday. Friday warm-up can be more intense since you're not going into max squats."),
                ]),
                TrainingSection(label: "Power block — periodized", exercises: [
                    Exercise(name: "Hang clean", sets: "5×3 / 4×5 ↗️",
                             hint: "STRENGTH WEEK: 5×3 heavier than Wednesday. HYPERTROPHY WEEK: 4×5 moderate with speed focus."),
                    Exercise(name: "Front squat", sets: "4×4 / 3×8 ↗️",
                             hint: "Start at ~75% of your back squat weight. Quad-dominant — directly trains the knee extension in your jump."),
                    Exercise(name: "Single-leg press", sets: "3 × 8 each",
                             hint: "Landing strength and knee health. Push through the heel. Prevents knee injuries from heavy jump training."),
                ]),
                TrainingSection(label: "Plyometric block", exercises: [
                    Exercise(name: "Spike approach — max jump", sets: "4 × 8",
                             hint: "Full 4-step approach, maximum effort jump, no ball. Most specific plyometric you can do. Count steps precisely."),
                    Exercise(name: "Reactive lateral hops", sets: "4 × 8 each",
                             hint: "Side to side over a line. Fast ground contact. Trains lateral quickness for reading and defending tips."),
                    Exercise(name: "Vertical jump tracking", sets: "5 jumps — record it",
                             hint: "Same target every Friday. Write the height down. This is how you know the program is working."),
                ]),
                TrainingSection(label: "Injury prevention", exercises: [
                    Exercise(name: "Copenhagen plank", sets: "3 × 20 sec each",
                             hint: "Adductor and groin strength. Side plank with top leg elevated on a bench. Volleyball players rarely train this — common injury site."),
                    Exercise(name: "Single-leg calf raise", sets: "3 × 15 each",
                             hint: "3 sec up, 3 sec down. Achilles tendon loading — prevents the most common volleyball injury."),
                    Exercise(name: "Nordic hamstring curl", sets: "3 × 5",
                             hint: "Partner holds your ankles, lower slowly from kneeling. Hardest hamstring exercise there is. Builds explosive jump resilience."),
                ]),
                TrainingSection(label: "Court — solo session (45 min)", exercises: [
                    Exercise(name: "Passing wall work", sets: "200+ reps",
                             hint: "Platform passing to a target on the wall. Film yourself from behind once a month to check platform angle."),
                    Exercise(name: "Jump serve — push power", sets: "40 reps",
                             hint: "Push slightly harder on power than Tuesday. Track how many land in zone. Stop if form breaks down."),
                    Exercise(name: "Free attack — mixed shots", sets: "20 min",
                             hint: "Relax and play. Mix safe shot, line shots and tips. Friday court time should feel more free than Tuesday."),
                ]),
            ],
            tip: "Friday is your second most important day. The vertical jump tracking takes 2 minutes and tells you if everything is working. Never skip it."
        ),

        // MARK: Saturday
        TrainingDay(
            name: "Saturday",
            short: "Sat",
            tags: ["vball"],
            dots: ["beach"],
            sub: "Beach volleyball or indoor solo — optional",
            sections: [
                TrainingSection(label: "Beach volleyball (recommended)", exercises: [
                    Exercise(name: "Match play", sets: "Self-directed",
                             hint: "No teammates to cover your weaknesses. Every bad pass costs a point. Fastest way to improve passing and defensive reading."),
                    Exercise(name: "Focus: staying low on off-speed balls", sets: "Throughout",
                             hint: "Beach forces this because the ball moves slower. Directly transfers to indoor tip defense."),
                    Exercise(name: "Reading tips and roll shots", sets: "Throughout",
                             hint: "Beach players tip constantly. Learn to anticipate it here — the patterns transfer directly to indoor."),
                ]),
                TrainingSection(label: "If no beach — indoor solo", exercises: [
                    Exercise(name: "Serve reception simulation", sets: "30 min",
                             hint: "Self-toss high, pass to target. Vary angle and spin. Gets boring fast but builds platform consistency."),
                    Exercise(name: "Jump serve volume", sets: "80–100 serves",
                             hint: "Highest serve volume of the week. You want automatic mechanics — this repetition builds that."),
                ]),
            ],
            tip: "Optional but the players who do Saturday improve noticeably faster. If you're genuinely tired or sore, rest instead — don't train badly."
        ),

        // MARK: Sunday
        TrainingDay(
            name: "Sunday",
            short: "Sun",
            tags: [],
            dots: ["rest"],
            sub: "Full rest — mandatory",
            sections: [],
            tip: nil,
            isRest: true
        ),
    ]
}
