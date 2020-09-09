//
//  ArticleTableViewCell.swift
//  VSeeDemo
//
//  Created by Vũ Tiến on 9/8/20.
//  Copyright © 2020 Vũ Tiến. All rights reserved.
//

import UIKit
import Kingfisher
import Hero

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(article: ArticleRealm) {
        if let imgURL = article.urlToImageParsed {
            imgView.isHidden = false
            imgView.kf.setImage(with: imgURL)
        } else {
            imgView.isHidden = true
        }
        
        imgView.hero.id = article.url
        
        titleLabel.text = article.title
        descLabel.text = article.articleDescription
        dateLabel.text = article.publishedAt.toString("MM-dd-yyyy HH:mm")
    }
}
