//
//  ViewController.swift
//  ChallengeProject3
//
//  Created by Rio Michelini on 13/12/2020.
//

import UIKit

extension AnswerError {
	var title: String {
		switch self {
			case .notRecognised:
				return "Not Recognised"
			case .characterAlreadyEntered:
				return "Character Already Entered"
			case .noCharacterEntered:
				return "No Character Entered"
			case .tooManyCharacters:
				return "Too Many Characters"
		}
	}
	var message: String {
		switch self {
			case .notRecognised:
				return "You must enter a single character."
			case .characterAlreadyEntered:
				return "You cannot reuse characters."
			case .noCharacterEntered:
				return "You must enter a single character."
			case .tooManyCharacters:
				return "You must only enter one character at a time."
		}
	}
}

class ViewController: UIViewController, ViewModelDelegate {
	
	var viewModel: ViewModel!
	
	var inputButton = UIButton()
	var livesLabel: UILabel!
	var levelLabel: UILabel!
	var scoreLabel: UILabel!
	var usedCharactersLabel: UILabel!
	var currentWord = UITextField()
	var hangmanView = UIImageView()
	
	override func loadView() {
		view = UIView()
		view.backgroundColor = .systemBackground
		
		livesLabel = UILabel()
		applyStyling(label: livesLabel, text: "Lives: 0 / 6")
		
		levelLabel = UILabel()
		applyStyling(label: levelLabel, text: "Level: 1")
		
		scoreLabel = UILabel()
		applyStyling(label: scoreLabel, text: "Score: 0")
		
		usedCharactersLabel = UILabel()
		applyStyling(label: usedCharactersLabel, text: "Letters Used: ")
		
		setupCurrentWordTextField()
		
		setupInputButton()
		
		setupHangmanView()
		
		setupConstraints()
	}
	
	private func applyStyling(label: UILabel, text: String) {
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .right
		label.text = text
		view.addSubview(label)
	}
	
	private func setupCurrentWordTextField() {
		currentWord = UITextField()
		currentWord.translatesAutoresizingMaskIntoConstraints = false
		currentWord.placeholder = "???"
		currentWord.textAlignment = .center
		currentWord.font = UIFont.systemFont(ofSize: 34)
		currentWord.isUserInteractionEnabled = false
		view.addSubview(currentWord)
	}
	
	private func setupInputButton() {
		inputButton = UIButton(type: .system)
		inputButton.translatesAutoresizingMaskIntoConstraints = false
		inputButton.setTitle("Guess", for: .normal)
		inputButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
		inputButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
		view.addSubview(inputButton)
	}
	
	private func setupHangmanView() {
		hangmanView = UIImageView(image: UIImage(named: "hangman6.jpg"))
		hangmanView.translatesAutoresizingMaskIntoConstraints = false
		hangmanView.layer.cornerRadius = 5
		hangmanView.layer.masksToBounds = true
		hangmanView.sizeToFit()
		hangmanView.center = view.center
		view.addSubview(hangmanView)
		view.bringSubviewToFront(hangmanView)
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([levelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
		 levelLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
		 
		 livesLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 10),
		 livesLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
		 
		 scoreLabel.topAnchor.constraint(equalTo: livesLabel.bottomAnchor, constant: 10),
		 scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
		 
		 usedCharactersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 10),
		 usedCharactersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
		 
		 inputButton.topAnchor.constraint(equalTo: currentWord.bottomAnchor, constant: 40),
		 inputButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
		 inputButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
		 
		 currentWord.topAnchor.constraint(equalTo: hangmanView.bottomAnchor, constant: 5),
		 currentWord.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
		 currentWord.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
		 
		 hangmanView.widthAnchor.constraint(equalToConstant: 400),
		 hangmanView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
		 hangmanView.heightAnchor.constraint(equalToConstant: 400),
		 hangmanView.topAnchor.constraint(equalTo: usedCharactersLabel.topAnchor, constant: 10)])
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		viewModel = ViewModel(delegate: self, service: FileHangmanService())
		// Do any additional setup after loading the view.
		self.navigationItem.title = "Hangman"
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restart))
		
		viewModel.loadHangmanImages()
		viewModel.loadLevel()
	}
	
	@objc func submitTapped(_ sender: UIButton) {
		print(viewModel.promptWord)
		let ac = UIAlertController(title: "Guess a letter", message: nil, preferredStyle: .alert)
		ac.addTextField()
		let submitAction = UIAlertAction(title: "Guess", style: .default) { [weak self, weak ac] action in
			guard let answer = ac?.textFields?[0].text else { return }
			self?.viewModel.submitAnswer(answer: answer)
			
		}
		ac.addAction(submitAction)
		present(ac, animated: true)
	}
	
	func presentAlertController(title: String, message: String, buttonTitle: String, handler: @escaping (UIAlertAction) -> Void) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: handler))
		present(ac, animated: true)
	}
	
	func updateUsedCharacters(to letters: String) {
		usedCharactersLabel.text = "Letters used: \(letters)"
	}
	
	func finishGameWon() {
		presentAlertController(title: "Well Done!", message: "Ready for the next level?", buttonTitle: "Let's go!", handler: levelUp)
	}
	
	func finishGameLost() {
		presentAlertController(title: "You Lose!", message: "Want to play again?", buttonTitle: "Sure!", handler: self.restart)
	}
	
	func updateHangmanImage(lives: Int) {
		hangmanView.image = UIImage(named: viewModel.hangmanImages[lives])
	}
	
	func updateScore(score: Int) {
		scoreLabel.text = "Score: \(score)"
	}
	
	func updateLives(lives: Int) {
		livesLabel.text = "Lives: \(lives) / 6"
		updateHangmanImage(lives: lives)
	}
	
	func updateCurrentWord(word: String) {
		currentWord.text = word
	}
	
	func updateLevel(level: Int) {
		levelLabel.text = "Level: \(level)"
	}
	
	@objc func loadLevel() {
		viewModel.loadLevel()
	}
	
	func levelUp(action: UIAlertAction) {
		loadLevel()
	}
	
	@objc func restart(action: UIAlertAction) {
		viewModel.level = 0
		loadLevel()
	}
	
	func showErrorMessage(_ error: AnswerError) {
		let ac = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Okay", style: .default))
		present(ac, animated: true)
	}

}

