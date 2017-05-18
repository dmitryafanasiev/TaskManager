//
//  TMTaskDetailsViewController.swift
//  TaskManager
//

import Foundation
import UIKit

class TMTaskDetailsViewController: KeyboardViewController {
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var stateLabel: UILabel!
    @IBOutlet weak private var progressLabel: UILabel!
    @IBOutlet weak private var dueDateLabel: UILabel!
    @IBOutlet weak private var stateSegmentedControl: UISegmentedControl!
    @IBOutlet weak private var progressSlider: UISlider!
    @IBOutlet weak private var dueDatePicker: UIDatePicker!
    @IBOutlet weak private var nameTextField: UITextField!
    
    var viewModel = TMTaskDetailsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = viewModel.mode == .CreateNew ? "Create Task" : "Task Details"
        customizeUI()
        customizeNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.scrollView.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.scrollView.endEditing(true)
    }
    
    override func keyboardWillHide(notification : NSNotification) {
        super.keyboardWillHide(notification: notification)
        
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    override func keyboardWillAppear(notification : NSNotification) {
        super.keyboardWillAppear(notification: notification)
        
        guard let notificationObject = notification.userInfo else {
            return
        }
        if let endFrame = notificationObject[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let window = AppDelegate.sharedDelegate.window {
            
            let keyboardEndFrameOnWindow = endFrame.cgRectValue
            
            if let tableSuperview = scrollView.superview {
                let scrollViewRectOnWindow = window.convert(scrollView.frame, from: tableSuperview)
                
                let height = keyboardEndFrameOnWindow.intersection(scrollViewRectOnWindow).size.height
                
                if height >= 0 {
                    scrollView.contentInset = UIEdgeInsets(top: 0,
                                                               left: 0,
                                                               bottom: height,
                                                               right: 0)
                    
                    scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0,
                                                                        left: 0,
                                                                        bottom: height,
                                                                        right: 0)
                }
            }
        }
    }
    
    @IBAction func sliderValueDidChange() {
        setSliderValue(value: progressSlider.value)
        if progressSlider.value == progressSlider.maximumValue {
            stateSegmentedControl.selectedSegmentIndex = 2
        } else {
            if progressSlider.value == progressSlider.minimumValue {
                stateSegmentedControl.selectedSegmentIndex = 0
            } else {
                stateSegmentedControl.selectedSegmentIndex = 1
            }
        }
    }

    @IBAction func segmentedControlSelectionDidChange() {
        switch stateSegmentedControl.selectedSegmentIndex {
        case 0:
            setSliderValue(value: progressSlider.minimumValue)
        case 1:
            if progressSlider.value == progressSlider.maximumValue {
                setSliderValue(value: progressSlider.maximumValue - 1)
            }
        case 2:
            setSliderValue(value: progressSlider.maximumValue)
        default:
            break
        }
    }
    
    private func setSliderValue(value: Float) {
        progressSlider.value = value
        let intValue = Int(value)
        progressLabel.text = "Progress: " + String(intValue) + "%"
    }
    
    private func customizeUI() {
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = 100
        stateSegmentedControl.selectedSegmentIndex = 0
        stateSegmentedControl.setTitle(TMTaskState.New.rawValue, forSegmentAt: 0)
        stateSegmentedControl.setTitle(TMTaskState.InProgress.rawValue, forSegmentAt: 1)
        stateSegmentedControl.setTitle(TMTaskState.Done.rawValue, forSegmentAt: 2)
        dueDatePicker.minimumDate = Date()
        
        if viewModel.mode == .CreateNew {
            progressLabel.text = "Progress: 0%"
            progressSlider.value = 0
        } else {
            nameTextField.text = viewModel.task?.name
            progressLabel.text = "Progress: " + String(viewModel.task?.persentsOfCompletion ?? 0) + "%"
            progressSlider.value = Float(viewModel.task?.persentsOfCompletion ?? 0)
            dueDatePicker.date = viewModel.task?.dueDate ?? Date()
            if let task = viewModel.task {
                let state = task.currentState
                stateSegmentedControl.selectedSegmentIndex = TMTaskState.allValues.index(of: state) ?? 0
            } else {
                stateSegmentedControl.selectedSegmentIndex = 0
            }
        }
    }
    
    private func customizeNavigationBar() {
        if viewModel.mode == .CreateNew {
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPressed))
            navigationItem.rightBarButtonItem = barButtonItem
        } else {
            let barButtonItemSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPressed))
            let barButtonItemDelete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonPressed))
            navigationItem.rightBarButtonItems = [barButtonItemDelete, barButtonItemSave]
        }
    }
    
    private func validateFields() -> (Bool, String) {
        guard let name = nameTextField.text, !name.isEmpty else {
            return (false, "Please enter task's name")
        }
        
        // Other fields are supposed to be always valid
        return (true, "Validation Success")
    }
    
    private func showSimpleAlert(withTitle title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func saveButtonPressed() {
        let fieldsValidationResult = validateFields()
        if fieldsValidationResult.0 {
            if viewModel.saveTask(withName: nameTextField.text!,
                                 status: TMTaskState.allValues[stateSegmentedControl.selectedSegmentIndex],
                                 progress: Int(progressSlider.value),
                                 dueDate: dueDatePicker.date) {
                let _ = navigationController?.popViewController(animated: true)
            } else {
                showSimpleAlert(withTitle: "Error", message: "Error during saving task")
            }
        } else {
           showSimpleAlert(withTitle: "Error", message: fieldsValidationResult.1)
        }
    }
    
    func deleteButtonPressed() {
        if viewModel.deleteTask() {
            let _ = navigationController?.popViewController(animated: true)
        } else {
            showSimpleAlert(withTitle: "Error", message: "Error during deleting task")
        }
    }
}
