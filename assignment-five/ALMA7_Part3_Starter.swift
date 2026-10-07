// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  ->
// PowerCell is a class so that multiple references can share and mutate the same physical battery instance without copying state.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        if charge > 100 {
            self.charge = 100
        } else if charge < 0 {
            self.charge = 0
        } else {
            self.charge = charge
        }
    }

    func level() -> Int {
        charge
    }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, charge >= amount else {
            return false
        }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = min(100, charge + amount)
    }
}

// Encapsulation proof (leave this commented, with the compiler error):
// let testCell = PowerCell(charge: 50)
// testCell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level

let demoCell = PowerCell(charge: 120)
print("Demo power cell clamped initial level: \(demoCell.level())")
demoCell.recharge(by: 10)
print("Demo power cell level after recharge: \(demoCell.level())")


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  ->
// Making runOnce() final enforces the template method pattern, guaranteeing that subclasses cannot bypass power deduction or change the shift ritual.
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int {
        10
    }

    var statusLine: String {
        "\(id): \(cell.level())% [\(cell.level().powerBar)]"
    }

    func performTask() -> Int {
        0
    }

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else {
            return 0
        }
        return performTask()
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int {
        25
    }

    override func performTask() -> Int {
        40
    }

    func weldSeam() -> String {
        "Welding seam complete"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int {
        10
    }

    override func performTask() -> Int {
        15
    }

    override var statusLine: String {
        super.statusLine + " [scanner]"
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int {
        20
    }

    override func performTask() -> Int {
        25
    }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":
        return WelderDrone(id: id, cell: cell)
    case "scanner":
        return ScannerDrone(id: id, cell: cell)
    case "cargo":
        return CargoDrone(id: id, cell: cell)
    default:
        return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("Warning: Unknown drone kind '\(record.kind)' for id \(record.id)")
    }
}

print("Built fleet drone count: \(fleet.count)")
for drone in fleet {
    print("Pre-shift: \(drone.statusLine)")
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var totalWork = 0
    for _ in 0..<rounds {
        for drone in fleet {
            totalWork += drone.runOnce()
        }
    }
    return totalWork
}

let A = runShift(fleet, rounds: 3)

var remainingChargeSum = 0
var readyDroneCount = 0

print("Post-shift drone status lines:")
for drone in fleet {
    print(drone.statusLine)
    remainingChargeSum += drone.cell.level()
    if drone.cell.level() >= drone.powerCost {
        readyDroneCount += 1
    }
}

let B = remainingChargeSum
let C = readyDroneCount

print("Total work units (A): \(A)")
print("Total remaining charge (B): \(B)")
print("Drones ready for one more task (C): \(C)")


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Why does Drone implement recharge(by:) without `mutating`?  ->
// Drone is a class (reference type), and methods modifying reference types mutate heap storage rather than self, satisfying mutating protocol requirements without the keyword.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String {
        id
    }

    var statusCode: Int {
        healthStatusCode(for: cell.level())
    }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String {
        id
    }

    var statusCode: Int {
        healthStatusCode(for: chargeLevel)
    }

    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = min(100, chargeLevel + amount)
    }
}

var sensorModules: [SensorModule] = []
for item in sensorData {
    sensorModules.append(SensorModule(id: item.id, chargeLevel: item.charge))
}

// 4.3
// Why could [Drone] never have held the sensors?  ->
// [Drone] is restricted to instances of the Drone class hierarchy and cannot hold independent struct types like SensorModule.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = ""
    for component in components {
        report += component.diagnose() + "\n"
    }
    return report
}

var initialDiagnostics: [Diagnosable] = []
for drone in fleet {
    initialDiagnostics.append(drone)
}
for sensor in sensorModules {
    initialDiagnostics.append(sensor)
}

print("Initial diagnostics report:\n\(diagnosticsReport(initialDiagnostics))")


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }

    func healthStatusCode(for metric: Int) -> Int {
        if metric < 20 {
            return 2
        } else if metric <= 49 {
            return 1
        } else {
            return 0
        }
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String {
        name
    }

    var statusCode: Int {
        healthStatusCode(for: signalStrength)
    }

    func diagnose() -> String {
        "[LEGACY] \(componentID): code \(statusCode)"
    }
}

var fullDiagnostics: [Diagnosable] = []
for drone in fleet {
    fullDiagnostics.append(drone)
}
for sensor in sensorModules {
    fullDiagnostics.append(sensor)
}
fullDiagnostics.append(beacon)

print("Full diagnostics report with legacy beacon:\n\(diagnosticsReport(fullDiagnostics))")

var totalStatusCodeSum = 0
for comp in fullDiagnostics {
    totalStatusCodeSum += comp.statusCode
}
let D = totalStatusCodeSum
print("Sum of all status codes (D): \(D)")

// 5.3
extension Int {
    var powerBar: String {
        var clamped = self / 10
        if clamped < 0 {
            clamped = 0
        } else if clamped > 10 {
            clamped = 10
        }
        var bar = ""
        for _ in 0..<clamped {
            bar.append("#")
        }
        for _ in 0..<(10 - clamped) {
            bar.append(".")
        }
        return bar
    }
}

