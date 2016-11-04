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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var label: UILabel!
    var isExecuting = false
    var latitude: Double!
    var longitude: Double!
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fr: NSFetchRequest<Pin> = Pin.fetchRequest()
    
    override func viewDidLoad() {
        UIEnabler(Status: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        constants.finishedLoading = false
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
    }
    
    @IBAction func dropPin(_ sender: AnyObject) {
      if longPress.state == .began
      {
    
        let touchPoint = sender.location(in: map)
        let coordinates = map.convert(touchPoint, toCoordinateFrom: map)
        let anotation = MKPointAnnotation()
        anotation.coordinate = coordinates
        constants.latitude = coordinates.latitude
        constants.longitude = coordinates.longitude
        /*map.addAnnotation(anotation)
        let entityDescription = NSEntityDescription.entity(forEntityName: "Pin", in: self.moc)
        let pin = Pin(entity: entityDescription!, insertInto: self.moc)
        pin.latitude = coordinates.latitude
        pin.longitude = coordinates.longitude */
        let netCode = network()
        UIEnabler(Status: false)
        // get images and store them
        netCode.getPhotos { (sucess, error) in
            if sucess == true
            {
                self.UIEnabler(Status: true)
                self.map.addAnnotation(anotation)
                let entityDescription = NSEntityDescription.entity(forEntityName: "Pin", in: self.moc)
                let pin = Pin(entity: entityDescription!, insertInto: self.moc)
                pin.latitude = coordinates.latitude
                pin.longitude = coordinates.longitude
                if pin.photo?.count == 0
                {
                    pin.photo = NSSet(array: constants.imagesToDisplay) as NSSet
                }
                
            }
            else
            {
                self.UIEnabler(Status: true)
                self.displayAlert(title: "Please check your Internet Connection", message: "Unable to add Annotation to Map")
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
            self.UIEnabler(Status: true)
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
    
    func UIEnabler(Status: Bool)
    {
        activityIndicator.isHidden = Status
        if Status == true
        {
            map.isHidden = false
        }
        else
        {
            map.isHidden = true
        }
        label.isHidden = Status
        
    }
    
    func displayAlert(title: String, message: String)
    {
        self.UIEnabler(Status: true)
        let alert = UIAlertController()
        alert.title = title
        alert.message = message
        let continueAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default){
            
            action in alert.dismiss(animated: true, completion: nil)
            
        }
        alert.addAction(continueAction)
        self.present(alert, animated: true, completion: nil)
    }

}

