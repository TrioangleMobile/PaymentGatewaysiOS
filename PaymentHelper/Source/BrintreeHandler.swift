//
//  BrianTreeHandler.swift
//  Gofer
//
//  Created by trioangle on 22/11/19.
//  Copyright © 2019 Trioangle Technologies. All rights reserved.
//

import Foundation
import Braintree
import BraintreeDropIn


public
enum BTErrors : Error{
    case clientNotInitialized
    case clientCancelled
}

public
extension BTErrors : LocalizedError {
    open
    var errorDescription: String?{
        return self.localizedDescription
    }
}

public
protocol BrainTreeProtocol {
    open func initalizeClient(with id : String)
    open func authenticatePaymentUsing(_ view : UIViewController,
                                  for amount : Double,
                                  result: @escaping BrainTreeHandler.BTResult)
    open func authenticatePaypalUsing(_ view : UIViewController,
                                  for amount : Double,
                                  currency: String,
                                  result: @escaping BrainTreeHandler.BTResult)
}

public
class BrainTreeHandler : NSObject{
    static var ReturnURL  : String  {
        let bundle = Bundle.main
        return bundle.bundleIdentifier ?? "comg.trioangle.gofer"
    }
    open
    class func isBrainTreeHandleURL(_ url: URL,
                                    options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool{
        if url.scheme?
            .localizedCaseInsensitiveCompare(BrainTreeHandler.ReturnURL) == .orderedSame {
            return BTAppContextSwitcher.handleOpenURL(url)
        }
        return false
    }
    typealias BTResult = (Result<BTPaymentMethodNonce, Error>) -> Void
    static var `default` : BrainTreeProtocol = {
        BrainTreeHandler()
    }()
    
    var client : BTAPIClient?
    var hostView : UIViewController?
    var result : BTResult?
    var clientToken : String?
    private override init(){
        super.init()
        
    }
    
}

//MARK:- BrainTreeProtocol
extension BrainTreeHandler : BrainTreeProtocol{
    
    open
    func initalizeClient(with id : String){
        
        self.clientToken = id
        self.client = BTAPIClient(authorization: id)
        BTAppContextSwitcher.setReturnURLScheme(BrainTreeHandler.ReturnURL)
    }
    
    open
    func authenticatePaypalUsing(_ view: UIViewController,
                                  for amount: Double,
                                  currency: String,
                                  result: @escaping BrainTreeHandler.BTResult) {
        guard let currentClient = self.client else{
            result(.failure(BTErrors.clientNotInitialized))
            return
        }
        self.hostView = view
        self.result = result
        let paypalDriver = BTPayPalDriver(apiClient: currentClient)
        let request = BTPayPalCheckoutRequest(amount: amount.description)
        request.currencyCode = currency
        paypalDriver.tokenizePayPalAccount(with: request) { (payPalAccountNonce, error) in
            guard let paypaNonce = payPalAccountNonce else{
                result(.failure(error ?? BTErrors.clientCancelled))
                return
            }
            print(paypaNonce.email ?? "")
            print(paypaNonce.firstName ?? "")
            print(paypaNonce.nonce)
            result(.success(paypaNonce))
        }
    }
    
    open
    func authenticatePaymentUsing(_ view : UIViewController,
                                  for amount : Double,
                  result: @escaping BTResult) {
        guard let currentClientToken = self.clientToken else{
            result(.failure(BTErrors.clientNotInitialized))
            return
        }
        self.hostView = view
        self.result = result
        
        
        _ = BTDropInRequest()
        let threeDSecureRequest = BTThreeDSecureRequest()
        threeDSecureRequest.amount = NSDecimalNumber(value: amount)
        threeDSecureRequest.email = UserDefaults.value(for: .user_email_id) ?? "test@email.com"
        threeDSecureRequest.versionRequested = .version2
        
        let address = BTThreeDSecurePostalAddress()
        address.givenName = UserDefaults.value(for: .first_name) ?? "Albin" // ASCII-printable characters required, else will throw a validation error
        address.surname = UserDefaults.value(for: .last_name) ?? "MrngStar" // ASCII-printable characters required, else will throw a validation error
        address.phoneNumber = UserDefaults.value(for: .phonenumber) ?? "123456"
    
       
        threeDSecureRequest.billingAddress = address
        
        // Optional additional information.
        // For best results, provide as many of these elements as possible.
        let info = BTThreeDSecureAdditionalInformation()
        info.shippingAddress = address
        threeDSecureRequest.additionalInformation = info
        
        let dropInRequest = BTDropInRequest()
        dropInRequest.threeDSecureRequest = threeDSecureRequest
        
        let _dropIn = BTDropInController(authorization: currentClientToken,
                                         request: dropInRequest) { (controller, result, error) in
            if let btError = error {
                // Handle error
                
                self.result?(.failure(btError))
                self.dismissPresentedView()
            } else if (result?.isCanceled == true) {
                // Handle user cancelled flow
                
                self.result?(.failure(BTErrors.clientCancelled))
                self.dismissPresentedView()
            } else if let nonce = result?.paymentMethod{
                self.result?(.success(nonce))
                // Use the nonce returned in `result.paymentMethod`
            }
            
            controller.presentedViewController?.dismiss(animated: true,
                                                        completion: nil)
            controller.dismiss(animated: true,
                               completion: nil)
        }
        guard let dropIn = _dropIn else{return}
        view.present(dropIn, animated: true,
                     completion: nil)
    }
}
//MARK:- BTDropInViewControllerDelegate
extension BrainTreeHandler : BTDropInControllerDelegate{
    open
    func reloadDropInData() {
        
    }
    
    open
    func editPaymentMethods(_ sender: Any) {
        
    }
    
    open
    func drop(_ viewController: BTDropInController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        viewController.presentedViewController?.dismiss(animated: true,
                                                        completion: nil)
        self.result?(.success(paymentMethodNonce))
        self.dismissPresentedView()
    }
    
    open
    func drop(inViewControllerDidCancel viewController: BTDropInController) {
        viewController.presentedViewController?.dismiss(animated: true,
                                                        completion: nil)
        self.result?(.failure(BTErrors.clientCancelled))
        self.dismissPresentedView()
    }
    
    
}
//MARK:- UDF
extension BrainTreeHandler {
    
    @objc
    func userDidCancelPayment() {
        self.result?(.failure(BTErrors.clientCancelled))
        self.dismissPresentedView()
    }
    
    open
    func dismissPresentedView(){
        self.hostView?.dismiss(animated: true,
                               completion: nil)
    }
}

extension BrainTreeHandler : BTViewControllerPresentingDelegate{
    
    open
    func paymentDriver(_ driver: Any,
                       requestsPresentationOf viewController: UIViewController) {
        
    }
    
    open
    func paymentDriver(_ driver: Any,
                       requestsDismissalOf viewController: UIViewController) {
        
    }
    
    
}
