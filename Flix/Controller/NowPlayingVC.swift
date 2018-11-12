//
//  ViewController.swift
//  Flix
//
//  Created by Eli Armstrong on 8/31/18.
//  Copyright © 2018 Eli Armstrong. All rights reserved.
//

import UIKit
import AlamofireImage

class NowPlayingVC: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [[String: Any]] = []
    var filterMovies: [[String: Any]] = []
    var refreshControl: UIRefreshControl!
    let alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: .alert)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tryAgain = UIAlertAction(title: "Try Again", style: .default) { (action) in
            self.fetchMovies()
        }
        self.alertController.addAction(tryAgain)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NowPlayingVC.didPullToRefresh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self
        searchBar.delegate = self
        fetchMovies()
        
        tableView.estimatedRowHeight = 190
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl){
        fetchMovies()
    }
    
    func fetchMovies(){
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=b98a0ccc0f9f7eb5813cde80b7af85e3&language=en-US&page=1")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                self.alertController.title = "Cannot Get Movies"
                self.alertController.message = error.localizedDescription
                self.present(self.alertController, animated: true){}
                print(error.localizedDescription)
            } else if let data = data{
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                
                let movies = dataDictionary["results"] as! [[String : Any]]
                self.movies = movies
                self.filterMovies = movies
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = filterMovies[indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        cell.titleLbl.text = title
        cell.overviewLbl.text = overview
        
        
        let posterPathString = movie["poster_path"] as! String
        let baseURLString = "https://image.tmdb.org/t/p/w500"
        
        
        let posterURL = URL(string: "\(baseURLString)\(posterPathString)")!
        let placeholderImage = UIImage(named: "now_playing_tabbar_item")!
        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
            size: cell.posterImg.frame.size,
            radius: 20.0
        )
        cell.posterImg.af_setImage(withURL: posterURL, placeholderImage: placeholderImage, filter: filter, imageTransition: .crossDissolve(0.2))
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell){
            let moive = filterMovies[indexPath.row]
            let detailVC = segue.destination as! DetailVC
            detailVC.movie = moive
        }
        searchBar.resignFirstResponder()
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
        self.filterMovies = searchText.isEmpty ? self.movies : movies.filter({ (filteredMovies: [String:Any]) -> Bool in
            let title = filteredMovies["title"] as! String
            return title.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.filterMovies = self.movies
        tableView.reloadData()
    }
}

