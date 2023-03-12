//
//  ViewControllerNewExercise.swift
//  GymTracker
//
//  Created by student on 3/20/22.
//

import UIKit

//TODO: move structs to dedicated/separate file
struct Exercise{ // is like a class
    // properties are target/goals
    var name: String
    var sets: Int
    var reps: [Int]
    var weight: [Double]
    var exertion: [Int]
    var exertionType: [String]
    var restMin: [Int]
    var restSec: [Int]
    var type: String
    
    var asDictionary : [String:Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
          guard let label = label else { return nil }
          return (label, value)
        }).compactMap { $0 })
        return dict
      }
    
    func displayProperties(){
        print("sets: \(self.sets) | reps: \(self.reps) | weight: \(self.weight) | exertion: \(self.exertion) |exertion label: \(self.exertionType)| restMin: \(self.restMin) | RestSec: \(self.restSec)")
    }
    
    init(Name: String ,Sets: Int, Reps: [Int], Weight:[Double], Exertion:[Int], ExertionType:[String], RestMin:[Int], RestSec:[Int], Type:String){
        self.name = Name
        self.sets = Sets
        self.reps = Reps
        self.weight = Weight
        self.exertion = Exertion
        self.exertionType = ExertionType
        self.restMin = RestMin
        self.restSec = RestSec
        self.type = Type
    }
    
    //for loading in firebase data
    init(dict: [String: Any]){
        self.name = dict["name"] as! String
        self.sets = dict["sets"] as! Int
        self.reps = dict["reps"] as! [Int]
        self.weight = dict["weight"] as! [Double]
        self.exertion = dict["exertion"] as! [Int]
        self.exertionType = dict["exertionType"] as! [String]
        self.restMin = dict["restMin"] as! [Int]
        self.restSec = dict["restSec"] as! [Int]
        self.type = dict["type"] as! String
    }
}

