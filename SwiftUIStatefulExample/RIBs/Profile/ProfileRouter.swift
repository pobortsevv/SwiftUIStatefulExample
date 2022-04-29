//
//  ProfileRouter.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift

final class ProfileRouter: ViewableRouter<ProfileInteractable, ProfileViewControllable>, ProfileRouting {
	
	private let profileEditorBuilder: ProfileEditorBuildable
	private let disposeBag = DisposeBag()
	
  init(interactor: ProfileInteractable,
			 viewController: ProfileViewControllable,
			 profileEditorBuilder: ProfileEditorBuildable) {
		self.profileEditorBuilder = profileEditorBuilder
    super.init(interactor: interactor, viewController: viewController)
    interactor.router = self
  }
  
	func routeToEdit(profile: Profile) {
		let router = profileEditorBuilder.build(profile: profile)
		attachChild(router)
		
		viewController.uiviewController.navigationController?.pushViewController(router.viewControllable.uiviewController, animated: true)
	
		detachWhenClosed(child: router, disposedBy: DisposeBag())
	}
}
