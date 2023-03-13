//
//  ViewControllerSelectWorkout.swift
//  GymTracker
//
//  Created by student on 2/17/23.
//

import UIKit
import FirebaseDatabase

class ViewControllerSelectWorkout: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: TABLEVIEW FUNCTIONS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (savedWorkouts?.isEmpty == true){
            return 1
        } else {
            if (selectedWorkout.count > 0){
                return selectedWorkout[0].exercises.count
            } else {
                //default
                return (savedWorkouts?.count)!
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellWorkout", for: indexPath)
        if (savedWorkouts?.isEmpty == true){
            cell.textLabel?.text = "You have no saved workouts..."
        } else {
            if (selectedWorkout.count > 0){
                cell.textLabel?.text = "\(selectedWorkout[0].exercises[indexPath.row].name)  sets:\(selectedWorkout[0].exercises[indexPath.row].sets)  reps:\(selectedWorkout[0].exercises[indexPath.row].reps)"
            } else {
                //default
                cell.textLabel?.text = "\(savedWorkouts?[indexPath.row].name ?? "Missing Name")"
            }
        }
        return cell
    }
    //TABLEVIEW EDITING
    //config editing styles.
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if (savedWorkouts?.isEmpty == true){
            return .none
        } else {
            if (selectedWorkout.count > 0 ){
                return .none
            } else {
                return .delete
            }
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //handles actions for editing styles.
        if (editingStyle == .delete){
            db_ref.child("data/user/").child(savedWorkouts![indexPath.row].name).removeValue()
            
            //indicates actions taken for the tableview to update after user deletes
            tableView.beginUpdates()
            savedWorkouts?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if (savedWorkouts?.isEmpty == true){
                tableView.insertRows(at: [indexPath], with: .automatic) //FOR THIS VIEW THERE ALWAYS NEEDS TO BE ATLEAST 1 CELL - KEEPS INDEX AT 1
            }
            
            tableView.endUpdates()
        }
        print(savedWorkouts)
    }
    
    //TABLE VIEW ON ROW SELECTED//
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (selectedWorkout.isEmpty && savedWorkouts?.count ?? 0 > 0){
            selectedWorkout.append(savedWorkouts![indexPath.row])
            mainTitle.text = ("Selected: \(selectedWorkout[0].name)")
            beginButton.isHidden = false
            revertButton.isHidden = false
        } else {
            mainTitle.text = ("Select a Workout")
            selectedWorkout = []
            beginButton.isHidden = true
            revertButton.isHidden = true
        }
        self.tableWorkout.reloadData()
    }
        
    //MARK: ViewDidLoad
    let db_ref = Database.database().reference()
    
    var selectedWorkout: [Workout] = []
    var savedWorkouts: [Workout]?
    @IBOutlet var tableWorkout: UITableView!
    @IBOutlet var beginButton: UIButton!
    @IBOutlet var revertButton: UIButton!
    @IBOutlet var mainTitle: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView config
        savedWorkouts = []
        tableWorkout.delegate = self
        tableWorkout.dataSource = self
        // Do any additional setup after loading the view.
        
        beginButton.isHidden = true
        revertButton.isHidden = true
        
        
        //TODO: created workout need to be loaded in from firebase.
        //MARK: READ DATABASE
        db_ref.child("data/user").observeSingleEvent(of: .value, with: { snapshot in //observe(DataEventType.value, with: { snapshot in
            if (snapshot.childrenCount != 0){
                let json = (snapshot.value as? [String: Any])!
                for (aKey, elementData) in json {
                    var loadedWorkout = Workout(name: aKey, exercises: [])
                    
                    if let dataWrapper = elementData as? [Any]{
                        //if let jsonData = dataWrapper[0] as? [String: Any]{
                        for i in 0 ..< dataWrapper.count{
                            
                            if let jsonData = dataWrapper[i] as? [String: Any]{
                                //create a class from JSON Data
                                let loaded_exercise = Exercise(Name: jsonData["name"] as! String, Sets: jsonData["sets"] as! Int, Reps: jsonData["reps"] as! [Int], Weight: jsonData["weight"] as! [Double], Exertion: jsonData["exertion"] as! [Int], ExertionType: jsonData["exertionType"] as! [String], RestMin: jsonData["restMin"] as! [Int], RestSec: jsonData["restSec"] as! [Int], Type: jsonData["type"] as! String)
                                loadedWorkout.addExercise(newExercise: loaded_exercise)
                            }
                            
                        }
                        print("TABLE RELOADED")
                        self.savedWorkouts?.append(loadedWorkout)
                        self.tableWorkout.reloadData()
                    }
                }
                print(self.savedWorkouts)
            }
          })
 
        //note: currently using an  instance of test workout
        /*var testExercise = Exercise(Name: "", Sets: 3, Reps: [1,1,1], Weight: [210, 215, 215], Exertion: ["9", "9", "9"], ExertionType: ["RPE", "RPE", "RPE"], RestMin: [0, 0, 0], RestSec: [30, 30, 30], Type: "str")
            testExercise.name = "benchpress"
            
        var testWorkout = Workout(name: "", exercises: [testExercise])
            testWorkout.name = "testWorkout"
            
        savedWorkouts?.append(testWorkout)*/
    }
    
    @IBAction func selectButtonPressed(_ sender: UIButton) {
        print("SELECT")
    }
    
    @IBAction func revertButtonPressed(_ sender: UIButton) {
        mainTitle.text = ("Select a Workout")
        selectedWorkout = []
        beginButton.isHidden = true
        revertButton.isHidden = true
        self.tableWorkout.reloadData()
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
