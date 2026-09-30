// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge
    case lab
    case cargo
    case medbay
    case engine

    var evacuationPriority: Int {
        switch self {
        case .bridge:
            return 1
        case .medbay:
            return 2
        case .lab:
            return 3
        case .engine:
            return 4
        case .cargo:
            return 5
        }
    }
}

for deck in Deck.allCases {
    print("Deck: \(deck.rawValue), priority: \(deck.evacuationPriority)")
}
print("Sample deck check: \(Deck.bridge) has priority \(Deck.bridge.evacuationPriority)")

// 1.2
enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let step = mass < 0 ? 0 : mass / 500
        return AlarmLevel(rawValue: step) ?? .red
    }
}

print("AlarmLevel for 0 kg: \(AlarmLevel.level(forTotalMass: 0)), 940 kg: \(AlarmLevel.level(forTotalMass: 940))")
print("AlarmLevel for 4000 kg: \(AlarmLevel.level(forTotalMass: 4000))")


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line, separatedBy: ":")
    guard let tag = parts.first else {
        return .unknown(raw: line)
    }

    switch tag {
    case "crate":
        if parts.count == 3, let id = Int(parts[1]), let mass = Int(parts[2]) {
            return .crate(id: id, massKg: mass)
        }
    case "container":
        if parts.count == 3, let mass = Int(parts[2]) {
            return .container(code: parts[1], massKg: mass)
        }
    case "livestock":
        if parts.count == 4, let count = Int(parts[2]), let perUnit = Int(parts[3]) {
            return .livestock(species: parts[1], count: count, massPerUnitKg: perUnit)
        }
    default:
        break
    }

    return .unknown(raw: line)
}

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg
    case .container(_, let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

var totalManifestMass = 0
var unknownCount = 0

for line in rawManifest {
    let entry = parseEntry(line)
    totalManifestMass += mass(of: entry)
    switch entry {
    case .unknown:
        unknownCount += 1
    default:
        break
    }
}

let A = totalManifestMass
print("Manifest parsed entries test: \(parseEntry("crate:101:120")) and \(parseEntry("junk"))")
print("Total manifest mass (A): \(A)")
print("Unknown manifest entries count: \(unknownCount)")


// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(0, oxygen - amount)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

// 3.2
var crewRoster: [CrewSnapshot] = []
for record in crewData {
    if let deck = Deck(rawValue: record.deck) {
        crewRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
    } else {
        print("Warning: deck '\(record.deck)' does not exist for crew member \(record.name)")
    }
}

print("Crew roster count: \(crewRoster.count)")
for member in crewRoster {
    print("Crew: \(member.name), Deck: \(member.deck), Oxygen: \(member.oxygen)")
}

// 3.3 · Value-semantics demonstration (copy / plain parameter / inout)
func modifyPlain(_ snapshot: CrewSnapshot) {
    var local = snapshot
    local.breathe(25)
    print("Plain function interior modified copy: \(local.name) oxygen = \(local.oxygen)")
}

func modifyInout(_ snapshot: inout CrewSnapshot) {
    snapshot.breathe(25)
}

var testOriginal1 = CrewSnapshot.rookie(named: "TestVal1")
print("1. Before copy modification: original oxygen = \(testOriginal1.oxygen)")
var testCopy1 = testOriginal1
testCopy1.breathe(30)
print("1. After copy modification: copy oxygen = \(testCopy1.oxygen), original oxygen = \(testOriginal1.oxygen)")

var testOriginal2 = CrewSnapshot.rookie(named: "TestVal2")
print("2. Before plain function call: original oxygen = \(testOriginal2.oxygen)")
modifyPlain(testOriginal2)
print("2. After plain function call: original oxygen = \(testOriginal2.oxygen)")

var testOriginal3 = CrewSnapshot.rookie(named: "TestVal3")
print("3. Before inout function call: original oxygen = \(testOriginal3.oxygen)")
modifyInout(&testOriginal3)
print("3. After inout function call: original oxygen = \(testOriginal3.oxygen)")


// MARK: Level 4 · The Teleport Pod

// 4.1
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // Structs automatically receive a memberwise initializer because their complete layout is known at compile time and values are stored inline, whereas classes require explicit initialization to guarantee valid state without inheritance ambiguity.
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else {
            return false
        }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let passenger = occupant else {
            return nil
        }
        chargeLevel -= 20
        occupant = nil
        return passenger
    }

    deinit {
        print("TeleportPod \(id) deinitialized")
    }
}

