//
//  ProfileServiceImp.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Сервис имитирует асинхронную работу запросов на бэк
final class ProfileServiceImp: ProfileService {
  let profileChange: Observable<Profile>
  
  private(set) var profile: Profile
  private let _profile: BehaviorRelay<Profile>

  private var profileRequestsCount: Int = 0
  
  init() {
    profile = Profile(firstName: nil, lastName: nil, email: nil, phone: "+7 999 123 45 67", authorized: false)
    _profile = BehaviorRelay(value: profile)
    self.profileChange = _profile.asObservable()
  }

  func getProfile(_ completion: @escaping (Result<Profile, Error>) -> Void) {
    let result: Result<Profile, Error>
    if profileRequestsCount == 0 {
      // При первом запросе на загрузку профиля имитируем ошибку в целях демонстрации
      result = .failure(ApiError.badNetwork)
    } else {
      result = .success(profile)
    }
    
    profileRequestsCount += 1
    
    let delay = Double.random(in: 0.25...3)
    DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + delay) {
      completion(result)
    }
  }
  
  func updateEmail(_ newEmail: String, completion: @escaping (Result<Void, Error>) -> Void) {
    let delay = Double.random(in: 1...2)
    DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + delay) {
      completion(.success(Void()))
    }
  }
}

enum ApiError: LocalizedError {
  case badNetwork
  
  var errorDescription: String? {
    switch self {
    case .badNetwork: return "Произошла ошибка при загрузке данных из сети."
    }
  }
}
