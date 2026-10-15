struct Favorite {
    let rank: Int
    let title: String
    let description: String
    let imageName: String
}

extension Favorite {
    static let all: [Favorite] = [
        Favorite(rank: 1, title: "Six", description: "Six... seven! The undisputed number one. You can't say it without doing the hand thing.", imageName: "digit6"),
        Favorite(rank: 2, title: "Seven", description: "Six's other half. Lucky, prime and forever part of the meme.", imageName: "digit7"),
        Favorite(rank: 3, title: "Zero", description: "The hero of zero. Nothing has ever felt this good.", imageName: "digit0"),
        Favorite(rank: 4, title: "One", description: "The one and only. A little lonely, but iconic.", imageName: "digit1"),
        Favorite(rank: 5, title: "Two", description: "Pairs, twins, duos. Two is just good company.", imageName: "digit2"),
        Favorite(rank: 6, title: "Four", description: "Four corners, four seasons. Solid and dependable.", imageName: "digit4"),
        Favorite(rank: 7, title: "Five", description: "High five! Halfway to ten and proud of it.", imageName: "digit5"),
        Favorite(rank: 8, title: "Eight", description: "Infinity standing up. Round, lucky, chill.", imageName: "digit8"),
        Favorite(rank: 9, title: "Nine", description: "Almost ten, never quite. Still living on cloud nine.", imageName: "digit9"),
        Favorite(rank: 10, title: "Three", description: "Dead last. Sorry, three, nobody asked for a third wheel.", imageName: "digit3"),
    ]
}
