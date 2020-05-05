import UIKit
import DatePicker
import DropDown
import Firebase

class MeetingSchedulerViewController: UIViewController{
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var meetingTextView: UITextView!
    @IBOutlet weak var doctorLabel: UILabel!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var subjectLabel: UITextField!
    
    let datePicker = DatePicker()
    let dropDown = DropDown()
    let db = Firestore.firestore()
    let startDate = Date(timeIntervalSinceReferenceDate: 0)
    var selectedDate: Date = Date(timeIntervalSinceReferenceDate: 0)
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.meetingTextView.delegate = self
        datePicker.setup { (selected, date) in
            if selected, let selectedDate = date {
                self.selectedDate = selectedDate
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                self.dateLabel.text = formatter.string(for: selectedDate)
            } else {
                print("cancelled")
            }
        }
        meetingTextView.text = Constants.meetingPlaceholder
        dropDown.anchorView = view
        dropDown.direction = .top
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.doctorLabel.text = item
        }
        loadDoctors()
    }
    @IBAction func selectDoctorPressed(_ sender: UIButton) {
        dropDown.show()
    }
    @IBAction func datePressed(_ sender: UIButton) {
        datePicker.display(in: self)
    }
    @IBAction func scheduleMeeting(_ sender: UIButton) {
        if let meetingSender = Auth.auth().currentUser?.email, var meetingInfo = meetingTextView.text, let meetingDoctor = doctorLabel.text, let subjectLabel = subjectLabel.text {
            if meetingInfo == Constants.meetingPlaceholder{
                meetingInfo = ""
            }
            if meetingDoctor == ""{
                return
            }
            if selectedDate == Date(timeIntervalSinceReferenceDate: 0){
                return
            }
            db.collection("meetings").addDocument(data: [
                "approved": false,
                "date": selectedDate.timeIntervalSince1970,
                "doctorEmail": meetingDoctor,
                "patientEmail": meetingSender,
                "subject": subjectLabel,
                "info": meetingInfo
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    self.navigationController?.isNavigationBarHidden = true
                    self.successView.isHidden = false
                    self.meetingTextView.text = Constants.meetingPlaceholder
                    self.doctorLabel.text = ""
                    self.dateLabel.text = ""
                    print("Successfully saved data.")
                    
                }
            }
        }
    }
    
    @IBAction func hideSuccessView(_ sender: UIButton) {
        successView.isHidden = true
        navigationController?.isNavigationBarHidden = false
    }
    func loadDoctors(){
        var doctors: [String] = []
        db.collection("users")
            .whereField("doctor", isEqualTo: true)
            .getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("There was an issue retrieving data from Firestore. \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let docEmail = data["email"] as? String{
                                doctors.append(docEmail)
                            }
                        }
                        self.dropDown.dataSource = doctors
                    }
                }
        }
    }
}
extension MeetingSchedulerViewController: UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Constants.meetingPlaceholder
        {
            textView.text = "";
        }
        textView.becomeFirstResponder()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == ""
        {
            textView.text = Constants.meetingPlaceholder;
        }
        textView.resignFirstResponder()
    }
}
