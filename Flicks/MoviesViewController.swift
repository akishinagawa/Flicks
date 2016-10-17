//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Akifumi Shinagawa on 10/14/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    var searchedMovies: [NSDictionary]?
    
    var endpoint: String! = "now_playing"
    var refreshControl: UIRefreshControl!
    
    var searchEnabled:Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchEnabled = false
        
        networkErrorView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        
        self.refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)

        searchBar.delegate = self
        searchBar.showsSearchResultsButton = false

        loadMoviesData()
    }
    
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        networkErrorView.isHidden = true
        loadMoviesData()
    }
    
    func loadMoviesData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        
        let task : URLSessionDataTask = session.dataTask(with: request,
                                                         completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
                                                            if errorOrNil != nil {
                                                                self.showLoadErrorMessage()
                                                            } else {
                                                                if let data = dataOrNil {
                                                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                                                        with: data, options:[]) as? NSDictionary {
                                                                        NSLog("response: \(responseDictionary)")

                                                                        self.movies = responseDictionary["results"] as? [NSDictionary]
                                                                        self.tableView.reloadData()
                                                                        self.refreshControl.endRefreshing()
                                                                    }
                                                                }
                                                            }
                                                            
                                                            MBProgressHUD.hide(for: self.view, animated: true)
        });
        task.resume() 
    }
    
    func showLoadErrorMessage() {
        networkErrorView.isHidden = false
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchEnabled == false {
            if let movies = movies {
                return movies.count
            }
            else {
                return 0
            }
        }
        else {
            if let searchedMovies = searchedMovies {
                return searchedMovies.count
            }
            else {
                return 0
            }
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell

        var movie = movies![indexPath.row]
        if self.searchEnabled == true {
            movie = searchedMovies![indexPath.row]
        }

        let title = movie["title"] as! String
        let overView = movie["overview"] as! String
        
        cell.titleLabel.text = title
        if overView != "" {
            cell.overviewLabel.text = overView
        }
        else {
            cell.overviewLabel.text = "no over view yet."
        }
        cell.loadingLabel.isHidden = false
        
        
        let baseUrl = "https://image.tmdb.org/t/p/w92/"    //availble size in poster "w92","w154","w185","w342","w500","w780"
        if let posterPath = movie["poster_path"] as? String {
            let posterUrl = URL(string: baseUrl + posterPath)
            let posterUrlRequest = URLRequest(url: posterUrl!)
            
            cell.loadingLabel.isHidden = true
            
            cell.posterView.setImageWith(
                posterUrlRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    cell.loadingLabel.isHidden = true
                    cell.posterView.image = UIImage(named: "no_image.png")
            })
        }
        else {
            cell.loadingLabel.isHidden = true
            cell.posterView.image = UIImage(named: "no_image.png")
        }

        // Selected BG color change
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0.6, green: 0.42, blue: 0.11, alpha: 1.0)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            self.searchBar.endEditing(true)
            
            searchedMovies = []
            self.searchEnabled = false
            self.tableView.reloadData()
        }
        else{
            self.searchEnabled = true
            prepareSerachedData(searchText: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        
        searchedMovies = []
        self.searchEnabled = false
        self.tableView.reloadData()
    }
    
    func prepareSerachedData(searchText: String) {
        searchedMovies = []
        for movieData in movies! {
            let titleName = movieData["title"] as! String
            if titleName.lowercased().contains(searchText.lowercased()) {
                searchedMovies?.append(movieData)
            }
        }
        
        self.tableView.reloadData()
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare for seque called")
        
        self.searchBar.endEditing(true)
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        
        var movie = movies![indexPath!.row]
        if self.searchEnabled == true {
            movie = searchedMovies![indexPath!.row]
        }
        
        let detailViewController = segue.destination as! DetailViewController

        // pass low resolution image for showing while loading a large iamge
        if let LowResImg = (cell as! MovieCell).posterView.image {
            detailViewController.lowResolutionImg = LowResImg
        }

        detailViewController.movie = movie
    }

}
