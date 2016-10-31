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
            
            guard let totalPages = photos["page"] as? Int else {
               print("cant get total pages")
                return
            }
            
            // pick a random page!
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
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
             print("photo count is \(photoDictionary.count)")
             var count = 0
             for images in photoDictionary
             {
             if count < 50
             {
             guard let imageURLString = images["url_m"] as? String else
             {
             print("unable to get image url")
             return
             }
             let imageURL = URL(string: imageURLString)!
            if let imageData = NSData(contentsOf: imageURL)
            {
                let image = UIImage(data: imageData as Data)
                let entityDescription = NSEntityDescription.entity(forEntityName: "Photo", in: self.moc)
                let photo = Photo(entity: entityDescription!, insertInto: self.moc)
                photo.photo = imageData
                do{
                    try self.moc.save()
                }
                catch{
                    
                    print("unable to save data")
                    return
                }
                
                }
                count = count + 1
             print("for loop executed\(count)")
             }
             
             }
            self.fetchStoredData()
            completionHandlerForPhotoswithpage(true, "")
        }
        task.resume()

    }
    
    func fetchStoredData()
    {
        
        let data:[Photo]!
        do{
            data = try self.moc.fetch(self.fr)
        }
        catch{
            
            print("unable to retrieve data")
            return
        }
        if data != nil
        {
        constants.imagesToDisplay = data
        print("we have totally \(constants.imagesToDisplay.count) photos")
        }
        
    }
}