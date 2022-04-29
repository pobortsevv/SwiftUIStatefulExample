//
//  LoadingIndicatorView.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import UIKit

final class LoadingIndicatorView: UIView {
	// Create Animation object
	
  let indicatorView = UIActivityIndicatorView()
//	let animationView = AnimationView()
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    initialSetup()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
		
    initialSetup()
  }
  
  private func initialSetup() {
//		let animation = Animation.named("Watermelon")
//		Bundle.main.path(forResource: <#T##String?#>, ofType: <#T##String?#>)
		
    backgroundColor = UIColor.black.withAlphaComponent(0.15)
    
    indicatorView.translatesAutoresizingMaskIntoConstraints = false
//		animationView.animation = animation
    addSubview(indicatorView)
//		animationView.play()
//		addSubview(animationView)
		
    
    let constraints: [NSLayoutConstraint] = [
      indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
      indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
    ]
    
    NSLayoutConstraint.activate(constraints)
  }
}
