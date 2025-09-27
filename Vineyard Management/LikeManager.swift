import Foundation
import SwiftUI

class LikeManager: ObservableObject {
    @Published var likedContainers: Set<Int> = []
    
    private let userDefaults = UserDefaults.standard
    private let likedContainersKey = "LikedContainers"
    
    init() {
        loadLikedContainers()
    }
    
    func toggleLike(for containerID: Int) {
        if likedContainers.contains(containerID) {
            likedContainers.remove(containerID)
        } else {
            likedContainers.insert(containerID)
        }
        saveLikedContainers()
    }
    
    func isLiked(_ containerID: Int) -> Bool {
        return likedContainers.contains(containerID)
    }
    
    func getLikedContainers(from containers: [Container]) -> [Container] {
        return containers.filter { likedContainers.contains($0.id) }
    }
    
    private func saveLikedContainers() {
        let likedArray = Array(likedContainers)
        userDefaults.set(likedArray, forKey: likedContainersKey)
    }
    
    private func loadLikedContainers() {
        if let likedArray = userDefaults.array(forKey: likedContainersKey) as? [Int] {
            likedContainers = Set(likedArray)
        }
    }
    
    func clearAllLikes() {
        likedContainers.removeAll()
        saveLikedContainers()
    }
    
    var likedCount: Int {
        return likedContainers.count
    }
}