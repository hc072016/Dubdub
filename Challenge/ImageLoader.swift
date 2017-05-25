//
//  ImageLoader.swift
//  Challenge
//
//  Created by Howie C on 5/25/17.
//  Copyright © 2017 Howie C. All rights reserved.
//
//  ImageLoader acts as model in MVC – Comprises all logic of preparing data

import Foundation

@objc class ImageLoader: NSObject {
    
    var cacheDictionary = [String : Data]()
    private let cacheFileName = "cache"
    private let cacheQueue = DispatchQueue(label: "com.hc.dubdub.cache", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent)
    
    func isCachedForImageOfURL(urlString: String) -> Bool {
        return cacheDictionary[urlString] != nil ? true : false
    }
    
    /*
    func emptyCache() {
    cacheDictionary.removeAll(keepingCapacity: false)
    // TODO: -delete the file as well
    }
    */
    
    func loadImageDataWith(urlString: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if let data = self.cacheDictionary[urlString] {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                completion(data, nil, nil)
            }
        } else {
            // async in the global queue read in the cache queue in sync
            // ensure the read (with concurrent potential) occurs after all the dispatched writes
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                // to simulate slow local access
                // Thread.sleep(forTimeInterval: 5)
                guard let fileURL = self.urlForDocumentDirectoryOf(file: self.cacheFileName) else {
                    completion(nil, nil, NSError(domain: "Challenge.ImageLoadingError", code: 1, userInfo: [NSLocalizedDescriptionKey : "Failed to Create Cache File URL"]))
                    return
                }
                var archivedDictionary: NSDictionary? = nil
                self.cacheQueue.sync {
                    archivedDictionary = NSDictionary(contentsOf: fileURL)
                }
                if let cacheDictionary = archivedDictionary as? Dictionary<String, Data> {
                    self.cacheDictionary = cacheDictionary
                }
                if let data = self.cacheDictionary[urlString] {
                    completion(data, nil, nil)
                } else {
                    // print(String(cString: __dispatch_queue_get_label(nil), encoding: String.Encoding.utf8)!)
                    guard let url = URL(string: urlString) else {
                        completion(nil, nil, NSError(domain: "Challenge.ImageLoadingError", code: 2, userInfo: [NSLocalizedDescriptionKey : "Invalid Image URL"]))
                        return
                    }
                    let task = URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
                        // to simulate slow network
                        // Thread.sleep(forTimeInterval: 2)
                        
                        // URLSession does not executes the closure on the main queue
                        // print(String(cString: __dispatch_queue_get_label(nil), encoding: String.Encoding.utf8)!)
                        guard let httpURLResponse = urlResponse as? HTTPURLResponse, httpURLResponse.statusCode == 200 else {
                            completion(nil, nil, NSError(domain: "Challenge.ImageLoadingError", code: 3, userInfo: [NSLocalizedDescriptionKey : "Reponse Failiure"]))
                            return
                        }
                        guard let mimeType = urlResponse?.mimeType, mimeType.hasPrefix("image") else {
                            completion(nil, nil, NSError(domain: "Challenge.ImageLoadingError", code: 4, userInfo: [NSLocalizedDescriptionKey : "Resource Is Not an Image"]))
                            return
                        }
                        // If you assign nil as the value for the given key, the dictionary removes that key and its associated value. – Documentation and API Reference
                        // It would work well even when data is nil
                        self.cacheDictionary[urlString] = data
                        // ensure sequential write (in a current queue) to the same file
                        self.cacheQueue.async(qos: DispatchQoS.default, flags: DispatchWorkItemFlags.barrier) {
                            if let fileURL = self.urlForDocumentDirectoryOf(file: self.cacheFileName) {
                                // Bridging from Dictionary to NSDictionary always takes O(1) time and space – Documentation and API Reference
                                if !(self.cacheDictionary as NSDictionary).write(to: fileURL, atomically: true) {
                                    print("Fail to cache the image. (Can not save a file)")
                                }
                            }
                        }
                        completion(data, urlResponse, error)
                    }
                    task.resume()
                }
            }
        }
    }
    
    func urlForDocumentDirectoryOf(file: String) -> URL? {
        let documentDirectoryURL = try? FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true)
        let fileURL = documentDirectoryURL?.appendingPathComponent(file)
        return fileURL
    }
    
    deinit {
        // print("vanishing...")
    }
}
