import UIKit

// Easy Tasks

// 1
let fruits = ["Apple", "Banana", "Orange", "Pineapple", "Strawberry"]
print(fruits[2]) // печатает орандж

// 2
var favoriteNumbers: Set<Int> = [67, 67, 67, 67, 67]
favoriteNumbers.insert(67)
print(favoriteNumbers) // prosto 67 ostanetsya

// 3
let codingLanguagesAndReleaseYears: [String: Int] = ["Kotlin": 2011, "Swift": 2014, "JavaScript": 1995]
print(codingLanguagesAndReleaseYears["Swift"])

// 4
var colors = ["red", "green", "blue", "white"]
colors[1] = "black"
print(colors)

// Medium Tasks

// 1
let numbersSetA: Set<Int> = [1, 2, 3, 4]
let numbersSetB: Set<Int> = [3, 4, 5, 6]
let intersectionResult = numbersSetA.intersection(numbersSetB)
print(intersectionResult)

// 2
var studentScores = ["aktan": 80, "maga": 90, "ktoto": 70]
studentScores.updateValue(95, forKey: "aktan")
print(studentScores)

// 3
let fruitsArrayOne = ["apple", "banana"]
let fruitsArrayTwo = ["cherry", "date"]
let mergedFruits = fruitsArrayOne + fruitsArrayTwo
print(mergedFruits)

// Hard Tasks

// 1
var countryPopulations = ["Kazakhstan": 19000000, "USA": 331000000]
countryPopulations.updateValue(38000000, forKey: "Canada")
print(countryPopulations)

// 2
let animalsSetA: Set<String> = ["cat", "dog"]
let animalsSetB: Set<String> = ["dog", "mouse"]
let animalsUnion = animalsSetA.union(animalsSetB)
let animalsResult = animalsUnion.subtracting(animalsSetB)
print(animalsResult)

// 3
let studentGrades = ["aktan": [85, 90, 78], "maga": [70, 88, 92]]
let aktansSecondGrade = studentGrades["aktan", default: []][1]
print(aktansSecondGrade)

