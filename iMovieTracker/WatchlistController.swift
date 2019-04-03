//
//  WatchlistController.swift
//  iMovieTracker
//
//  Created by Niels Evenblij on 01/04/2019.
//  Copyright © 2019 thomniels. All rights reserved.
//

import UIKit

class WatchlistController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var watchlist = [Movie]()
    var defaultStorage = DefaultStorage()
    var defaults = UserDefaults.standard
    var activityIndicatorView: UIActivityIndicatorView!
    
    var searchData = [Movie]()
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //startup loading animation
        activityIndicatorView = UIActivityIndicatorView(style: .gray)
        self.tableView.backgroundView = activityIndicatorView
        activityIndicatorView.startAnimating()
        
        //make sure there are no lines in screen from table
        self.tableView.separatorStyle = .none
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        DispatchQueue.main.async {
            WatchList.loadMovies()
            self.setWatchlist(watchlist: WatchList.getMovies())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateWatchlist()
    }
    
    func setWatchlist(watchlist: [Movie]){
        self.watchlist = watchlist
        
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
            self.tableView.separatorStyle = .singleLine
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (isSearching) {
            return searchData.count
        }
        
        return watchlist.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Movie", for: indexPath)
        var hideMoviePoster = defaultStorage.getSetting(key: "hideMoviePoster")
        if (defaults.string(forKey: "hideMoviePoster") != nil) {
            hideMoviePoster = defaults.bool(forKey: "hideMoviePoster")
        }
        
        if (isSearching) {
            cell.textLabel?.text = searchData[indexPath.row].title
            if (!hideMoviePoster) {
                cell.imageView?.image = searchData[indexPath.row].image
            }
        }
        else {
            cell.textLabel?.text = watchlist[indexPath.row].title
            if (!hideMoviePoster) {
                cell.imageView?.image = watchlist[indexPath.row].image
            }
        }
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if (searchBar.text == nil || searchBar.text == ""){
            isSearching = false;
            
            view.endEditing(true)
            
            tableView.reloadData()
        }
        else {
            isSearching = true
            
            if let query = searchBar.text {
                searchData = watchlist.filter({$0.title.lowercased().contains(query.lowercased())})
            }
            
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow,
            let destination = segue.destination as? DetailsController {
            destination.movie = watchlist[selectedIndexPath.row]
        }
    }
    
    func updateWatchlist() {
        if WatchList.didListChange() {
            DispatchQueue.main.async {
                self.setWatchlist(watchlist: WatchList.getMovies())
            }
        }
    }
}

