//
//  ViewController.swift
//  AddressSearchExample
//
//  Created by Justin Ji on 10/05/2019.
//  Copyright © 2019 tlsolution. All rights reserved.
//

import UIKit
import AddressSearchModule

class ExampleViewController: UIViewController {

    private var addressSearchHelper: AddressSearchHelper? = nil
    @IBOutlet private weak var bunjiAddrsLabel: UILabel!
    @IBOutlet private weak var roadAddrsLabel: UILabel!
    @IBOutlet private weak var engAddrsLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var zipCodeLabel: UILabel!
    
    fileprivate var bunjiAddrs: String? {
        get {
            return bunjiAddrsLabel.text
        }
        set {
            bunjiAddrsLabel.text = "번지주소: \(newValue ?? "")"
        }
    }
    
    fileprivate var roadAddrs: String? {
        get {
            return roadAddrsLabel.text
        }
        set {
            roadAddrsLabel.text = "도로명 주소: \(newValue ?? "")"
        }
    }
    
    fileprivate var engAddrs: String? {
        get {
            return engAddrsLabel.text
        }
        set {
            engAddrsLabel.text = "영어 주소: \(newValue ?? "")"
        }
    }
    
    fileprivate var detail: String? {
        get {
            return detailLabel.text
        }
        set {
            detailLabel.text = "상세주소: \(newValue ?? "")"
        }
    }
    
    fileprivate var zipCode: String? {
        get {
            return zipCodeLabel.text
        }
        set {
            zipCodeLabel.text = "우편번호: \(newValue ?? "")"
        }
    }
    
    @IBAction func touchStartSearching(_ sender: UIButton) {
        addressSearchHelper?.startSearchingAddress(completionHandler: { (addrsError) in
            if let error = addrsError {
                switch error {
                case .apiError(errorCode: let apiError):
                    if apiError == .invalidConfmKey {
                        
                    }
                default: return
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressSearchHelper = AddressSearchHelper()
        addressSearchHelper?.viewController = self
        addressSearchHelper?.confmKey = "U01TX0FVVEgyMDE5MDQyODE5NTM0NjEwODY4ODQ="
        addressSearchHelper?.countPerPage = 50
        addressSearchHelper?.delegate = self
    }


}

extension ExampleViewController: AddressSearchHelperDelegate {
    
    func didFinishSearchingAddress(_ address: Address?) {
        guard let addrs = address else { return }
        bunjiAddrs = addrs.jibunAddr
    }
}
