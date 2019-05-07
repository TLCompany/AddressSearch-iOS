//
//  ViewController.swift
//  tls_address
//
//  Created by Justin Ji on 30/04/2019.
//  Copyright © 2019 tlsolution. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift

/// 주소 검색 결과의 리스트를 보여주는 controller
class AddressListViewController: UIViewController {
    
    private let urlString = "http://www.juso.go.kr/addrlink/addrLinkApiJsonp.do"
    private let feedbackGenerator = UIImpactFeedbackGenerator()
    public var confmKey: String = ""
    public var countPerPage: Int = 0
    public weak var delegate: AddressSearchHelperDelegate?
    
    @IBAction func touchDismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func touchSearch(_ sender: UIButton) {
        search()
    }
    
    private func search() {
        guard let url = URL(string: urlString) else { print("😭 url is not valid"); return }
        guard let keyword = searchTextField.text, !keyword.isEmpty else { self.view.makeToast("검색어를 입력해 주세요."); return }
        guard let kData = keyword.data(using: .utf8), let cfkData = confmKey.data(using: .utf8), let jData = "json".data(using: .utf8) else { return }
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(kData, withName: "keyword")
            multipartFormData.append(cfkData, withName: "confmKey")
            multipartFormData.append(jData, withName: "resultType")
            multipartFormData.append("1".data(using: .utf8)!, withName: "currentPage")
            multipartFormData.append("\(self.countPerPage)".data(using: .utf8)!, withName: "countPerPage")
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: nil) { (result) in
            switch result {
            case .success(let request, _, _):
                request.responseJSON(completionHandler: { (response) in
                    
                    guard let data = response.data else { return }
                    self.processData(data)
                })
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    private func processData(_ data: Data) {
        feedbackGenerator.impactOccurred()
        self.addresses.removeAll()
        let jsonStr = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        guard let refinedData = jsonStr?.data(using: .utf8) else { return }
        guard let initialJson = try? JSONSerialization.jsonObject(with: refinedData, options: .mutableContainers) as? [String: Any] else {
            print("😭 initial json KOV cannot be json-serialised. There must be something wrong with dealing with string data received from the API server.")
            return
        }
        
        guard let resultJson = initialJson["results"] as? [String: Any] else {
            print("😭 the values of results is missing")
            return
        }
        
        guard let jusoArray = resultJson["juso"] as? [[String: Any]] else {
            
            DispatchQueue.main.async {
                self.totalResultLabel.text = "검색결과 없음"
                self.addrsListTableView.reloadData()
            }
            return
        }
        
        jusoArray.forEach {
            if let address = Address(json: $0) {
                addresses.append(address)
            }
        }
        
        DispatchQueue.main.async {
            self.addrsListTableView.reloadData()
            self.totalResultLabel.text = "검색결과(\(self.addresses.count)건)"
        }
    }
    
    @IBOutlet private weak var providerButton: UIButton!
    @IBOutlet private weak var logoButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var addrsListTableView: UITableView!
    @IBOutlet private weak var totalResultLabel: UILabel!
    
    @IBAction func touchTLLogo(_ sender: UIButton) {
        guard let tlWebURL = URL(string: "http://www.tlsolution.co.kr") else { return }
        if UIApplication.shared.canOpenURL(tlWebURL) {
            UIApplication.shared.open(tlWebURL, options: [:], completionHandler: nil)
        }
    }
    @IBAction func touchProvidersLogo(_ sender: Any) {
        guard let tlWebURL = URL(string: "https://www.juso.go.kr/addrlink/getDevEventBoardMainList.do") else { return }
        if UIApplication.shared.canOpenURL(tlWebURL) {
            UIApplication.shared.open(tlWebURL, options: [:], completionHandler: nil)
        }
    }
    
    fileprivate var addresses = [Address]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addrsListTableView.tableFooterView = UIView()
        addrsListTableView.tableFooterView?.isHidden = true
        searchButton.layer.cornerRadius = 5.0
        logoButton.layer.cornerRadius = 5.0
        logoButton.layer.masksToBounds = true
        searchTextField.delegate = self
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchTextField.becomeFirstResponder()
    }
}

extension AddressListViewController: UITableViewDelegate,  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let itemCell = tableView.dequeueReusableCell(withIdentifier: AddressListItemCell.id, for: indexPath) as? AddressListItemCell else {
            fatalError("AddressResultItemCell cannot be utilised")
        }
        
        itemCell.address = addresses[indexPath.row]
        
        return itemCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        
        let bundle = Bundle(for: AddressDetailViewController.self)
        guard let addDetailVC = UIStoryboard(name: "Address", bundle: bundle).instantiateViewController(withIdentifier: "AddressDetailViewController") as? AddressDetailViewController else { return }
        
//        guard let addDetailVC = UIStoryboard(name: "Address", bundle: nil).instantiateViewController(withIdentifier: "AddDetailViewController") as? AddressDetailViewController else { return }
        addDetailVC.delegate = self.delegate
        addDetailVC.address = addresses[indexPath.row]
        navigationController?.pushViewController(addDetailVC, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    
    
}

extension AddressListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        
        return true
    }
}

























