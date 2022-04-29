//
//  ValidatorBuilder.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 23.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs

final class ValidatorBuilder: Builder<RootDependency>, ValidatorBuildable {
	func build(phoneNumber: String, listener: ValidatorListener) -> ValidatorRouting {
		let viewController = ValidatorViewController.instantiateFromStoryboard()
		let presenter = ValidatorPresenter(phoneNumber: phoneNumber)
		let interactor = ValidatorInteractor(presenter: presenter, authorizationProvider: dependency.profileProvider, phoneNumber: phoneNumber)
		interactor.listener = listener
		
		VIPBinder.bind(view: viewController, interactor: interactor, presenter: presenter)
		
		return ValidatorRouter(interactor: interactor, viewController: viewController)
	}
}