// 4.2 · Charge ledger: load+fire three times, then fire an empty pod
var memberTimur: CrewSnapshot?
var memberDana: CrewSnapshot?
var memberNurlan: CrewSnapshot?

for member in crewRoster {
    if member.name == "Timur" { memberTimur = member }
    if member.name == "Dana" { memberDana = member }
    if member.name == "Nurlan" { memberNurlan = member }
}

let podP1 = TeleportPod(id: "P-1", chargeLevel: 100)
print("Starting charge: \(podP1.chargeLevel)")

if let timur = memberTimur {
    _ = podP1.load(timur)
    _ = podP1.fire()
    print("Step 1 (Timur loaded & fired): charge = \(podP1.chargeLevel)")
}

if let dana = memberDana {
    _ = podP1.load(dana)
    _ = podP1.fire()
    print("Step 2 (Dana loaded & fired): charge = \(podP1.chargeLevel)")
}

if let nurlan = memberNurlan {
    _ = podP1.load(nurlan)
    _ = podP1.fire()
    print("Step 3 (Nurlan loaded & fired): charge = \(podP1.chargeLevel)")
}

_ = podP1.fire()
print("Step 4 (Empty pod fired): charge = \(podP1.chargeLevel)")

let C = podP1.chargeLevel
print("Integrity fragment C: \(C)")

// 4.3 · Reference-semantics demonstration
let refPodA = TeleportPod(id: "Shared-1", chargeLevel: 100)
let refPodB = refPodA
refPodB.chargeLevel = 45
print("Reference type test - refPodA charge: \(refPodA.chargeLevel), refPodB charge: \(refPodB.chargeLevel)")

var valCrewA = CrewSnapshot.rookie(named: "Independent-1")
var valCrewB = valCrewA
valCrewB.oxygen = 45
print("Value type test - valCrewA oxygen: \(valCrewA.oxygen), valCrewB oxygen: \(valCrewB.oxygen)")

// Classes share a single instance across references, while structs copy their entire value so modifications remain independent.


// MARK: Level 5 · Station Systems

// 5.1
final class Station {
    let callSign: String
    var oxygenByDeck: [Deck: Int]

