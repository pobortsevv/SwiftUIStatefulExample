//
//  ProfileEditorInteractor.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 25.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

final class ProfileEditorInteractor: PresentableInteractor<ProfileEditorPresentable>, ProfileEditorInteractable {
	weak var router: ProfileEditorRouting?
	
	private let profileProvider: AuthorizationProfileProvider

	// MARK: Internals
	
	private let _state = BehaviorRelay<ProfileEditorInteractorState>(value: .userInput)
	private let _screenDataModel: BehaviorRelay<ProfileEditorScreenDataModel>
	
	private let responses = Responses()
	
	private let disposeBag = DisposeBag()
	
	init(presenter: ProfileEditorPresentable,
			 profileProvider: AuthorizationProfileProvider,
			 profile: Profile) {
		self.profileProvider = profileProvider
		let screenDataModel = ProfileEditorScreenDataModel(profile: profile)
		_screenDataModel = BehaviorRelay(value: screenDataModel)
		super.init(presenter: presenter)
	}
	
	private func updateProfile(profile: Profile) {
		profileProvider.updateProfile(profile) { [weak self] result in
			switch result {
			case .success: self?.responses.$profileUpdated.accept(Void())
			case .failure(let error): self?.responses.$updateError.accept(error)
			}
		}
	}
}

// MARK: - IOTransformer

extension ProfileEditorInteractor: IOTransformer {
	func transform(input viewOutput: ProfileEditorViewOutput) -> ProfileEditorInteractorOutput {
		let trait = StateTransformTrait(_state: _state, disposeBag: disposeBag)

		let requests = makeRequests()
		let routes = makeRoutes()
		
		StateTransform.transform(trait: trait,
														 viewOutput: viewOutput,
														 response: responses,
														 requests: requests,
														 screenDataModel: _screenDataModel,
														 disposeBag: disposeBag)
		
		ProfileEditorInteractor.bindStatefulRouting(viewOutput, trait: trait, routes: routes)
		
		return ProfileEditorInteractorOutput(state: trait.readOnlyState,
																				 screenDataModel: _screenDataModel.asObservable(),
																				 updateProfileButtonTap: viewOutput.updateProfileButtonTap)
	}
	
	static private func bindStatefulRouting(_ viewOutput: ProfileEditorViewOutput,
																	 trait: StateTransformTrait<State>,
																	 routes: Routes) {
		viewOutput.alertButtonTap
			.filteredByState(trait.readOnlyState, filter: { state -> Bool in
				guard case .routedToProfile = state else { return false }; return true
			})
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: routes.close)
			.disposed(by: trait.disposeBag)
		
	}
}

extension ProfileEditorInteractor {
	private typealias State = ProfileEditorInteractorState
	
	/// State-Машина
	private enum StateTransform: StateTransformer {
		// Case .UserInput
		static let byUserInputState: (State) -> Bool = { state -> Bool in
			guard case .userInput = state else { return false }; return true
		}
		
		// Case .UpdatingProfile
		static let byUpdatingProfileState: (State) -> Profile? = { state in
			guard case .updatingProfile(let profile) = state else { return nil }; return profile
		}
		
		static func transform(trait: StateTransformTrait<State>,
													viewOutput: ProfileEditorViewOutput,
													response: Responses,
													requests: Requests,
													screenDataModel: BehaviorRelay<ProfileEditorScreenDataModel>,
													disposeBag: DisposeBag) {
			
			let name = viewOutput.firstNameTextChange
				.map { name -> String in
					let _name = name.removingCharacters(except: .letters)
					
					return String(_name)
				}
			
			let secondName = viewOutput.lastNameTextChange
				.map { secondName -> String in
					let _secondName = secondName
						.removingCharacters(except: .letters)
					
					return String(_secondName)
				}
			
			let email = viewOutput.emailTextChange
				.map { email -> String in
					let _email = email
						.removingCharacters(in: .whitespacesAndNewlines)
					
					return String(_email)
				}
			
			StateTransform.transitions {
				// UserInput -> UpdatingProfile
				viewOutput.updateProfileButtonTap.filteredByState(trait.readOnlyState, filter: byUserInputState)
					.withLatestFrom(screenDataModel.asObservable())
					.compactMap { screenDataModel -> Profile? in
						switch screenDataModel.email {
						case .success(let email):
							return Profile(firstName: screenDataModel.firstNameTextField,
														 lastName: screenDataModel.lastNameTextField,
														 email: email,
														 phone: screenDataModel.phoneNumberTextField,
														 authorized: true)
						case .failure:
							return nil
						}
					}
					.do(afterNext: requests.updateProfile)
					.map { profile in State.updatingProfile(profile: profile)}
				
				// UpdatingProfile -> UpdateProfileRequestError
				response.updateError
					.filteredByState(trait.readOnlyState, filterMap: byUpdatingProfileState)
					.map { error, profile in State.updateProfileError(error: error, profile: profile) }
				
				// UpdateProfileRequestError -> UpdatingProfile
				viewOutput.retryButtonTap.filteredByState(trait.readOnlyState, filterMap: { state -> Profile? in
					guard case let .updateProfileError(_, profile) = state else { return nil }; return profile
				})
				.do(afterNext: requests.updateProfile)
				.map { profile in State.updatingProfile(profile: profile) }
				
				// UpdatingProfile -> routeToProfile
				response.profileUpdated
					.filteredByState(trait.readOnlyState, filterMap: byUpdatingProfileState)
					.map { _ in State.routedToProfile}
			}.bindToAndDisposedBy(trait: trait)
			
			updateScreenDataModel(screenDataModel: screenDataModel,
														nameText: name,
														secondNameText: secondName,
														emailText: email,
														disposeBag: disposeBag)
			
		}
		
		static func updateScreenDataModel(screenDataModel: BehaviorRelay<ProfileEditorScreenDataModel>,
																			nameText: Observable<String>,
																			secondNameText: Observable<String>,
																			emailText: Observable<String>,
																			disposeBag: DisposeBag) {
			let readOnlyScreenDataModel = screenDataModel.asObservable()
			
			Observable<ProfileEditorScreenDataModel>.merge {
				nameText.withLatestFrom(readOnlyScreenDataModel, resultSelector: { ($0, $1) })
					.map { name, screenDataModel in
						mutate(value: screenDataModel, mutation: { $0.firstNameTextField = name } )
					}
				
				secondNameText.withLatestFrom(readOnlyScreenDataModel, resultSelector: { ($0, $1) })
					.map { secondName, screenDataModel in
						mutate(value: screenDataModel, mutation: { $0.lastNameTextField = secondName } )
					}
				
				emailText.withLatestFrom(readOnlyScreenDataModel, resultSelector: { ($0, $1) })
					.map { email, screenDataModel in
						screenDataModel.copy(email: email)
					}
			}
			.bind(to: screenDataModel)
			.disposed(by: disposeBag)
		}
	}
}

// MARK: - Help Methods

extension ProfileEditorInteractor {
	private func makeRequests() -> Requests {
		Requests(updateProfile: { [weak self] profile in self?.updateProfile(profile: profile) })
	}
	
	private func makeRoutes() -> Routes {
		Routes(close: { [weak self] in self?.router?.close()} )
	}
}

// MARK: - Nested Types

extension ProfileEditorInteractor {
	private struct Responses {
		@PublishObservable var profileUpdated: Observable<Void>
		@PublishObservable var updateError: Observable<Error>
	}
	
	private struct Requests {
		let updateProfile: (_ profile: Profile) -> Void
	}
	
	private struct Routes {
		let close: VoidClosure
	}
}
