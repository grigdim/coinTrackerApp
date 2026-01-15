//
//  ViewState.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 15/1/26.
//

import SwiftUI

/// Generic view state to represent loading lifecycle.
enum ViewState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(Error)
}
