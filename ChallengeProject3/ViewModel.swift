//
//  ViewModel.swift
//  ChallengeProject3
//
//  Created by Rio Michelini on 13/01/2021.
//

import Foundation

enum AnswerError {
	case notRecognised
	case characterAlreadyEntered
	case noCharacterEntered
	case tooManyCharacters
}

protocol ViewModelDelegate {
	func updateUsedCharacters(to letters: String)
	func finishGameWon()
	func finishGameLost()
	func updateHangmanImage(lives: Int)
	func updateScore(score: Int)
	func updateLives(lives: Int)
	func updateCurrentWord(word: String)
	func updateLevel(level: Int)
	func showErrorMessage(_ error: AnswerError)
}

class ViewModel {
	
	init(delegate: ViewModelDelegate, service: HangmanService) {
		self.delegate = delegate
		self.service = service
	}
	
	var promptWord: String = ""
	var word: String = ""
	var usedLetters = [String]()
	var lives: Int = 6
	var level: Int = 0
	var score: Int = 0
	var character: Character = "?"
	var hangmanImages = [String]()
	
	var delegate: ViewModelDelegate
	var service: HangmanService
	
	func submitAnswer(answer: String) {
		print(promptWord)
		let allowedCharacters = CharacterSet.letters
		let characterSet = CharacterSet(charactersIn: answer)
		var error: AnswerError?
		if answer != "" {
			if !usedLetters.contains(answer) {
				if allowedCharacters.isSuperset(of: characterSet) {
					if answer.count > 1 {
						error = .tooManyCharacters
					} else {
						usedLetters.append(answer)
						checkAnswer(Character(answer))
					}
				} else {
					error = .notRecognised
				}
			} else {
				error = .characterAlreadyEntered
			}
		} else {
			error = .noCharacterEntered
		}
		guard let unwrappedError = error else { return }
		delegate.showErrorMessage(unwrappedError)
	}
	
	private func checkAnswer(_ char: Character) {
		promptWord = ""
		delegate.updateUsedCharacters(to: usedLetters.joined(separator: " "))
		for letter in String(word) {
			if word.contains(char) {
				if usedLetters.contains(String(letter)) {
					promptWord.append(letter)
					if promptWord == word {
						delegate.finishGameWon()
					}
				} else {
					promptWord += "_ "
				}
			} else {
				score -= 1
				lives -= 1
				delegate.updateScore(score: score)
				delegate.updateLives(lives: lives)
				delegate.updateHangmanImage(lives: lives)
				if lives == 0 {
					delegate.updateHangmanImage(lives: lives)
					delegate.finishGameLost()
				}
				break
			}
			delegate.updateCurrentWord(word: promptWord)
		}
		if word.contains(char) {
			score += 1
			delegate.updateScore(score: score)
		}
	}
	
	func loadLevel() {
		// reset all the scores and arrays
		usedLetters.removeAll()
		promptWord = ""
		word = ""
		delegate.updateUsedCharacters(to: "")
		lives = 6
		level += 1
		delegate.updateLives(lives: lives)
		delegate.updateHangmanImage(lives: lives)
		let words = service.loadHangmanWords()?.shuffled()
		guard let word = words?.first else { return }
		self.word = word
		print(word)
		for _ in String(word) {
			promptWord += "_ "
		}
		delegate.updateCurrentWord(word: promptWord)
		delegate.updateLevel(level: level)
	}
	
	func loadHangmanImages() {
		hangmanImages = service.loadHangmanImages()
		hangmanImages.sort()
	}
	
}

protocol HangmanService {
	func loadHangmanImages() -> [String]
	func loadHangmanWords() -> [String]?
}

class FileHangmanService: HangmanService {
	
	func loadHangmanImages() -> [String] {
		var hangmanImages = [String]()
		let fm = FileManager.default
		let path = Bundle.main.resourcePath!
		let items = try! fm.contentsOfDirectory(atPath: path)
		for item in items {
			if item.hasPrefix("hangman") {
				hangmanImages.append(item)
			}
		}
		return hangmanImages
	}
	
	func loadHangmanWords() -> [String]? {
		if let wordsFile = Bundle.main.url(forResource: "words", withExtension: "txt") {
			if let wordContents = try? String(contentsOf: wordsFile) {
				let words = wordContents.components(separatedBy: "\n")
				return words
			}
		}
		return nil
	}
}
