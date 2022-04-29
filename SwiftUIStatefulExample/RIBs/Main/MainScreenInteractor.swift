//
//  MainScreenInteractor.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 08.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift

final class MainScreenInteractor: Interactor, MainScreenInteractable {
  weak var router: MainScreenRouting?

  private let disposeBag = DisposeBag()
}

// MARK: - IOTransformer

extension MainScreenInteractor: IOTransformer {
  func transform(input viewOutput: MainScreenViewOutput) -> Empty {
		disposeBag.insert {
			viewOutput.tableViewButtonTap.bind { [weak self] in self?.router?.routeToTableViewProfile() }
			
			viewOutput.authorizationButtonTap.bind { [weak self] in self?.router?.routeToAuthorization() }
		}
    return Empty()
  }
}