print("PowerBar 42: \(42.powerBar)")
print("PowerBar -5: \((-5).powerBar)")
print("PowerBar 250: \(250.powerBar)")


// MARK: Level 6 · Incident Reports
// Two of these do not compile. Two compile and lie.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}
*/
// Report 1 Analysis:
// Expected: The author expected PatchDrone to override performTask() and return 30 work units.
// Actual behaviour: Does not compile. Error: Overriding declaration requires an 'override' keyword.
// Language rule: In Swift, overriding any superclass method requires the explicit `override` keyword to prevent accidental shadowing or signature mismatches.
// Fix:
class FixedPatchDrone: Drone {
    override func performTask() -> Int {
        return 30
    }
}
let patchTest = FixedPatchDrone(id: "P-1", cell: PowerCell(charge: 50))
print("Fixed Report 1 work units: \(patchTest.runOnce())")

/*
// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}
*/
// Report 2 Analysis:
// Expected: The author expected to subclass WelderDrone and override runOnce() to return 999 units.
// Actual behaviour: Does not compile. Errors: Instance method overrides a 'final' instance method, and inheritance from a final class 'WelderDrone'.
// Language rule: Methods marked `final` cannot be overridden by any subclass, and classes marked `final` cannot be inherited from.
// Fix: Subclass Drone instead and override performTask() while respecting final runOnce():
final class FixedHeavyWelder: Drone {
    override var powerCost: Int {
        25
    }
    override func performTask() -> Int {
        999
    }
}
let heavyTest = FixedHeavyWelder(id: "HW-1", cell: PowerCell(charge: 100))
print("Fixed Report 2 work units: \(heavyTest.runOnce())")

/*
// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())
*/
// Report 3 Analysis:
// Expected: The author expected to call the WelderDrone-specific method weldSeam() directly on the first array element.
// Actual behaviour: Does not compile. Error: Value of type 'Drone' has no member 'weldSeam'.
// Language rule: The static type of the array elements is Drone, which exposes only base class members. Accessing subclass-specific members requires a runtime conditional downcast.
// as? returns an optional because conditional downcasting can fail at runtime if the instance does not match the target type, returning nil instead of crashing.
// Fix:
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print("Fixed Report 3: \(welder.weldSeam())")
}

/*
// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
*/
// Report 4 Analysis:
// Expected: The author expected parts[0].label() to print "thruster T-1".
// Actual behaviour: Compiles but prints "generic component".
// Language rule: Method dispatch in protocol extensions. Because label() is defined only in the protocol extension and not declared as a protocol requirement, Swift statically dispatches to the extension implementation based on the existential type [Labelled], bypassing the concrete type's implementation.
// Fix: Declare label() as a protocol requirement to enable dynamic customization-point dispatch:
protocol FixedLabelled {
    var componentID: String { get }
    func label() -> String
}

extension FixedLabelled {
    func label() -> String { "generic component" }
}

struct FixedThruster: FixedLabelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let fixedParts: [FixedLabelled] = [FixedThruster(componentID: "T-1")]
print("Fixed Report 4: \(fixedParts[0].label())")


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// 1. Two ways to make "you must not use Drone directly" visible:
// - Runtime: Implement performTask() in Drone to call fatalError("Abstract method performTask() must be overridden by subclass").
// - Compile-time: Mark Drone's initializer as fileprivate or require a private token parameter that only permitted subclasses can supply, preventing direct instantiation.

// 2. Protocol-based redesign with WelderDrone as a struct:
protocol DroneProtocol {
    var id: String { get }
    var powerCost: Int { get }
    mutating func performTask() -> Int
    mutating func runOnce(using cell: inout PowerCell) -> Int
}

extension DroneProtocol {
    var powerCost: Int { 10 }
    mutating func runOnce(using cell: inout PowerCell) -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

struct WelderDroneStruct: DroneProtocol {
    let id: String
    var powerCost: Int { 25 }
    mutating func performTask() -> Int { 40 }
}

// 3. Comparison:
// The protocol-and-struct architecture promotes value semantics, preventing accidental mutation aliasing and thread data races while improving compile-time optimizations.
// However, when drones must share a physical, mutable power cell or maintain shared reference identity across system subsystems, class inheritance with reference semantics is more natural and prevents state synchronization issues.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?
 classes mutating change the reference, not the class itself, because class never reassing self, they satisfy the protocol.
 
 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:
 inhetiance lets inherit some state storage and final funcs, sharing implementation, while protocols only outlines what should be done, protocols can be implemented by structs, classes, and vals, while inheritance works only for  classes

 3. What does `final` prevent, and what did it protect in runOnce()?
 final doesnt let subclasses ovveride a method, in runOnce it guaranteed that no subclass could bypass battery consumption or execution sequence

 4. In Report 4, why did the protocol extension's method win?
 extensions that are not from protocol are dispatched statically at compile time. 

*/
