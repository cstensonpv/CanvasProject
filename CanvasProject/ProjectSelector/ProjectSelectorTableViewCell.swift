//
//  ProjectSelectorTableCell.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-04-01.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit

class ProjectSelectorTableViewCell: UITableViewCell {

	// MARK: Properties

	@IBOutlet weak var projectNameLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
