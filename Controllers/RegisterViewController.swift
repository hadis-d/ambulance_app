import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var docSwitch: UISwitch!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Register controller")
    }

    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text, let firstName = firstNameTextField.text, let lastName = lastNameTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e)
                } else {
                    if let loggedInEmail = Auth.auth().currentUser?.email {
                        self.db.collection("users").addDocument(data: [
                            "firstName": firstName,
                            "lastName": lastName,
                            "email": loggedInEmail,
                            "doctor": self.docSwitch.isOn,
                        ]) { (error) in
                            if let e = error {
                                print("There was an issue saving data to firestore, \(e)")
                            } else {
                                print("Successfully saved data.")
                            }
                        }
                    }
                    self.performSegue(withIdentifier: "RegisterToDashboard", sender: self)
                }
            }
        }
    }
    
    
}

