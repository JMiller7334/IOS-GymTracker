//
//  ViewControllerRunWorkout.swift
//  GymTracker
//
//  Created by student on 2/26/23.
//

import UIKit

class ViewControllerRunWorkout: UIViewController {
    
    //TEST WORKOUT INIT
    var workoutHistory: [Exercise] = []//TODO: History needs to be changed to a property within the class of workout.
    var sessionRecord: [Exercise] = [] //record for the current workout sessions.
    var currentWorkout = Workout(name: "Test Workout", exercises: [])
    let exeSquat = Exercise(Name: "Squats(wide)", Sets: 5, Reps: [3,3,1,1,1], Weight: [235, 278, 295], Exertion: ["6","6","8","8","8"], ExertionType: ["RPE", "RPE", "RPE", "RPE", "RPE"], RestMin: [], RestSec: [30, 30, 60, 60, 90], Type: "Str")
    let exeRackPull = Exercise(Name: "Rack Pulls", Sets: 4, Reps: [8, 8, 6, 3], Weight: [315, 325, 365], Exertion: ["7", "7", "8", "9"], ExertionType: ["RPE", "RPE", "RPE", "RPE"], RestMin: [1, 1, 1, 1], RestSec: [], Type: "Str")
    
    //IB OUTLET VARIABLES//
    @IBOutlet var exerciseTitle: UILabel!
    
    @IBOutlet var historyTitle:UILabel!
    @IBOutlet var historyWeight: UILabel!
    @IBOutlet var historyReps: UILabel!
    @IBOutlet var historyRPE: UILabel!
    @IBOutlet var historyRest: UILabel!
    
    @IBOutlet var goalTitle: UILabel!
    @IBOutlet var goalWeight: UILabel!
    @IBOutlet var goalReps: UILabel!
    @IBOutlet var goalRPE: UILabel!
    @IBOutlet var goalRest: UILabel!
    
    @IBOutlet var summary: UITextView!
    @IBOutlet var userInput: UITextInput!
    
    //VARIABLES//
    var totalSets: Int = 0
    var currentSet: Int = 0
    
    var totalExercises: Int = 0
    var currentExercise: Int = 0 //refers to the index of the current exercise found via array in workout class
    var currentPhase: Int = 0
    
    var loadupSuccess = false
    
    
    //MARK: Functions
    func updateScreen(){
        if(loadupSuccess != true){
            //TODO: USER SHOULD BE NOTIFIED THAT WORKOUT FAILED TO LOAD.
            print("APP: workout data failed to load in")
        }
        if (currentPhase == 1){
            print("INDEX \(currentSet)")
            let historyExercise = workoutHistory[currentExercise]
            let dataExercise = currentWorkout.exercises[currentExercise]
            exerciseTitle.text = "\(dataExercise.name) - \(dataExercise.type)"
            //Setup Goals
            goalTitle.text = "Set \(currentSet+1) Goals"
            goalWeight.text = "Goal Weight: \(dataExercise.weight[currentSet])lbs."
            goalReps.text = "Goal Reps: \(dataExercise.reps[currentSet])"
            goalRPE.text = "Goal \(dataExercise.exertionType[currentSet]): \(dataExercise.exertion[currentSet])"
            
            if (dataExercise.restMin.isEmpty){
                goalRest.text = "Subsequent set rest time\(dataExercise.restSec[currentSet]) "
            } else {
                goalRest.text = "Subsequent set rest time\(dataExercise.restMin[currentSet]) "
            }
            
            //Setup History
            historyTitle.text = "Set \(currentSet+1) History"
            historyWeight.text = "Weight: \(historyExercise.weight[currentSet])lbs."
            historyRPE.text = "\(historyExercise.exertionType[currentSet])/\(historyExercise.exertion[currentSet])"
            historyReps.text = " \(historyExercise.reps[currentSet])/\(historyExercise.reps[currentSet])"
            
            if (historyExercise.restMin.isEmpty){ //determine if user is using min or seconds for rest-time
                historyRest.text = "Subsequent set rest time\(historyExercise.restSec[currentSet]) "
            } else {
                historyRest.text = "Subsequent set rest time\(historyExercise.restMin[currentSet]) "
            }
         print("App:/runSscreen: screen updated")
        }
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //TODO: This is test data and will should be replaced w/data from workout class
        // WORKOUT DATA TO BE OBTAINED BELOW IF POSSIBLE AND VERIFIED BELOW.
        currentWorkout.addExercise(newExercise: exeSquat)
        currentWorkout.addExercise(newExercise: exeRackPull)
        
        workoutHistory = [exeRackPull, exeSquat]
        
        //VARIABLE INIT//
        if(currentWorkout.exercises.isEmpty){
            print("App: no exercises found for workout")
            return
        }
        currentPhase = 1
        currentSet = 0 //for display values +1 to this.
        currentExercise = 0 //refers to array index
        
        totalExercises = currentWorkout.exercises.count
        totalSets = currentWorkout.exercises[0].sets
        
        loadupSuccess = true //indicates the workout loaded in without issues; if false will notify user.
        updateScreen() //update the screen to start.
    }
    
    //MARK: IBActions
    @IBAction func buttonNextTapped(_ sender: UIButton) {
        print("App buttonNextTapped")
        updateScreen()
    }
    
    
    @IBAction func buttonBackTapped(_ sender: UIButton) {
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
