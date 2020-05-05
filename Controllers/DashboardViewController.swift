import UIKit
import Firebase

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var patientView: UIView!
    @IBOutlet weak var doctorView: UIView!
    @IBOutlet weak var approvedMeetingsView: UIView!
    @IBOutlet weak var pendingMeetingsView: UIView!
    
    @IBOutlet weak var doctorsTable: UITableView!
    @IBOutlet weak var patientsPendingTable: UITableView!
    @IBOutlet weak var patientsApprovedTable: UITableView!
    
    var user : User = User(firstName: "", lastName: "", email: "", doctor: false)
    var meetings: [Meeting] = []
    var pendingMeetings : [Meeting] = []
    let db = Firestore.firestore()
    var selectedMeeting : Meeting? = nil
    override func viewDidLoad(){
        super.viewDidLoad()
        doctorsTable.dataSource = self
        patientsApprovedTable.dataSource = self
        patientsPendingTable.dataSource = self
        doctorsTable.register(UINib(nibName: "MeetingCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        patientsApprovedTable.register(UINib(nibName: "MeetingCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        patientsPendingTable.register(UINib(nibName: "MeetingCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        loadUser()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.setHidesBackButton(false, animated: false);
    }
    func loadUser() {
        if let loggedInEmail = Auth.auth().currentUser?.email {
            db.collection("users")
                .whereField("email", isEqualTo: loggedInEmail)
                .limit(to: 1)
                .getDocuments { (querySnapshot, error) in
                    if let e = error {
                        print("There was an issue retrieving data from Firestore. \(e)")
                    } else {
                        if let snapshotDocuments = querySnapshot?.documents {
                            for doc in snapshotDocuments {
                                let data = doc.data()
                                if let docEmail = data["email"] as? String, let docDoctor = data["doctor"] as? Bool, let docFirstName = data["firstName"] as? String, let docLastName = data["lastName"] as? String{
                                    self.user = User(firstName: docFirstName, lastName: docLastName, email: docEmail, doctor: docDoctor)
                                    self.welcomeLabel.text = "Hello \(self.user.firstName)"
                                    self.doctorView.isHidden = true
                                    self.patientView.isHidden = true
                                    if docDoctor{
                                        self.doctorView.isHidden = false
                                        self.loadDoctorsMeetings()
                                    }
                                    else{
                                        self.patientView.isHidden = false
                                        self.loadPatientsMeetings()
                                    }
                                }
                            }
                        }
                    }
            }
        }
    }
    
    @IBAction func showApproved(_ sender: UIButton) {
        approvedMeetingsView.backgroundColor = UIColor.black
        pendingMeetingsView.backgroundColor = UIColor.brown
        patientsPendingTable.isHidden = true
        patientsApprovedTable.isHidden = false
    }
    @IBAction func showPending(_ sender: UIButton) {
        pendingMeetingsView.backgroundColor = UIColor.black
        approvedMeetingsView.backgroundColor = UIColor.brown
        patientsApprovedTable.isHidden = true
        patientsPendingTable.isHidden = false
    }
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    func loadDoctorsMeetings() {
        
        
        if let loggedInUser = Auth.auth().currentUser {
            let today = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
            
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            let email = "doctorEmail"
            db.collection("meetings")
                .whereField(email, isEqualTo: loggedInUser.email ?? "")
                .whereField("date", isGreaterThanOrEqualTo: today.timeIntervalSince1970)
                .whereField("date", isLessThan:  tomorrow.timeIntervalSince1970)
                .whereField("approved", isEqualTo: true)
                .order(by: "date")
                
                .addSnapshotListener { (querySnapshot, error) in
                    
                    
                    if let e = error {
                        print("There was an issue retrieving data from Firestore. \(e)")
                    } else {
                        if let snapshotDocuments = querySnapshot?.documents {
                            self.meetings = []
                            for doc in snapshotDocuments {
                                let data = doc.data()
                                if let doctorEmail = data["doctorEmail"] as? String, let patientEmail = data["patientEmail"] as? String, let info = data["info"] as? String, let meetingDate = data["date"] as? Double, let subject = data["subject"] as? String, let approved = data["approved"] as? Bool {
                                    let newMeeting = Meeting(patientEmail: patientEmail, doctorEmail: doctorEmail, date: meetingDate, subject: subject, info: info, approved: approved, documentID: doc.documentID)
                                    self.meetings.append(newMeeting)
                                }
                            }
                            DispatchQueue.main.async {
                                self.doctorsTable.reloadData()
                            }
                        }
                    }
            }
        }
    }
    func loadPatientsMeetings() {
        
        
        if let loggedInUser = Auth.auth().currentUser {
            let today = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
            
            let email = "patientEmail"
            db.collection("meetings")
                .whereField(email, isEqualTo: loggedInUser.email ?? "")
                .whereField("date", isGreaterThanOrEqualTo: today.timeIntervalSince1970)
                .whereField("approved", isEqualTo: true)
                .order(by: "date")
                
                .addSnapshotListener { (querySnapshot, error) in
                    
                    
                    if let e = error {
                        print("There was an issue retrieving data from Firestore. \(e)")
                    } else {
                        if let snapshotDocuments = querySnapshot?.documents {
                            self.meetings = []
                            for doc in snapshotDocuments {
                                let data = doc.data()
                                if let doctorEmail = data["doctorEmail"] as? String, let patientEmail = data["patientEmail"] as? String, let info = data["info"] as? String, let subject = data["subject"] as? String, let meetingDate = data["date"] as? Double, let approved = data["approved"] as? Bool {
                                    let newMeeting = Meeting(patientEmail: patientEmail, doctorEmail: doctorEmail, date: meetingDate, subject: subject, info: info, approved: approved, documentID: doc.documentID)
                                    self.meetings.append(newMeeting)
                                }
                            }
                            DispatchQueue.main.async {
                                self.patientsApprovedTable.reloadData()
                            }
                        }
                    }
            }
            
            //================
            db.collection("meetings")
                .whereField(email, isEqualTo: loggedInUser.email ?? "")
                .whereField("date", isGreaterThanOrEqualTo: today.timeIntervalSince1970)
                .whereField("approved", isEqualTo: false)
                .order(by: "date")
                .addSnapshotListener { (querySnapshot, error) in
                    
                    
                    if let e = error {
                        print("There was an issue retrieving data from Firestore. \(e)")
                    } else {
                        if let snapshotDocuments = querySnapshot?.documents {
                            self.pendingMeetings = []
                            for doc in snapshotDocuments {
                                let data = doc.data()
                                if let doctorEmail = data["doctorEmail"] as? String, let patientEmail = data["patientEmail"] as? String, let info = data["info"] as? String, let subject = data["subject"] as? String, let meetingDate = data["date"] as? Double, let approved = data["approved"] as? Bool {
                                    let newMeeting = Meeting(patientEmail: patientEmail, doctorEmail: doctorEmail, date: meetingDate, subject: subject, info: info, approved: approved, documentID: doc.documentID)
                                    self.pendingMeetings.append(newMeeting)
                                }
                            }
                            DispatchQueue.main.async {
                                self.patientsPendingTable.reloadData()
                            }
                        }
                    }
            }
        }
    }
}

extension DashboardViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == patientsPendingTable{
            return self.pendingMeetings.count
        }
        return self.meetings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var data = self.meetings
        if tableView == patientsPendingTable{
            data = self.pendingMeetings
        }
        let meeting = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! MeetingCell
        cell.actionBlock = {
            if tableView == self.doctorsTable || tableView == self.patientsApprovedTable{
                self.selectedMeeting = self.meetings[indexPath.row]
            }
            else{
                self.selectedMeeting = self.pendingMeetings[indexPath.row]
            }
            
            self.performSegue(withIdentifier: "dashDetailsSegue", sender: self)
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let date = Date(timeIntervalSince1970: meeting.date)
        cell.dateLabel.text = formatter.string(for: date)
        cell.meetingSubjectLabel.text = meeting.subject
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dashDetailsSegue" {
            let dvc = segue.destination as! DetailsViewController
            dvc.meeting = self.selectedMeeting
            dvc.populate()
        }
    }
}
