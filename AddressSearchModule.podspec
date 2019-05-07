Pod::Spec.new do |spec|

spec.name         = "AddressSearchModule"
spec.version      = "1.0.2"
spec.summary      = "대한민국 주소 검색 iOS Library"
spec.description  = "대한민국의 주소(번지, 도로명 또는 영어)를 검색할 수 있는 iOS Library입니다."
spec.homepage     = "https://github.com/TLCompany/AddressSearch-iOS"
spec.license      = "MIT"

spec.author       = { "Justin Ji" => "jjeui0308@gmail.com" }
spec.platform     = :ios, "11.0"
spec.source       = { :git =>"https://github.com/TLCompany/AddressSearch-iOS.git", :tag => "1.0.2" }
spec.swift_version = '5.0'
spec.source_files  = "AddressSearchModule"
spec.dependency 'Alamofire'
spec.dependency 'Toast-Swift'
end
