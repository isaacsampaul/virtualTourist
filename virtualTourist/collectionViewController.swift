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
        let coordinate = constants.coordinate!
        let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        map.setRegion(region, animated: true)
        frc = self.fetchResultsController()
        self.fetchUsing()
        self.fetchPhoto()
        makeAnnotation()
    }
    
    override func viewDidLoad() {
        collectionView.reloadData()
    }
    
    //dismiss present view controller when done button is pressed
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //reload collectionView with new set of images
    @IBAction func refresh(_ sender: AnyObject)
    {
        deleteExistingPhotos()
        reloadImages { (sucess, error) in
            if sucess == true
            {
                self.fetchPhoto()
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
        return self.imageData.count
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
        self.collectionView.isScrollEnabled = false
        let netCode = network()
        netCode.getPhotos { (sucess, error) in
            if sucess == true
            {
                self.Done.isEnabled = true
                self.reload.isEnabled = true
                self.collectionView.isScrollEnabled = true
                let data = self.fetchStoredPins()
                for items in data
                {
                    // find the selected pin object and delete it. Then add the same pin object with different photoObject set
                    if items.latitude == constants.latitude && items.longitude == constants.longitude
                    {
                        self.moc.delete(data[data.index(of: items)!])
                        let entityDescription = NSEntityDescription.entity(forEntityName: "Pin", in: self.moc)
                        let pin = Pin(entity: entityDescription!, insertInto: self.moc)
                        pin.latitude = constants.latitude
                        pin.longitude = constants.longitude
                        pin.photo = NSSet(array: constants.imagesToDisplay) as NSSet
                        self.application.saveContext()
                        
                    }
                }
                
                return completionHandlerForReloadingImages(true, "")
                
            }
            else
            {
                self.Done.isEnabled = true
                self.reload.isEnabled = true
                self.collectionView.isScrollEnabled = true
               self.displayAlert(title: "Please check your Internet Connection", message: "Unable to Reload Images")
                return completionHandlerForReloadingImages(false,"unable to reload images")
            }
        }
        
    }

    // displays an alert using the given title and messagae
    func displayAlert(title: String, message: String)
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
    
    // returns a array of pinObjects
    func fetchStoredPins() -> [Pin]
    {
        
        let data:[Pin]!
        do{
            data = try self.moc.fetch(self.fr)
        }
        catch{
            
            print("unable to retrieve data")
            return []
        }
        return data
    }
    
    // loads the data into the data variabe in collectionView
    func loadDataIntoCollectionView()
    {
        let data = self.fetchStoredPins()
        for items in data{
            if items.latitude == constants.latitude && items.longitude == constants.longitude
            {
                self.data = data[data.index(of: items)!]
                print("found the Items to reload")
                
            }
            
        }
        performUIUpdatesOnMain {
            print("executed the reloading process")
        self.collectionView.reloadData()
            
        }
    }
    
    func deleteExistingPhotos()
    {
        print("deleting photos")
        let data:[Photo]!
        do{
            data = try self.moc.fetch(self.fr1)
            
        }
        catch{
            
            print("unable to retrieve data")
            return
        }
        
        for items in data
        {
            if items.pin == self.data
            {
                self.moc.delete(data[data.index(of: items)!])
                self.application.saveContext()
                print("executed")
                
            }
            
        }
    }
    
    // fetching the objects
    func fetchResultsController() -> NSFetchedResultsController<Photo>
    {
        //self.fr1.predicate = NSPredicate(format: "pin == %@", self.data)
        self.fr1.sortDescriptors = [NSSortDescriptor(key: "photoID", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: self.fr1, managedObjectContext: self.moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }
    func fetchUsing()
    {
        do
    {
         try self.frc.performFetch()
    }
    catch
    {
        print("unable to fetch the objects using frc")
        return
        }
    }
}
