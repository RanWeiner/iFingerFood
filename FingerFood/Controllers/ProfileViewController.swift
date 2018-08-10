//
//  ProfileViewController.swift
//  FingerFood
//
//  Created by Mac on 18/07/2018.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource {
    
   
   
    @IBOutlet weak var numOfDishesLabel: UILabel!
    @IBOutlet weak var numOfRestsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    private var userData : User? = nil
    private var dataHandler : DataManager? = nil
    
    private var likedCards : [Card] = []
    private var allRests : [Restaurant] = []
    private var username : String = ""
    
    private let tileMargin: CGFloat = 2.0
    private let numberOfItemsPerRow: CGFloat = 3.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        
        userData = User.getInstance()
        dataHandler = DataManager.getInstance()
        
        username = (userData?.getUsername())!
        likedCards = (userData?.getAllLikes())!
        allRests = (dataHandler?.getAllRestaurants())!
        
       setCollectionViewCells()
        setUserName()
        setStatus()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        
    }
    
   
    func setUserName() {
        if userData != nil {
            usernameLabel.text = username
        }
        else {
            usernameLabel.text = "user"
        }
    }
    
    func setStatus(){
        let numOfLikedRest = getNumOfLikesRest()
        numOfRestsLabel.text  = String(numOfLikedRest)
        numOfDishesLabel.text = String(likedCards.count)
    }
    
    
    
    func getNumOfLikesRest() -> Int{
        var set = Set<String>()
        
        for card in likedCards {
            set.insert(card.getRestId())
        }
        return set.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likedCards.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardViewCell
        
        cell.setIndex(index: indexPath.item)
        cell.setCard(card: likedCards[indexPath.item])
        cell.cellImage.kf.setImage(with: likedCards[indexPath.item].getCardURL())
    
        return cell
    }
    
    
 /*
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setCollectionViewCells()
    }
   */
    
    
    
    
    func setCollectionViewCells()
    {
        let collectionViewWidth = collectionView.frame.width 
        
        let itemWidth = (collectionViewWidth) / numberOfItemsPerRow
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        collectionView.collectionViewLayout = layout
       //layout.minimumLineSpacing = 0
       //layout.minimumInteritemSpacing = 0
    }
    
    
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout , insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(tileMargin, tileMargin, tileMargin, tileMargin)
    }
    
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CardViewCell
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier:  "PopUpViewController") as! PopUpViewController
        
        let selectedCard = cell.getCard()
        viewController.restName = selectedCard.getRestName()
        viewController.image = cell.cellImage.image
        viewController.card = selectedCard
        viewController.cellIndexPath = indexPath
        viewController.delegate = self
        
        self.addChildViewController(viewController)
        viewController.view.frame = self.view.frame
        self.view.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
        
    }
    
    
    
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ProfileViewController : PopupDelegate {
    func deleteCard(card: Card, indexPath : IndexPath) {
        let i = likedCards.index(of: card)
        likedCards.remove(at: i!)
        collectionView.deleteItems(at: [indexPath])
        setStatus()
        
    }
    
    
}
