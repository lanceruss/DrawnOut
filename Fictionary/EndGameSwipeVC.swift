//
//  EndGameSwipeVC.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/11/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase
import MultipeerConnectivity

class EndGameSwipeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, EndGameCellDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var anotherGameButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet var headerView: UIView!
    
    var exitDictionary = [MCPeerID : [Int : AnyObject]]()
    
    var imageToPass = UIImage()
    
    var items = [AnyObject]()
    var itemsAllPlayers = [AnyObject]()

    var stacks: [String] = ["stack1.jpg", "stack2.jpg", "stack3.jpg"]
    
    var ref = FIRDatabase.database().reference()
    
    //var arrayOfArrays = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // July 10, 2016:
        // get user from firebase now that we are NOT using a player object
        
        headerView.backgroundColor = UIColor.pastelGreen()
        self.view.backgroundColor = UIColor.medAquamarine()
        
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOpacity = 0.25
        headerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        headerView.layer.shadowRadius = 3.5
        
        self.collectionView.backgroundColor = UIColor.medAquamarine()
        self.backgroundView.backgroundColor = UIColor.medAquamarine()
        
        homeButton.layer.cornerRadius = 0.5 * homeButton.bounds.size.height
        homeButton.backgroundColor = UIColor.shamrock()
        
        anotherGameButton.layer.cornerRadius = 0.5 * anotherGameButton.bounds.size.height
        anotherGameButton.backgroundColor = UIColor.shamrock()
        

        
        // --------------- ORIGINAL ARRAY OF SAMPLE DATA THAT WORKS -------------------- //
        /*
        let array1 = ["jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
        let array2 = ["etphonehome", "image2.jpg", "jackandjill", "image1.jpeg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
        let array3 = ["bullinachinacloset", "image3.gif","jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg",  "cowjumpedoverthemoon", "image5.jpg"]
        let array4 = ["jackandjill", "image4.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
        let array5 = ["etphonehome", "image5.jpg", "jackandjill", "image1.jpeg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
        let array6 = ["bullinachinacloset", "image6.gif","jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg",  "cowjumpedoverthemoon", "image5.jpg"]
        
        arrayOfArrays = [array1, array2, array3, array4, array5, array6]
        */
        
        // ---------------- DICTIONARY OF DATA TO USE ---------------------- //
        
        /*
        let dictionary2 = ["<MCPeerID: 0x14590ff70 DisplayName = John's iPhone>":
            ["2": image3,
                "3": "ET Phone Home",
                "1": "Kitty Cat Drinking Milk",
                "4": image4]
        ]
        */
        
        // THE FINAL RESULT WILL BE A DICTIONARY OF DICTIONARIES (ONE FOR EACH DEVICE)....
        //let finalDictionary = [dictionary, dictionary2]
        
        /* // 1
        let dictionary = ["<MCPeerID: 0x14590ff70 DisplayName = Ernie's iPhone>":
            ["2": image1,
                "3": "Eating a Burger",
                "1": "Finding Nemo in the Ocean",
                "4": image2]
        ]
        
        // for single player dictionary (this does work for one player)
        /*
        for (key,value) in dictionary {
            
            let dict2 = value as NSDictionary
            var keyArray = dict2.allKeys
            
            keyArray.sortInPlace({ (element1, element2) -> Bool in
                element1.intValue < element2.intValue
            })
            
            // print(keyArray)
            
            print("\nThis is the output ordered list: \n")
            for key in keyArray {
                let value1 = dict2["\(key)"]
                print(value1)
                items.append(value1!)
            }
            print("\n")
        }
        */

        let dictionary2 = [
            // player 1
            "<MCPeerID: 0x14590ff70 DisplayName = Ernie's iPhone>":
                ["2": image1,
                    "3": "Eating a Burger",
                    "1": "Finding Nemo in the Ocean",
                    "4": image2],
            
            // player 2
            "<MCPeerID: 0x14590ff70 DisplayName = Lance's iPhone>":
                ["2": image3,
                    "3": "Playing Golf",
                    "1": "Looking in the Fridge",
                    "4": image4]
        ]
        */ // 1

        
        /*
        // ------------------- TEST DATA: JULY 12, 2016 @ 3:22PM ------------------- //
        // THIS IS THE DATA TO USE TO TEST WITHOUT HAVING TO GO THROUGH THE ENTIRE GAME:
        // DONT FORGET TO SET THE MAIN APP ENTRY POINT AS "EndGameSwipe"

        
        let image1:UIImage = UIImage(named: "green.jpg")!
        let image2:UIImage = UIImage(named: "yellow.jpg")!
        let image3:UIImage = UIImage(named: "red.jpg")!
        let image4:UIImage = UIImage(named: "blue.jpg")!
        let image5:UIImage = UIImage(named: "sample1.jpg")!
        let image6:UIImage = UIImage(named: "sample2.jpg")!
        
        let dictionary2 = [
            // player 1
            "<MCPeerID: 0x14590ff70 DisplayName = Ernie's iPhone>":
                ["2": image1,
                    "3": "Eating a Burger",
                    "1": "Finding Nemo in the Ocean",
                    "4": image2,
                    "5": image5],
            
            // player 2
            "<MCPeerID: 0x14590ff70 DisplayName = John iPhone>":
                ["2": image3,
                    "3": "Eating a Burger",
                    "1": "Finding Nemo in the Ocean",
                    "4": image2,
                    "5": image4],
            
            // player 3
            "<MCPeerID: 0x14590ff70 DisplayName = Caleb iPhone>":
                ["2": image2,
                    "3": "Eating a Burger",
                    "1": "Finding Nemo in the Ocean",
                    "4": image3,
                    "5": image6],
            
            // player 4
            "<MCPeerID: 0x14590ff70 DisplayName = Lance's iPhone>":
                ["2": image6,
                    "3": "Playing Golf",
                    "1": "Looking in the Fridge",
                    "4": image1,
                    "5": image6]
        ]


        // for multiple player dictionary scenario:
        for (_,value) in dictionary2 {
         
            print("\(exitDictionary)")
            
            items = []
            
            let dict2 = value as NSDictionary
            var keyArray = dict2.allKeys
            
            keyArray.sortInPlace({ (element1, element2) -> Bool in
                element1.intValue < element2.intValue
            })
            
            // print(keyArray)
            
            print("\nThis is the output ordered list: \n")
            for key in keyArray {
                let value1 = dict2["\(key)"]
                print(value1)
                items.append(value1!)
            }
            
            print("\n")
            
            itemsAllPlayers.append(items)
            
        } // end of for key-value in dictionary

        print("itemsAllPlayers:\n")
        print(itemsAllPlayers)
        print("# of Players: \(itemsAllPlayers.count)")
        
        // ----------------- END OF TEST DATA SCENARIO ------------------------- //
        */
        
        
        
        // -------------------- REAL GAME DATA FLOW -------------------------- //
        // THE BELOW FOR LOOP IS USED FOR REAL GAME DICTIONARY FLOW
        // USE THE CODE BELOW FOR PRODUCTION.
        // DONT FORGET TO SET THE MAIN APP ENTRY POINT AS "LOGIN"
        // for multiple player dictionary scenario:
        for (_,value) in exitDictionary {
            
            print("\(exitDictionary)")
            
            items = []
            
            let dict2 = value as NSDictionary
            var keyArray = dict2.allKeys
            
            keyArray.sort(by: { (element1, element2) -> Bool in
                (element1 as AnyObject).int32Value < (element2 as AnyObject).int32Value
            })
            
            // print(keyArray)
            
            print("\nThis is the output ordered list: \n")
            for key in keyArray {
                let keyAsInt = key as! Int
                let value1 = dict2[keyAsInt]
                //print(value1!)
                items.append(value1! as AnyObject)
            }
            
            print("\n")
            
            itemsAllPlayers.append(items as AnyObject)
            
        } // end of for key-value in dictionary
        
        //print("itemsAllPlayers:\n")
        //print(itemsAllPlayers)
        //print("# of Players: \(itemsAllPlayers.count)")

        // --------------- END OF REAL GAME DATA FLOW -------------------- //
        
        
        
        
    } // end of viewDidLoad
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // This DOES return the right # of collection view cells (columns):
        //return arrayOfArrays.count
        return itemsAllPlayers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! EndGameCollectionViewCell
        cell.delegate = self
        //cell.imageView.image = UIImage(named: stacks[indexPath.row])
        //cell.array = arrayOfArrays[indexPath.row] as! [String]
        cell.array = itemsAllPlayers[indexPath.row] as! [AnyObject]
        //print("\(cell.array)")
        
        // This DOES add the text label to the collection view cell:
        cell.testCVLabel.text = "TEST CV LABEL"
        
        return cell
        
    }
    
    func rowWasSelectedForImage(_ imageNamed: UIImage) {
        print("rowWasSelected FOR IMAGE ******: \(imageNamed)")
        imageToPass = imageNamed
        print("imageToPass: \(imageToPass)")
        performSegue(withIdentifier: "imageSegue", sender: self)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageSegue" {
            let dvc = segue.destination as! EndGameViewImageVC
            dvc.imagePassed = imageToPass
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        //device screen size
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        //calculation of cell size
        if itemsAllPlayers.count == 2 {
        return CGSize(width: (width / 2), height: height - 157)
        } else {
        return CGSize(width: (width / 2.8), height: height - 157)
        }
    }
    
    @IBAction func viewMyProfileTapped(_ sender: AnyObject) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("******** COLLECTIONVIEW > cell selected: \(indexPath.row)")
    }
    
}
