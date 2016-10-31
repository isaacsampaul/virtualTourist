//
//  ViewController.swift
//  virtualTourist
//
//  Created by Isaac sam paul on 10/29/16.
//  Copyright © 2016 Isaac sam paul. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class mapViewController: UIViewController,MKMapViewDelegate,NSFetchedResultsControllerDelegate {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet var longPress: UILongPressGestureRecognizer!
    var anotations: [MKPointAnnotation] = []
    var latitude: Double!
    var longitude: Double!
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fr: NSFetchRequest<Pin> = Pin.fetchRequest()
    
    override func viewDidLoad() {
        let data:[Pin]!
        do{
            data = try self.moc.fetch(self.fr)
        }
        catch{
            
            print("unable to retrieve data")
            return
        }
        if data.count > 0
        {
        for items in data
        {
            let lat = items.latitude
            let long = items.longitude
            let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            map.addAnnotation(annotation)
        }
        }
    }
    
    @IBAction func dropPin(_ sender: AnyObject) {
        let touchPoint = sender.location(in: map)
        let coordinates = map.convert(touchPoint, toCoordinateFrom: map)
        let anotation = MKPointAnnotation()
        anotation.coordinate = coordinates
        constants.latitude = coordinates.latitude
        constants.longitude = coordinates.longitude
        self.anotations.append(anotation)
        map.addAnnotation(anotation)
        let entityDescription = NSEntityDescription.entity(forEntityName: "Pin", in: self.moc)
        let pin = Pin(entity: entityDescription!, insertInto: self.moc)
        pin.latitude = coordinates.latitude
        pin.longitude = coordinates.longitude
        let netCode = network()
        
        // get images and store them
        netCode.getPhotos { (sucess, error) in
            if sucess == true
            {
                if pin.photo?.count == 0
                {
                   guard let set = NSSet(array: constants.imagesToDisplay) as? NSSet else
                   {
                    print("unable to convert to set")
                    return
                    }
                    pin.photo = set
                    
                }
                
            }
            else
            {
                print(error)
            }
        
        // save the datas
        do{
            try self.moc.save()
        }
        catch{
            
            print("unable to save data")
            return
        }
        // fetch the data
        self.fetchStoredData()
            
        }
    }
    
    func fetchStoredData()
    {

        let data:[Pin]!
        do{
            data = try self.moc.fetch(self.fr)
        }
        catch{
            
            print("unable to retrieve data")
            return
        }
        for items in data
        {
            let lat = items.latitude
            let long = items.longitude
            let data = items.photo
            print("latitude: \(lat) longitude: \(long)")
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        constants.latitude = view.annotation?.coordinate.latitude
        constants.longitude = view.annotation?.coordinate.longitude
        constants.coordinate = view.annotation?.coordinate
        print("latitude: \(constants.latitude!) longitude: \(constants.longitude!)")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "collectionViewController") as! collectionViewController
        let netCode = network()
        netCode.getPhotos { (sucess, error) in
            if sucess == true
            {
                let entityDescription = NSEntityDescription.entity(forEntityName: "Pin", in: self.moc)
                let pin = Pin(entity: entityDescription!, insertInto: self.moc)
                if pin.photo?.count == 0
                {
                pin.photo = NSSet(array: constants.imagesToDisplay)
                }
                do{
                    try self.moc.save()
                }
                catch{
                    
                    print("unable to save data")
                    return
                }
                self.fetchStoredData()
            }
            else
            {
                print(error)
            }
        }
        present(controller, animated: true, completion: nil)
    }
    
    

}

