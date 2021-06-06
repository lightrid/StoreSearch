//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Mykhailo Kviatkovskyi on 05.06.2021.
//

import UIKit

class LandscapeViewController: UIViewController {
    //MARK: - Public Properties
    var searchResults = [SearchResult]()
    var search: Search!
    
    //MARK: - Private Properties
    private var firstTime = true
    private var downloads = [URLSessionDownloadTask]()
    
    //MARK: - IBOutlet properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    //MARK: - View Lifecycle
    deinit {
        print("deinit \(self)")
        for task in downloads {
            task.cancel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Remove constraints from main view
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        // Remove constraints for page control
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        // Remove constraints for scroll view
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        
        pageControl.numberOfPages = 0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        scrollView.frame = safeFrame
        pageControl.frame = CGRect(x: safeFrame.origin.x, y: safeFrame.size.height - pageControl.frame.size.height, width: safeFrame.size.width, height: pageControl.frame.size.height)
        if firstTime {
            firstTime = false
            switch search.state {
            case .notSearchedYet:
                break
            case .loading:
                showSpinner()
            case .noResult:
                showNothingFoundLabel()
            case .results(let list):
                tileButtons(list)
            }
        }
    }
    
    // MARK: - IBAction Methods
    @IBAction func pageChanged(_ sender: UIPageControl) {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
        }, completion: nil)
        
    }
    
    // MARK: - ObjC Methods
    @objc func buttonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowDetail", sender: sender)
    }
    
    //MARK: - Public Methods
    func searchResultsReceived() {
        hideSpinner()
        
        switch search.state {
        case .notSearchedYet, .loading:
            break
        case .noResult:
            showNothingFoundLabel()
        case .results(let list):
            tileButtons(list)
        }
    }
    
    // MARK:- Private Methods
    private func showSpinner() {
        let spiner = UIActivityIndicatorView(style: .large)
        spiner.center = CGPoint(x: view.bounds.midX + 0.5, y: view.bounds.midY + 0.5)
        spiner.tag = 1000
        view.addSubview(spiner)
        spiner.startAnimating()
    }
    
    private func hideSpinner() {
        view.viewWithTag(1000)?.removeFromSuperview()
    }
    
    private func showNothingFoundLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.text = "Nothing Found"
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        
        label.sizeToFit()
        var rect = label.frame
        rect.size.width = ceil(rect.size.width/2) * 2
        rect.size.height = ceil(rect.size.height/2) * 2
        
        label.frame = rect
        
        label.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        
        view.addSubview(label)
    }
    
    private func tileButtons(_ searchResults: [SearchResult]) {
        var columnsPerPage = 6
        var rowsPerPage = 3
        var itemWidth: CGFloat = 94
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 2
        var marginY: CGFloat = 20
        
        let viewWidth = scrollView.bounds.size.width
        switch viewWidth {
        case 568:
            // 4-inch device
            break
            
        case 667:
            // 4.7-inch device
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
            
        case 736:
            // 5.5-inch device
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
            marginX = 0
            
        case 724:
            // iPhone X
            columnsPerPage = 8
            rowsPerPage = 3
            itemWidth = 90
            itemHeight = 98
            marginX = 2
            marginY = 29
        case 750...1000:
            columnsPerPage = 9
            rowsPerPage = 4
            itemWidth = 90
            itemHeight = CGFloat(Int(viewWidth/8.5))
            marginX = 2
            marginY = 2
        default:
            break
        }
        
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth)/2
        let paddingVert = (itemHeight - buttonHeight)/2
        
        var row = 0
        var column = 0
        var x = marginX
        for (index, result) in searchResults.enumerated() {
            let button = UIButton(type: .custom)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            button.tag = 2000 + index
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            button.frame = CGRect(x: x + paddingHorz, y: marginY + CGFloat(row)*itemHeight + paddingVert, width: buttonWidth, height: buttonHeight)
            downloadImage(for: result, andPlaceOn: button)
            scrollView.addSubview(button)
            
            row += 1
            if row == rowsPerPage {
                row = 0
                x += itemWidth
                column += 1
                
                if column == columnsPerPage {
                    column = 0
                    x += marginX * 2
                }
            }
        }
        
        // Set scroll view content size
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        scrollView.contentSize = CGSize(width: CGFloat(numPages) * viewWidth, height: scrollView.bounds.size.height)
        
        print("Number of pages: \(numPages)")
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
    }
    
    //MARK: - Networking
    private func downloadImage(for searchResult: SearchResult, andPlaceOn button: UIButton) {
        guard let url = URL(string: searchResult.imageSmall) else {
            return
        }
        
        let task = URLSession.shared.downloadTask(with: url) {
            [weak button] url, response, error in
            
            guard error == nil, let url = url else {
                return
            }
            guard let data = try? Data(contentsOf: url) else {
                return
            }
            guard let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                if let button = button {
                    button.setImage(image, for: .normal)
                }
            }
            
        }
        task.resume()
        downloads.append(task)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowDetail" else {
            return
        }
        if case .results(let list) = search.state {
            guard let detailViewController = segue.destination as? DetailViewController else {
                return
            }
            
            let searchResult = list[(sender as! UIButton).tag - 2000]
            detailViewController.searchResult = searchResult
        }
    }
}

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2) / width)
        pageControl.currentPage = page
    }
}
