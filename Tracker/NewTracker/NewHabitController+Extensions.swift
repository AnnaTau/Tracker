//
//  NewHabitController+Extensions.swift
//  Tracker
//
//  Created by Анна Рыкунова on 24.12.2024.
//

import UIKit

extension NewHabitController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch sections[section] {
        case .emojis:
            return CollectionData.emojis.count
        case .colors:
            return CollectionData.colors.count
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "emojiCell", for: indexPath
            ) as? EmojiCell else {
                return UICollectionViewCell()
            }
            let emoji = CollectionData.emojis[indexPath.item]
            cell.configure(with: emoji)
            if emojiIndexPath == indexPath {
                cell.selectCell()
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "colorCell", for: indexPath
            ) as? ColorCell else {
                return UICollectionViewCell()
            }
            let color = CollectionData.colors[indexPath.item]
            cell.configure(with: color)
            if colorIndexPath == indexPath {
                cell.selectCell()
            }
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "emojiAndColorHeader",
                for: indexPath
            )
            let label = UILabel(frame: headerView.bounds)
            switch sections[indexPath.section] {
            case .colors:
                label.text = NSLocalizedString("tracker.color.text", comment: "")
            case .emojis:
                label.text = "Emoji"
            }

            label.textAlignment = .left
            label.textColor = .ypBlack
            label.font = UIFont.boldSystemFont(ofSize: 19)
            headerView.addSubviews([label])
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 28),
                label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
            ])
            
            return headerView
        }
        return UICollectionReusableView()
    }
}

extension NewHabitController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 34)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(
            width: (collectionView.bounds.width - (params.leftOrRightInset * 2) - (params.cellSpacing * (params.itemsInRow - 1)))/params.itemsInRow,
            height: 52
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        params.cellSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: params.topOrBottomInset,
            left: params.leftOrRightInset,
            bottom: params.topOrBottomInset,
            right: params.leftOrRightInset
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        switch sections[indexPath.section] {
        case .emojis:
            guard let emojiIndexPath else { return }
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell
            if emoji != nil {
                let newCell = collectionView.cellForItem(at: emojiIndexPath) as? EmojiCell
                newCell?.clearSelection()
            }
            cell?.selectCell()
            if emojiIndexPath != indexPath {
                let previousEmoji = collectionView.cellForItem(at: emojiIndexPath) as? EmojiCell
                previousEmoji?.clearSelection()
            }
            emoji = CollectionData.emojis[indexPath.row]
            self.emojiIndexPath = indexPath
        case .colors:
            guard let colorIndexPath else { return }
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCell
            if color != nil {
                let newCell = collectionView.cellForItem(at: colorIndexPath) as? ColorCell
                newCell?.clearSelection()
            }
            cell?.selectCell()
            if colorIndexPath != indexPath {
                let previousEmoji = collectionView.cellForItem(at: colorIndexPath) as? ColorCell
                previousEmoji?.clearSelection()
            }
            color = CollectionData.colors[indexPath.row]
            self.colorIndexPath = indexPath
        }
        updateSaveButton()
    }
}
