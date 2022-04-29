////
////  RIBs+Close.swift
////  StatefulScreenExample
////
////  Created by Vladimir Pobortsev on 30.08.2021.
////  Copyright © 2021 IgnatyevProd. All rights reserved.
////
//
//import RIBs
//
//extension ViewableRouter {
//	func dismiss(toRoot: Bool, animated: Bool, completion: RouteCompletion?) {
//			/// контроллеры, которые будут удалены из стека, в зависимости от того, до какой глубины происходит dismiss
//			let dismissingViewControllers = toRoot
//				? getPresentedControllersStack(for: viewControllable.uiviewController)
//				: [viewControllable.uiviewController.topPresentedViewController]
//
//			/// связанные с контроллерами для удаления роутеры
//			let routersForDetach = findRouters(for: dismissingViewControllers)
//
//			viewControllable.uiviewController.dismiss(toRoot: toRoot, animated: animated) {
////				routersForDetach.forEach { $0.detachFromParent() }
//				completion?()
//			}
//		}
//}
//
//public typealias RouteCompletion = () -> Void
//
//extension Routing {
//	func findRouters(for viewControllers: [UIViewController]) -> [Routing] {
//		viewControllers
//			.map({ viewController in
//				findRouterInTree { router in
//					if let viewableRouter = router as? ViewableRouting {
//						return viewableRouter.viewControllable.uiviewController === viewController
//					} else {
//						return false
//					}
//				}
//			})
//			.compactMap { $0 }
//	}
//
//	func findRouter(for viewController: UIViewController) -> Routing? {
//			findRouters(for: [viewController]).first
//		}
//
//		/// Возвращает все презентованные по цепочке контроллеры
//		/// - Parameter presentingViewController: контроллер, с которого начинается цепочка
//		func getPresentedControllersStack(for presentingViewController: UIViewController) -> [UIViewController] {
//			var presentedControllers = [UIViewController]()
//
//			func addPresentedViewController(from viewController: UIViewController) {
//				if let presentedViewController = viewController.presentedViewController {
//					presentedControllers.append(presentedViewController)
//					addPresentedViewController(from: presentedViewController)
//				} else {
//					return
//				}
//			}
//
//			addPresentedViewController(from: presentingViewController)
//
//			return presentedControllers
//		}
//
//	func findRouterInTree(predicate: (Routing) -> (Bool)) -> Routing? {
//			findRoutersInSubtree(root: topRouter, predicate: predicate)
//		}
//
//	func findRoutersInSubtree(root: Routing, predicate: (Routing) -> (Bool)) -> Routing? {
//			if predicate(root) { return root }
//
//			for child in root.children {
//				if let router = findRoutersInSubtree(root: child, predicate: predicate) {
//					return router
//				}
//			}
//
//			return nil
//		}
//}
//
//extension UIViewController {
//var topPresentedViewController: UIViewController {
//		presentedViewController?.topPresentedViewController ?? self
//	}
//
//	func dismiss(toRoot: Bool,
//								 animated: Bool,
//								 completion: RouteCompletion?) {
//			let dismissalViewController = toRoot ? self : topPresentedViewController
//			dismissalViewController.dismiss(animated: animated, completion: completion)
//		}
//}
