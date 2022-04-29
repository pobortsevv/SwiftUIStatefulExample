//
//  ValidatorPresenter.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 23.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

final class ValidatorPresenter: ValidatorPresentable {
	private let phoneNumber: String
	
	init(phoneNumber: String) {
		self.phoneNumber = phoneNumber
	}
}

// MARK: - IOTransformer

extension ValidatorPresenter: IOTransformer {
	func transform(input: ValidatorInteractorOutput) -> ValidatorPresenterOutput {
		let state = input.state
		
		let showNumber = Observable.singleElement(phoneNumber)
		.asSignalIgnoringError()
		
		let isContentViewVisible = state.compactMap { state -> Void? in
			switch state {
			case .userInput: return Void()
			case .sendingCodeCheckRequest, .updatingProfile, .updatedProfile: return nil
			}
		}
		.map { true }
		.startWith(false)
		.asDriverIgnoringError()
		
		let initialLoadingIndicatorVisible = loadingIndicatorEvent(state: state)
		
		let code = input.screenDataModel.map { screenDataModel -> String in
			return screenDataModel.codeTextField
		}
		.asDriverIgnoringError()
		
		let showNetworkError = Helper.networkError(state)
		
		let showValidationError = Helper.validationError(state)
		
		return ValidatorPresenterOutput(showNumber: showNumber,
																		isContentViewVisible: isContentViewVisible,
																		initialLoadingIndicatorVisible: initialLoadingIndicatorVisible,
																		code: code,
																		showNetworkError: showNetworkError,
																		showValidationError: showValidationError)
	}
}

extension ValidatorPresenter {
	private enum Helper: Namespace {
		static func validationError(_ state: Observable<ValidatorInteractorState>) -> Signal<String?> {
			return state.map { state -> String? in
				switch state {
				case let .userInput(error):
					switch error {
					case .validationError:
						return error?.localizedDescription
					case .networkError, .none:
						return nil
					}
				case .sendingCodeCheckRequest, .updatingProfile, .updatedProfile:
					return nil
				}
			}
			.distinctUntilChanged()
			.asSignalIgnoringError()
		}
		
		static func networkError(_ state: Observable<ValidatorInteractorState>) -> Signal<String?> {
			return state.map { state -> String? in
				switch state {
				case let .userInput(error):
					switch error {
					case  .networkError:
						return error?.localizedDescription
					case .validationError, .none:
						return nil
					}
				case .sendingCodeCheckRequest, .updatingProfile, .updatedProfile:
					return nil
				}
			}
			.distinctUntilChanged()
			.asSignalIgnoringError()
		}
	}
}
