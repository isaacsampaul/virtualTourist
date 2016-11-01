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
    @IBOutlet weak var reload: UIBarButtonItem!
    @IBOutlet weak var Done: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var map: MKMapView!
    var data: Pin!
    var imageData: [NSData] = []
    var removedData: NSData!
    
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fr1: NSFetchRequest<Photo> = Photo.fetchRequest()
    var fr: NSFetchRequest<Pin> = Pin.fetchRequest()
    
    override func viewWillAppear(_ animated: Bool) {
        let coordinate = constants.coordinate!
        let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        map.setRegion(region, animated: true)
        self.fetchPhoto()
        makeAnnotation()
    }
    
    override func viewDidLoad() {
        collectionView.reloadData()
    }
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func refresh(_ sender: AnyObject) {
        self.fetchPhoto()
        self.reloadImages()
    }
    
    func makeAnnotation()
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate = constants.coordinate!
        map.addAnnotation(annotation)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! collectionViewCell
        let data = self.imageData[indexPath.row]
        cell.image.image = UIImage(data: data as Data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.removedData = imageData[indexPath.row]
        imageData.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        moc.delete(ObjectToDelete(indexPath: indexPath))
        do{
            print("savinData")
            try self.moc.save()
            
        }
        catch{
            
            print("unable to save data")
            return
        }
    }
    
    func fetchPhoto()
    {
        self.imageData = []
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
                self.imageData.append(items.photo!)
            }
        }
            print("total image retrieved is \(self.imageData.count)")
    }
    
    func ObjectToDelete(indexPath: IndexPath) -> NSManagedObject
    {
        let data:[Photo]!
        data = try! self.moc.fetch(self.fr1)
        for items in data
        {
            if items.photo == self.removedData
            {
                print("found the item to be deleted")
                return data[data.index(of: items)!]
                
            }
            
        }
        
        return data[1290129102]
    
    }
    
    func reloadImages()
    {
        self.Done.isEnabled = false
        self.reload.isEnabled = false
        let netCode = network()
        netCode.getPhotos { (sucess, error) in
            if sucess == true
            {
                self.Done.isEnabled = true
                self.reload.isEnabled = true
                let data = self.fetchStoredData()
                for items in data
                {
                    if items.latitude == constants.latitude && items.longitude == constants.longitude
                    {
                        items.photo = NSSet(array: constants.imagesToDisplay) as? NSSet
                        do{
                            print("savinData")
                            try self.moc.save()

                        }
                        catch{
                            
                            print("unable to save data")
                            return
                        }
                    }
                    
                    let data = self.fetchStoredData()
                    for items in data
                    {
                        if items.latitude == constants.latitude && items.longitude == constants.longitude
                        {
                            constants.indexOfData = data.index(of: items)
                        }
                    }
                    self.data = data[constants.indexOfData]
                    
                }
            }
            else
            {
                self.Done.isEnabled = true
                self.reload.isEnabled = true
               self.displayAlert(title: "Please check your Internet Connection", message: "Unable to Reload Images")
            }
        }
        
    }

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
    
    func fetchStoredData() -> [Pin]
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
}
