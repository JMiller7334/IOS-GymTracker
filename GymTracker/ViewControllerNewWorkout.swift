//
//  ViewControllerNewWorkout.swift
//  GymTracker
//
//  Created by student on 3/20/22.
//

import UIKit
import FirebaseDatabase

class ViewControllerNewWorkout: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: TABLEVIEW FUNCTIONS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (newWorkout?.exercises.isEmpty == true){
            return 1
        } else {
            return (newWorkout?.exercises.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if (newWorkout?.exercises.isEmpty == true){
            cell.textLabel?.text = "You have no exercises yet. Add some!"
        } else {
            var repString = ""
            for v in newWorkout?.exercises[indexPath.row].reps ?? [] { //Note the ??[] is the default value required for this to run
                repString.append("\(v) ")
            }
            //Missing... x in string are the default values for possible nil to prevent warnings.
            cell.textLabel?.text = "\(newWorkout?.exercises[indexPath.row].name ?? "Missing Name") Sets:\(newWorkout?.exercises[indexPath.row].sets ?? 00) Reps:\(repString) \(newWorkout?.exercises[indexPath.row].type ?? "Missing type") movement"
            
        }
        return cell
    }
    
    
    //TABLEVIEW EDITING
    //config editing styles.
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if (newWorkout?.exercises.isEmpty == true){
            return .none
        } else {
            return .delete
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //handles actions for editing styles.
        if (editingStyle == .delete){
            
            //indicates actions taken for the tableview to update after user deletes
            tableView.beginUpdates()
            
            newWorkout?.exercises.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if (newWorkout?.exercises.isEmpty == true){
                tableView.insertRows(at: [indexPath], with: .automatic) //FOR THIS VIEW THERE ALWAYS NEEDS TO BE ATLEAST 1 CELL - KEEPS INDEX AT 1
            }
            
            tableView.endUpdates()
        }
    }
    
    
    //MARK: VIEW-DID-LOAD
    var newWorkout: Workout?
    @IBOutlet var editWorkoutName: UITextField!
    @IBOutlet var tableNewExercises: UITableView!
    @IBOutlet var buttonSave: UIButton!
    
    let db_ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView config
        tableNewExercises.delegate = self
        tableNewExercises.dataSource = self
        // Do any additional setup after loading the view.
        if ((newWorkout?.exercises.count)! >= 1){
            self.navigationController?.viewControllers.remove(at: 1) //if count greater than 1 indicates a previous NewExerciseScreen. This removes it.
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "newExercise"){
            print("segue: path > newExercise")
            let controller = segue.destination as! ViewControllerNewExercise
            print("Passing data")
            newWorkout?.name = editWorkoutName.text!
            controller.newWorkout = newWorkout!
        }
    }
    
    
    //TODO: DUPLICATED FUNC SHOW ALERT, SHOULD BE CALLED UNIVERSERALLY.
    func showAlert(){
           let alert = UIAlertController(title: "Missing Field", message: "Please enter an exercise name", preferredStyle: .alert)
           let alertOK = UIAlertAction(title: "OK", style: .default, handler: {action -> Void in})
           alert.addAction(alertOK)
           self.present(alert, animated: true, completion: nil)
       }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if (editWorkoutName.text == nil || editWorkoutName.text == ""){
            showAlert() //missing field alert
        } else {
            newWorkout?.name = editWorkoutName.text!
            var array2Save: [Any] = []
            //db_ref.child("data/user").setValue(newWorkout?.name)
            for i in 0 ..< (newWorkout?.exercises.count)! {
                array2Save.append(newWorkout?.exercises[i].asDictionary as Any)
            }
            print("DATABASE: array2Save: \(array2Save)")
            db_ref.child("data/user/\(newWorkout!.name)").setValue(array2Save)
            
            
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "NewWorkout") as! ViewControllerNewWorkout
            self.navigationController?.viewControllers.remove(at: 1) //removes last view
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
