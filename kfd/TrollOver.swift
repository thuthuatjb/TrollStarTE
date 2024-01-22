//
//  TrollOver.swift
//  kfd
//
//  Created by Huy Nguyen on 13/01/2024.
//

import Foundation

func processDirectories() {
    let downloadURL = URL(string: "https://github.com/opa334/TrollStore/releases/download/2.0.9/PersistenceHelper_Embedded")!
    let Embedded = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Embedded")
    let mountDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path.replacingOccurrences(of: "file://", with: "")
    var detectTips = false
    downloadFile(from: downloadURL, to: Embedded) { error in
        UIApplication.shared.dismissAlert(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let error = error {
                print("Error downloading file: \(error)")
                UIApplication.shared.alert(title: "Network Error", body: "Please check your connection to the network")
            } else {
                createFolderAndRedirectR("/var/containers/Bundle/Application/", "\(mountDir)/mounted0")
                if let dirs0 = try? FileManager.default.contentsOfDirectory(atPath: "\(mountDir)/mounted0") {
                    for dir0 in dirs0 {
                        createFolderAndRedirectR("/var/containers/Bundle/Application/\(dir0)", "\(mountDir)/mounted1")
                        if let dirs1 = try? FileManager.default.contentsOfDirectory(atPath: "\(mountDir)/mounted1") {
                            for dir1 in dirs1 {
                                if dir1 == "Tips.app" {
                                    detectTips = true
                                    createFolderAndRedirectR("/var/containers/Bundle/Application/\(dir0)/Tips.app", "\(mountDir)/mounted2")
                                    if let dirs2 = try? FileManager.default.contentsOfDirectory(atPath: "\(mountDir)/mounted2") {
                                        for dir2 in dirs2 {
                                            if dir2 == "Tips" {
                                                let success = kfdOverwrite(from: Embedded.path, to: "\(mountDir)/mounted2/Tips")
                                                if success != 0 {
                                                    UIApplication.shared.alert(title: "Error", body: "Press \"Respring to Apply\" or reboot your device and try again.\nI'd recommend try \"Respring to Apply\" for few times before you reboot!")
                                                }else{
                                                    UIApplication.shared.alert(title: "Successful", body: "Now Press \"Respring to Apply\" then open Tips app and install TrollStore.")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if !detectTips {
                    UIApplication.shared.dialog(title: "Error", body: "Tips app is not installed. Would you like to open the AppStore?", onOK: {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        if let url = URL(string: "https://apps.apple.com/us/app/tips/id1069509450") {
                            UIApplication.shared.open(url)
                        }
                    })
                }
            }
        }
    }
}

func downloadFile(from: URL, to: URL, completion: @escaping (Error?) -> Void) {
    URLSession.shared.downloadTask(with: from) { (tempURL, response, error) in
        if let tempURL = tempURL {
            do {
                try? FileManager.default.removeItem(at: to)
                try FileManager.default.copyItem(at: tempURL, to: to)
                completion(nil)
            } catch {
                completion(error)
            }
        } else {
            completion(error)
        }
    }.resume()
}
