//
//  ProfileEditorBuilder.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 25.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RIBs

final class ProfileEditorBuilder: Builder<RootDependency>, ProfileEditorBuildable {
	func build(profile: Profile) -> ProfileEditorRouting {
		let viewController = ProfileEditorViewController.instantiateFromStoryboard()
		let presenter = ProfileEditorPresenter()
		let interactor = ProfileEditorInteractor(presenter: viewController,
																						 profileProvider: dependency.profileProvider,
																						 profile: profile)
		
		VIPBinder.bind(view: viewController, interactor: interactor, presenter: presenter)
		
		return ProfileEditorRouter(interactor: interactor, viewController: viewController)
	}
}
