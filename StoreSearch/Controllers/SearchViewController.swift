//
//  ViewController.swift
//  StoreSearch
//
//  Created by Mykhailo Kviatkovskyi on 28.05.2021.
//

import UIKit



class SearchViewController: UIViewController {
    //MARK: - Cell Identifiers
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
        }
    }
    
    //MARK: - Properties
   private let search = Search()
    var landscapeVC: LandscapeViewController?
    
    //MARK: - IBOutlet properties
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        
        searchBar.becomeFirstResponder()//Show keyboard on launch
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        @unknown default:
            break
        }
    }
    
    //MARK: - IBAction Methods
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    //MARK: - Helpers Methods
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store. Plese try again.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Landscape View Controller
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeVC == nil else {
            return
        }
        
        landscapeVC = storyboard?.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
            
        guard let controller = landscapeVC else {
            return
        }
        controller.search = search
        
        controller.view.frame = view.bounds
        controller.view.alpha = 0
        
        view.addSubview(controller.view)
        addChild(controller)
        coordinator.animate { (_) in
            controller.view.alpha = 1
            self.searchBar.resignFirstResponder()
            if self.presentedViewController != nil {
                self.dismiss(animated: true, completion: nil)
            }
        } completion: { (_) in
            controller.didMove(toParent: self)
        }

    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard let controller = landscapeVC else {
            return
        }
        
        controller.willMove(toParent: nil)
        
        coordinator.animate { (_) in
            controller.view.alpha = 0
        } completion: { (_) in
            controller.view.removeFromSuperview()
            controller.removeFromParent()
            self.landscapeVC = nil
        }
    }
    
    //MARK: - Navigations
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowDetail" else {
            return
        }
        guard let detailViewController = segue.destination as? DetailViewController else {
            return
        }
        guard let indexPath = sender as? IndexPath else {
            return
        }
        
        detailViewController.searchResult = search.searchResults[indexPath.row]
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        search.performSearch(for: searchBar.text!, category: segmentedControl.selectedSegmentIndex) { (success) in
            if !success {
                self.showNetworkError()
            }
            self.tableView.reloadData()
        }
        
        tableView.reloadData()
        searchBar.resignFirstResponder() //Hide keyboard afted press "Search"/Enter button
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return search.isLoading ?
            1 : !search.hasSearched ?
            0 : search.searchResults.count == 0 ?
            1 : search.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard !search.isLoading else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
        
        guard search.searchResults.count != 0 else {
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
        
        let searchResult = search.searchResults[indexPath.row]
        
        cell.configure(for: searchResult)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return search.searchResults.count == 0 || search.isLoading ? nil : indexPath
    }
    
}

