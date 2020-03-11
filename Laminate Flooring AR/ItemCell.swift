import UIKit

class ItemCell: UICollectionViewCell {
    
    @IBOutlet weak var laminateLabel: UILabel!
    @IBOutlet weak var checkMarkButton: UIButton!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 13
    }
    
    override var isSelected: Bool{
        didSet{
            if self.isSelected {
                checkMarkButton.isHidden = false
            }
            else {
                checkMarkButton.isHidden = true
            }
        }
    }
}
