//
//  ViewController.swift
//  GymTracker
//
//  Created by student on 3/20/22.
//

import UIKit

//TODO: move structs to dedicated/separate file
struct Workout{
    var name:String?
    var exercises:[Exercise]
    
    mutating func addExercise(newExercise: Exercise){
        print("adding new exercise: \(newExercise)")
        self.exercises.append(newExercise)
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "newWorkout"){
            print("segue: path> newWorkout")
            let controller = segue.destination as! ViewControllerNewWorkout
            var newWorkout = Workout(name: "", exercises: [])
            newWorkout.name = ("TestWorkout")
            print(newWorkout.name!)
            controller.newWorkout = newWorkout
            
        }else{
            print("segue: path> planWorkout")
            
        }
    }
    
    //MARK: BUTTON FUNCTIONS
    @IBAction func planWorkoutPressed(_ sender: UIButton) {
        print("planWorkoutPressed")
    }
}

