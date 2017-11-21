//
//  DependencyManager.swift
//  DWM
//
//  Created by Clay Ellis on 11/19/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation
import Swinject

protocol DependencyMangerProtocol {
    associatedtype Service: Any
    func resolve<Service>(after primary: Service?) -> Service
}

open class DependencyManager {

    public enum Error: Swift.Error {
        case resolutionFailed
    }

    /// A singleton instance of `DependencyManager`.
    public static var shared = DependencyManager()

    public let container = Container()

    public init() {}

    /// Configures the dependencies in the shared `Container`.
    public func configureDependencies() {
        registerConfiguration()
        registerProviders()
        registerRepositories()
        registerServices()
        registerViewModels()
        registerCoordinators()
        _ = container.synchronize()
    }

    /// Register a `Configuration` in the shared `Container`.
    open func registerConfiguration() {

    }

    /// Register providers in the shared `Container`. Subclasses should call super.
    open func registerProviders() {

    }

    /// Register persistent repositories in the shared `Container`. Subclasses should call super.
    open func registerRepositories() {

    }

    /// Register services in the shared `Container`. Subclasses should call super.
    open func registerServices() {

    }

    /// Register view models in the shared `Container`.
    open func registerViewModels() {

    }

    /// Register coorindators in the shared `Container`.
    open func registerCoordinators() {

    }

}

extension DependencyManager {

    /// Returns the `primary` service if it is not `nil`, otherwise resolves and returns the service in the `shared` `Container`.
    /// - parameter after: The service which will be returned if not `nil`
    public func resolve<T: Any>(after primary: T?) throws -> T {
        guard let resolved = primary ?? container.resolve(T.self) else {
            throw Error.resolutionFailed
        }
        return resolved
    }

    public func resolve<T: Any>(_ serviceType: T.Type) throws -> T {
        guard let resolved = container.resolve(T.self) else {
            throw Error.resolutionFailed
        }
        return resolved
    }

}

extension Container {
    @discardableResult
    public func registerInContainerScope<Service>(_ serviceType: Service.Type, name: String? = nil, factory: @escaping (Resolver) -> Service) -> Swinject.ServiceEntry<Service> {
        return register(serviceType, name: name, factory: factory).inObjectScope(.container)
    }
}
