//
//  ViewControllerRunWorkout.swift
//  GymTracker
//
//  Created by student on 2/26/23.
//

import UIKit

class ViewControllerRunWorkout: UIViewController, UITextFieldDelegate {
    
    //TEST WORKOUT INIT
    var workoutHistory: [Exercise] = []//TODO: History needs to be changed to a property within the class of workout.
    var sessionRecord: [Exercise] = [] //record for the current workout sessions.

    var savedWeight: [Double] = []
    var savedReps: [Int] = []
    var savedExersion: [Int] = []
    var savedRest: [Int] = []
    
    var recordedRest = 0
    
    
    var currentWorkout = Workout(name: "Test Workout", exercises: [])
    let exeSquat = Exercise(Name: "Squats(wide)", Sets: 2, Reps: [3,3,1,1,1], Weight: [235, 278, 295, 180, 80], Exertion: [6,6,8,8,8], ExertionType: ["RPE", "RPE", "RPE", "RPE", "RPE"], RestMin: [], RestSec: [30, 30, 60, 60, 90], Type: "Str")
    
    let exeRackPull = Exercise(Name: "Rack Pulls", Sets: 2, Reps: [8, 8, 6, 3], Weight: [315, 325, 365, 335], Exertion: [7, 7, 8, 9], ExertionType: ["RPE", "RPE", "RPE", "RPE"], RestMin: [1, 1, 1, 1], RestSec: [], Type: "Str")
    
    //IB OUTLET VARIABLES//
    @IBOutlet var exerciseTitle: UILabel!
    
    @IBOutlet var historyTitle:UILabel!
    @IBOutlet var historyWeight: UILabel!
    @IBOutlet var historyReps: UILabel!
    @IBOutlet var historyRPE: UILabel!
    
    @IBOutlet var goalTitle: UILabel!
    @IBOutlet var goalWeight: UILabel!
    @IBOutlet var goalReps: UILabel!
    @IBOutlet var goalRPE: UILabel!
    
    @IBOutlet var summary: UITextView!
    
    @IBOutlet var inputTitle: UILabel!
    @IBOutlet var userInput: UITextField!

    
    //VARIABLES//
    var totalSets: Int = 0
    var currentSet: Int = 0
    
    var totalExercises: Int = 0
    var currentExercise: Int = 0 //refers to the index of the current exercise found via array in workout class
    var currentPhase: Int = 0
    
