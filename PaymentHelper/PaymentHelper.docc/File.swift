//
//  File.swift
//  PaymentHelper
//
//  Created by Trioangle on 25/10/21.
//

import Foundation

class PaymentHandler : NSObject {
    
    static let shared = PaymentHandler()
    
    func setStripe(Number: String,
                   amount: Double,
                   cvc: String) {
        print("Number: " + Number)
        print("amount: " + amount.description)
        print("cvc: " + cvc)
    }
    
}
