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
    @IBOutlet weak var map: MKMapView!
    var data: Pin!
    
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fr1: NSFetchRequest<Photo> = Photo.fetchRequest()
    var fr: NSFetchRequest<Pin> = Pin.fetchRequest()
    
    override func viewWillAppear(_ animated: Bool) {
        let coordinate = constants.coordinate!
        let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        map.setRegion(region, animated: true)
        makeAnnotation()
        
    }
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func refresh(_ sender: AnyObject) {
    }
    
    func makeAnnotation()
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate = constants.coordinate!
        map.addAnnotation(annotation)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let fc = fetchImageData()
        return (fc.sections?[section].numberOfObjects)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let fc = self.fetchImageData()
        let items = fc.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! collectionViewCell
        cell.image.image = UIImage(data: items.photo as! Data)
        return cell
    }
    
    func fetchImageData() -> NSFetchedResultsController<Photo>
    {
            let predicate = NSPredicate(format: "pin = %@", argumentArray: [data])
            fr1.predicate = predicate
            fr1.sortDescriptors = [NSSortDescriptor(key: "photo", ascending: true)]
            let fc1 = NSFetchedResultsController(fetchRequest: self.fr1, managedObjectContext: self.moc, sectionNameKeyPath: nil, cacheName: nil)
            return fc1
 
    }
    
}
