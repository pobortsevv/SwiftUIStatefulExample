//
//  MainScreenRouter.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 08.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RxSwift
import RIBs

final class MainScreenRouter: ViewableRouter<MainScreenInteractable, MainScreenViewControllable>, MainScreenRouting {
  
  private let profileBuilder: ProfileBuildable
	private let authorizationBuilder: AuthorizationBuildable
  
  private let disposeBag = DisposeBag()
  
  init(interactor: MainScreenInteractable,
                viewController: MainScreenViewControllable,
                profileBuilder: ProfileBuildable,
								authorizationBuilder: AuthorizationBuildable) {
    self.profileBuilder = profileBuilder
		self.authorizationBuilder = authorizationBuilder
    super.init(interactor: interactor, viewController: viewController)
    interactor.router = self
  }
  
  func routeToTableViewProfile() {
    let router = profileBuilder.build()
    attachChild(router)
		
    viewController.uiviewController.navigationController?.pushViewController(router.viewControllable.uiviewController,
                                                                             animated: true)
    detachWhenClosed(child: router, disposedBy: disposeBag)
  }
	
	func routeToAuthorization() {
		let router = authorizationBuilder.build()
		attachChild(router)
		viewController.uiviewController.present(router.viewControllable.uiviewController, animated: true)
		detachWhenClosed(child: router, disposedBy: disposeBag)
	}
}
