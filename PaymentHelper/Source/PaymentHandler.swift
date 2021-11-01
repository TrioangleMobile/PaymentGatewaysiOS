//
//  File.swift
//  PaymentHelper
//
//  Created by Trioangle on 25/10/21.
//

import Foundation

open class PaymentHandler : NSObject {
    
    public static let shared = PaymentHandler()
    
    public func setStripe(Number: String,
                          amount: Double,
                          cvc: String) {
        print("Number: " + Number)
        print("amount: " + amount.description)
        print("cvc: " + cvc)
    }
    
}