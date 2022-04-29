//
//  AuthorizationProtocols.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 12.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa

// MARK: - Builder

protocol AuthorizationBuildable: Buildable {
	/// В Authorization модуле происходит ввод номера телефона
	/// пользователем для последущей авторизации аккаунта
	func build() -> AuthorizationRouting
}

// MARK: - Router

protocol AuthorizationInteractable: Interactable, ValidatorListener {
	var router: AuthorizationRouting? { get set }
}

protocol AuthorizationViewControllable: ViewControllable {}

// MARK: - Interactor

protocol AuthorizationRouting: ViewableRouting {
	func routeToValidator(phoneNumber: String)
	func close()
}

protocol AuthorizationPresentable: Presentable {}

// MARK: States

/// В данном перечислении находятся сами состояния.
/// Необходимо объявить их здесь, реализовать переходы
/// в интеракторе
public enum AuthorizationInteractorState {
	case userInput
	case sendingSMSCodeRequest(phoneNumber: String)
	case smsCodeRequestError(error: Error, phoneNumber: String)
	/// Перешли на экран ввода и проверки смс кода (терминальное состояние)
	case routedToCodeCheck(code: String)
}

extension AuthorizationInteractorState: GeneralizableState {
	public var isLoadingState: Bool {
		guard case .sendingSMSCodeRequest = self else { return false }
		return true
	}
	
	public var isDataLoadedState: Bool {
		guard case .routedToCodeCheck = self else { return false }
		return true
	}
	
	public var isLoadingErrorState: Bool {
		guard case .smsCodeRequestError = self else { return false }
		return true
	}
}

extension AuthorizationInteractorState: LoadingIndicatableState {
	public var shouldLoadingIndicatorBeVisible: Bool {
		guard case .sendingSMSCodeRequest = self else { return false }
		return true
	}
}

// MARK: Outputs

struct AuthorizationInteractorOutput {
	let state: Observable<AuthorizationInteractorState>
	let screenDataModel: Observable<AuthorizationScreenDataModel>
}

struct AuthorizationPresenterOutput {
	let showCode: Signal<String>
	
	let initialLoadingIndicatorVisible: Driver<Bool>
	
	let phoneNumber: Signal<String>
	let	isButtonEnable: Driver<Bool>
	let showError: Signal<ErrorMessageViewModel?>
}

protocol AuthorizationViewOutput {
	var getSMSButtonTap: ControlEvent<Void> { get }
	var phoneNumberTextChange: ControlEvent<String> { get }
	var retryButtonTap: ControlEvent<Void> { get }
}

// MARK: ScreenDataModel

struct AuthorizationScreenDataModel {
	var phoneNumberTextField: String
}

extension AuthorizationScreenDataModel {
	init() {
		phoneNumberTextField = ""
	}
}
