//
//  ProfileBuilder.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs

final class ProfileBuilder: Builder<RootDependency>, ProfileBuildable {
  func build() -> ProfileRouting {
		let viewController = ProfileViewController.instantiateFromStoryboard()
		let presenter = ProfilePresenter()
		let interactor = ProfileInteractor(presenter: presenter, profileService: dependency.profileProvider)
		
		VIPBinder.bind(view: viewController, interactor: interactor, presenter: presenter)
      
		return ProfileRouter(interactor: interactor, viewController: viewController, profileEditorBuilder: ProfileEditorBuilder(dependency: dependency))
  }
}
