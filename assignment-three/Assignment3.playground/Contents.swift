// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each signature when you start working on it.


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let (sensor, rawValue) = splitOnce(raw, by: ":"),
          !sensor.isEmpty,
          let value = Int(rawValue),
          value >= 0 || sensor == "TEMP"
            else { return nil }
    
    
    return (sensor, value)
}

print(parseReading("O2:87"))
print(parseReading("TEMP:-12"))
print(parseReading("RAD:-1"))
print(parseReading(":55"))

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    
    return (valid, invalidCount)
}

let A = parseLog(rawLog).invalidCount

print(parseLog(rawLog))
print(parseLog(["O2:1", "bad", ":5"]))
print("A = \(A)")


// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

let valid = parseLog(rawLog).valid
let o2Readings = select(valid) { $0.sensor == "O2" }
print(o2Readings)
print(values(of: o2Readings))

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }

    var min = first
    var max = first
    var sum = 0
    for value in values {
        if value < min { min = value }
        if value > max { max = value }
        sum += value
    }
    return (min, max, Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print(stats(3, 8, 1))
print(stats())

let o2Stats = stats(of: values(of: o2Readings))
let B = Int(o2Stats?.average ?? 0)

// 2.3 · The Closure Ladder (5 sorts, then compare results in code)
let sorted1 = valid.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})
let sorted2 = valid.sorted(by: { a, b in return a.value > b.value })
let sorted3 = valid.sorted(by: { a, b in a.value > b.value })
let sorted4 = valid.sorted(by: { $0.value > $1.value })
let sorted5 = valid.sorted { $0.value > $1.value }

let expected = values(of: sorted1)
let allMatch = values(of: sorted2) == expected
    && values(of: sorted3) == expected
    && values(of: sorted4) == expected
    && values(of: sorted5) == expected
print(expected)
print(allMatch)


// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int {
    t + 5
}

func coolDown(_ t: Int) -> Int {
    t - 3
}

func hold(_ t: Int) -> Int {
    t
}

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 { return heatUp }
    if temp > 24 { return coolDown }
    return hold
}

print(chooseProtocol(for: 10)(10))
print(chooseProtocol(for: 30)(30))

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    let safeRange = 18...24
    var temp = start
    var steps = 0

    while !safeRange.contains(temp) && steps < maxSteps {
        let applyProtocol = chooseProtocol(for: temp)
        temp = applyProtocol(temp)
        steps += 1
    }
    return (temp, steps, safeRange.contains(temp))
}

print(runUntilStable(from: 31))
print(runUntilStable(from: -100, maxSteps: 5))

let tempReadings = select(valid) { $0.sensor == "TEMP" }
let tempStats = stats(of: values(of: tempReadings))
let lowestTemp = tempStats?.min ?? 0
let C = runUntilStable(from: lowestTemp).steps


// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

for member in crew {
    print(oxygenLevel(of: member))
}

// 4.2
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let place = member.module?.name ?? "open space"
        return "\(member.name): no data (\(place))"
    }
    let state = level < 20 ? "CRITICAL" : "OK"
    return "\(member.name): \(level)% \(state)"
}

for member in crew {
    print(status(of: member))
}

// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }

    let freeSpace = 100 - target
    let transferred = min(amount, source, freeSpace)
    source -= transferred
    target += transferred
    return transferred
}

var testSource = 10
var testTarget = 95
print(transferOxygen(from: &testSource, to: &testTarget, amount: 20))
print(transferOxygen(from: &testSource, to: &testTarget, amount: -5))

if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
}

let D = hab.oxygenTank?.level ?? 0

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }

    let sortedMembers = found.sorted { $0.priority < $1.priority }
    var result: [String] = []
    for member in sortedMembers {
        result.append(member.name)
    }
    return result
}

print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))
print(evacuationOrder("Nurlan", "Timur", roster: roster))


// MARK: Level 5 · The Saboteur's Logbook
// The saboteur's code is below, commented out (it needs your
// oxygenLevel(of:) to compile). Comment on every problem, then
// write fixed versions and a test that proves the logic bug is gone.

/*
func reportOxygen(for member: CrewMember) -> String {
    // module! crashes for Nurlan, no module (open space)
    // oxygenTank! crashes for Dana, Dock has no tank
    let tank = member.module!.oxygenTank!
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        // crashes on Dana, oxygenLevel is nil
        if oxygenLevel(of: member)! < 20 {
            // logic bug: no break, so it keeps going and returns the LAST critical member, not the first
            result = member.name
        }
    }
    // crashes if nobody is critical, result stays nil
    return result!
}
*/

func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        guard let level = oxygenLevel(of: member) else { continue }
        if level < 20 { return member.name }
    }
    return nil
}

for member in crew {
    print(reportOxygen(for: member))
}
print(firstCritical(in: crew))

let firstModule = Module(name: "Test1", oxygenTank: Tank(level: 5))
let secondModule = Module(name: "Test2", oxygenTank: Tank(level: 10))
let testCrew = [
    CrewMember(name: "First", role: "Test", priority: 1, module: firstModule),
    CrewMember(name: "Second", role: "Test", priority: 2, module: secondModule)
]
print(firstCritical(in: testCrew) == "First")


// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0
    return { level in
        guard level < threshold else { return false }
        count += 1
        print("Alarm #\(count)")
        return true
    }
}

let alarm = makeAlarm(threshold: 20)
print(alarm(12))
print(alarm(40))
print(alarm(5))


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax: guard let creates a variable, that you can access out of the guard let's scope, while if let creates a variable, thats only accessible inside if lets block. Also guard let looks more clean for several related clauses, rather than creating ladder code

 2. Why can't you pass [Int] to stats(_ values: Int...)? Int... expects 0, 1 or more integer values, it takes them, and makes them an array, when you just pass an array, it will have type mismatch

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile? Because it will have atomicity problems, passing two the same inout vars into one func will lead to exclusivity problems, both of them in one place trying to change one variable.

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile? oxygen level func returns Int? while we try to null safe it to the String type, which leads to type mismatch.

 5. Full type of chooseProtocol and how to read it: It takes an Int, and depending on the result returns a functions, thats takes Int, to return Int, which is Int -> Int -> Int

 Bonus. Where does the alarm counter live after makeAlarm returns? because we save the method inside a variable, so it goes to heap, then we use pass 20 as a threshold, and every func that calls it takes a func, that was return when we created let alarm : {20 -> Int -> Bool }.

*/
