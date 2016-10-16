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



class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    
    var movies: [NSDictionary]?
    
    var endpoint: String! = "now_playing"
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        networkErrorView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        

        self.refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)

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
                                                                        //                                                                                    successCallback(responseDictionary)
                                                                        
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
        if let movies = movies {
            return movies.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell

        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overView = movie["overview"] as! String
        
        cell.titleLabel.text = title
        if overView != "" {
            cell.overviewLabel.text = overView
        }
        else {
            cell.overviewLabel.text = "no over view yet."
        }
        //cell.overviewLabel.sizeToFit() // let's leave it trancated in table view
    
//        cell.loadingLabel.isHidden = false
        
        
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

        print("row \(indexPath.row)")
        return cell
    }
    
    
    

    
    

    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare for seque called")
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        let detailViewController = segue.destination as! DetailViewController

        // pass low resolution image for showing while loading a large iamge
        if let LowResImg = (cell as! MovieCell).posterView.image {
            detailViewController.lowResolutionImg = LowResImg
        }

        detailViewController.movie = movie
        
        
        
    }

}
