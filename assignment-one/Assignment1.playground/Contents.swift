import Foundation

var firstName = "Aktanberdi"
var lastName = "Ybyraiym"
var birthYear = 2006
var isStudent = true
var height = 1.78

let currentYear = 2026
var age = currentYear - birthYear

var hobby = "playing Civ 6"
var numberOfHobbies = 3
var favoriteNumber = 7
var isHobbyCreative = false

var futureGoals = "become super mega rich, some CTO at Google"
var mood = "🚀"

let studentStatus = isStudent ? "currently a student" : "not a student"
let creativeStatus = isHobbyCreative ? "a creative hobby" : "not a creative hobby"

var lifeStory = "My name is \(firstName) \(lastName). I am \(age) years old, born in \(birthYear). I am \(studentStatus). My height is \(height) meters. I enjoy \(hobby), which is \(creativeStatus). I have \(numberOfHobbies) hobbies in total, and my favorite number is \(favoriteNumber). In the future, I want to \(futureGoals). My current mood is \(mood)"

print(lifeStory)