class ViewControllerNewExercise: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
    
    //MARK: IB OUTLETS/VARIABLES
    var newWorkout: Workout?
    
    @IBOutlet var labelPhase: UILabel!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var labelHint: UILabel!
    @IBOutlet var textSummary: UITextView!
    @IBOutlet var labelSummary: UILabel!
    @IBOutlet var fieldName: UITextField!
    
    var thisExercise = Exercise(Name: "", Sets: 1, Reps: [], Weight: [], Exertion: [], ExertionType: [], RestMin: [], RestSec: [], Type: "Strength")
    
    var currentPhase = 1
    var currentSet = 1
    var totalSets = 0
    
    //TEXTFIELD FUNCTIONS
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fieldName.resignFirstResponder()
        return true
    }
    
    //MARK: PICKER FUNCTIONS
    func configArray(max:Int, increment:Int, startAt0: Bool) -> [String]{
        var dataSet: [String] = []
        if (startAt0 == true){
            dataSet.append("0")
        }
        for i in 1...max {
            if (i * increment < max){
                dataSet.append(String(increment * i))
            }
        }
        return dataSet
    }
    
    func getContentFromPhase() -> [[String]]{
        switch currentPhase {
        case 0: //used for when the user does not want to track target weight
            labelPhase.text = "3/6 - Set \(currentSet)"
            labelHint.text = "Target wieght for set \(currentSet)"
            progressView.progress = 0.5
            //currentPhase = 3
            return [["Add target weight", "No target weight"]]
        case 1:
            labelPhase.text = "1/6 - Sets"
            labelHint.text = "How many sets?"
            progressView.progress = 0.1667
            //STRUCT UPDATES
            thisExercise.sets = 0
            
            return [["sets"], pickerSets]
        case 2:
            labelPhase.text = "2/6 - Set \(currentSet)"
            labelHint.text = "How many reps for set \(currentSet)"
            progressView.progress = 0.32
            return [["reps"], pickerReps]
        case 3:
            labelPhase.text = "3/6 - Set \(currentSet)"
            labelHint.text = "Target wieght for set \(currentSet)"
            progressView.progress = 0.5
            return [pickerTargetWeightMain, pickerTargetWeightMain, pickerTargetWeightMain, pickerTargetWeightSecondary, pickerTargetWeightLabel]
        case 4:
            labelPhase.text = "4/6 - Set \(currentSet)"
            labelHint.text = "Target exertion for set \(currentSet)"
            progressView.progress = 0.9
            return [pickerRPE, pickerRPELabel]
        case 5:
            labelPhase.text = "5/6 - Set \(currentSet)"
            labelHint.text = "Target rest time after set \(currentSet)"
            progressView.progress = 0.76
            return [["min"], pickerRestMin, ["sec"], pickerRestSec]

        default:
            labelPhase.text = "6/6 - Post movement rest"
            labelHint.text = "Target rest time before next exercise"
            progressView.progress = 1
            return [["min"], pickerRestMin, ["sec"], pickerRestSec]
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch currentPhase {
        case 6:
            return 4
        case 5:
            return 4
        case 3:
            return 5
        case 0: //This phase is for when user is not tracking target weight.
            return 1
        default:
            return 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let pickerContent = getContentFromPhase()
        switch component{
        case 0:
            return pickerContent[0].count
        case 1:
            return pickerContent[1].count
        case 2:
            return pickerContent[2].count
        case 3:
            return pickerContent[3].count
        default:
            return pickerContent[4].count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let pickerContent = getContentFromPhase()
        switch component{
        case 0:
            return pickerContent[0][row]
        case 1:
            return pickerContent[1][row]
        case 2:
            return pickerContent[2][row]
        case 3:
            return pickerContent[3][row]
        default:
            return pickerContent[4][row]
        }
    }
    
    //ON PICKER OPTION SELECTION FUNCTION
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        fieldName.resignFirstResponder()
        if (currentPhase == 3 && row == 1 && component == 4){
            print("Update picker")
            currentPhase = 0
            pickerView.reloadAllComponents()
            pickerView.selectRow(1, inComponent: 0, animated: true)
        }
        
        if (currentPhase == 0 && row == 0){
            currentPhase = 3
            pickerView.reloadAllComponents()
            
            pickerView.selectRow(defaults3[0], inComponent: 0, animated: true)
            pickerView.selectRow(defaults3[1], inComponent: 1, animated: true)
            pickerView.selectRow(defaults3[2], inComponent: 2, animated: true)
            pickerView.selectRow(defaults3[3], inComponent: 3, animated: true)
            pickerView.selectRow(defaults3[4], inComponent: 4, animated: true)
        }
    }

    // MARK: PICKERVIEW PROPERTIES
    //phase 1
    var pickerReps: [String] = []
    //phase 2
    var pickerSets: [String] = []
    //phase 3
    var pickerTargetWeightLabel: [String] = ["lbs", "N/A"]
    var pickerTargetWeightMain: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    var pickerTargetWeightSecondary: [String] = [".00",".25",".50"]
    //phase 5
    var pickerRestMin: [String] = []
    var pickerRestSec: [String] = []
    //phase 4
    var pickerRPE: [String] = ["None", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    var pickerRPELabel: [String] = ["RPE", "RIR"]
    //picker position defaults
    var defaults0 = 1 // this is the default for the choice of whether or not to track weight for your set.
    var defaults1 = [0, 0]
    var defaults2 = [0, 0]
    var defaults3 = [0, 0, 0, 0, 0]
    var defaults4 = [0, 0]
    var defaults5 = [0, 0, 0, 0]
    //var defaults6 = [0, 0, 0, 0]
    
    //MARK: VIEWDIDLOAD/FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        //TEXTFIELD SETUP
        fieldName.returnKeyType = .done
        fieldName.autocapitalizationType = .words
        fieldName.autocorrectionType = .no
        fieldName.delegate = self
        
        //PICKER SETUP
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerSets = configArray(max: 20, increment: 1, startAt0: false)
        pickerReps = configArray(max: 100, increment: 1, startAt0: false)
        pickerRestMin = configArray(max: 16, increment: 1, startAt0: true)
        pickerRestSec = configArray(max: 59, increment: 5, startAt0: true)
        pickerRestSec[0] = "00"
        pickerRestSec[1] = "05"
        
        textSummary.text = ""
        // Do any additional setup after loading the view.
    }
    
    
    
    //MARK: MAIN FUNCTIONS
    func generateSummary(){
        var summary = ""
        // Generate text for all completed sets in this exercise listing, but not on the first set
        if (currentSet-1 > 0){
            for i in 0...currentSet-2 {
                summary = "\(summary) \n Set\(i+1) - Reps:\(thisExercise.reps[i]) | Weight:\(thisExercise.weight[i])lbs. |  \(thisExercise.exertionType[i]):\(thisExercise.exertion[i]) | Rest-time: min:\(thisExercise.restMin[i]) sec:\(thisExercise.restSec[i])"
            }
        }
        
        // Generate all the needed text up to the current phase
        print("SUMMARY GEN: current phase: \(currentPhase)")
        if (currentPhase-1 >= 1){
            for phase in 1...currentPhase-1 {
                switch phase {
                case 5:
                    summary = "\(summary) \n Rest min:\(thisExercise.restMin[currentSet-1]) sec:\(thisExercise.restSec[currentSet-1])"
                case 4:
                    summary = "\(summary) \n \(thisExercise.exertionType[currentSet-1]):\(thisExercise.exertion[currentSet-1])"
                case 3:
                    summary = "\(summary) \n Weight:\(thisExercise.weight[currentSet-1])lbs."
                case 2:
                    summary = "\(summary) \n Reps:\(thisExercise.reps[currentSet-1])"
                case 1:
                    summary = "\(summary) \n \n Currently working on: Set\(currentSet)"
                default:
                    print("Summary Gen: no marked event for this stage")
                }
            }
        }
        textSummary.text = summary
        let range = NSMakeRange(textSummary.text.count - 1, 0)
        textSummary.scrollRangeToVisible(range)
    }
    
    func updateScreen(sender: UIButton, reverse: Bool){
        //MARK: STRUCT DATA UPDATES
        let pIndex0 = pickerView.selectedRow(inComponent: 0)
        var pIndex1 = 0
        if (currentPhase != 0){
            pIndex1 = pickerView.selectedRow(inComponent: 1)
        }
        if (reverse == false){
            // save last selection as default starting position for picker.
            switch currentPhase {
            //case 6: NOTE: This doesn't need to written as the user will exit the screen
                //defaults6 = [pIndex0, pIndex1, pickerView.selectedRow(inComponent: 2), pickerView.selectedRow(inComponent: 3)]
                //textSummary.text = (textSummary.text + "  Post-set rest min:\(pIndex1):\(defaults5[3]).")
            case 5:
                defaults5 = [pIndex0, pIndex1, pickerView.selectedRow(inComponent: 2), pickerView.selectedRow(inComponent: 3)]
                //textSummary.text = (textSummary.text + "  Rest min:\(pIndex1):\(pickerRestSec[defaults5[3]])")
                
                //STRUCT UPDATE
                thisExercise.restMin[currentSet-1] = Int(pickerRestMin[pIndex1])!
                thisExercise.restSec[currentSet-1] = Int(pickerRestSec[pickerView.selectedRow(inComponent: 3)])!
                
            case 4:
                defaults4 = [pIndex0, pIndex1]
                textSummary.text = (textSummary.text + "  \(pickerRPELabel[pIndex1]): \(pickerRPE[pIndex0])")
                
                //STRUCT UPDATE\\
                thisExercise.exertion[currentSet-1] = Int(pickerRPE[pIndex0])!
                thisExercise.exertionType[currentSet-1] = String(pickerRPELabel[pIndex1])
                
            case 3:
                defaults3 = [pIndex0, pIndex1, pickerView.selectedRow(inComponent: 2), pickerView.selectedRow(inComponent: 3), pickerView.selectedRow(inComponent: 4)]
                let convertedNumber = Double("\(defaults3[0])\(defaults3[1])\(defaults3[2])\(pickerTargetWeightSecondary[defaults3[3]])")!
                //textSummary.text = (textSummary.text + "  Weight: \(convertedNumber!)lbs.") //lbs is sent as array further above and connot be referenced.
                
                //STRUCT UPDATE
                defaults0 = 0
                thisExercise.weight[currentSet-1] = convertedNumber
            case 2:
                defaults2 = [pIndex0, pIndex1]
                //textSummary.text = (textSummary.text + "\n Set \(currentSet)   Reps \(defaults2[1]+1)")
                //STRUCT UPDATE
                thisExercise.reps[currentSet-1] = Int(pickerReps[pIndex1])!
                
            case 0:
                print("This will be listed as NO TARGET")
                defaults0 = 1
                thisExercise.weight[currentSet-1] = 0.0
                
            default:
                defaults1 = [pIndex0, pIndex1]
                if (currentPhase == 1){ //prevents phase 6 from running this code
                    //STRUCT UPDATES
                    //Using the values from picker properties variables leads to the true values selected.
                    // NOTE: pIndex0 represents the 'Label' and is not part of user selection in this phase
                    thisExercise.sets = Int("\(pickerSets[pIndex1])")! //string convertions
                    print("TESTING: \(thisExercise.sets)")
                    
                    for _ in 1...thisExercise.sets {
                        thisExercise.reps.append(0)
                        thisExercise.weight.append(0.0)
                        thisExercise.exertion.append(0)
                        thisExercise.exertionType.append("RPE")
                        thisExercise.restMin.append(0)
                        thisExercise.restSec.append(0)
                    }
                } else if (currentPhase == 6){
                    //STRUCT UPDATE
                    thisExercise.restMin[currentSet-1] = Int(pickerRestMin[pIndex1])!
                    thisExercise.restSec[currentSet-1] = Int(pickerRestSec[pickerView.selectedRow(inComponent: 3)])!
                    //TODO: Navigate back, save class of exercise to the workout
                }
            }
        }
        if (currentPhase == 0){
            currentPhase = 3
        }
        thisExercise.displayProperties()
        
        // MARK: PHASE & SET CYCLING
        if (reverse == false){
            // step/cycle forward
            if (currentPhase == 5 && currentSet <= totalSets){
                    currentPhase = 2
                    currentSet = currentSet + 1
            } else {
                if (currentPhase == 1){
                    totalSets = pIndex1
                    labelSummary.text = ("Total Sets: \(totalSets + 1)")
                }
                // MODIFIED FOR SKIPPING WEIGHT TARGET //
                if (currentPhase == 2 && defaults0 == 1){
                    currentPhase = 0
                } else {
                    currentPhase = currentPhase + 1
                }
                
            }
            // step forward to last rest period setup
            if (currentPhase == 5 && currentSet == totalSets + 1){ //skip rest period input for last set
                currentPhase = 6
            }
        }
        
        if (reverse == true ){
            // step back to first phase - backing out of set setup
            if (currentPhase == 2 && currentSet == 1){
                currentPhase = 1
                
                //STRUCT UPDATE
                //Reset Values - total sets could change!
                thisExercise.reps.removeAll()
                thisExercise.weight.removeAll()
                thisExercise.exertion.removeAll()
                thisExercise.restMin.removeAll()
                thisExercise.restSec.removeAll()
                print("Sets Cleared")
            }
            else {
                
                // step/cycle backward
                print("cycle back")
                if (currentPhase == 2 && currentSet >= 2){
                    currentPhase = 5
                    currentSet = currentSet - 1
                }
                if (currentPhase == 6){
                    currentPhase = 4
                }
                else if (currentPhase > 1){
                    // MODIFIED FOR SKIPPING WEIGHT TARGET //
                    if (currentPhase == 4){
                        //sets the user on the right screen depending if target wieght or not
                        if (thisExercise.weight[currentSet-1] == 0.0){
                            currentPhase = 0
                        } else {
                            currentPhase = 3
                        }
  
                    } else {
                        currentPhase = currentPhase - 1
                    }
                    print("Current Phase @\(currentPhase)")
                }
            }
        }
        
        // SCREEN UPDATE
        pickerView.reloadAllComponents()
        switch currentPhase {
        case 0:
            pickerView.selectRow(1, inComponent: 0, animated: true)
        case 1:
            pickerView.selectRow(defaults1[0], inComponent: 0, animated: true)
            pickerView.selectRow(defaults1[1], inComponent: 1, animated: true)
        case 2:
            pickerView.selectRow(defaults2[0], inComponent: 0, animated: true)
            pickerView.selectRow(defaults2[1], inComponent: 1, animated: true)
        case 3:
            pickerView.selectRow(defaults3[0], inComponent: 0, animated: true)
            pickerView.selectRow(defaults3[1], inComponent: 1, animated: true)
            pickerView.selectRow(defaults3[2], inComponent: 2, animated: true)
            pickerView.selectRow(defaults3[3], inComponent: 3, animated: true)
            pickerView.selectRow(defaults3[4], inComponent: 4, animated: true)
        case 4:
            pickerView.selectRow(defaults4[0], inComponent: 0, animated: true)
            pickerView.selectRow(defaults4[1], inComponent: 1, animated: true)
        case 5:
            pickerView.selectRow(defaults5[0], inComponent: 0, animated: true)
            pickerView.selectRow(defaults5[1], inComponent: 1, animated: true)
            pickerView.selectRow(defaults5[2], inComponent: 2, animated: true)
            pickerView.selectRow(defaults5[3], inComponent: 3, animated: true)

        default:
            print("SCREEN UPDATE: last phase")
            //pickerView.selectRow(defaults6[0], inComponent: 0, animated: true)
            //pickerView.selectRow(defaults6[1], inComponent: 1, animated: true)
            //pickerView.selectRow(defaults6[2], inComponent: 2, animated: true)
            //pickerView.selectRow(defaults6[3], inComponent: 3, animated: true)
        }
    }
    
    func showAlert(){
           let alert = UIAlertController(title: "Missing Field", message: "Please enter an exercise name", preferredStyle: .alert)
           let alertOK = UIAlertAction(title: "OK", style: .default, handler: {action -> Void in})
        
           alert.addAction(alertOK)
           self.present(alert, animated: true, completion: nil)
       }
    
    // MARK: IB ACTIONS
    @IBAction func movementTypeChanged(_ sender: UISegmentedControl) {
        fieldName.resignFirstResponder()
        switch sender.selectedSegmentIndex {
        case 0:
            thisExercise.type = "Strength"
            
        case 1:
            thisExercise.type = "Supplemental"
        
        default:
            thisExercise.type = "Accessory"
        }
        print("changed movement type: \(thisExercise.type)")
    }
    
    
    @IBAction func buttonBackTapped(_ sender: UIButton) {
        updateScreen(sender: sender, reverse: true)
        generateSummary()
    }
    
    @IBAction func buttonConfirmTapped(_ sender: UIButton) {
        if (currentPhase == 6){
            if (fieldName.text == nil || fieldName.text == ""){
                showAlert() //missing field alert
            } else {
                //MARK: DATA PASSING
                //WORKOUT STRUCT DATA HANDLING
                thisExercise.name = fieldName.text!
                /*print("classInfo: \(thisExercise.asDictionary)")*/
                newWorkout?.addExercise(newExercise: thisExercise)
                //print("workout info: \(newWorkout?.asDictionary)")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "NewWorkout") as! ViewControllerNewWorkout
                vc.newWorkout = newWorkout!
                self.navigationController?.viewControllers.remove(at: 1) //removes last view
                self.navigationController?.pushViewController(vc, animated: true)
                //self.navigationController?.popViewController(animated: true)
                
            }

            
        } else {
            updateScreen(sender: sender, reverse: false)
            generateSummary()
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
