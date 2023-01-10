//
//  SSKit.swift
//  Charming
//
//  Created by minse on 2022/10/15.
//

import Foundation

public final class SSFramework<Base> {
    public let base: Base
    
    public init(_ base: Base) {
        self.base = base;
    }
}

public protocol SSKitNamespaceWrappable {
    associatedtype WrapperType
    
    static var ss: SSFramework<WrapperType>.Type { get }
    var ss: SSFramework<WrapperType> { get }
}


extension SSKitNamespaceWrappable {
    public static var ss: SSFramework<Self>.Type {
        get { return SSFramework<Self>.self }
    }
    
    public var ss: SSFramework<Self> {
        get { return SSFramework(self) }
    }
}

extension NSObject: SSKitNamespaceWrappable { }
