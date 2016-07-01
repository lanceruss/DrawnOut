//
//  SwipeStacksViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 6/28/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class SwipeStacksViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, StackCellDelegate {

    var arrayOfArrays=[]
    var imageToPass = ""
    
    @IBAction func dismissButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var array1 = ["jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
        var array2 = ["etphonehome", "image2.jpg", "jackandjill", "image1.jpeg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
        var array3 = ["bullinachinacloset", "image4.gif","jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg",  "cowjumpedoverthemoon", "image5.jpg"]
        var array4 = ["jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
        var array5 = ["etphonehome", "image2.jpg", "jackandjill", "image1.jpeg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
        var array6 = ["bullinachinacloset", "image4.gif","jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg",  "cowjumpedoverthemoon", "image5.jpg"]

        arrayOfArrays = [array1, array2, array3, array4, array5, array6]
        
        
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfArrays.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("stackCell", forIndexPath: indexPath) as! StackCell
        cell.array = arrayOfArrays[indexPath.row] as! [String]
        print("cell.array: \(cell.array)")
        cell.delegate = self
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
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

    func rowWasSelectedForImage(imageNamed: String) {
        print("rowWasSelected FOR IMAGE ******: \(imageNamed)")
        imageToPass = imageNamed
        print("imageToPass: \(imageToPass)")
        performSegueWithIdentifier("imageSegue", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("prepare for segue from main VC > imageToPass: \(imageToPass)")
        let vc = segue.destinationViewController as! ViewImageViewController
        vc.imageNamePassed = imageToPass
    }
    

}

extension SwipeStacksViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        print("didselectrow - from SwipeStacks VC")
    }
    
    
}


