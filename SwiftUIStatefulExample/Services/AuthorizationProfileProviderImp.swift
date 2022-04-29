//
//  AuthorizationProviderImp.swift
//  StatefulScreenExample
//
//  Created by Vladimir Pobortsev on 13.08.2021.
//  Copyright © 2021 IgnatyevProd. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation

final class ProfileProviderImp: AuthorizationProfileProvider {
	private let _profile: BehaviorRelay<Profile>
	
	let profileChange: Observable<Profile>
	
	private(set) var profile: Profile // = Profile(firstName: nil, lastName: nil, email: nil, phone: "+7 999 123 45 67", authorized: false)
	
	private(set) var smsCode = ""
	private var profileRequestsCount: Int = 0
	
	init() {
		profile = Profile(firstName: nil, lastName: nil, email: nil, phone: "+7 999 123 45 67", authorized: false)
		_profile = BehaviorRelay(value: profile)
		self.profileChange = _profile.asObservable()
	}
	
	func updateProfile(_ profile: Profile, completion: @escaping (Result<Void, Error>) -> Void) {
		DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + .random(in: 0.5...1)) { [weak self] in
			guard let self = self else { return }
			
			let isSuccess = Bool.random()
			
			let result: Result<Void, Error>
			if isSuccess {
				result = .success(Void())
				self.profile = profile
				
				self._profile.accept(self.profile)
			} else {
				result = .failure(NetworkError())
			}
			
			completion(result)
		}
	}
	
	func updatePhoneNumber(_ phoneNumber: String, completion: @escaping (Result<Void, Error>) -> Void) {
		DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + .random(in: 0.1...0.2)) {
			let isSuccess = Bool.random()
			let result: Result<Void, Error>
			switch isSuccess {
			case false:
				result = .failure(NetworkError())
			case true:
				result = .success(Void())
				self.profile = Profile(firstName: nil, lastName: nil, email: nil, phone: phoneNumber, authorized: true)
			}
			completion(result)
		}
		
	}
	
	func checkNumber(_ number: String?, completion: @escaping (Result<String, Error>) -> Void) {
		DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + .random(in: 0.5...1)) { [weak self] in
			let isSuccess = Bool.random()
			let result: Result<String, Error>
			switch isSuccess {
			case false:
				result = .failure(NetworkError())
			case true:
				let code = String.randomCode()
				self?.smsCode = code
				result = .success(code)
			}
			completion(result)
		}
	}
	
	func checkCode(code: String?, completion: @escaping (Result<Bool, AuthError>) -> Void) {
		DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + .random(in: 0.5...1)) { [weak self] in
			let isSuccess = Bool.random()
			let result: Result<Bool, AuthError>
			switch isSuccess {
			case false:
				result = .failure(.networkError)
			case true:
				if code != self?.smsCode {
					result = .failure(.validationError)
				} else {
					result = .success(true)
				}
			}
			completion(result)
		}
	}
}

extension ProfileProviderImp: ProfileService {
	func getProfile(_ completion: @escaping (Result<Profile, Error>) -> Void) {
		let result: Result<Profile, Error>
		if profileRequestsCount == 0 {
			// При первом запросе на загрузку профиля имитируем ошибку в целях демонстрации
			result = .failure(NetworkError())
		} else {
			result = .success(profile)
		}
		
		profileRequestsCount += 1
		
		let delay = Double.random(in: 0.25...1)
		DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + delay) {
			completion(result)
		}
	}
}

public enum AuthError: LocalizedError {
	case networkError
	case validationError
	
	public var errorDescription: String? {
		switch self {
		case .networkError: return "Кажется у вас отключен интернет"
		case .validationError: return "Введен неверный код"
		}
	}
}

struct NetworkError: LocalizedError {
	var errorDescription: String? { "Кажется у вас отключен интернет" }
}

struct ValidationCodeError: LocalizedError {
	var errorDescription: String? { "Введен неверный код" }
}
