//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by Mykhailo Kviatkovskyi on 04.06.2021.
//

import UIKit

extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        
        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] (url, response, error) in
            
            if error == nil,
               let url = url,
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                
                DispatchQueue.main.async {
                    if let weakSelf = self {
                        weakSelf.image = image
                    }
                    
                }
            }
        }
        downloadTask.resume()
        return downloadTask
    }
}
