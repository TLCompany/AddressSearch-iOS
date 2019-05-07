//
//  AddDetailViewController.swift
//  tls_address
//
//  Created by Justin Ji on 30/04/2019.
//  Copyright © 2019 tlsolution. All rights reserved.
//

import UIKit

class AddressDetailViewController: UIViewController {
    
    public var address: Address?
    public weak var delegate: AddressSearchHelperDelegate?
    
    @IBAction private func touchBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func touchComplete(_ sender: Any) {
        let detail = detailTextField.text
        address?.detail = detail
        dismiss(animated: true) {
            self.delegate?.didFinishSearchingAddress(self.address)
        }
    }
    
    @IBOutlet private weak var jibunAddrsLabel: UILabel!
    @IBOutlet private weak var rdAddrsLabel: UILabel!
    @IBOutlet private weak var zipCodeLabel: UILabel!
    @IBOutlet private weak var detailTextField: UITextField!
    @IBOutlet private weak var completeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        completeButton.layer.cornerRadius = 5.0
        displayAddressInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        detailTextField.becomeFirstResponder()
    }
    
    /// AddressSearchViewController에서 선택된 Address를 화면에 보여준다
    private func displayAddressInfo() {
        guard let address = self.address else {
            print("😭 address is nil")
            return
        }
        
        
        jibunAddrsLabel.text = address.jbAddrs
        rdAddrsLabel.text = address.rdAddrs
        zipCodeLabel.text = "우편번호: \(address.zipCode)"
    }
}
