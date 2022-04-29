//
//  AuthorizationRouter.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 12.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift


final class AuthorizationRouter: ViewableRouter<AuthorizationInteractable, AuthorizationViewControllable>, AuthorizationRouting {
	private let validatorBuilder: ValidatorBuildable
	
	private let disposeBag = DisposeBag()
	
	init(interactor: AuthorizationInteractable,
			 viewController: AuthorizationViewControllable,
			 validatorBuilder: ValidatorBuildable) {
		self.validatorBuilder = validatorBuilder
		super.init(interactor: interactor, viewController: viewController)
		interactor.router = self
	}
	
	func routeToValidator(phoneNumber: String) {
		let router = validatorBuilder.build(phoneNumber: phoneNumber, listener: interactor)
		attachChild(router)
		viewController.uiviewController.present(router.viewControllable.uiviewController, animated: true)
		detachWhenClosed(child: router, disposedBy: disposeBag)
	}
	
	func close() {
		viewController.uiviewController.presentingViewController?.dismiss(animated: true)
	}
}
