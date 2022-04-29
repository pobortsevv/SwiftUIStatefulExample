//
//  ValidatorViewController.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 23.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa
import UIKit

final class ValidatorViewController: UIViewController, ValidatorViewControllable {
	@IBOutlet private weak var networkErrorLabel: UILabel!
	@IBOutlet private weak var phoneNumberLabel: UILabel!
	@IBOutlet private weak var codeTextField: UITextField!
	@IBOutlet private weak var codeErrorLabel: UILabel!
	
	// Provider view
	private let loadingIndicatorView = LoadingIndicatorView()
	
	// MARK: View Events
	
	private let viewOutput = ViewOutput()
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		initialSetup()
	}
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		viewOutput.$viewDidDisappear.accept(Void())
	}
}

extension ValidatorViewController {
	private func initialSetup() {
		title = "Подтверждение кода"
		
		codeTextField.layer.cornerRadius = 12
		codeTextField.becomeFirstResponder()
		codeErrorLabel.text = nil
		
		view.addStretchedToBounds(subview: loadingIndicatorView)
		loadingIndicatorView.isVisible = false
	}
}

extension ValidatorViewController: BindableView {
	func getOutput() -> ValidatorViewOutput { viewOutput }
	
	func bindWith(_ input: ValidatorPresenterOutput) {
		disposeBag.insert {
			input.initialLoadingIndicatorVisible.drive(loadingIndicatorView.rx.isVisible,
																								 loadingIndicatorView.indicatorView.rx.isAnimating)
			
			input.code.drive(codeTextField.rx.text)
			input.showNumber.emit(onNext: { [weak self] number in
				guard case self = self else { return }
				self?.phoneNumberLabel.text = number
			})
			
			input.showNetworkError.emit(onNext: { [weak self] error in
				guard let self = self else { return }
				self.networkErrorLabel.text = error != nil ? error : "Введите код из смс, отправленного на номер"
				self.networkErrorLabel.textColor = error != nil ? .red : .lightGray
				if error != nil {
					self.codeTextField.text = nil
				}
			})
			
			input.showValidationError.emit(onNext: { [weak self] error in
				guard let self = self else { return }
				self.codeErrorLabel.isHidden = error != nil ? false : true
				self.codeErrorLabel.text = error
				if error != nil {
					self.codeTextField.text = nil
					self.codeErrorLabel.textColor = .red
				}
			})
			
			codeTextField.rx.text.orEmpty.bind(to: viewOutput.$codeTextChange)
		}
	}
}

extension ValidatorViewController {
	private struct ViewOutput: ValidatorViewOutput {
		@PublishControlEvent var codeTextChange: ControlEvent<String>
		@PublishControlEvent var viewDidDisappear: ControlEvent<Void>
	}
}

extension ValidatorViewController: RibStoryboardInstantiatable {}
