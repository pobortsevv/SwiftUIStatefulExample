//
//  FixedTextField.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 20.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import  UIKit

final class CustomTextField: UITextField {
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		textFieldRect(forBounds: bounds)
	}
	
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		textFieldRect(forBounds: bounds)
	}
	
	private func textFieldRect(forBounds bounds: CGRect) -> CGRect {
		let width = bounds.width - 16 - 16
		
		return CGRect(x: 16, y: 0, width: width, height: bounds.height)
	}
}

