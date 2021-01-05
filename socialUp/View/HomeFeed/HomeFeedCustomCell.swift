import UIKit

class HomeFeedCustomCell : HomeFeedCustomCellWithoutImage {
    lazy var eventImageView : UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = UIImageView.ContentMode.scaleToFill
        imageView.backgroundColor = .green
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(eventImageView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: eventImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 1.125),
            NSLayoutConstraint(item: eventImageView, attribute: .trailing, relatedBy: .equal, toItem: self , attribute: .trailing, multiplier: 1, constant: -1.125),
            NSLayoutConstraint(item: eventImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.frame.width * 9 / 16 - 4)
            ])
        
        eventImageView.layer.cornerRadius = self.frame.width / 20
        
    }
    
    override func setEventDescriptionContainerConstraint() {
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: eventDescriptionContainer, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventDescriptionContainer, attribute: .trailing, relatedBy: .equal, toItem: self , attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventDescriptionContainer, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -self.frame.width * 9 / 16 * 0.2),
            NSLayoutConstraint(item: eventDescriptionContainer, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
