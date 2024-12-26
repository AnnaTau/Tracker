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
        switch self.sections[section] {
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
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "colorCell", for: indexPath
            ) as? ColorCell else {
                return UICollectionViewCell()
            }
            let color = CollectionData.colors[indexPath.item]
            cell.configure(with: color)
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections.count
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
            headerView.translatesAutoresizingMaskIntoConstraints = false
            let label = UILabel(frame: headerView.bounds)
            label.translatesAutoresizingMaskIntoConstraints = false
            switch self.sections[indexPath.section] {
            case .colors:
                label.text = "Color"
            case .emojis: 
                label.text = "Emoji"
            }

            label.textAlignment = .left
            label.textColor = .ypBlack
            label.font = UIFont.boldSystemFont(ofSize: 19)
            headerView.addSubview(label)
            
            NSLayoutConstraint.activate([
                headerView.heightAnchor.constraint(equalToConstant: 18),
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
                label.topAnchor.constraint(equalTo: headerView.topAnchor)
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
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}
