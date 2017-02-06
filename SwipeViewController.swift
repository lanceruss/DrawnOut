//
//  ViewController.swift
//  LGLinearFlowViewSwift
//
//  Created by Ernie Barojas on 07/07/2016.
//  Copyright © 2016 Ernie Barojas. All rights reserved.
//

import UIKit

class SwipeViewController: UIViewController {
    
    // MARK: Vars
    
    fileprivate var collectionViewLayout: LGHorizontalLinearFlowLayout!
    fileprivate var dataSource: Array<String>!
    
    @IBOutlet fileprivate var collectionView: UICollectionView!
    @IBOutlet fileprivate var nextButton: UIButton!
    @IBOutlet fileprivate var previousButton: UIButton!
    @IBOutlet fileprivate var pageControl: UIPageControl!
    
    var selectedStackID = Int()
    
    fileprivate var animationsCount = 0
    
    fileprivate var pageWidth: CGFloat {
        return self.collectionViewLayout.itemSize.width + self.collectionViewLayout.minimumLineSpacing
    }
    
    fileprivate var contentOffset: CGFloat {
        return self.collectionView.contentOffset.x + self.collectionView.contentInset.left
    }

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureDataSource()
        self.configureCollectionView()
        self.configurePageControl()
        self.configureButtons()
    }
    
    // MARK: Configuration
    
    fileprivate func configureDataSource() {
        self.dataSource = Array()
        for index in 1...8 {
            self.dataSource.append("Stack \(index)")
        }
    }
    
    fileprivate func configureCollectionView() {
        self.collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        self.collectionViewLayout = LGHorizontalLinearFlowLayout.configureLayout(collectionView: self.collectionView, itemSize: CGSize(width: 180, height: 480), minimumLineSpacing: 0)
    }
    
    fileprivate func configurePageControl() {
        self.pageControl.numberOfPages = self.dataSource.count
    }
    
    fileprivate func configureButtons() {
        self.nextButton.isEnabled = self.dataSource.count > 0 && self.pageControl.currentPage < self.dataSource.count - 1
        self.previousButton.isEnabled = self.pageControl.currentPage > 0
    }
    
    // MARK: Actions
    
    @IBAction fileprivate func pageControlValueChanged(_ sender: AnyObject) {
        self.scrollToPage(self.pageControl.currentPage, animated: true)
    }
    
    @IBAction fileprivate func nextButtonAction(_ sender: AnyObject) {
        self.scrollToPage(self.pageControl.currentPage + 1, animated: true)
    }

    @IBAction fileprivate func previousButtonAction(_ sender: AnyObject) {
        self.scrollToPage(self.pageControl.currentPage - 1, animated: true)
    }

    fileprivate func scrollToPage(_ page: Int, animated: Bool) {
        self.collectionView.isUserInteractionEnabled = false
        self.animationsCount += 1
        let pageOffset = CGFloat(page) * self.pageWidth - self.collectionView.contentInset.left
        self.collectionView.setContentOffset(CGPoint(x: pageOffset, y: 0), animated: true)
        self.pageControl.currentPage = page
        self.configureButtons()
    }
}

extension SwipeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        collectionViewCell.pageLabel.text = self.dataSource[indexPath.row]
        return collectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.isDragging || collectionView.isDecelerating || collectionView.isTracking {
            return
        }
        
        let selectedPage = indexPath.row
        
        if selectedPage == self.pageControl.currentPage {
            print("Did select center item: selectedPage: \(selectedPage) currentPage:\(self.pageControl.currentPage) indexPath.row: \(indexPath.row)")
            
            // This creates a reference to the VC to pass data to - not using a prepareForSegue...
            let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ViewStackViewController") as! ViewStackViewController
            controller.stackID = indexPath.row
            self.present(controller, animated: true, completion: nil)

            
        }
        else {
            self.scrollToPage(selectedPage, animated: true)
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(self.contentOffset / self.pageWidth)
        self.configureButtons()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if --self.animationsCount == 0 {
            self.collectionView.isUserInteractionEnabled = true
        }
    }
    
}
