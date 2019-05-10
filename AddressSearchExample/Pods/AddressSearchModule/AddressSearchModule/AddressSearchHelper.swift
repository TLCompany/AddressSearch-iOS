//
//  AddressSearchHelper.swift
//  tls_address
//
//  Created by Justin Ji on 30/04/2019.
//  Copyright © 2019 tlsolution. All rights reserved.
//

import UIKit
import Alamofire

/// 주소 검색을 위한 Helper
public final class AddressSearchHelper: NSObject {
    
    static let TAG = "AddressSearchHelper"
    /// 주소 검색 화면을 띄어줄 View Controller
    public var viewController: UIViewController?
    /// 한번 검색에 최대 몇 개의 결과값(max=100)
    public var countPerPage: Int = 100
    /// 한국지역개발원에서 발행하는 주소 검색 API Key
    public var confmKey: String? = nil
    
    /// 주소 검색 + 상세주소 입력 후 데이터를 받을 delegate
    public weak var delegate: AddressSearchHelperDelegate?
    
    private var isConfmKeyValid = false
    
    /// 주소 검색을 시작한다.
    public func startSearchingAddress(completionHandler completion: @escaping (AddrsError?) -> Void) {
        
        guard let confmKey = self.confmKey else {
            print("😱 confmKey is nil.")
            completion(.apiError(errorCode: .invalidConfmKey))
            return
        }
        
        guard let viewController = self.viewController else {
            print("😱 viewController is nil.")
            completion(.noViewController)
            return
        }
        
        testConfmKey(confmKey) { (isValid) in
            if isValid {
                print("😀 주소검색을 위한 모든 세팅이 완료되었습니다.")
                let bundle = Bundle(for: AddressListViewController.self)
                guard let addressSearchVC = UIStoryboard(name: "Address", bundle: bundle).instantiateViewController(withIdentifier: "AddressSearchViewController") as? AddressListViewController else {
                    print("😱 AddressListViewController cannot be instantiated.")
                    return
                }
                addressSearchVC.delegate = self.delegate
                addressSearchVC.countPerPage = self.countPerPage
                addressSearchVC.confmKey = confmKey
                let navCtrler = UINavigationController(rootViewController: addressSearchVC)
                viewController.present(navCtrler, animated: true) { completion(nil) }
            } else {
                
            }
        }
    
    }
    
    /// confmKey가 유효한지 아닌지 API Request를 해봐서 테스트 하는 함수
    private func testConfmKey(_ confmKey: String, completionHandler completion: @escaping (Bool) -> Void) {
        guard !isConfmKeyValid else { completion(true); return }
        let urlString = "http://www.juso.go.kr/addrlink/addrLinkApiJsonp.do"
        let keyword = "롯데타워"
        guard let url = URL(string: urlString) else { print("😭 url is not valid"); return }
        
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
                    
                    AddressSearchHelper.processData(data, completionHandler: { (receivedAddress, addrsError) in
                        if let error = addrsError {
                            switch error {
                            case .apiError(errorCode: let code):
                                if code == .invalidConfmKey {
                                    completion(false)
                                    self.isConfmKeyValid = false
                                    return
                                }
                            default: return
                            }
                            return
                        }
                        self.isConfmKeyValid = true
                        completion(true)
                    })
                })
            case .failure(let err):
                print(err.localizedDescription)
                self.isConfmKeyValid = false
                completion(false)
            }
        }
    }
    
    
    /// 한국지역정보 개발원에서 받은 주소 검색 결과값을 JSON형태로 변환하고 Address데이터 모델로 처리하는 함수
    static func processData(_ data: Data, completionHandler completion: ([Address]?, AddrsError?) -> Void) {
        NSLog(TAG, "😎 데이터 프로세싱을 시작합니다.")
        let jsonStr = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        guard let refinedData = jsonStr?.data(using: .utf8) else { return }
        guard let initialJson = try? JSONSerialization.jsonObject(with: refinedData, options: .mutableContainers) as? [String: Any] else {
            completion(nil, .jsonParsing(message: "😭 initialJson cannot be serialised..."))
            print("😭 initial json KOV cannot be json-serialised. There must be something wrong with dealing with string data received from the API server.")
            return
        }
        
        guard let resultJson = initialJson["results"] as? [String: Any] else {
            completion(nil, .jsonParsing(message: "😭 resultJson cannot be serialised..."))
            return
        }
        
        if let commonJson = resultJson["common"] as? [String: Any],
            let errorCode = commonJson["errorCode"] as? String,
            errorCode != "0" {
            
            guard let apiErrCode = APIError(rawValue: errorCode) else {
                NSLog(TAG, "😭 APIError를 생성할 수 없습니다...")
                return
            }
            completion(nil, .apiError(errorCode: apiErrCode))
            return
        }
        
        guard let jusoJson = resultJson["juso"] as? [[String: Any]] else {
            completion(nil, .jsonParsing(message: "😭 jusoJson cannot be serialised..."))
            return
        }
        
        var addresses = [Address]()
        jusoJson.forEach {
            if let address = Address(json: $0) {
                addresses.append(address)
            }
        }
        
        completion(addresses, nil)
    }
}

/// 주소검색시에 밣생하는 전체적인 Error
///
/// - jsonParsing: API에서 받은 데이터를 JSON으로 변환할때 생기는 Error
/// - noViewController: AddressSearchHelper의 viewController가 nil일 때
/// - apiError: 한국지역정보 개발원 API에서 보내주는 ErrorCode
public enum AddrsError {
    case jsonParsing(message: String)
    case noViewController
    case apiError(errorCode: APIError)
}

/// 한국지역정보 개발원 API에서 보내주는 ErrorCode
public enum APIError: String {
    case ok = "0"
    case sysErr = "-999"
    case invalidConfmKey = "E0001"
    case noKeyword = "E0005"
    case noDetailAddrs = "E0006"
    case noSignleKeyword = "E0008"
    case noOnlyNumbers = "E0009"
    case noMoreThan80words = "E0010"
    case noMoreThan10NumComb = "E0011"
    case noCombNumAndSpeicalChars = "E0012"
    
    var message: String {
        switch self {
        case .ok: return "정상"
        case .sysErr: return "시스템에러"
        case .invalidConfmKey: return "승인되지 않은 KEY 입니다."
        case .noKeyword: return "검색어가 입력되지 않았습니다."
        case .noDetailAddrs: return "주소를 상세히 입력해 주시기 바랍니다."
        case .noSignleKeyword: return "검색어는 두글자 이상 입력되어야 합니다."
        case .noOnlyNumbers: return "검색어는 문자와 숫자 같이 입력되어야 합니다."
        case .noMoreThan80words: return "검색어가 너무 깁니다. (한글40자, 영문,숫자 80자 이하)"
        case .noMoreThan10NumComb: return "검색어에 너무 긴 숫자가 포함되어 있습니다. (숫자10자 이하)"
        case .noCombNumAndSpeicalChars: return "특수문자+숫자만으로는 검색이 불가능 합니다."
        }
    }
}

public protocol AddressSearchHelperDelegate: class {
    
    /// 주소 검색과 상세주소 입력이 완료 된 후의 Address를 보내준다.
    func didFinishSearchingAddress(_ address: Address?)
}
