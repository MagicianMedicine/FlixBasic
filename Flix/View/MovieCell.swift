//
//  MovieCell.swift
//  Flix
//
//  Created by Eli Armstrong on 8/31/18.
//  Copyright © 2018 Eli Armstrong. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var overviewLbl: UILabel!
    
    @IBOutlet weak var posterImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        self.selectionStyle = .none
        
        if self.isSelected{
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.white
            self.selectedBackgroundView = backgroundView
            self.titleLbl.textColor = UIColor.black
            self.overviewLbl.textColor = UIColor.black
        } else{
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.black
            self.selectedBackgroundView = backgroundView
            self.titleLbl.textColor = UIColor.white
            self.overviewLbl.textColor = UIColor.white
        }
        
    }

}
