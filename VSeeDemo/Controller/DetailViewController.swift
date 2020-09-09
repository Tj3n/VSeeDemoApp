//
//  DetailViewController.swift
//  VSeeDemo
//
//  Created by Vũ Tiến on 9/9/20.
//  Copyright © 2020 Vũ Tiến. All rights reserved.
//

import UIKit
import Kingfisher
import Hero

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var readMoreBtn: UIButton!
    @IBOutlet weak var imgViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var authorLabel: UILabel!
    
    var article: ArticleRealm = ArticleRealm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Article"
        bind()
    }
    
    func bind() {
        if let imgURL = article.urlToImageParsed {
            imageView.kf.setImage(with: imgURL, placeholder: #imageLiteral(resourceName: "defaultBanner")) { (result) in
                switch result {
                case .success(let imgResult):
                    //Calculate ratio for image
                    let ratio = imgResult.image.size.width / imgResult.image.size.height
                    let newHeight = self.imageView.frame.width / ratio
                    self.imgViewHeightConstraint.constant = newHeight
                    self.view.layoutIfNeeded()
                    
                case .failure(_):
                    break
                }
            }
        }
        
        self.hero.isEnabled = true
        imageView.hero.id = article.url
        navigationController?.interactivePopGestureRecognizer?.delegate = nil //re-enable swipe gesture
        
        authorLabel.text = article.author
        dateLabel.text = article.publishedAt.toString("MM-dd-yyyy HH:mm")
        titleLabel.text = article.title
        descLabel.text = article.articleDescription
    }
    
    @IBAction func readMoreTouched(_ sender: Any) {
        openURL(article.url) {
            
        }
    }

}
