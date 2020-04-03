//
//  CategoryBox.swift
//  Module code sample instead of a running project
//
//  Created by Maryia Bahlai on 11/21/19.
//  Copyright © 2019 BM. All rights reserved.
//

import Foundation
import UIKit

class CategoryBox: UICollectionViewCell {
    
    @IBOutlet weak var title: BrandedLabelBold!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var view: BrandedView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    var presenter: CategoryBoxPresenterProtocol?
    var gradient = false
    
    func addImage(image: UIImage) {
        self.stopActivity()
        self.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        self.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        imageView.layer.add(transition, forKey: nil)
        self.image.layer.add(transition, forKey: nil)
        title.layer.add(transition, forKey: nil)
        subtitle.layer.add(transition, forKey: nil)
        descriptionLabel.layer.add(transition, forKey: nil)
        self.imageView.image = image
        self.setTextColor(color: UIColor.white)
       
    }
    
    func setTitle(text: String?) {
        title.text = text
    }
    
    func setSubtile(text: String?) {
        subtitle.text = text
    }
    
    func setDescription(text: String?) {
        descriptionLabel.text = text
    }
    
    func stopActivity() {
        activity.stopAnimating()
    }
    
    func navigationItem() {
        if !gradient {
            let gradientLayer = view.addGradientLayer(below: subtitle.layer)
            gradientLayer.frame = view.bounds
            gradient = true
        }
        let theme = ThemeManager.currentTheme()
        self.image.tintColor = theme.textColor
        let tintedimage = UIImage(named: "box")?.withRenderingMode(.alwaysTemplate)
        self.image.image = tintedimage
    }
    
    func setup() {
        activity.hidesWhenStopped = true
        self.layer.cornerRadius = view.frame.height / 20
    }
    
    func clean() {
        for i in 0...(self.view.layer.sublayers?.count ?? 1)-1 {
            if let _ = self.view.layer.sublayers?[i] as? CAGradientLayer {
                self.view.layer.sublayers?.remove(at: i)
                break
            }
        }
        setTextColor(color: ThemeManager.currentTheme().textColor)
        self.imageView.image = nil
        self.gradient = false
        self.title.text = ""
        self.subtitle.text = ""
        self.descriptionLabel.text = ""
        navigationItem()
        self.view.layer.layoutIfNeeded()
    }
    
    func setTextColor(color: UIColor?) {
        self.title.textColor = color
        self.subtitle.textColor = color
        self.descriptionLabel.textColor = color
        self.image.tintColor = color
        let tintedimage = self.image.image?.withRenderingMode(.alwaysTemplate)
        self.image.image = tintedimage
    }

}
