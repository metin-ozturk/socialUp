//
//  NumberRangeInteractor+Searcher.swift
//  InstantSearchCore
//
//  Created by Guy Daher on 14/06/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation

public protocol Boundable: class {
  associatedtype Number: Comparable & Numeric & InitaliazableWithFloat

  func applyBounds(bounds: ClosedRange<Number>?)
}
