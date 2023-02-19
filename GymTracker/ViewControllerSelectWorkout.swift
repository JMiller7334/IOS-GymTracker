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
            return (savedWorkouts?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellWorkout", for: indexPath)
        if (savedWorkouts?.isEmpty == true){
            cell.textLabel?.text = "You have no saved workouts..."
        } else {
            //Missing... x in string are the default values for possible nil to prevent warnings.
            cell.textLabel?.text = "\(savedWorkouts?[indexPath.row].name ?? "Missing Name")"//TODO: give better desc for workouts. Only using workout name right now
            
        }
        return cell
    }
    
    
    //TABLEVIEW EDITING
    //config editing styles.
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if (savedWorkouts?.isEmpty == true){
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
            
            savedWorkouts?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if (savedWorkouts?.isEmpty == true){
                tableView.insertRows(at: [indexPath], with: .automatic) //FOR THIS VIEW THERE ALWAYS NEEDS TO BE ATLEAST 1 CELL - KEEPS INDEX AT 1
            }
            
            tableView.endUpdates()
        }
    }
        
    //MARK: ViewDidLoad
    var savedWorkouts: [Workout]?
    @IBOutlet var tableWorkout: UITableView!
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView config
        savedWorkouts = []
        tableWorkout.delegate = self
        tableWorkout.dataSource = self
        // Do any additional setup after loading the view.
        
        //TODO: created workout need to be loaded in from firebase.
        //MARK: READ DATABASE
        let db_ref = Database.database().reference()
        db_ref.child("data/user").observe(DataEventType.value, with: { snapshot in
            let json = (snapshot.value as? [String: Any])!
            for (aKey, elementData) in json {
                print(elementData)
                //print(aKey)
                
                let loadedWorkout = Workout(name: aKey, exercises: [])
                self.savedWorkouts?.append(loadedWorkout)
                self.tableWorkout.reloadData()
            }
          })
 
        //note: currently using an  instance of test workout
        /*var testExercise = Exercise(Name: "", Sets: 3, Reps: [1,1,1], Weight: [210, 215, 215], Exertion: ["9", "9", "9"], ExertionType: ["RPE", "RPE", "RPE"], RestMin: [0, 0, 0], RestSec: [30, 30, 30], Type: "str")
            testExercise.name = "benchpress"
            
        var testWorkout = Workout(name: "", exercises: [testExercise])
            testWorkout.name = "testWorkout"
            
        savedWorkouts?.append(testWorkout)*/
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
