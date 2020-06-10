//
//  Protocols.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 19/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//


protocol UserProfileHeaderDelegate {
    func handleEditFollowTapped(for header: UserProfileHeader)
    func setUserStats(for header: UserProfileHeader)
    func handleFollowersTapped(for header: UserProfileHeader)
    func handleFollowingTapped(for header: UserProfileHeader)
}
protocol FeedCellDelegate {
    func handleUsernameTapped(for cell: FeedCell)
    func handleOptionsTapped(for cell: FeedCell)
    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool)
    func handleCommentTapped(for cell: FeedCell)
    func handleConfigureLikeButton(for cell: FeedCell)
    func handleConfigureSaveButton(for cell: FeedCell)
    func handleShowLikes(for cell: FeedCell)
    func configureCommentIndicatorView(for cell: FeedCell)
    func handleDetailTapped(for cell: FeedCell)
    func handleSaveTapped(for cell: FeedCell, isDoubleTap: Bool)
}

protocol FollowCellDelegate {
    func handleFollowTapped(for cell: FollowLikeCell)
}

protocol NotificationCellDelegate {
    func handleFollowTapped(for cell: NotificationCell)
    func handlePostTapped(for cell: NotificationCell)
}

protocol CommentInputAccesoryViewDelegate {
    func didSubmit(forComment comment: String)
}

protocol Printable {
    var description: String { get }
}
