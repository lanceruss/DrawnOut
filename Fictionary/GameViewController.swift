//
//  GameViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 6/30/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    var numberOfTurns = 5
    var players = []
    var players2 = []

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var textView6: UITextView!
    
    @IBAction func dismissButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func segmentedControl(sender: AnyObject) {
        if segmentedControl.selectedSegmentIndex == 0 {
            textView.hidden = false
            textView6.hidden = true
        } else {
            textView.hidden = true
            textView6.hidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.hidden = false
        textView6.hidden = true

        let player1 = "Ernie"
        let player2 = "Mike"
        let player3 = "Jacob"
        let player4 = "Tom"
        let player5 = "Gerry"
        let player6 = "Debby"
        
        let players = [player1, player2, player3, player4]
        let players2 = [player1, player2, player3, player4, player5]

        
        // START OF OUTPUT  - 5 PLAYER GAME //
        
        print("*------------------------------------------------------*")
        textView.text = "\(textView.text)\n*-----------------FICTIONARY---------------------*"
       
            print("Total # of Players: \(players.count)")
            textView.text = "\(textView.text)\nTotal # of Players: \(players.count)"
            

            numberOfTurns = players.count
            
        
        for i in 1...numberOfTurns {
            
                if i == 1 {
                    print("*-*-*-*-*-*-*-*-*-*-*-* START GAME *-*-*-*-*-*-*-*-*-*-*-*-*-*-*")
                    textView.text = "\(textView.text)\n*-*-*-*-*-*-*-*-*-*-*-* START GAME *-*-*-*-*-*-*-*-*-*-*-*-*-*-*"

                }
            
                print(i)
                textView.text = "\(textView.text)\n\(i)"
            
                if i % 2 == 0 {
                    print("Draw Picture")
                    textView.text = "\(textView.text)\nDraw Picture"

                } else {
                    print("Write Caption")
                    textView.text = "\(textView.text)\nWrite Caption"

                }
                
                for turn in players {
                    print("-\(turn)")
                    textView.text = "\(textView.text)\n-\(turn)"

                }
                
                if i == players.count {
                    print("*-*-*-*-*-*-*-*-*-*-*-* GAME OVER *-*-*-*-*-*-*-*-*-*-*-*-*-*-*")
                    textView.text = "\(textView.text)\n*-*-*-*-*-*-*-*-*-*-*-* GAME OVER *-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
                    

            }
            
        }
        

        
        // START OF OUTPUT  - 6 PLAYER GAME //
        
        textView6.text = "\(textView6.text)\n*-----------------FICTIONARY---------------------*"
        
            textView6.text = "\(textView6.text)\nTotal # of Players: \(players2.count)"
        
            numberOfTurns = players2.count
        
        for i in 1...numberOfTurns {
            
            if i == 1 {
                textView6.text = "\(textView6.text)\n*-*-*-*-*-*-*-*-*-*-*-* START GAME *-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
                
            }
            
            print(i)
            textView6.text = "\(textView6.text)\n\(i)"
            
            if i % 2 == 0 {
                print("Draw Picture")
                textView6.text = "\(textView6.text)\nDraw Picture"
                
            } else {
                print("Write Caption")
                textView6.text = "\(textView6.text)\nWrite Caption"
                
            }
            
            for turn in players2 {
                print("-\(turn)")
                textView6.text = "\(textView6.text)\n-\(turn)"
                
            }
            
                if i == players2.count {
                    textView6.text = "\(textView6.text)\n*-*-*-*-*-*-*-*-*-*-*-* GAME OVER *-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
                    
                
            }
            
        }
        
        

        
    } // end of view did load


    
}
