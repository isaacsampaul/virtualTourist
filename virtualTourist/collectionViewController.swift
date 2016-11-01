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

}
