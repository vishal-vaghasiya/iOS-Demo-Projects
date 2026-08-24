//
//  SignatureViewModel.swift
//  PDF Drawer
//
//  Created by Salah Khaled on 20/06/2024.
//

import Foundation

class SignatureViewModel {
    
    private var signatureList: [String] = []
    
    var didFillSignatureHandler: (() -> Void)?
    
    func getSignatueCount() -> Int {
        return signatureList.count
    }
    
    func getSignatureAt(index: Int) -> String {
        return signatureList[index]
    }
    
}

// MARK: - Signature
extension SignatureViewModel {
    
    func fillSignature() {
        signatureList.append("signature1".localize())
        signatureList.append("signature2".localize())
        signatureList.append("signature3".localize())
        
        didFillSignatureHandler?()
    }
}

