//
//  AppComponent.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 08.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs

final class AppComponent: Component<EmptyDependency>, RootDependency {
	let profileProvider: ProfileProviderImp = ProfileProviderImp()
	
  init() {
    super.init(dependency: EmptyComponent())
  }
}
