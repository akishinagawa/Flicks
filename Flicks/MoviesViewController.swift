//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Akifumi Shinagawa on 10/14/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit
import AFNetworking


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        

        
   

        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,
                                                                    completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
                                                                        if errorOrNil != nil {
//                                                                            errorCallback?(requestError)
                                                                        } else {
                                                                            if let data = dataOrNil {
                                                                                if let responseDictionary = try! JSONSerialization.jsonObject(
                                                                                    with: data, options:[]) as? NSDictionary {
                                                                                    NSLog("response: \(responseDictionary)")
//                                                                                    successCallback(responseDictionary)
                                                                                    
                                                                                    self.movies = responseDictionary["results"] as? [NSDictionary]
                                                                                    self.tableView.reloadData()
                                                                                }
                                                                            }
                                                                        }
        });
        task.resume()
        
        
        
        
        
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
        cell.overviewLabel.text = overView
    
        let baseUrl = "https://image.tmdb.org/t/p/w500/"
        if let posterPath = movie["poster_path"] as? String {
            let posterUrl = URL(string: baseUrl + posterPath)
            cell.posterView.setImageWith(posterUrl!)
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

        detailViewController.movie = movie
    }

}
