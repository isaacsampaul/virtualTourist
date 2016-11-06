//
//  collectionViewController.swift
//  virtualTourist
//
//  Created by Isaac sam paul on 10/29/16.
//  Copyright © 2016 Isaac sam paul. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class collectionViewController: UIViewController,MKMapViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,NSFetchedResultsControllerDelegate
{
    // var and outlet declaration
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var reload: UIBarButtonItem!
    @IBOutlet weak var Done: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var map: MKMapView!
    var data: Pin!
    var imageData: [NSData] = []
    var removedData: NSData!
    var application = (UIApplication.shared.delegate as! AppDelegate)
    var frc: NSFetchedResultsController<Photo>!
    
    // creating managed object context and fetch request for both pin and photo objects
    
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fr1: NSFetchRequest<Photo> = Photo.fetchRequest()
    var fr: NSFetchRequest<Pin> = Pin.fetchRequest()
    
    override func viewWillAppear(_ animated: Bool) {
        let space:CGFloat = 1.0
        //let dimension1 = (view.frame.size.width - (2 * space))/3.0
        //let dimension2 = (view.frame.size.height - (2 * space))/3.0
        flowLayout.minimumLineSpacing = space
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSize(width: 92, height: 64)
        let coordinate = constants.coordinate!
        let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        map.setRegion(region, animated: true)
        frc = self.fetchResultsController()
        self.fetchPhoto()
        makeAnnotation()
        if data.photo?.count == 0 || data.photo?.count == nil
        {
            self.uiEnabler(status: false)
            
            reloadImages(completionHandlerForReloadingImages: { (sucess, error) in
                
                if sucess == true
                    {
                    self.uiEnabler(status: true)
                }
                else
                {
                    performUIUpdatesOnMain {
                        self.displayError(title: "Check your Internet Connection", message: "Unable to download images")
                        self.uiEnabler(status: true)
                    }
                    
                }
                
            })
        }
        print("the loaded images are \(self.imageData.count)")
        constants.finishedLoading = false
        constants.iserror = false
    }
    
    override func viewDidLoad() {
        collectionView.reloadData()
        constants.loadedData = self.data
    }
    
    //dismiss present view controller when done button is pressed
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //reload collectionView with new set of images
    @IBAction func refresh(_ sender: AnyObject)
    {

        self.uiEnabler(status: false)
        self.deleteAllPhotos()
        reloadImages { (sucess, error) in
            if sucess == true
            {
                self.uiEnabler(status: true)
            }
            else
            {
               
                performUIUpdatesOnMain {
                    self.displayError(title: "Check your Internet Connection", message: "Unable to download images")
                }
                
                self.uiEnabler(status: true)
                
            }
        }
    }
    
    //create annotation when displaying the view
    func makeAnnotation()
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate = constants.coordinate!
        map.addAnnotation(annotation)
    }
    
    // Tells collection view the number of items to be displayed
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("The total fetched object is \(self.frc.fetchedObjects?.count)")
        return imageData.count
    }
    
    // Displays all the items for the selected pin
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! collectionViewCell
        let data = self.imageData[indexPath.row]
        cell.image.image = UIImage(data: data as Data)
        return cell
    }
    
    // Delete the selected item from the collectionView and the coreData
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.removedData = imageData[indexPath.row]
        imageData.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        moc.delete(ObjectToDelete(indexPath: indexPath))
        application.saveContext()
    }
    
    // Fetch the photo objects for the particular pin
    func fetchPhoto()
    {
        self.imageData = []
        
        guard let data = frc.fetchedObjects else
        {
            print("unable to move objects to data")
            return
        }
        print("data count in collectionView is \(data.count)")
        for items in data
        {
            
            self.imageData.append(items.photo!)
        
        }
        
            print("total image retrieved is \(self.imageData.count)")
    }
    
    // Returns an object that has to be deleted from CoreData
    func ObjectToDelete(indexPath: IndexPath) -> NSManagedObject
    {
        let data:[Photo]!
        data = try! self.moc.fetch(self.fr1)
        for items in data
        {
            if items.photo == self.removedData
            {
                
                return data[data.index(of: items)!]
                
            }
            
        }
        
        return data[1290129102]
    }
    
    // Gets a new list of images and updates the CoreData
    func reloadImages(completionHandlerForReloadingImages: @escaping(_ sucess: Bool, _ error: String) -> Void)
    {
        self.Done.isEnabled = false
        self.reload.isEnabled = false
        let netCode = network()
        netCode.getPhotos { (sucess, error) in
        
            if error != ""
            {
                return completionHandlerForReloadingImages(sucess,error)
            }
            else
            {
                return completionHandlerForReloadingImages(sucess,error)
            }
        }
        
    }
    
    // fetching the objects
    func fetchResultsController() -> NSFetchedResultsController<Photo>
    {
        self.fr1.predicate = NSPredicate(format: "pin == %@", self.data)
        self.fr1.sortDescriptors = [NSSortDescriptor(key: "photoID", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: self.fr1, managedObjectContext: self.moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        do
        {
            print("executed fetch")
            try frc.performFetch()
        }
        catch
        {
            print("unable to fetch the objects using frc")
            return frc
        }
        return frc
    }
    
    func deleteAllPhotos()
    {
        for items in frc.fetchedObjects!
        {
            self.moc.delete(items)
            self.application.saveContext()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .delete
        {
            self.imageData.remove(at: (indexPath?.row)!)
            print("image data after deletion is \(imageData.count)")
            collectionView.reloadData()
        }
        if type == .update
        {
            print("data is getting updated")
        }
        if type == .insert
        {
            self.imageData = []
            print("data is getting inserted")
            let data = frc.fetchedObjects
            print("fetched object after inserting is \(data?.count)")
            for items in data!
            {
                
               self.imageData.append(items.photo!)
                
            }
                self.collectionView.reloadData()
            print("image appended after inserting is \(imageData.count)")
        }
    }
    
    func displayError(title: String, message: String)
    {
        let alert = UIAlertController()
        alert.title = title
        alert.message = message
        let continueAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default){
            
            action in alert.dismiss(animated: true, completion: nil)
            
        }
        alert.addAction(continueAction)
        self.present(alert, animated: true, completion: nil)
    }

    func uiEnabler(status: Bool)
    {
        performUIUpdatesOnMain {
        self.reload.isEnabled = status
        self.Done.isEnabled = status
        }
    }
}
