import UIKit
import Firebase

class DetailsViewController: UIViewController {
    
    var meeting : Meeting? = nil
    var doc : Bool = false
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    @IBAction func pressedBack(_ sender: Any) {
        print(meeting?.doctorEmail)
    }
    
    func populate(){
    }
}
