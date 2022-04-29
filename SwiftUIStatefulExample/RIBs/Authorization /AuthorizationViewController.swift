//
//  AuthorizationViewController.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 12.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa
import UIKit
import NotificationCenter

final class AuthorizationViewController: UIViewController, AuthorizationViewControllable {
	@IBOutlet private weak var phoneNumberTextField: CustomTextField!
	@IBOutlet private weak var getSMSButton: UIButton!
	
	// Notification
	internal var notificationCenter = UNUserNotificationCenter.current()
	
	// Provider views
	private let loadingIndicatorView = LoadingIndicatorView()
	private let errorMessageView = ErrorMessageView()
	
	// MARK: View Events
	
	private let viewOutput = ViewOutput()
	private let disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()
		initialSetup()
	}
}

extension AuthorizationViewController {
	private func initialSetup() {
		title = "Авторизация"
		notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
		notificationCenter.delegate = self
		
		let toolbar = UITextField.toolbarInitialSetup(target: self, selector: #selector(doneButtonTapped))
		
		getSMSButton.layer.cornerRadius = 12
		phoneNumberTextField.layer.cornerRadius = 12
		phoneNumberTextField.becomeFirstResponder()
		
		view.addStretchedToBounds(subview: errorMessageView)
		view.addStretchedToBounds(subview: loadingIndicatorView)
		
		errorMessageView.isVisible = false
	
		phoneNumberTextField.inputAccessoryView = toolbar
	}
	
	@objc private func doneButtonTapped() {
		view.endEditing(true)
	}
}

extension AuthorizationViewController: BindableView {
	func getOutput() -> AuthorizationViewOutput { viewOutput }
	
	func bindWith(_ input: AuthorizationPresenterOutput) {
		disposeBag.insert {
			input.initialLoadingIndicatorVisible.drive(loadingIndicatorView.rx.isVisible,
																								 loadingIndicatorView.indicatorView.rx.isAnimating)
			
			input.phoneNumber.emit(to: phoneNumberTextField.rx.text)
			
			input.isButtonEnable.do(onNext: { [weak self] isEnabled in
				guard let self = self else { return }
				self.getSMSButton?.alpha = isEnabled ? 1 : 0.3
				if isEnabled {
					self.view.endEditing(true)
				}
			}).drive(getSMSButton.rx.isEnabled)
			
			input.showCode.emit(onNext: { [weak self] smsCode in
				self?.sendNotification(code: smsCode)
				UIPasteboard.general.string = smsCode
			})
			
			input.showError.emit(onNext: { [weak self] maybeViewModel in
				self?.errorMessageView.isVisible = (maybeViewModel != nil)
		
				if let viewModel = maybeViewModel {
					self?.errorMessageView.resetToEmptyState()

					self?.errorMessageView.setTitle(viewModel.title, buttonTitle: viewModel.buttonTitle, action: {
						self?.viewOutput.$retryButtonTap.accept(Void())
					})
				}
			})
			
			getSMSButton.rx.tap.bind(to: viewOutput.$getSMSButtonTap)
			
			phoneNumberTextField.rx.text.orEmpty.bind(to: viewOutput.$phoneNumberTextChange)
		}
	}
}

// MARK: - RibStoryboardInstantiatable

extension AuthorizationViewController: RibStoryboardInstantiatable {}

// MARK: - View Output

extension AuthorizationViewController {
	private struct ViewOutput: AuthorizationViewOutput {
		@PublishControlEvent var getSMSButtonTap: ControlEvent<Void>
		@PublishControlEvent var phoneNumberTextChange: ControlEvent<String>
		@PublishControlEvent var retryButtonTap: ControlEvent<Void>
	}
}