    var hullIntegrity: Int {
        willSet {
            print("Hull integrity will change from \(hullIntegrity) to \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 {
                hullIntegrity = 100
            } else if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "CallSign: \(callSign), Hull: \(hullIntegrity)%, Total O2: \(totalOxygen)%"
    }()

    var totalOxygen: Int {
        var sum = 0
        for val in oxygenByDeck.values {
            sum += val
        }
        return sum
    }

    var averageOxygen: Int {
        get {
            guard !oxygenByDeck.isEmpty else { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for key in oxygenByDeck.keys {
                oxygenByDeck[key] = newValue
            }
        }
    }

    init(callSign: String, hullIntegrity: Int, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        var o2: [Deck: Int] = [:]
        for item in readings {
            if let deck = Deck(rawValue: item.deck) {
                o2[deck] = item.oxygen
            }
        }
        self.oxygenByDeck = o2
    }
}

let station = Station(callSign: "ALMA-7", hullIntegrity: 100, readings: deckReadings)
let B = station.averageOxygen
print("Starting average oxygen (B): \(B)")
print("Total oxygen before modifications: \(station.totalOxygen)")

print("Diagnostics not accessed yet.")
print("Accessing fullDiagnostics (first time):")
print(station.fullDiagnostics)
print("Accessing fullDiagnostics (second time):")
print(station.fullDiagnostics)

// 5.2 · The clamp trap: 130, then -40, then 55
// Assigning to a property inside its own didSet observer does not invoke the observer again in Swift, which halts recursion and prevents an infinite loop.
station.hullIntegrity = 130
print("Clamped hull integrity: \(station.hullIntegrity)")

station.hullIntegrity = -40
print("Clamped hull integrity: \(station.hullIntegrity)")

station.hullIntegrity = 55
print("Clamped hull integrity: \(station.hullIntegrity)")


// MARK: Level 6 · Incident Reports
// Three of these compile and are wrong. One does not compile.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)   // author expected the crew to have lost oxygen
*/
// Report 1 Analysis:
// Expected: The author expected roster[0].oxygen to decrease by 10.
// Actual behaviour: roster[0].oxygen remains unchanged.
// Language rule: Value semantics. CrewSnapshot is a struct, so iterating with `for var member in roster` creates a local copy of each element. Mutating the local variable modifies only that copy, not the struct in the array.
// Fix:
var fixedRoster1 = crewRoster
for i in 0..<fixedRoster1.count {
    fixedRoster1[i].oxygen -= 10
}
print("Fixed Report 1: \(fixedRoster1[0].oxygen)")

/*
// Report 2
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)   // author expected 100
*/
// Report 2 Analysis:
// Expected: The author expected podA.chargeLevel to remain 100.
// Actual behaviour: podA.chargeLevel prints 0.
// Language rule: Reference semantics. TeleportPod is a class, so assigning podB = podA copies the memory reference, pointing both variables to the exact same instance on the heap.
// Fix:
let fixedPodA = TeleportPod(id: "A", chargeLevel: 100)
let fixedPodB = TeleportPod(id: "B", chargeLevel: fixedPodA.chargeLevel)
fixedPodB.chargeLevel = 0
print("Fixed Report 2: podA charge = \(fixedPodA.chargeLevel), podB charge = \(fixedPodB.chargeLevel)")

/*
// Report 3
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {
        entries.append(entry)
    }
}
*/
// Report 3 Analysis:
// Expected: Calling add(_:) appends a string to entries.
// Actual behaviour: Does not compile. Error: Cannot use mutating member on immutable value: 'self' is immutable.
// Language rule: Struct mutating method requirement. Methods on a struct cannot mutate stored properties unless declared with the mutating keyword.
// Fix:
struct FixedLogbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}
var fixedLogbook = FixedLogbook()
fixedLogbook.add("System report logged")
print("Fixed Report 3 count: \(fixedLogbook.entries.count)")

/*
// Report 4
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
*/
// Report 4 Analysis:
// Expected: The author expected both assignments to behave similarly.
// Actual behaviour: snapshot.oxygen = 40 fails to compile with error: "Cannot assign to property: 'snapshot' is a 'let' constant", whereas pod.chargeLevel = 10 compiles and runs successfully.
// Language rule: Immutability semantics of let for value vs reference types. For a struct (value type), `let` freezes the entire struct value and all its properties, making them completely immutable. For a class (reference type), `let` only freezes the reference pointer, preventing reassignment to another instance, while the instance's own mutable `var` properties remain mutable.
// Fix:
var fixedSnapshot = CrewSnapshot.rookie(named: "Dana")
fixedSnapshot.oxygen = 40
let fixedPod4 = TeleportPod(id: "B", chargeLevel: 50)
fixedPod4.chargeLevel = 10
print("Fixed Report 4: snapshot oxygen = \(fixedSnapshot.oxygen), pod charge = \(fixedPod4.chargeLevel)")


// MARK: Level 7 · Sealing the Black Box

// The leaky original:
//
// class FlightRecorder {
//     var entries: [String] = []
//     var isSealed = false
// }
//
// Your sealed version below. One comment per access keyword.

final class FlightRecorder {
    // Blocks external direct reading and overwriting of the recorded entries array.
    private var entries: [String] = []

    // Blocks external callers from directly mutating the sealed state while permitting public reads.
    private(set) var isSealed: Bool = false

    var count: Int {
        entries.count
    }

    func record(_ entry: String) -> Bool {
        guard !isSealed else { return false }
        entries.append(entry)
        return true
    }

