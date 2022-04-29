//
//  MainScreenViewController.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 08.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift
import RxCocoa
import UIKit

final class MainScreenViewController: UIViewController, MainScreenViewControllable {
  @IBOutlet private weak var tableViewScreenButton: UIButton!
	@IBOutlet private weak var authorizationButton: UIButton!
	
	private let viewOutput = ViewOutput()
	private let disposeBag = DisposeBag()
}

// MARK: - BindableView

extension MainScreenViewController: BindableView {
	func getOutput() -> MainScreenViewOutput { viewOutput }

  func bindWith(_ input: Empty) {
		disposeBag.insert {
			tableViewScreenButton.rx.tap.bind(to: viewOutput.$tableViewButtonTap)
			authorizationButton.rx.tap.bind(to: viewOutput.$authorizationButtonTap)
		}
	}
}

// MARK: - RibStoryboardInstantiatable

extension MainScreenViewController: RibStoryboardInstantiatable {}

// MARK: - ViewOutput

extension MainScreenViewController {
	private struct ViewOutput: MainScreenViewOutput {
		@PublishControlEvent var tableViewButtonTap: ControlEvent<Void>
		@PublishControlEvent var authorizationButtonTap: ControlEvent<Void>
	}
}
