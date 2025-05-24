//
//  EmojiGameViewController.swift
//  MatchEigo
//
//  Created by Dee Jordan on 26/3/2025.
//

import UIKit
import FirebaseCore
import RealmSwift
import FirebaseFirestore



class EmojiGameViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var questionsStackView: UIStackView!
    @IBOutlet weak var answersStackView: UIStackView!
    
    @IBOutlet weak var roundLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    private let realm = try! Realm()
    private var currentUser: UserScore?
    
    let db = Firestore.firestore()
    var emojiPairs = [("", "")]
    var selectedQuestionLabel: UILabel?
    var selectedAnswerLabel: UILabel?
    let timerService = TimerService.shared
    var elapsedTime: Double = 0
    var timer: Timer?
       
    func fetchEmojiPairs() {
            db.collection("emojiPairs").getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Firestore error: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                self.emojiPairs = documents.compactMap { doc in
                    guard let emoji = doc["emoji"] as? String,
                          let english = doc["english"] as? String else {
                        print("Invalid document format")
                        return nil
                    }
                    return (emoji, english)
                }
                
                DispatchQueue.main.async {
                    self.startNewRound()
                }
            }
        }
    
    var score = 0 {
        didSet { scoreLabel.text = "Score: \(score)" }
    }
    var currentRound = 1 {
        didSet { roundLabel.text = "Round: \(currentRound)/5" }
    }
    var matchedPairs = 0
    var currentRoundPairs: [(String, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startNewRound()
        setupLabels()
        fetchEmojiPairs()
        setupAnswerButtons()
    }
    func setupLabels() {
            // Configure all labels in both stack views
            configureLabelAppearance()
            addTapGestures()
        }
    
    func configureLabelAppearance() {
            let allLabels = questionsStackView.arrangedSubviews + answersStackView.arrangedSubviews
            for case let label as UILabel in allLabels {
                label.layer.cornerRadius = 15
                label.layer.masksToBounds = true
                label.backgroundColor = .systemBlue
                label.textColor = .white
                label.font = UIFont.systemFont(ofSize:50)
                label.textAlignment = .center
                label.isUserInteractionEnabled = true
            }
        }
    
    func setupAnswerButtons() {
        for button in answersStackView.arrangedSubviews.compactMap({ $0 as? UIButton }) {
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.5
            button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
    }
    func addTapGestures() {
            for case let label as UILabel in questionsStackView.arrangedSubviews {
                let tap = UITapGestureRecognizer(target: self, action: #selector(questionTapped(_:)))
                label.addGestureRecognizer(tap)
            }
            for case let label as UILabel in answersStackView.arrangedSubviews {
                let tap = UITapGestureRecognizer(target: self, action: #selector(answerTapped(_:)))
                label.addGestureRecognizer(tap)
            }
        }

    func setupEmojiGame() {
        score = 0
        currentRound = 1
        matchedPairs = 0
        selectedQuestionLabel = nil
        selectedAnswerLabel = nil
        startNewRound()
    }
    
    func startNewRound() {
        matchedPairs = 0
        selectedQuestionLabel = nil
        selectedAnswerLabel = nil // check
        if currentRound == 1 {
            timerService.startRound()
            startLiveTimer()
        }
        currentRoundPairs = Array(emojiPairs.shuffled().prefix(4))

        
        let questions = currentRoundPairs.map { $0.0 }.shuffled()
        let answers = currentRoundPairs.map { $0.1 }.shuffled()
        
        for (index, label) in questionsStackView.arrangedSubviews.enumerated() {
            guard let label = label as? UILabel,
                  index < questions.count else { continue }
            label.text = questions[index]
            label.backgroundColor = .systemBlue
            label.alpha = 1.0
            label.isUserInteractionEnabled = true
        }

        // For answer buttons (Japanese words)
        for (index, label) in answersStackView.arrangedSubviews.enumerated() {
            guard let label = label as? UILabel,
                  index < answers.count else { continue }
            label.text = answers[index]
            label.backgroundColor = .systemBlue
            label.alpha = 1.0
            label.isUserInteractionEnabled = true
        }
    }
    
    @objc func questionTapped(_ sender: UITapGestureRecognizer) {
            guard let label = sender.view as? UILabel else { return }
            
            // Deselect previous
            selectedQuestionLabel?.layer.borderWidth = 0
            
            // Select new
            label.layer.borderColor = UIColor.systemYellow.cgColor
            label.layer.borderWidth = 4
            selectedQuestionLabel = label
            
            checkForMatch()
        }

    @objc func answerTapped(_ sender: UITapGestureRecognizer) {
            guard let label = sender.view as? UILabel else { return }
            
            selectedAnswerLabel?.layer.borderWidth = 0
            
            label.layer.borderColor = UIColor.systemYellow.cgColor
            label.layer.borderWidth = 4
            selectedAnswerLabel = label
            
            checkForMatch()
        }
        
    func checkForMatch() {
        guard let questionLabel = selectedQuestionLabel,
        let answerLabel = selectedAnswerLabel else { return }
        questionLabel.transform = .identity
        answerLabel.transform = .identity
                
        let selectedEmoji = questionLabel.text ?? ""
        let selectedWord = answerLabel.text ?? ""
        
        // Checking pairs
        if currentRoundPairs.contains(where: { $0 == (selectedEmoji, selectedWord) }) {
            score += 1
            matchedPairs += 1

            UIView.animate(withDuration: 0.3, animations: {
                questionLabel.backgroundColor = .systemGreen
                answerLabel.backgroundColor = .systemGreen
                questionLabel.alpha = 0.7
                answerLabel.alpha = 0.7
                questionLabel.layer.borderWidth = 0
                answerLabel.layer.borderWidth = 0
            }) { _ in
                
                questionLabel.isUserInteractionEnabled = false
                answerLabel.isUserInteractionEnabled = false
                self.clearSelection()
            }
            if matchedPairs == 4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.checkGameProgress()
                }
            }
        } else {
            // Wrong match
                    score = max(0, score - 1)
                    
                    UIView.animate(withDuration: 0.15, animations: {
                        // Scale up
                        questionLabel.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                        answerLabel.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                        questionLabel.backgroundColor = .systemRed
                        answerLabel.backgroundColor = .systemRed
                        questionLabel.layer.borderColor = UIColor.systemRed.cgColor
                        answerLabel.layer.borderColor = UIColor.systemRed.cgColor
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseOut, animations: {
                            // Scale back down
                            questionLabel.transform = .identity
                            answerLabel.transform = .identity
                            questionLabel.backgroundColor = .systemBlue
                            answerLabel.backgroundColor = .systemBlue
                        }, completion: { _ in
                            self.clearSelection()
                        })
                    })
                }
            }
    private func clearSelection() {
        // Remove all selection styling
        selectedQuestionLabel?.layer.borderWidth = 0
        selectedAnswerLabel?.layer.borderWidth = 0
        selectedQuestionLabel = nil
        selectedAnswerLabel = nil
    }
    
    func checkGameProgress() {
        if currentRound < 5 {
            currentRound += 1
            startNewRound()
        } else {
            let totalTime = timerService.endRound()
            stopTimer()
            // Game over, show results
            showResults(with: totalTime)
        }
    }
    func showResults(with totalTime: Double) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let resultsVC = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController {
            resultsVC.finalScore = score
            resultsVC.totalTime = totalTime
            resultsVC.gameViewController = self
            resultsVC.modalPresentationStyle = .fullScreen
            present(resultsVC, animated: true)
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Leave Game?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Stay", style: .cancel))
        alert.addAction(UIAlertAction(title: "Leave", style: .default) { _ in
            let transition = CATransition()
            
            //            3D Block animation
            transition.type = CATransitionType(rawValue: "cube")
            transition.subtype = .fromLeft
            transition.duration = 0.8
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.view.window?.layer.add(transition, forKey: nil)
            self.tabBarController?.selectedIndex = 0
            
            if let window = self.view.window {
                window.layer.add(transition, forKey: kCATransition)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
                window.rootViewController = tabBarController
            }
        })
        present(alert, animated: true)
    }
    func resetGameForNewSession() {
        // Reset all game state
        score = 0
        currentRound = 1
        matchedPairs = 0
        selectedQuestionLabel = nil
        selectedAnswerLabel = nil
        stopTimer()
        
        // Start fresh 5 rounds
        setupEmojiGame() // check
        startNewRound()
        emojiPairs.shuffle()
    }
    func startLiveTimer() {
        timer?.invalidate() // Cancel any existing timer
        elapsedTime = 0
        updateTimerLabel() // Update immediately
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 0.1
            self.updateTimerLabel()
        }
    }
    func updateTimerLabel() {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        timerLabel.text = formatter.string(from: elapsedTime)
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
