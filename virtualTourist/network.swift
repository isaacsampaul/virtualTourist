//
//  network.swift
//  virtualTourist
//
//  Created by Isaac sam paul on 10/29/16.
//  Copyright © 2016 Isaac sam paul. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class network
{
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fr: NSFetchRequest<Photo> = Photo.fetchRequest()
    var fr1: NSFetchRequest<Pin> = Pin.fetchRequest()
    var application = (UIApplication.shared.delegate as! AppDelegate)
    
    func getPhotos(completionHandlerForPhotos: @escaping(_ sucess: Bool, _ error: String) -> Void)
    {
        let parameters = ["method" : "flickr.photos.search", "api_key" : "1084fa06094e329ec25f7df4421c8ecb","bbox" : bboxString() , "safe_search" : "1", "extras" : "url_m", "format" : "json", "nojsoncallback" : "1"]
        let url = flickrURLFromParameters(parameters: parameters)
        print(url)
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard error == nil else
            {
                print("error occured while making request")
                completionHandlerForPhotos(false,(error?.localizedDescription)!)
                return
            }
            guard let data = data else
            {
                print("unable to get data")
                return
            }
            var parsedJsonData: NSDictionary!
            do
            {
                parsedJsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
            }
            catch
            {
                print("unable to parse data")
                return
            }
            guard let photos = parsedJsonData["photos"] as? [String : AnyObject] else
            {
                print("unable to get photos")
                return
            }
            
            guard let totalPages = photos["pages"] as? Int else {
               print("cant get total pages")
                return
            }

            // pick a random page!
            let pageLimit = min(totalPages, 40)
            print("total pages is \(totalPages)")
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            print("random page number is \(randomPage)")
            self.getPhotosWithRandomPage(parameters: parameters, pageNumber: randomPage, completionHandlerForPhotoswithpage: { (sucess, error) in
                completionHandlerForPhotos(sucess, error)
            })
            
        }
        task.resume()
        
    }
    
    private func flickrURLFromParameters(parameters: [String:String]) -> URL {
        let queryItems :[NSURLQueryItem] = []
        let components = NSURLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        components.queryItems = queryItems as [URLQueryItem]?
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem as URLQueryItem)
        }
        
        return components.url!
    }
    
    private func bboxString() -> String
    {
        let latitude = constants.latitude!
        let longitude = constants.longitude!
        let minimumLon = max(longitude - 1, constants.SearchLonRange.0)
        let minimumLat = max(latitude - 1, constants.SearchLatRange.0)
        let maximumLon = min(longitude + 1, constants.SearchLonRange.1)
        let maximumLat = min(latitude + 1, constants.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    func getPhotosWithRandomPage(parameters: [String:String], pageNumber: Int,completionHandlerForPhotoswithpage: @escaping(_ sucess: Bool, _ error: String) -> Void)
    {
        var methodParameter = parameters
        methodParameter["page"] = "\(pageNumber)"
        let url = flickrURLFromParameters(parameters: parameters)
        print(url)
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard error == nil else
            {
                print("error occured while making request")
                completionHandlerForPhotoswithpage(false, (error?.localizedDescription)!)
                return
            }
            guard let data = data else
            {
                print("unable to get data")
                return
            }
            var parsedJsonData: NSDictionary!
            do
            {
                parsedJsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
            }
            catch
            {
                print("unable to parse data")
                return
            }
            guard let photos = parsedJsonData["photos"] as? [String : AnyObject] else
            {
                print("unable to get photos")
                return
            }
            
            guard let photoDictionary = photos["photo"] as? [[String: AnyObject]] else
             {
             print("unable to get photo list")
             return
             }
             var count: Float = 0
             for images in photoDictionary
             {
             if count < 50
             {
                let randomPhoto = Int(arc4random_uniform(UInt32(photoDictionary.count)))
                let data = photoDictionary[randomPhoto]
                guard let imageURLString = data["url_m"] as? String else
             {
             print("unable to get image url")
             return
             }
            
            guard let photoID = data["id"] as? String else
            {
                print("unable to get photo id")
                return completionHandlerForPhotoswithpage(false, "unable to get photo ID")
            }
             let imageURL = URL(string: imageURLString)!
            if let imageData = NSData(contentsOf: imageURL)
            {
                constants.imageData.append(imageData)
                constants.imageID.append(photoID)
                let entityDescription = NSEntityDescription.entity(forEntityName: "Photo", in: self.moc)
                let photo = Photo(entity: entityDescription!, insertInto: self.moc)
                photo.photo = imageData
                photo.photoID = photoID
                constants.imageID1 = photoID
                do{
                    try self.moc.save()
                }
                catch{
                    
                    print("unable to save data")
                    return
                }
                
                }
                else
            {
                print("unable to get data")
                return completionHandlerForPhotoswithpage(false, "unable to get data")
            
                }
                count = count + 1
                constants.progress = count
             print("for loop executed\(count)")
            self.fetchStoredData()
             }
             
             }
           return completionHandlerForPhotoswithpage(true, "")
        }
        task.resume()

    }
    
    func fetchStoredData()
    {
    
        var data:[Photo]!
        do{
            data = try self.moc.fetch(self.fr)
            print("total photos present in data base is \(data.count)")

        }
        catch{
            
            print("unable to retrieve data")
            return
        }
        
        var pin:[Pin] = []
        do{
            pin = try self.moc.fetch(self.fr1)
        }
        catch
        {
            print("unable to get pin data")
        }
        for items in pin
        {
            if items.latitude == constants.latitude && items.longitude == constants.longitude
            {
                do{
                    data = try self.moc.fetch(self.fr)
                    print("total photos present in data base is \(data.count)")
                    
                }
                catch{
                    
                    print("unable to retrieve data")
                    return
                }
                
                for item in data
                {
                    if item.photoID == constants.imageID1
                    {
                        print("found the photo")
                        item.pin = pin[pin.index(of: items)!]
                        self.application.saveContext()
                    }
                }
            
            }
        }
        
        self.application.saveContext()
    }
    
   
}