    var loadupSuccess = false
    
    
    //MARK: Functions
    func updateSummary(){
        if (currentPhase == 0){
            print("APP:-updateSummary; closing")
            return
        }
        
        var stringAddition = ""
        if (currentPhase == 1){
            stringAddition = "weight: \(savedWeight[currentSet])lbs"
        } else if (currentPhase == 2){
            stringAddition = "reps: \(savedReps[currentSet])"
        } else if (currentPhase == 3){
            stringAddition = "\(currentWorkout.exercises[currentExercise].exertionType[currentSet]): \(savedExersion[currentSet])"
        }
        
        
        summary.text = ("\(summary.text ?? "") \(stringAddition)")
    }
    
    
    func updateScreen(){
        //CONFIGURE FOR NEXT SET/EXERCISE - runs after rest-timer
        if (currentPhase == 4){
            currentPhase = 0
            savedRest.append(recordedRest)
            
            summary.text = "\(summary.text ?? "") | rest: \(recordedRest)sec"
            
            recordedRest = 0
            
            currentSet = currentSet + 1
            
            //increment current exercise.
            if (currentSet >= currentWorkout.exercises[currentExercise].sets){
                print("RUN: max sets reached")
                currentSet = 0
                let recordedExercise = Exercise(Name: currentWorkout.exercises[currentExercise].name, Sets: currentWorkout.exercises[currentExercise].sets, Reps: savedReps, Weight: savedWeight, Exertion: savedExersion, ExertionType: currentWorkout.exercises[0].exertionType, RestMin: [], RestSec: savedRest, Type: currentWorkout.exercises[currentExercise].type)
                
                sessionRecord.append(recordedExercise)
                print(recordedExercise)
                
                savedRest = []
                savedReps = []
                savedWeight = []
                savedExersion = []
                                
                currentExercise = currentExercise + 1
                print("MAX EXE INDEX: \(currentWorkout.exercises.count) | currentEXE: \(currentExercise)")
                if (currentExercise == currentWorkout.exercises.count){
                    print("WORKOUT FINISHED")
                    return
                }
                
                summary.text = " \n \(summary.text ?? "") \n \n \(currentWorkout.exercises[currentExercise].name)"
            }
            
            //HANDLE DATA RECORDING
            print("Timer: Stopped")
        }
        
        
        //CONFIG HISTORY DISPLAY
        let historyExercise = workoutHistory[currentExercise]
        let dataExercise = currentWorkout.exercises[currentExercise]
        
        if (currentPhase > 0 && userInput.hasText == false){
            print("APP: user must enter text to move on.")
            return
            //TODO: Inform user that must enter into input to move on.
        }

        if(loadupSuccess != true){
            //TODO: USER SHOULD BE NOTIFIED THAT WORKOUT FAILED TO LOAD.
            print("APP: workout data failed to load in")
            return
        }
        
        
        //SCREEN UPDATES BY PHASE - this where things are changed by phase.
        if (currentPhase == 0){ //UPDATE PHASE//
            
            summary.text = "\(summary.text ?? "") \n Set \(currentSet+1)"

            inputTitle.text = "ENTER WEIGHT"
            
            exerciseTitle.text = "\(dataExercise.name) - \(dataExercise.type)"
            //Setup Goals
            goalTitle.text = "Set \(currentSet+1) Goals of \(totalSets) sets"
            goalWeight.text = "Goal Weight: \(dataExercise.weight[currentSet])lbs."
            goalReps.text = "Goal Reps: \(dataExercise.reps[currentSet])"
            goalRPE.text = "Goal \(dataExercise.exertionType[currentSet]): \(dataExercise.exertion[currentSet])"
            
            //Setup History
            //History is either all or nothing, app will currently not support partial history entries
            if (workoutHistory.count == currentWorkout.exercises.count){
                historyTitle.text = "Set \(currentSet+1) History"
                historyWeight.text = "Weight: \(historyExercise.weight[currentSet])lbs."
                historyRPE.text = "\(historyExercise.exertionType[currentSet]): \(historyExercise.exertion[currentSet])"
                historyReps.text = "Reps: \(historyExercise.reps[currentSet])/\(historyExercise.reps[currentSet])"
            }

         print("App:/runSscreen: screen updated")
            //pre phase setup for next phase
            userInput.keyboardType = UIKeyboardType.decimalPad
            userInput.reloadInputViews()
            
        } else if (currentPhase == 1){ //USER ENTERS WEIGHT
            //TODO: TRY AND CATCH - ENSURE SUCCESSFUL CONVERSION
            savedWeight.append(Double(userInput.text!)!)
            
            userInput.placeholder = "Enter reps"
            userInput.keyboardType = UIKeyboardType.numberPad
            userInput.reloadInputViews()
            inputTitle.text = ("ENTER REPS")
            
        } else if (currentPhase == 2){ //USER ENTERS REPS
            savedReps.append(Int(userInput.text!)!)
            
            userInput.placeholder = "Enter \(dataExercise.exertionType[currentSet])"
            inputTitle.text = "ENTER \(dataExercise.exertionType[currentSet].uppercased())"
            
        } else if (currentPhase == 3){//USER ENTERS RPE
            savedExersion.append(Int(userInput.text!)!)
            
            userInput.isHidden = true
            print("Timer function loaded")
        }
        
        userInput.text = ""
        updateSummary()
        currentPhase += 1
        //TIMER//
        if (currentPhase == 4){
            var i = 0
            let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ [self] intervals in
                var restFormat = ""
                if (dataExercise.restSec.isEmpty){
                    restFormat = String(dataExercise.restMin[currentSet] * 60)
                } else {
                    restFormat = String(dataExercise.restSec[currentSet])
                }
                inputTitle.text = "RESTING: \(i)/\(restFormat)Sec"
                recordedRest = i
                i += 1
                if (currentPhase != 4){
                    intervals.invalidate()
                    userInput.isHidden = false
                    inputTitle.text = "ENTER WEIGHT"
                    userInput.placeholder = "Enter weight"
                    //exercise record needs to be an array of arrays [[Any]] with each [any] represneting a completed set
                }
            }
        }
        //
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: VIEWDIDLOAD
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);

        //Do any additional setup after loading the view.
        //KEYBOARD SETUP FOR INPUT
        userInput.delegate = self
        userInput.tag = 1
        setupToolbar()
        
        
        //TODO: This is test data and will should be replaced w/data from workout class
        // WORKOUT DATA TO BE OBTAINED BELOW IF POSSIBLE AND VERIFIED BELOW.
        currentWorkout.addExercise(newExercise: exeSquat)
        currentWorkout.addExercise(newExercise: exeRackPull)
        
        workoutHistory = [exeSquat, exeRackPull]
        
        //LOAD-UP HANDLING//
        //VARIABLE INIT//
        if(currentWorkout.exercises.isEmpty){
            print("App: no exercises found for workout")
            return
        }
        currentPhase = 0 // phase zero is used to bring in new data to the screen. It also indicates that the user has not tapped the confirm/next button for this iteration.
        currentSet = 0 //for display values +1 to this.
        currentExercise = 0 //refers to array index
        
        totalExercises = currentWorkout.exercises.count
        totalSets = currentWorkout.exercises[0].sets
        
        
        loadupSuccess = true //indicates the workout loaded in without issues; if false will notify user.
        summary.text = "\(currentWorkout.exercises[currentExercise].name)"
        updateScreen() //update the screen to start.
    }
    
    
    //MARK: INPUT KEYBOARD FUNCTIONS
    func setupToolbar(){
        //Create a toolbar
        let bar = UIToolbar()
        //Create a done button with an action to trigger our function to dismiss the keyboard
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissMyKeyboard))
        //Create a felxible space item so that we can add it around in toolbar to position our done button
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        //Add the created button items in the toobar
        bar.items = [flexSpace, flexSpace, doneBtn]
        bar.sizeToFit()
        //Add the toolbar to our textfield
        userInput.inputAccessoryView = bar
    }
    @objc func keyboardWillShow(sender: NSNotification) {
        print("APP: moving input field")
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.frame.origin.y = -(keyboardHeight) // Move view up by keyboard height.
        }
    }
    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
    

    
    //MARK: IBActions
    @IBAction func buttonNextTapped(_ sender: UIButton) {
        dismissMyKeyboard()
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
