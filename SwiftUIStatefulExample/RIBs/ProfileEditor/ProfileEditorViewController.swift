//
//  ProfileEditorViewController.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 25.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa
import UIKit

final class ProfileEditorViewController: UIViewController, ProfileEditorPresentable, ProfileEditorViewControllable {
	@IBOutlet weak private var nameTextField: CustomTextField!
	@IBOutlet weak private var secondNameTextField: CustomTextField!
	@IBOutlet weak private var phoneNumberTextField: CustomTextField!
	@IBOutlet weak private var emailTextField: CustomTextField!
	
	@IBOutlet weak private var emailValidationErrorLabel: UILabel!
	@IBOutlet weak private var saveUpdateButton: UIButton!
	
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

extension ProfileEditorViewController {
	private func initialSetup() {
		title = "Редактировать"
		
		let toolbar = UITextField.toolbarInitialSetup(target: self, selector: #selector(doneButtonTapped))
		
		nameTextField.layer.cornerRadius = 12
		secondNameTextField.layer.cornerRadius = 12
		phoneNumberTextField.layer.cornerRadius = 12
		emailTextField.layer.cornerRadius = 12
		saveUpdateButton.layer.cornerRadius = 12
		
		view.addStretchedToBounds(subview: errorMessageView)
		view.addStretchedToBounds(subview: loadingIndicatorView)
		errorMessageView.isVisible = false
		loadingIndicatorView.isVisible = false

		emailValidationErrorLabel.text =  "Введен неверный email"
		phoneNumberTextField.isEnabled = false
		phoneNumberTextField.textColor = .gray
		phoneNumberTextField.layer.borderColor = UIColor.lightGray.cgColor
		phoneNumberTextField.layer.borderWidth = 1.0
		
		nameTextField.inputAccessoryView = toolbar
		secondNameTextField.inputAccessoryView = toolbar
		emailTextField.inputAccessoryView = toolbar
		emailValidationErrorLabel.isVisible = false
	}
	
	@objc private func doneButtonTapped() {
		view.endEditing(true)
	}
}

extension ProfileEditorViewController: BindableView {
	func getOutput() -> ProfileEditorViewOutput { viewOutput }
	
	func bindWith(_ input: ProfileEditorPresenterOutput) {
		disposeBag.insert {
			input.initialLoadingIndicatorVisible.drive(loadingIndicatorView.rx.isVisible,
																								 loadingIndicatorView.indicatorView.rx.isAnimating)
			input.firstName.drive(nameTextField.rx.text)
			input.lastName.drive(secondNameTextField.rx.text)
			input.phone.drive(phoneNumberTextField.rx.text)
			input.email.drive(emailTextField.rx.text)
			
			input.profileSuccessfullyEdited.emit(onNext: { [weak self] _ in self?.presentProfileSuccessUpdateAlert() } )
			
			input.emailValidationError
				.do(onNext: { [weak self] error in
					let notValid = error != nil
					self?.emailValidationErrorLabel.isVisible = notValid ? true : false
					self?.emailTextField.textColor = notValid ? .red : .black
					self?.emailValidationErrorLabel.textColor = notValid ? .red : .black
					self?.emailTextField.layer.borderColor = notValid ? UIColor.red.cgColor : nil
					self?.emailTextField.layer.borderWidth = notValid ? 1 : 0
				})
				.emit(to: emailValidationErrorLabel.rx.text)
			
			input.showError.emit(onNext: { [weak self] maybeViewModel in
				guard let self = self else { return }
				self.errorMessageView.isVisible = (maybeViewModel != nil)
		
				if let viewModel = maybeViewModel {
					self.errorMessageView.resetToEmptyState()

					self.errorMessageView.setTitle(viewModel.title, buttonTitle: viewModel.buttonTitle, action: { [weak self] in
						self?.viewOutput.$retryButtonTap.accept(Void())
					})
				}
			})
			nameTextField.rx.text.orEmpty.bind(to: viewOutput.$firstNameTextChange)
			secondNameTextField.rx.text.orEmpty.bind(to: viewOutput.$lastNameTextChange)
			emailTextField.rx.text.orEmpty.bind(to: viewOutput.$emailTextChange)
			saveUpdateButton.rx.tap.bind(to: viewOutput.$updateProfileButtonTap)
		}
	}
}

// MARK: - RibStoryboardInstantiatable

extension ProfileEditorViewController: RibStoryboardInstantiatable {}

// MARK: - ViewOutput

extension ProfileEditorViewController {
	private struct ViewOutput: ProfileEditorViewOutput {
		@PublishControlEvent var updateProfileButtonTap: ControlEvent<Void>
		@PublishControlEvent var firstNameTextChange: ControlEvent<String>
		@PublishControlEvent var lastNameTextChange: ControlEvent<String>
		@PublishControlEvent var emailTextChange: ControlEvent<String>
		@PublishControlEvent var retryButtonTap: ControlEvent<Void>
		@PublishControlEvent var alertButtonTap: ControlEvent<Void>
	}
}

// MARK: - Help Method

extension ProfileEditorViewController {
	private func presentProfileSuccessUpdateAlert() {
		let profileSuccessfullyUpdated = UIAlertController(title: "Профиль успешно обновлён",
																															 message: nil,
																															 preferredStyle: UIAlertController.Style.alert)
		profileSuccessfullyUpdated.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { [weak self] action in
			self?.viewOutput.$alertButtonTap.accept(Void())
		}))
		self.present(profileSuccessfullyUpdated, animated: true, completion: nil)
	}
}
