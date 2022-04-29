//
//  MainScreenProtocols.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 08.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

// MARK: - Builder

protocol MainScreenBuildable: Buildable {
	/// Основной экран, где происходят переходы между авторизацией
	/// и экраном профиля пользователя
  func build() -> MainScreenRouting
}

// MARK: - Router

protocol MainScreenInteractable: Interactable {
  var router: MainScreenRouting? { get set }
}

protocol MainScreenViewControllable: ViewControllable {}

// MARK: - Interactor

protocol MainScreenRouting: ViewableRouting {
  func routeToAuthorization()
  func routeToTableViewProfile()
}

// MARK: Outputs

protocol MainScreenViewOutput {
	var tableViewButtonTap: ControlEvent<Void> { get }
	var authorizationButtonTap: ControlEvent<Void> { get }
}
