import UIKit
import Firebase

class MeetingManagerViewController : UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    var meetings: [Meeting] = []
    let db = Firestore.firestore()
    var selectedMeeting : Meeting?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MeetingCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        loadMeetings()
    }
    func loadMeetings() {
        if let loggedInEmail = Auth.auth().currentUser?.email {
            let today = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
            
            
            
            db.collection("meetings")
                .whereField("doctorEmail", isEqualTo: loggedInEmail)
                .whereField("date", isGreaterThanOrEqualTo: today.timeIntervalSince1970)
            .order(by: "date")
                .addSnapshotListener { (querySnapshot, error) in
                    
                    
                    if let e = error {
                        print("There was an issue retrieving data from Firestore. \(e)")
                    } else {
                        if let snapshotDocuments = querySnapshot?.documents {
                            
                            
                            print(snapshotDocuments.count)
                            self.meetings = []
                            
                            for doc in snapshotDocuments {
                                let data = doc.data()
                                if let meetingPatient = data["patientEmail"] as? String, let meetingDoctor = data["doctorEmail"] as? String, let meetingInfo = data["info"] as? String, let meetingSubject = data["subject"] as? String, let meetingApproved = data["approved"] as? Bool{
                                    
                                    if let dateData = data["date"] as? Double{
                                        let date : Date = Date(timeIntervalSince1970: dateData)
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "MM/dd/yyyy"
                                        let formattedDate = dateFormatter.string(from: date)
                                        let newMeeting = Meeting(patientEmail: meetingPatient, doctorEmail: meetingDoctor, date: dateData, subject: meetingSubject, info: meetingInfo, approved: meetingApproved, documentID: doc.documentID)
                                        self.meetings.append(newMeeting)
                                        
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
                                    }
                                }
                            }
                        }
                    }
            }
            
        }
    }
    
    @IBAction func approvePressed(_ sender: UIButton) {
        guard let row = tableView.indexPathForSelectedRow?.row else { return }
        let meeting = meetings[row]
        print(meeting.patientEmail)
        print(meeting.documentID)
        let meetingRef = db.collection("meetings").document(meeting.documentID)
        
        meetingRef.updateData([
            "approved": true
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
    }
    
    @IBAction func disapprovePressed(_ sender: UIButton) {
        guard let row = tableView.indexPathForSelectedRow?.row else { return }
        let meeting = meetings[row]
        print(meeting.patientEmail)
        print(meeting.documentID)
        let meetingRef = db.collection("meetings").document(meeting.documentID)
        
        meetingRef.updateData([
            "approved": false
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
}
extension MeetingManagerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.meetings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meeting = meetings[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! MeetingCell
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let date = Date(timeIntervalSince1970: meeting.date)
        cell.dateLabel.text = formatter.string(for: date)
        //cell.dateLabel.text = meeting.date
        cell.meetingSubjectLabel.text = meeting.subject
        if meeting.approved{
            cell.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        }
        else{
            cell.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        }
        cell.actionBlock = {
            self.selectedMeeting = self.meetings[indexPath.row]
            
            self.performSegue(withIdentifier: "managerDetailsSegue", sender: self)
        }
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "managerDetailsSegue" {
            let dvc = segue.destination as! DetailsViewController
            dvc.meeting = self.selectedMeeting
            dvc.populate()
        }
    }
}
