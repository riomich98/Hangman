//
//  ChallengeProject3Tests.swift
//  ChallengeProject3Tests
//
//  Created by Rio Michelini on 17/01/2021.
//
@testable import ChallengeProject3
import XCTest

class ChallengeProject3Tests: XCTestCase {
	
	var delegate: MockViewModelDelegate!
	var service: MockHangmanService!
	var viewModel: ViewModel!
	
	override func setUp() {
		delegate = MockViewModelDelegate()
		service = MockHangmanService()
		viewModel = ViewModel(delegate: delegate, service: service)
	}

	func test_shouldLoadImages() {
		service.hangmanImages = ["test"]
		viewModel.loadHangmanImages()
		XCTAssertEqual(viewModel.hangmanImages, ["test"])
	}
	
	func test_shouldLoadImagesAndSort() {
		service.hangmanImages = ["hangman0","hangman2","hangman1"]
		viewModel.loadHangmanImages()
		XCTAssertEqual(viewModel.hangmanImages, ["hangman0","hangman1","hangman2"])
		XCTAssertNotEqual(viewModel.hangmanImages, ["hangman0","hangman2","hangman1"])
	}
	
	func test_shouldLoadWords_WhenLevelStarts() {
		service.words = ["dressed", "arrange"]
		viewModel.loadLevel()
		XCTAssertFalse(viewModel.word.isEmpty)
		XCTAssertTrue(["dressed", "arrange"].contains(viewModel.word))
	}
	
	func test_shouldNotReturnWord_GivenServiceReturnsNoWords_WhenLevelStarts() {
		service.words = []
		viewModel.loadLevel()
		XCTAssertTrue(viewModel.word.isEmpty)
	}
	
	func test_shouldClearUsedCharacters_WhenLevelStarts() {
		viewModel.loadLevel()
		XCTAssertTrue(delegate.usedCharacters.isEmpty)
	}
	
	func test_ShouldResetLives_WhenLevelStarts() {
		viewModel.loadLevel()
		XCTAssertEqual(delegate.lives, 6)
	}
	
	func test_ShouldResetHangmanImage_WhenLevelStarts() {
		viewModel.loadLevel()
		XCTAssertEqual(delegate.hangmanImageLives, 6)
	}
	
	func test_ShouldUpdateCurrentWord_WhenLevelStarts() {
		service.words = ["sad"]
		viewModel.loadLevel()
		XCTAssertEqual(delegate.promptWord, "_ _ _ ")
	}
	
	func test_ShouldUpdateLevel_WhenLevelStarts() {
		service.words = ["kombucha"]
		viewModel.loadLevel()
		XCTAssertEqual(delegate.level, 1)
		viewModel.loadLevel()
		XCTAssertEqual(delegate.level, 2)
	}
	
	func test_ShouldReturnNotRecognisedError_WhenCharacterIsntAlphabetical() {
		service.words = ["icecream"]
		viewModel.submitAnswer(answer: "1")
		XCTAssertEqual(delegate.error, .notRecognised)
	}
	
	func test_ShouldReturnCharacterAlreadyEntered_WhenCharacterAlreadyEntered() {
		service.words = ["fukushimea"]
		viewModel.submitAnswer(answer: "e")
		viewModel.submitAnswer(answer: "e")
		XCTAssertEqual(delegate.error, .characterAlreadyEntered)
	}
	
	func test_ShouldReturnNoCharacterEntered_WhenNothingIsEntered() {
		service.words = ["jujitsu"]
		viewModel.submitAnswer(answer: "")
		XCTAssertEqual(delegate.error, .noCharacterEntered)
	}
	
	func test_ShouldReturnTooManyCharacters_WhenMoreThanOneCharacterEntered() {
		service.words = ["smoking"]
		viewModel.submitAnswer(answer: "kkk")
		XCTAssertEqual(delegate.error, .tooManyCharacters)
	}
	
	func test_ShouldUpdateUsedCharacters_WhenAnswerChecked() {
		service.words = ["services"]
		viewModel.loadLevel()
		viewModel.submitAnswer(answer: "g")
		XCTAssertEqual(delegate.usedCharacters, "g")
	}
	
	func test_ShouldUpdateScoreLivesImage_WhenAnswerIncorrect() {
		service.words = ["coconut"]
		viewModel.loadLevel()
		viewModel.submitAnswer(answer: "q")
		XCTAssertEqual(delegate.score, -1)
		XCTAssertEqual(delegate.lives, 5)
		XCTAssertEqual(delegate.hangmanImageLives, 5)
		XCTAssertEqual(delegate.promptWord, "_ _ _ _ _ _ _ ")
	}
	
	func test_ShouldUpdateScoreLivesImage_WhenAnswerCorrect() {
		service.words = ["sunshine"]
		viewModel.loadLevel()
		viewModel.submitAnswer(answer: "u")
		XCTAssertEqual(delegate.score, 1)
		XCTAssertEqual(delegate.lives, 6)
		XCTAssertEqual(delegate.promptWord, "_ u_ _ _ _ _ _ ")
	}
	
	func test_ShouldOnlyIncreaseScoreByOne_WhenAnswerCorrect_AndWordContainsDoubleCharacters() {
		service.words = ["dessert"]
		viewModel.loadLevel()
		viewModel.submitAnswer(answer: "s")
		XCTAssertEqual(delegate.score, 1)
	}
	
	func test_ShouldFinishGame_WhenWordGuessedCorrectly() {
		service.words = ["queues"]
		viewModel.loadLevel()
		viewModel.submitAnswer(answer: "q")
		viewModel.submitAnswer(answer: "u")
		viewModel.submitAnswer(answer: "e")
		viewModel.submitAnswer(answer: "s")
		XCTAssertTrue(delegate.didWin)
	}
	
	func test_ShouldFinishGame_WhenWordGuessedIncorrectly() {
		service.words = ["bad"]
		viewModel.loadLevel()
		for letter in ["k","r","g","o","i","y"] {
			viewModel.submitAnswer(answer: letter)
		}
		XCTAssertTrue(delegate.didLose)
		
	}
}

class MockHangmanService: HangmanService {
	
	var hangmanImages: [String]!
	var words: [String]!
	
	func loadHangmanImages() -> [String] {
		return hangmanImages
	}
	
	func loadHangmanWords() -> [String]? {
		return words
	}
	
	
}

class MockViewModelDelegate: ViewModelDelegate {
	
	var usedCharacters = "silkworm"
	var hangmanImageLives = 0
	var promptWord = "silkworm"
	var lives = 0
	var level = 0
	var score = 0
	var error: AnswerError!
	var didWin = false
	var didLose = false
	
	func updateUsedCharacters(to letters: String) {
		usedCharacters = letters
	}
	
	func finishGameWon() {
		didWin = true
	}
	
	func finishGameLost() {
		didLose = true
	}
	
	func updateHangmanImage(lives: Int) {
		hangmanImageLives = lives
	}
	
	func updateScore(score: Int) {
		self.score = score
	}
	
	func updateLives(lives: Int) {
		self.lives = lives
	}
	
	func updateCurrentWord(word: String) {
		self.promptWord = word
	}
	
	func updateLevel(level: Int) {
		self.level = level
	}
	
	func showErrorMessage(_ error: AnswerError) {
		self.error = error
	}
	
}
