//
//  TMProjectsViewController.swift
//  TaskManager
//

import Foundation
import UIKit
import CoreData

class TMProjectsViewController: CoreDataCollectionViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak private var menuBackgroundView: UIView!
    private var menuView: TMProjectsSortingView?
    
    var viewModel = TMProjectsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Projects"
        shouldHideNavigationBarOnScroll = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(UINib(nibName: TMProjectCell.defaultReuseIdentifier, bundle: nil),
                                forCellWithReuseIdentifier: TMProjectCell.defaultReuseIdentifier)
        
        customizeMenu()
        customizeNavBar()
        configureFetchController()
        
        collectionView.allowsMultipleSelection = viewModel.projectsRemoveWorkflowState != .None
        
        viewModel.projectCreationCallback = { [weak self] completed, errorMessage in
            if !completed {
                let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Change Name", style: .default, handler: { _ in
                    self?.addProjectButtonPressed()
                }))
                alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if viewModel.projectsRemoveWorkflowState == .None {
            // Go to project details page
            performSegue(withIdentifier: TMProjectDetailsViewModel.showFromProjectsScreenSegueId, sender: indexPath)
        } else {
            // Mark project as selected for removal
            if let project = fetchResultController?.object(at: indexPath) as? TMProject {
                viewModel.projectSelectionStateChanged(projectId: project.id, isSelected: true)
                if let cell = collectionView.cellForItem(at: indexPath) as? TMProjectCell {
                    cell.customSelectedFlag = true
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if viewModel.projectsRemoveWorkflowState == .SelectingToRemove {
            if let project = fetchResultController?.object(at: indexPath) as? TMProject {
                viewModel.projectSelectionStateChanged(projectId: project.id, isSelected: false)
                if let cell = collectionView.cellForItem(at: indexPath) as? TMProjectCell {
                    cell.customSelectedFlag = false
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchResultController?.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TMProjectCell.defaultReuseIdentifier, for: indexPath)
        let project = fetchResultController?.object(at: indexPath)
        if let cell = cell as? TMProjectCell {
            cell.customizeWithProject(project: project as? TMProject)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? TMProjectCell, let project = fetchResultController?.object(at: indexPath) as? TMProject {
            if viewModel.projectsIdsToRemove.contains(project.id) {
                cell.customSelectedFlag = true
            } else {
                cell.customSelectedFlag = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.cellSize(collectionViewSize: collectionView.frame.size)
    }
    
    func addProjectButtonPressed() {
        let alertController = UIAlertController(title: "Add New Project", message: "Please enter project's name below", preferredStyle: .alert)
        let submit = UIAlertAction(title: "Create", style: .default) { action in
            if let textField = alertController.textFields?.first,
                let text = textField.text, !text.isEmpty {
            self.viewModel.createNewProjectWithName(name: text)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .default
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Project's name"
            textField.clearButtonMode = .whileEditing
        }
        alertController.addAction(submit)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    func removeProjectsButtonPressed() {
        switch viewModel.projectsRemoveWorkflowState {
        case .None:
            viewModel.projectsRemoveWorkflowState = .SelectingToRemove
            collectionView.allowsMultipleSelection = true
            showPromptMessageForDeletingProjects()
        case .SelectingToRemove:
            viewModel.removeSelectedProjects()
            viewModel.projectsRemoveWorkflowState = .None
        }
    }
    
    private func showPromptMessageForDeletingProjects() {
        let alertController = UIAlertController(title: "Remove Projects", message: "Select projects you want to delete, then press Delete button again", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let targetVC = segue.destination as? TMProjectDetailsViewController,
            let path = sender as? IndexPath,
            let project = fetchResultController?.object(at: path) as? TMProject {
            targetVC.viewModel.projectId = project.id
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue: segue, sender: sender)
        
        if let targetVC = segue.destination as? TMProjectDetailsViewController,
            let path = sender as? IndexPath,
            let project = fetchResultController?.object(at: path) as? TMProject {
            targetVC.viewModel.projectId = project.id
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    override func configureFetchController() {
        let fetchRequest = TMProject.fetchRequestFromDefaultContextWithPredicate(predicate: nil, sortDescriptors: viewModel.sortDescriptor())
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                           managedObjectContext: AppDelegate.sharedDelegate.managedObjectContext,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)
        
        startFetchingData()
    }
    
    private func startFetchingData() {
        fetchLocalData()
        collectionView.reloadData()
    }
    
    private func customizeNavBar() {
        let addProjectButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProjectButtonPressed))
        let removeProjectButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeProjectsButtonPressed))
        navigationItem.rightBarButtonItems = [addProjectButton, removeProjectButton]
    }
    
    private func customizeMenu() {
        if let menuView = UINib(nibName: TMProjectsSortingView.defaultReuseIdentifier, bundle: nil).instantiate(withOwner: nil, options: nil).first as? TMProjectsSortingView {
            self.menuView = menuView
            self.menuView?.selectedSorting = viewModel.selectedSorting
            self.menuView?.selectedRepresentation = viewModel.selectedRepresentation
            self.menuView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            self.menuView?.frame = menuBackgroundView.bounds
            menuBackgroundView.addSubview(self.menuView!)
        }
        
        menuView?.sortingButtonPressed = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let alertController = UIAlertController(title: "SORT BY", message: "Please select sorting", preferredStyle: .actionSheet)
            
            for sort in ProjectsSorting.allValues {
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
        
        menuView?.representationButtonPressed = { [weak self] format in
            guard let strongSelf = self else {
                return
            }
            strongSelf.viewModel.selectedRepresentation = format
        }
        
        viewModel.selectedSortingChangeCallbak = { [weak self] sorting in
            self?.menuView?.selectedSorting = sorting
            self?.configureFetchController()
        }
        
        viewModel.representationChangeCallback = { [weak self] in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
}
