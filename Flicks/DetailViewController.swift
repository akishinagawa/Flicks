//
//  DetailViewController.swift
//  Flicks
//
//  Created by Akifumi Shinagawa on 10/15/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    var movie: NSDictionary!
    var lowResolutionImg:UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        print(movie)
        
        
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overView = movie["overview"] as? String
        overviewLabel.text = overView
        overviewLabel.sizeToFit()
        
        
        // set low-res image first
        posterImageView.image = lowResolutionImg
        
        let baseUrl = "https://image.tmdb.org/t/p/w500/"
        if let posterPath = movie["poster_path"] as? String {
            let posterUrl = URL(string: baseUrl + posterPath)
            posterImageView.setImageWith(posterUrl!)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
