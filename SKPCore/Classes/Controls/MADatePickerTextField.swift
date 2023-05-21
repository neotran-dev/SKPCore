//
//  MADatePickerTextField.swift
//  majica_renew
//
//  Created by Tran Tung Lam on 7/8/20.
//  Copyright © 2020 Tran Tung Lam. All rights reserved.
//

import UIKit

public class MADatePickerTextField: LHBaseTextField {
    
    fileprivate lazy var datePicker: UIDatePicker = {
        let result = UIDatePicker()
        result.locale = Locale.current
        result.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        result.calendar.locale = Locale.current
        result.datePickerMode = .date
        return result
    }()
    
    fileprivate var inittialDate: Date = Date()
    
    public var pickerDate: Date {
        return datePicker.date
    }
    
    public var dateFormat: String = "MM/dd/yyyy"
    
    public var date: Date? {
        get {
            return self.text?.toDate(format: dateFormat)
        }
        set {
            if let value = newValue {
                datePicker.date = value
            } else {
                self.text = ""
            }
        }
    }
    
    public func setup(initialDate: Date, target: Any, cancelSelector: Selector, doneSelector: Selector) {
        self.inputView = datePicker
        self.inittialDate = initialDate
        datePicker.date = initialDate
        let toolbar = UIToolbar.toolbar(with: target, cancelSelector: cancelSelector, doneSelector: doneSelector)
        self.inputAccessoryView = toolbar
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.datePicker.date = self.date ?? inittialDate
    }
}
