//
//  Tooling.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import Foundation
import UIKit

public typealias VoidClosure = () -> Void

public protocol Namespace: CaseIterable {}

public protocol IOTransformer: AnyObject {
  associatedtype Input
  associatedtype Output

  func transform(input: Input) -> Output
}

public protocol BindableView: AnyObject {
  associatedtype Input
  associatedtype Output

  func getOutput() -> Output
  func bindWith(_ input: Input)
}

public struct TitledText: Hashable {
  public let title: String
  public let text: String

  public init(title: String, text: String) {
    self.title = title
    self.text = text
  }

  public static func makeEmpty() -> Self {
    .init(title: "", text: "")
  }
}

/// Для случаев, когда для отображения в UI'е нужна модель, дополненная заголовоком или пояснением
public struct TitledOptionalText: Hashable {
  public let title: String
  public let maybeText: String?

  public init(title: String, maybeText: String?) {
    self.title = title
    self.maybeText = maybeText
  }
}

public struct Empty: Hashable, Codable {
  public init() {}
}

/// Generic решение для closured-based инициализации
/// For class instances only. Value-types are not supported
public func configured<T: AnyObject>(object: T, closure: (_ object: T) -> Void) -> T {
  closure(object)
  return object
}

/// Для изменения
public func mutate<T>(value: T, mutation: (inout T) throws -> Void) rethrows -> T {
	var mutableValue = value
	try mutation(&mutableValue)
	return mutableValue
}

public func formatPhone(number: String) -> String {
	var formatedNumber = number
	
	// Добавление постоянной +7 в строку
	formatedNumber.count != 0 ? nil : formatedNumber.insert(contentsOf: "7", at: formatedNumber.startIndex)
	formatedNumber.contains("+") ? nil : formatedNumber.insert(contentsOf: "+", at: formatedNumber.startIndex)
	
	// Добавление пробелов между цифрами
	switch formatedNumber.count {
	case 11...:
		formatedNumber.insert(contentsOf: " ", at: formatedNumber.index(formatedNumber.startIndex, offsetBy: 10))
			fallthrough
	case 9...:
		formatedNumber.insert(contentsOf: " ", at: formatedNumber.index(formatedNumber.startIndex, offsetBy: 8))
			fallthrough
	case 6...:
		formatedNumber.insert(contentsOf: " ", at: formatedNumber.index(formatedNumber.startIndex, offsetBy: 5))
			fallthrough
	case 3...:
		formatedNumber.insert(contentsOf: " ", at: formatedNumber.index(formatedNumber.startIndex, offsetBy: 2))
	default:
		break
	}
	return formatedNumber
}

extension CharacterSet {
	/// "0123456789"
	public static let arabicNumerals = CharacterSet(charactersIn: "0123456789")
}

extension String {
	/// Удалятся все символы (Unicode Scalar'ы) кроме символов из указанного CharacterSet. Например все кроме цифр
	public func removingCharacters(except characterSet: CharacterSet) -> String {
		let scalars = unicodeScalars.filter(characterSet.contains(_:))
		return String(scalars)
	}
	
	/// Удалятся все символы (Unicode Scalar'ы), которые соответствуют указанному CharacterSet.
	/// Например все точки и запятые
	public func removingCharacters(in characterSet: CharacterSet) -> String {
		let scalars = unicodeScalars.filter { !characterSet.contains($0) }
		return String(scalars)
	}
	
	public func compareLenght(with len: Int) -> String {
		if (self.count > len) {
			return String(self.prefix(len))
		}
		return self
	}
	
	/// Функция генерации  sms кода
	public static func randomCode() -> String {
		let len = 5
		let codeChars = "0123456789"
		let code = String((0..<len).compactMap{ _ in codeChars.randomElement() })
		return code
	}
}

extension UITextField {
	static func toolbarInitialSetup(target: Any?, selector: Selector?) -> UIToolbar {
		let toolbar = UIToolbar(frame: CGRect(origin: .zero,
																					size: CGSize(width: UIScreen.main.bounds.width,
																											 height: 50)))

		
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: target, action: selector)
		
		doneButton.tintColor = .green
		toolbar.setItems([flexSpace, doneButton], animated: true)
		toolbar.sizeToFit()
		
		return toolbar
	}
}
