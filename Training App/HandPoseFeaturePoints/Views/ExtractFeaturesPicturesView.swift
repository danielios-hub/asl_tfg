//
//  ExtractFeaturesPicturesView.swift
//  HandPoseFeaturePoints
//
//  Created by Daniel Gallego Peralta on 28/2/21.
//

import UIKit

class ExtractFeaturesPicturesView: UIView {
    
    @IBOutlet var imageViewPreview: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var buttonLoad: UIButton!
    @IBOutlet var buttonDownload: UIButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        buttonLoad.layer.cornerRadius = 8
        buttonDownload.layer.cornerRadius = 8
        buttonDownload.isHidden = true
    }
    
    func setImage(url: String) {
        guard !url.isEmpty else {
            return
        }
        
        if let url = URL(string: url),
           let data = try? Data(contentsOf: url) {
            let img = UIImage(data: data)
            imageViewPreview.image = img
            
        }
    }
    
    func setDownloadButton() {
        buttonDownload.isHidden = false
    }
    
    func setTextInformation(current: Int, total: Int){
        if total > 0 {
            descriptionLabel.text = "\(current) of \(total) images processes"
        }
    }
}
