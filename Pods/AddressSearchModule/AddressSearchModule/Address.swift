//
//  Address.swift
//  tls_address
//
//  Created by Justin Ji on 30/04/2019.
//  Copyright © 2019 tlsolution. All rights reserved.
//

import Foundation

public struct Address {
    /// 전체주소(번지)
    let jbAddrs: String
    /// 전체주소(도로명)
    let rdAddrs: String
    /// 전체주소(영어)
    let enAddrs: String
    /// 우편번호
    let zipCode: String
    /// 시 이름
    let siName: String
    /// 시군구 명
    let sggName: String
    /// 읍면동 명
    let emdName: String
    /// 법정리 명
    let liName: String
    /// 도로명
    let rdName: String
    /// 번지
    let bunji: String
    /// 호
    let ho: String
    /// 상세주소(사용자입력)
    var detail: String? = nil
    
    init?(json: [String: Any]) {
        guard let jbAddrs = json["jibunAddr"] as? String else {
            print("jbAddrs JSON 변환 중 에러발생 😭"); return nil
        }
        
        guard let rdAddrsPart1 = json["roadAddrPart1"] as? String else {
            print("rdAddrs JSON 변환 중 에러발생 😭"); return nil
        }
        
        let rdAddrsPart2 = json["roadAddrPart2"] as? String
        
        guard let enAddrs = json["engAddr"] as? String else {
            print("enAddrs JSON 변환 중 에러발생 😭"); return nil
        }
        
        guard let zipCode = json["zipNo"] as? String else {
            print("zipCode JSON 변환 중 에러발생 😭"); return nil
        }
        
        guard let siName = json["siNm"] as? String else {
            print("siName JSON 변환 중 에러발생 😭"); return nil
        }
        
        guard let sggName = json["sggNm"] as? String else {
            print("sggName JSON 변환 중 에러발생 😭"); return nil
        }
        
        guard let emdName = json["emdNm"] as? String else {
            print("emdName JSON 변환 중 에러발생 😭"); return nil
        }
        
        guard let liName = json["liNm"] as? String else {
            print("liName JSON 변환 중 에러발생 😭"); return nil
        }
        guard let rdName = json["rn"] as? String else {
            print("rdName JSON 변환 중 에러발생 😭"); return nil
        }
        guard let bunji = json["lnbrMnnm"] as? String else {
            print("bunji JSON 변환 중 에러발생 😭"); return nil
        }
        guard let ho = json["lnbrSlno"] as? String else {
            print("ho JSON 변환 중 에러발생 😭"); return nil
        }
        
        self.jbAddrs = jbAddrs
        self.rdAddrs = rdAddrsPart1 + (rdAddrsPart2 == nil ? "" : " (\(rdAddrsPart2!.replacingOccurrences(of: " ", with: "")))")
        self.enAddrs = enAddrs
        self.zipCode = zipCode
        self.siName = siName
        self.sggName = sggName
        self.emdName = emdName
        self.liName = liName
        self.rdName = rdName
        self.bunji = bunji
        self.ho = ho
    }
}


































