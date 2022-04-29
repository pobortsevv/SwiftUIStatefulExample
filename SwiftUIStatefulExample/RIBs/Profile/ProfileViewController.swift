//
//  ProfileViewController.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class ProfileViewController: UIViewController, ProfileViewControllable {
  @IBOutlet private weak var tableView: UITableView!
	private let edit = UIBarButtonItem(title: "Edit",
																		 style: .plain,
																		 target: self,
																		 action: nil)

  private let loadingIndicatorView = LoadingIndicatorView()
  private let errorMessageView = ErrorMessageView()
  
  private let refreshControl = UIRefreshControl()

  private lazy var dataSource: RxTableViewSectionedAnimatedDataSource<Section> = {
    let makeCellForRowDataSource = TableViewHelper.makeCellForRowDataSource(vc: self)
    return RxTableViewSectionedAnimatedDataSource<Section>(configureCell: makeCellForRowDataSource)
  }()

  // MARK: View Events

  private let viewOutput = ViewOutput()

  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
  }
}

extension ProfileViewController {
  private func initialSetup() {
    title = "TableView Profile"

    errorMessageView.isVisible = false

    view.addStretchedToBounds(subview: loadingIndicatorView)
    view.addStretchedToBounds(subview: errorMessageView)
		
		navigationItem.rightBarButtonItem = self.edit

    tableView.refreshControl = refreshControl
    
    tableView.register(ContactFieldCell.self)
    tableView.register(DisclosureTextCell.self)

    tableView.rx.setDelegate(self).disposed(by: disposeBag)

    dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .fade,
                                                               reloadAnimation: .fade,
                                                               deleteAnimation: .fade)
  }
}

// MARK: - BindableView

extension ProfileViewController: BindableView {
  func getOutput() -> ProfileViewOutput {
    viewOutput
  }

  func bindWith(_ input: ProfilePresenterOutput) {
    bindTableView(input.viewModel)

    input.isContentViewVisible.drive(tableView.rx.isVisible).disposed(by: disposeBag)

    input.initialLoadingIndicatorVisible.drive(loadingIndicatorView.rx.isVisible).disposed(by: disposeBag)
    input.initialLoadingIndicatorVisible.drive(loadingIndicatorView.indicatorView.rx.isAnimating).disposed(by: disposeBag)
		
		input.isButtonEditEnable.do(onNext: { [weak self] isEnabled in
			if isEnabled {
				self?.edit.isEnabled = true
			} else {
				self?.edit.isEnabled = false
			}
		})
		.drive(edit.rx.isEnabled)
		.disposed(by: disposeBag)

    input.showError.emit(onNext: { [weak self] maybeViewModel in
      self?.errorMessageView.isVisible = (maybeViewModel != nil)

      if let viewModel = maybeViewModel {
        self?.errorMessageView.resetToEmptyState()

        self?.errorMessageView.setTitle(viewModel.title, buttonTitle: viewModel.buttonTitle, action: {
          self?.viewOutput.$retryButtonTap.accept(Void())
        })
      }
    }).disposed(by: disposeBag)
    
    input.hideRefreshControl.emit(to: refreshControl.rx.endRefreshing).disposed(by: disposeBag)
    
    refreshControl.rx.controlEvent(.valueChanged).bind(to: viewOutput.$pullToRefresh).disposed(by: disposeBag)
		
		edit.rx.tap.bind(to: viewOutput.$editProfileTap).disposed(by: disposeBag)
  }

  /// Преобразуем ProfileViewModel в представление, подходящее для TableView
  private func bindTableView(_ viewModel: Driver<ProfileViewModel>) {
    let sectionsSource = viewModel.map { viewModel -> [Section] in

      let rowItems: [RowItem] = [
				.authorized(viewModel.authorized),
				.contactOptionalText(viewModel.firstName),
				.contactOptionalText(viewModel.lastName),
        .contactOptionalText(viewModel.phone),
				.contactOptionalText(viewModel.email),
      ]

      return [Section(title: nil, items: rowItems)]
    }

    sectionsSource.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
  }
}

// MARK: - TableViewHelper

extension ProfileViewController {
  private enum TableViewHelper: Namespace {
    static func makeCellForRowDataSource(vc: ProfileViewController)
      -> RxTableViewSectionedAnimatedDataSource<Section>.ConfigureCell {
      return { _, tableView, indexPath, item -> UITableViewCell in
        switch item {
				case .authorized(let title):
					let cell: ContactFieldCell = tableView.dequeue(forIndexPath: indexPath)
					cell.textLabel?.text = title
					cell.textLabel?.textColor = title == "Незарегистрированный пользователь" ? .red : .green
					return cell
				
        case .contactField(let viewModel):
          let cell: ContactFieldCell = tableView.dequeue(forIndexPath: indexPath)
          cell.view.setTitle(viewModel.title, text: viewModel.text)
          return cell

        case .contactOptionalText(let viewModel):
          let cell: ContactFieldCell = tableView.dequeue(forIndexPath: indexPath)
          cell.view.setTitle(viewModel.title, text: viewModel.maybeText)
          return cell

        case .email(let viewModel):
          let cell: ContactFieldCell = tableView.dequeue(forIndexPath: indexPath)
          cell.view.setTitle(viewModel.title, text: viewModel.text)
          return cell
				}
      }
    }
  }
}

extension ProfileViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let rowItem = dataSource[indexPath]

    switch rowItem {
		case .authorized: break
    case .email: break
    case .contactField: break
    case .contactOptionalText: break
    }
  }
}

// MARK: - RibStoryboardInstantiatable

extension ProfileViewController: RibStoryboardInstantiatable {}

// MARK: - View Output

extension ProfileViewController {
	private struct ViewOutput: ProfileViewOutput {

    @PublishControlEvent var retryButtonTap: ControlEvent<Void>
    
    @PublishControlEvent var pullToRefresh: ControlEvent<Void>
	
		@PublishControlEvent var editProfileTap: ControlEvent<Void>
  }
}

// MARK: Section & Row Item

extension ProfileViewController {
  private struct Section: Hashable, AnimatableSectionModelType {
    var title: String?
    var items: [RowItem]

    var identity: String = "SingleSection" // т.к секция одна то уникальный id ей не нужен

    init(original: Section, items: [RowItem]) {
      self = original
      self.items = items
    }

    init(title: String?, items: [RowItem]) {
      self.title = title
      self.items = items
    }

    typealias Item = RowItem
  }

  private enum RowItem: Hashable, IdentifiableType {
		case authorized(String)
    case contactField(TitledText)
    case contactOptionalText(TitledOptionalText)
    case email(TitledText)

    var identity: String {
      switch self {
			case .authorized(let text): return text
      case .contactField(let viewModel): return viewModel.title
      case .contactOptionalText(let viewModel): return viewModel.title
      case .email(let viewModel): return viewModel.title
      }
    }
  }
}
