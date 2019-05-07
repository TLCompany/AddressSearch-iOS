//
//  AddressSearchHelper.swift
//  tls_address
//
//  Created by Justin Ji on 30/04/2019.
//  Copyright © 2019 tlsolution. All rights reserved.
//

import UIKit

public final class AddressSearchHelper: NSObject {
    
    public var viewController: UIViewController?
    public var countPerPage: Int = 100
    public var confmKey: String? = nil
    
    public weak var delegate: AddressSearchHelperDelegate?
    
    public func startSearchingAddress() {
        
        guard let confmKey = self.confmKey else {
            print("😱 confmKey is missing.")
            return
        }
        
        guard let addressSearchVC = UIStoryboard(name: "Address", bundle: nil).instantiateViewController(withIdentifier: "AddressSearchViewController") as? AddressListViewController else { return }
        addressSearchVC.delegate = self.delegate
        addressSearchVC.countPerPage = self.countPerPage
        addressSearchVC.confmKey = confmKey
        let navCtrler = UINavigationController(rootViewController: addressSearchVC)
        viewController?.present(navCtrler, animated: true, completion: nil)
    }
}

public protocol AddressSearchHelperDelegate: class {
    
    /// 주소 검색과 상세주소 입력이 완료 된 후의 Address를 보내준다.
    func didFinishSearchingAddress(_ address: Address?)
}
