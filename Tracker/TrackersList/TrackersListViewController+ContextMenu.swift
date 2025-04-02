//
//  TrackersListViewController+ContextMenu.swift
//  Tracker
//
//  Created by Анна Рыкунова on 31.03.2025.
//

import UIKit

extension TrackersListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            self.makeContextMenu(for: indexPath)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionCell else {
            return nil
        }
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: cell.cellView.bounds, cornerRadius: cell.cellView.layer.cornerRadius)
        return UITargetedPreview(view: cell.cellView, parameters: parameters)
    }
    
    private func makeContextMenu(for indexPath: IndexPath) -> UIMenu {
        guard let tracker = collectionHelper?.object(at: indexPath)
        else { return UIMenu() }
        let pinMessage = !tracker.isPinned ? NSLocalizedString("trackers.context_menu.pin", comment: "") : NSLocalizedString("trackers.context_menu.unpin", comment: "")
        let pinAction = UIAction(
            title: pinMessage) { _ in
                self.pinItem(at: indexPath)
                self.updateCollection()
            }
        let editAction = UIAction(
            title: NSLocalizedString("trackers.context_menu.edit", comment: "")) { _ in
                self.editItem(at: indexPath)
            }
        let deleteAction = UIAction(
            title: NSLocalizedString("trackers.context_menu.delete", comment: ""),
            attributes: .destructive
        ) { _ in
            self.deleteItem(at: indexPath)
        }
        return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
    }
    
    private func pinItem(at indexPath: IndexPath) {
        guard let tracker = collectionHelper?.object(at: indexPath)
        else { return }
        collectionHelper?.togglePinned(id: tracker.id)
        updateCollection()
    }
    
    private func deleteItem(at indexPath: IndexPath) {
        guard let tracker = collectionHelper?.object(at: indexPath) else { return }
        self.showDeleteAlert(for: tracker.id)
    }
    
    private func showDeleteAlert(for id: UUID) {
        let alertController = UIAlertController(
            title: NSLocalizedString("delete.alert.title", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("delete.alert.action.delete", comment: ""),
            style: .destructive
        ) { _ in self.collectionHelper?.delete(id: id) }
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("delete.alert.action.cancel", comment: ""),
            style: .cancel,
            handler: nil
        )
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        if let topViewController = UIApplication.shared.windows.first?.rootViewController {
            topViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func editItem(at indexPath: IndexPath) {
        guard let tracker = collectionHelper?.object(at: indexPath)
        else {
            print("failed to find item at \(indexPath.row)")
            return
        }
        let category = trackerStore.categoryFor(trackerID: tracker.id)
        let count = trackerRecordStore.findRecordsBy(trackerId: tracker.id).count
        let updateTrackerViewController = NewHabitController(habitType: tracker.isHabit ? .habit : .event, category: category, recordsCount: count, tracker: tracker)
        updateTrackerViewController.delegate = self
        updateTrackerViewController.modalPresentationStyle = .pageSheet
        present(updateTrackerViewController, animated: true, completion: nil)
    }
}
