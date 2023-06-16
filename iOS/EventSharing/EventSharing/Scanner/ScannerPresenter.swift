//
//  ScannerPresenter.swift
//  EventSharing
//
//  Created by certimeter on 05/05/23.
//

import Foundation
import AVFoundation
import UIKit

final class ScannerPresenter: ScannerViewControllerDelegate {
    
    func startScanner() -> ScannerViewController {
        let scannerViewController = ScannerViewController()
        scannerViewController.delegate = self
        scannerViewController.captureSession = AVCaptureSession()
        return scannerViewController
    }
    
    func presentAlert(_ viewController: ScannerViewController, title: String) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let attributedString = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 20) ?? UIFont.systemFont(ofSize: 22.0, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ])
        alert.setValue(attributedString, forKey: "attributedTitle")
        alert.addAction(UIAlertAction(title: "Ok", style: .default){
            (action: UIAlertAction) in
            alert.dismiss(animated: true)
            if !viewController.captureSession.isRunning {
                viewController.captureSession.startRunning()
            }
        })
        viewController.present(alert, animated: true)
    }
    
    func showInfo(_ viewController: ScannerViewController, _ scanResult: String) {
        guard let scan = Int(scanResult) else {
            presentAlert(viewController, title: "Event not found")
            return
        }
        guard let homeViewController = PresenterManager.homePresenter?.getHomeViewController() else { return }
        
        if PresenterManager.homePresenter?.takeEvent(scan) == nil {
            PresenterManager.eventPresenter?.eventService.getEvent(scan) { event in
                guard let event = event else {
                    self.presentAlert(viewController, title: "Event not found")
                    return
                }
                PresenterManager.mainPresenter?.presentInfoEvent(homeViewController, event: event, viewController)
            }
        } else {
            guard let event = PresenterManager.homePresenter?.takeEvent(scan) else {
                self.presentAlert(viewController, title: "Event not found")
                return
            }
            PresenterManager.mainPresenter?.presentInfoEvent(homeViewController, event: event, viewController)
        }
    }
}
