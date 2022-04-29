//
//  ProfilePresenter.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

final class ProfilePresenter: ProfilePresentable {}

// MARK: - IOTransformer

extension ProfilePresenter: IOTransformer {
  /// Метод отвечает за преобразование состояния во ViewModel'и и сигналы (команды)
  func transform(input state: Observable<ProfileInteractorState>) -> ProfilePresenterOutput {
    let viewModel = Helper.viewModel(state)
    
    let isContentViewVisible = state.compactMap { state -> Void? in
      // После загрузки 1-й порции данных контент всегда виден
      switch state {
      case .dataLoaded: return Void()
			case .loadingError, .isLoading, .routeToEdit: return nil
      }
    }
    .map { true }
    .startWith(false)
    .asDriverIgnoringError()
    
    let (initialLoadingIndicatorVisible, hideRefreshControl) = refreshLoadingIndicatorEvents(state: state)
    
    let showError = state.map { state -> ErrorMessageViewModel? in
      switch state {
      case .loadingError(let error):
        return ErrorMessageViewModel(title: error.localizedDescription, buttonTitle: "Повторить")
			case .isLoading, .dataLoaded, .routeToEdit:
        return nil
      }
    }
    // .distinctUntilChanged() - ⚠️ здесь этот оператор применять не нужно
    .asSignal(onErrorJustReturn: nil)
		
		let isButtonEditEnable = state.map { state -> Bool in
			switch state {
			case .dataLoaded(let profile):
				return profile.authorized
			case .loadingError, .isLoading, .routeToEdit:
				return false
			}
		}
		.asDriverIgnoringError()
    
    return ProfilePresenterOutput(viewModel: viewModel,
                                  isContentViewVisible: isContentViewVisible,
                                  initialLoadingIndicatorVisible: initialLoadingIndicatorVisible,
																	hideRefreshControl: hideRefreshControl, isButtonEditEnable: isButtonEditEnable,
                                  showError: showError)
  }
}

extension ProfilePresenter {
  private enum Helper: Namespace {
    static func viewModel(_ state: Observable<ProfileInteractorState>) -> Driver<ProfileViewModel> {
      return state.compactMap { state -> ProfileViewModel? in
        switch state {
        case .dataLoaded(let profile):
					let authorizedTitle: String = (profile.authorized ? "Зарегистрированный пользователь" : "Незарегистрированный пользователь")
          
          return ProfileViewModel(authorized: authorizedTitle,
																	firstName: TitledOptionalText(title: "Имя", maybeText: profile.firstName),
                                  lastName: TitledOptionalText(title: "Фамилия", maybeText: profile.lastName),
                                  email: TitledOptionalText(title: "E-mail", maybeText: profile.email),
                                  phone: TitledOptionalText(title: "Телефон", maybeText: profile.phone))
          
				case .loadingError, .isLoading, .routeToEdit:
          return nil
				}
      }
      .distinctUntilChanged()
      .asDriverIgnoringError()
    }
  }
}
