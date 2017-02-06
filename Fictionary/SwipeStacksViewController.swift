//
//  SwipeStacksViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 6/28/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class SwipeStacksViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, StackCellDelegate {

    var arrayOfArrays = [[String]]()
    var imageToPass = ""
    
    @IBAction func dismissButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let array1 = ["jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
        let array2 = ["etphonehome", "image2.jpg", "jackandjill", "image1.jpeg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
        let array3 = ["bullinachinacloset", "image4.gif","jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg",  "cowjumpedoverthemoon", "image5.jpg"]
        let array4 = ["jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
        let array5 = ["etphonehome", "image2.jpg", "jackandjill", "image1.jpeg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
        let array6 = ["bullinachinacloset", "image4.gif","jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg",  "cowjumpedoverthemoon", "image5.jpg"]

        arrayOfArrays = [array1, array2, array3, array4, array5, array6]
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfArrays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stackCell", for: indexPath) as! StackCell
        cell.array = arrayOfArrays[indexPath.row] as! [String]
        print("cell.array: \(cell.array)")
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let itemsPerRow:CGFloat = 2.5
        let hardCodedPadding:CGFloat = 5
        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
//    func rowWasSelectedAtIndexPath(indexPath: NSIndexPath) {
//        print("Row Was Selected!!!!!\(indexPath.row)")
//        
//        //performSegueWithIdentifier("imageSegue", sender: self)
//    }

    func rowWasSelectedForImage(_ imageNamed: String) {
        print("rowWasSelected FOR IMAGE ******: \(imageNamed)")
        imageToPass = imageNamed
        print("imageToPass: \(imageToPass)")
        performSegue(withIdentifier: "imageSegue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare for segue from main VC > imageToPass: \(imageToPass)")
        let vc = segue.destination as! ViewImageViewController
        vc.imageNamePassed = imageToPass
    }
    

}

extension SwipeStacksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print("didselectrow - from SwipeStacks VC")
    }
    
    
}


