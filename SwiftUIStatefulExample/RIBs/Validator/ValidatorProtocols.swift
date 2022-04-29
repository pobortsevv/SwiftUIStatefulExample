//
//  ValidatorProtocols.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 23.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

// MARK: - Builder

protocol ValidatorBuildable: Buildable {
	/// На экране Validator выполняется подтверждение смс-кода
	func build(phoneNumber: String, listener: ValidatorListener) -> ValidatorRouting
}

protocol ValidatorListener: AnyObject {
	func successAuth()
	func closedValidatorView()
}

// MARK: - Router

protocol ValidatorInteractable: Interactable {
	var router: ValidatorRouting? { get set }
	var listener: ValidatorListener? { get set }
}

protocol ValidatorViewControllable: ViewControllable {}

// MARK: - Interactor

protocol ValidatorRouting: ViewableRouting {}

protocol ValidatorPresentable: Presentable {}

// MARK: States

public enum ValidatorInteractorState {
	case userInput(error: AuthError?)
	case sendingCodeCheckRequest
	case updatingProfile
	case updatedProfile
}

extension ValidatorInteractorState: GeneralizableState {
	public var isLoadingState: Bool {
		switch self {
		case .sendingCodeCheckRequest, .updatingProfile:
			return true
		case .updatedProfile, .userInput:
			return false
		}
	}
	
	public var isDataLoadedState: Bool {
		guard case .updatedProfile = self else { return false }
		return true
	}
	
	public var isLoadingErrorState: Bool {
		guard case .userInput(let error) = self else { return false }
		return error == nil
	}
}

extension ValidatorInteractorState: LoadingIndicatableState {
	public var shouldLoadingIndicatorBeVisible: Bool {
		switch self {
		case .sendingCodeCheckRequest, .updatingProfile:
			return true
		case .updatedProfile, .userInput:
			return false
		}
	}
}

// MARK: Outputs

struct ValidatorInteractorOutput {
	let state: Observable<ValidatorInteractorState>
	let screenDataModel: Observable<ValidatorScreenDataModel>
}

struct ValidatorPresenterOutput {
	let showNumber: Signal<String>
	let isContentViewVisible: Driver<Bool>

	let initialLoadingIndicatorVisible: Driver<Bool>

	let code: Driver<String>
	let showNetworkError: Signal<String?>
	let showValidationError: Signal<String?>
}

protocol ValidatorViewOutput {
	var codeTextChange: ControlEvent<String> { get }
	var viewDidDisappear: ControlEvent<Void> { get }
}

// MARK: ScreenDataModel

struct ValidatorScreenDataModel {
	var codeTextField: String
}

extension ValidatorScreenDataModel {
	init() {
		codeTextField = ""
	}
}