    func seal() {
        isSealed = true
    }

    // Blocks access outside this source file while allowing the file's free audit function to access it.
    fileprivate func formattedTranscript() -> String {
        var transcript = ""
        for (index, entry) in entries.enumerated() {
            transcript += "[\(index + 1)] \(entry)\n"
        }
        return transcript
    }
}

// A free function elsewhere in the file that uses your fileprivate helper:
func auditTranscript(of recorder: FlightRecorder) -> String {
    recorder.formattedTranscript()
}

/*
// Attempting to break the recorder from outside the type:
let breachRecorder = FlightRecorder()
// Breach 1: Replacing or clearing entries
breachRecorder.entries = []
// Compiler error: 'entries' is inaccessible due to 'private' protection level

// Breach 2: Unsealing after being sealed
breachRecorder.seal()
breachRecorder.isSealed = false
// Compiler error: Cannot assign to property: 'isSealed' setter is inaccessible
*/

let flightRecorder = FlightRecorder()
_ = flightRecorder.record("Sensor online")
_ = flightRecorder.record("Teleport sequence started")
flightRecorder.seal()
let failedAppend = flightRecorder.record("Unauthorized entry")
print("FlightRecorder entry count: \(flightRecorder.count), post-seal append: \(failedAppend)")
print("FlightRecorder transcript:\n\(auditTranscript(of: flightRecorder))")


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

// 1 & 2: Lifetime experiment with do-block and ARC
var secondaryPodRef: TeleportPod?
print("Bonus 2: Before entering do-block")
do {
    let scopedPod = TeleportPod(id: "ARC-Pod", chargeLevel: 75)
    secondaryPodRef = scopedPod
    print("Bonus 2: Inside do-block, scopedPod initialized and referenced by secondaryPodRef")
}
print("Bonus 2: Exited do-block, local scopedPod reference ended but secondaryPodRef holds reference")
secondaryPodRef = nil
print("Bonus 2: secondaryPodRef set to nil. Deinitialization fired immediately above as reference count hit 0")

// 3: Identity operator === vs equal contents
func comparePods(_ podOne: TeleportPod, _ podTwo: TeleportPod) -> (isIdenticalInstance: Bool, hasEqualContent: Bool) {
    let identical = (podOne === podTwo)
    let equal = (podOne.id == podTwo.id && podOne.chargeLevel == podTwo.chargeLevel && podOne.occupant?.name == podTwo.occupant?.name)
    return (identical, equal)
}

let primaryPod = TeleportPod(id: "P-ALPHA", chargeLevel: 60)
let aliasPod = primaryPod
let clonePod = TeleportPod(id: "P-ALPHA", chargeLevel: 60)
print("Bonus 3 (same reference): \(comparePods(primaryPod, aliasPod))")
print("Bonus 3 (distinct instances, identical content): \(comparePods(primaryPod, clonePod))")


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
 Structs auto get initializers, classes dont, TeleportPod dont have default values, compiler wants an explicit initializer

 2. What does `mutating` do to self, and why do classes never need it?
 mutating is inout self, you can change the struct itself, classes never need mutating because we modify the object on a heap via reference pointer, without modifying the reference itself.

 3. In Report 4 both values are `let`. What exactly does `let` freeze for a
    struct, and what does it freeze for a class?
 let freezes the entire value for a struct, for a class let freezes only the reference pointer

 4. Why must a lazy property be var? When does lazy change behaviour, not
    just performance?
 becuase lazy will be changed in the future, it doesnt initalize immediately, it will lose its meaning, if we could never initialize it

 5. private vs fileprivate: where in your FlightRecorder would private be
    too strict?
 fileprivate allow any code in the same file access it, while private would work only in FlightRecoder class body

 Bonus. On which line does deinit fire, and why can't === be used on
 CrewSnapshot?
 it fires where secondaryPodRef = nil, because arc decrements to 0, triggers dealllocation. === cant be used because its for object reference identity and is defined for only classes. structs lack pointer identity, so we cant === them
*/
