//
//  ProfileProtocols.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa

// MARK: - Builder

protocol ProfileBuildable: Buildable {
	/// Экран профиля пользователя, который можно редактироватьы
  func build() -> ProfileRouting
}

// MARK: - Router

protocol ProfileInteractable: Interactable {
  var router: ProfileRouting? { get set }
}

protocol ProfileViewControllable: ViewControllable {}

// MARK: - Interactor

protocol ProfileRouting: ViewableRouting {
	func routeToEdit(profile: Profile)
}

protocol ProfilePresentable: Presentable {}

// MARK: Outputs

//typealias ProfileInteractorState = LoadingState<Profile, Error>

enum ProfileInteractorState {
	case isLoading
	case dataLoaded(profile: Profile)
	case loadingError(error: Error)
	case routeToEdit
}

extension ProfileInteractorState: GeneralizableState {
	public var isLoadingState: Bool {
		guard case .isLoading = self else { return false }
		return true
	}
	
	public var isDataLoadedState: Bool {
		guard case .dataLoaded = self else { return false }
		return true
	}
	
	public var isLoadingErrorState: Bool {
		guard case .loadingError = self else { return false }
		return true
	}
}

extension ProfileInteractorState: LoadingIndicatableState {
	public var shouldLoadingIndicatorBeVisible: Bool {
		guard case .isLoading = self else { return false }
		return true
	}
}

struct ProfilePresenterOutput {
  let viewModel: Driver<ProfileViewModel>
  let isContentViewVisible: Driver<Bool>
  
  let initialLoadingIndicatorVisible: Driver<Bool>
  let hideRefreshControl: Signal<Void>
	let isButtonEditEnable: Driver<Bool>
  
  /// nil означает что нужно спрятать сообщение об ошибке
  let showError: Signal<ErrorMessageViewModel?>
}

protocol ProfileViewOutput {
  /// Добавление / изменение e-mail'a
  var retryButtonTap: ControlEvent<Void> { get }
  
  var pullToRefresh: ControlEvent<Void> { get }
	
	var editProfileTap: ControlEvent<Void> { get }
}

struct ProfileViewModel: Equatable {
	let authorized: String
  let firstName: TitledOptionalText
  let lastName: TitledOptionalText

  let email: TitledOptionalText
  let phone: TitledOptionalText
}

struct ErrorMessageViewModel: Equatable {
  let title: String
  let buttonTitle: String
}
