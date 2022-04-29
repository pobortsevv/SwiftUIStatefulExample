//
//  ValidatorRouter.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 23.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs

final class ValidatorRouter: ViewableRouter<ValidatorInteractable, ValidatorViewControllable>, ValidatorRouting {
	override init(interactor: ValidatorInteractable, viewController: ValidatorViewControllable) {
		super.init(interactor: interactor, viewController: viewController)
		interactor.router = self
	}
}
