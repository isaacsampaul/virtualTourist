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
    var isExecuting = false
    var latitude: Double!
    var longitude: Double!
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fr: NSFetchRequest<Pin> = Pin.fetchRequest()
    
    override func viewDidLoad() {
        longPress.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {

    
        constants.finishedLoading = false
        constants.iserror = false
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
                map.removeAnnotation(annotation)
                map.addAnnotation(annotation)
            }
        }
        map.reloadInputViews()
    }
    
    @IBAction func dropPin(_ sender: AnyObject) {
        print("pressed")
      if longPress.state == .began
      {
    
        let touchPoint = sender.location(in: map)
        let coordinates = map.convert(touchPoint, toCoordinateFrom: map)
        let anotation = MKPointAnnotation()
        anotation.coordinate = coordinates
        constants.latitude = coordinates.latitude
        constants.longitude = coordinates.longitude
        map.addAnnotation(anotation)
        let netCode = network()
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "loadingViewController")as! loadingViewController
        performUIUpdatesOnMain {
        self.present(controller, animated: true, completion: nil)
        }
        // get images and store them
        netCode.getPhotos { (sucess, error) in
            if sucess == true
            {
    
                self.map.addAnnotation(anotation)
                let entityDescription = NSEntityDescription.entity(forEntityName: "Pin", in: self.moc)
                let pin = Pin(entity: entityDescription!, insertInto: self.moc)
                pin.latitude = coordinates.latitude
                pin.longitude = coordinates.longitude
                if pin.photo?.count == 0
                {
                    pin.photo = NSSet(array: constants.imagesToDisplay) as NSSet
                }
                
                constants.finishedLoading = true
                
            }
            else
            {
                performUIUpdatesOnMain {
                self.map.removeAnnotation(anotation)
                }
                constants.errorTitle = "Please check your Internet Connection"
                constants.errorMessage = "Unable to add Annotation to Map"
                constants.iserror = true
                constants.finishedLoading = true
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
            self.longPress.isEnabled = true
        // fetch the data
        self.fetchStoredData()
            }
        }
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
        for items in data
        {
            let lat = items.latitude
            let long = items.longitude
            let data = items.photo?.count
            print("latitude: \(lat) longitude: \(long) has totally \(data) photos")
        }
        
        return data
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        constants.latitude = view.annotation?.coordinate.latitude
        constants.longitude = view.annotation?.coordinate.longitude
        constants.coordinate = view.annotation?.coordinate
        let data = fetchStoredData()
        for items in data
        {
            if items.latitude == constants.latitude && items.longitude == constants.longitude
            {
                constants.indexOfData = data.index(of: items)
            }
        }
        let data1 = data[constants.indexOfData]
        print("latitude chosen is \(constants.latitude), longitude chosen is \(constants.longitude)")
        print("latitdue obtained is \(data1.latitude), longitude obtained is \(data1.longitude)")
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "collectionViewController") as! collectionViewController
        controller.data = data1
        present(controller, animated: true, completion: nil)
    }
    
    
}

