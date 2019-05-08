//
//  AddressSearchHelper.swift
//  tls_address
//
//  Created by Justin Ji on 30/04/2019.
//  Copyright © 2019 tlsolution. All rights reserved.
//

import UIKit

/// 주소 검색을 위한 Helper
public final class AddressSearchHelper: NSObject {
    
    /// 주소 검색 화면을 띄어줄 View Controller
    public var viewController: UIViewController?
    /// 한번 검색에 최대 몇 개의 결과값(max=100)
    public var countPerPage: Int = 100
    /// 한국지역개발원에서 발행하는 주소 검색 API Key
    public var confmKey: String? = nil
    
    /// 주소 검색 + 상세주소 입력 후 데이터를 받을 delegate
    public weak var delegate: AddressSearchHelperDelegate?
    
    /// 주소 검색을 시작한다.
    public func startSearchingAddress() {
        guard let confmKey = self.confmKey else {
            print("😱 confmKey is nil.")
            return
        }
        
        guard let viewController = self.viewController else {
            print("😱 viewController is nil.")
            return
        }
        
        let bundle = Bundle(for: AddressListViewController.self)
        guard let addressSearchVC = UIStoryboard(name: "Address", bundle: bundle).instantiateViewController(withIdentifier: "AddressSearchViewController") as? AddressListViewController else {
            print("😱 AddressListViewController cannot be instantiated.")
            return
        }
        addressSearchVC.delegate = self.delegate
        addressSearchVC.countPerPage = self.countPerPage
        addressSearchVC.confmKey = confmKey
        let navCtrler = UINavigationController(rootViewController: addressSearchVC)
        viewController.present(navCtrler, animated: true, completion: nil)
    }
}

public protocol AddressSearchHelperDelegate: class {
    
    /// 주소 검색과 상세주소 입력이 완료 된 후의 Address를 보내준다.
    func didFinishSearchingAddress(_ address: Address?)
}
