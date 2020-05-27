//
//  RecetaCell.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 12/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit

class RecetaCell: UITableViewCell {

    @IBOutlet weak var recetaBubble: UIView!
    @IBOutlet weak var titleReceta: UILabel!
    @IBOutlet weak var creatorReceta: UILabel!
    @IBOutlet weak var imageReceta: UIImageView!
    @IBOutlet weak var likeCount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageReceta.layer.cornerRadius = imageReceta.frame.height / 5
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        

        // Configure the view for the selected state
    }
    
    @IBAction func likePressed(_ sender: UIButton) {
    }
    @IBAction func savedPressed(_ sender: UIButton) {
    }
}
