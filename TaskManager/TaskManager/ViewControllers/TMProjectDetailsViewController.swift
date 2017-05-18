//
//  TMProjectDetailsViewController.swift
//  TaskManager
//

import Foundation
import CoreData
import UIKit

class TMProjectDetailsViewController: CoreDataCollectionViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak private var menuBackgroundView: UIView!
    private var menuView: TMTasksSortingView?
    
    var viewModel = TMProjectDetailsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = viewModel.project?.projectName
        
        shouldHideNavigationBarOnScroll = true
        collectionView.allowsMultipleSelection = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(UINib(nibName: TMTaskCell.defaultReuseIdentifier, bundle: nil),
                                forCellWithReuseIdentifier: TMTaskCell.defaultReuseIdentifier)
        
        configureFetchController()
        customizeNavBar()
        customizeMenu()
    }
    
    override func configureFetchController() {
        let fetchRequest = TMTask.fetchRequestFromDefaultContextWithPredicate(predicate: viewModel.predicate(), sortDescriptors: viewModel.sortDescriptor())
        fetchRequest.propertiesToFetch = ["id", "project", "completion", "state", "estimatedTime", "creationDate", "startDate", "dueDate", "name"]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                           managedObjectContext: AppDelegate.sharedDelegate.managedObjectContext,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)
        
        startFetchingData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let targetVC = segue.destination as? TMTaskDetailsViewController {
            targetVC.viewModel.projectId = viewModel.projectId
            if sender == nil {
                // Request to add a new task
                targetVC.viewModel.mode = .CreateNew
            } else if let taskId = sender as? NSNumber {
                // Request to view task details
                targetVC.viewModel.taskId = taskId
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue: segue, sender: sender)
        
        if let targetVC = segue.destination as? TMTaskDetailsViewController {
            targetVC.viewModel.projectId = viewModel.projectId
            if sender == nil {
                // Request to add a new task
                targetVC.viewModel.mode = .CreateNew
            } else if let taskId = sender as? NSNumber {
                // Request to view task details
                targetVC.viewModel.taskId = taskId
            }
        }
    }

    
    private func startFetchingData() {
        fetchLocalData()
        collectionView.reloadData()
    }
    
    private func customizeNavBar() {
        let addTaskButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTaskButtonPressed))
        navigationItem.rightBarButtonItem = addTaskButton
    }
    
    private func customizeMenu() {
        if let menuView = UINib(nibName: TMTasksSortingView.defaultReuseIdentifier, bundle: nil).instantiate(withOwner: nil, options: nil).first as? TMTasksSortingView {
            self.menuView = menuView
            self.menuView?.selectedSorting = viewModel.selectedSorting
            self.menuView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            self.menuView?.frame = menuBackgroundView.bounds
            menuBackgroundView.addSubview(self.menuView!)
        }
        
        menuView?.sortingButtonPressed = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let alertController = UIAlertController(title: "SORT BY", message: "Please select sorting", preferredStyle: .actionSheet)
            
            for sort in TasksSorting.allValues {
                if sort != strongSelf.viewModel.selectedSorting {
                    let action = UIAlertAction(title: sort.rawValue, style: .default, handler: { _ in
                        strongSelf.viewModel.selectedSorting = sort
                    })
                    alertController.addAction(action)
                }
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            alertController.addAction(cancel)
            
            strongSelf.present(alertController, animated: true, completion: nil)
        }
        
        viewModel.selectedSortingChangeCallbak = { [weak self] sorting in
            self?.menuView?.selectedSorting = sorting
            self?.configureFetchController()
        }
    }
    
    func addTaskButtonPressed() {
        performSegue(withIdentifier: TMTaskDetailsViewModel.showFromTasksScreenSegueId, sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchResultController?.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let task = fetchResultController?.object(at: indexPath) as? TMTask {
            performSegue(withIdentifier: TMTaskDetailsViewModel.showFromTasksScreenSegueId, sender: task.id)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TMTaskCell.defaultReuseIdentifier, for: indexPath)
        let task = fetchResultController?.object(at: indexPath)
        if let cell = cell as? TMTaskCell {
            cell.customizeWithTask(task: task as? TMTask)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.cellSize(collectionViewSize: collectionView.frame.size)
    }
    
}
