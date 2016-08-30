//
//  NodeDescription.swift
//  Katana
//
//  Created by Luca Querella on 09/08/16.
//  Copyright © 2016 Bending Spoons. All rights reserved.
//

import UIKit

public protocol AnyNodeDescription {
  var frame: CGRect { get set }
  var key: String? { get }
  var anyProps: Any { get }
  
  func node(store: AnyStore) -> RootNode
  func node(parentNode: AnyNode) -> AnyNode
  func replaceKey() -> Int
}

public protocol NodeDescription : AnyNodeDescription {
  associatedtype NativeView: UIView
  associatedtype Props: Equatable, Frameable
  associatedtype State: Equatable
  
  static var initialState: State { get }
  
  var props: Props { get set }

  static func applyPropsToNativeView(props: Props,
                                     state: State,
                                     view: NativeView,
                                     update: @escaping (State)->(),
                                     node: AnyNode) -> Void
  
  static func render(props: Props,
                     state: State,
                     update: @escaping (State)->(),
                     dispatch: StoreDispatch) -> [AnyNodeDescription]
  
  static func childrenAnimationForNextRender(currentProps: Props,
                                             nextProps: Props,
                                             currentState: State,
                                             nextState: State,
                                             parentAnimation: Animation) -> Animation
  
  func replaceKey() -> Int
}

extension NodeDescription {
  public var frame : CGRect {
    get {
      return self.props.frame
    }

    set(newFrame) {
      self.props.frame = newFrame
    }
  }
  
  public var key: String? {
    guard let props = self.props as? Keyable else {
      return nil
    }
    
    return props.key
  }
  
  public var anyProps: Any {
    return self.props
  }
}

extension NodeDescription {
  public static func applyPropsToNativeView(props: Props,
                                     state: State,
                                     view: NativeView,
                                     update: @escaping (State)->(),
                                     node: AnyNode) ->  Void {
    view.frame = props.frame
  }
  
  public static func childrenAnimationForNextRender(currentProps: Props,
                                                    nextProps: Props,
                                                    currentState: State,
                                                    nextState: State,
                                                    parentAnimation: Animation) -> Animation {
    return parentAnimation
  }
  
  public func node(store: AnyStore) -> RootNode {
    return RootNode(store: store, node: Node(description: self, parentNode: nil, store: store))
  }
  
  public func node(parentNode: AnyNode) -> AnyNode {
    return Node(description: self, parentNode: parentNode, store: parentNode.store)
  }
  
  public func replaceKey() -> Int {
    if let props = self.props as? Keyable, let key = props.key {
      return "\(ObjectIdentifier(type(of: self)).hashValue)_\(key)".hashValue
    }

    return ObjectIdentifier(type(of: self)).hashValue
  }
}