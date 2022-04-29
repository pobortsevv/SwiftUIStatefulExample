//
//  ProfileEditorPresenter.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 25.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

final class ProfileEditorPresenter: ProfileEditorPresentable {}

// MARK: - IOTransformer

extension ProfileEditorPresenter: IOTransformer {
	func transform(input: ProfileEditorInteractorOutput) -> ProfileEditorPresenterOutput {
		let state = input.state
		
		let initialLoadingIndicatorVisible = loadingIndicatorEvent(state: state)
		
		let userName = input.screenDataModel.map { screenDataModel in
			return screenDataModel.firstNameTextField
		}
		.asDriverIgnoringError()
		
		let secondName = input.screenDataModel.map { screenDataModel in
			return screenDataModel.lastNameTextField
		}
		.asDriverIgnoringError()
		
		let phone = input.screenDataModel.map { screenDataModel in
			return screenDataModel.phoneNumberTextField
		}
		.asDriverIgnoringError()
		
		
		
		let email = input.screenDataModel.compactMap { screenDataModel -> String? in
			switch screenDataModel.email {
			case .success(let email): return email
			case .failure: return nil
			}
		}
		.asDriverIgnoringError()
		
		let emailValidationError = Observable<String?>.merge {
			input.screenDataModel
				.map { screenDataModel -> String? in
					switch screenDataModel.email {
					case .failure, .success: return nil
					}
				}
			
			input.updateProfileButtonTap
				.withLatestFrom(input.screenDataModel.asObservable())
				.map { screenDataModel -> String? in
					switch screenDataModel.email {
					case .success: return nil
					case .failure: return "Введен неверный email"
					}
				}
			}
			.asSignalIgnoringError()
		
		let showError = state.map { state -> ErrorMessageViewModel? in
			switch state {
			case let .updateProfileError(error, _):
				return ErrorMessageViewModel(title: error.localizedDescription, buttonTitle: "Повторить")
			case .userInput, .routedToProfile, .updatingProfile:
				return nil
			}
		}
		.asSignalIgnoringError()
		
		let profileSuccessfullyEdited = state.compactMap { state -> Void? in
			switch state {
			case .routedToProfile: return Void()
			case .userInput, .updatingProfile, .updateProfileError: return nil
			}
		}
		.map { true }
		.distinctUntilChanged()
		.asSignalIgnoringError()
	
		return ProfileEditorPresenterOutput(initialLoadingIndicatorVisible:
																				initialLoadingIndicatorVisible,
																				firstName: userName,
																				lastName: secondName,
																				email: email,
																				phone: phone,
																				emailValidationError: emailValidationError,
																				profileSuccessfullyEdited: profileSuccessfullyEdited,
																				showError: showError)
	}
}
