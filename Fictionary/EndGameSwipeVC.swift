//
//  EndGameSwipeVC.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/11/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase

class EndGameSwipeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var anotherGameButton: UIButton!
    
    var items = [AnyObject]()
    var itemsAllPlayers = [AnyObject]()

    var stacks: [String] = ["stack1.jpg", "stack2.jpg", "stack3.jpg"]
    
    var ref = FIRDatabase.database().reference()
    
    var arrayOfArrays=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // July 10, 2016:
        // get user from firebase now that we are NOT using a player object
        
        self.view.backgroundColor = UIColor.pastelGreen()
        self.collectionView.backgroundColor = UIColor.shamrock()
        
        // --------------- ORIGINAL ARRAY OF SAMPLE DATA THAT WORKS -------------------- //
        
        let array1 = ["jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
        let array2 = ["etphonehome", "image2.jpg", "jackandjill", "image1.jpeg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
        let array3 = ["bullinachinacloset", "image4.gif","jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg",  "cowjumpedoverthemoon", "image5.jpg"]
        let array4 = ["jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
        let array5 = ["etphonehome", "image2.jpg", "jackandjill", "image1.jpeg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
        let array6 = ["bullinachinacloset", "image4.gif","jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg",  "cowjumpedoverthemoon", "image5.jpg"]
        
        arrayOfArrays = [array1, array2, array3, array4, array5, array6]
        
        // ---------------- DICTIONARY OF DATA TO USE ---------------------- //
        
        let image1:UIImage = UIImage(named: "strawberry")!
        let image2:UIImage = UIImage(named: "kitten")!
        let image3:UIImage = UIImage(named: "jackandjill")!
        let image4:UIImage = UIImage(named: "etphonehome")!
        

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
        
        // for multiple player dictionary scenario:
        for (key,value) in dictionary2 {
            
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
        
        
    } // end of viewDidLoad
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // This DOES return the right # of collection view cells (columns):
        //return arrayOfArrays.count
        return itemsAllPlayers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! EndGameCollectionViewCell
        
        //cell.imageView.image = UIImage(named: stacks[indexPath.row])
        //cell.array = arrayOfArrays[indexPath.row] as! [String]
        cell.array = itemsAllPlayers[indexPath.row] as! [AnyObject]
        
        // This DOES add the text label to the collection view cell:
        cell.testCVLabel.text = "TEST CV LABEL"
        
        return cell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dvc = segue.destinationViewController as! EndGameViewImageVC
        //dvc.imagePassed =
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("******** COLLECTIONVIEW > cell selected: \(indexPath.row)")
    }
    
    

    
}
