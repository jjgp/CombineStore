//
//  GameState.swift
//  TicTacToe
//
//  Created by Jason Prasad on 5/14/20.
//  Copyright © 2020 Jason Prasad. All rights reserved.
//

import Foundation

public enum Player: Equatable {
  case o
  case x

  public mutating func toggle() {
    switch self {
    case .o: self = .x
    case .x: self = .o
    }
  }

  public var label: String {
    switch self {
    case .o: return "⭕️"
    case .x: return "❌"
    }
  }
}

public struct GameState: Equatable {
  public var board: [[Player?]] = .empty
  public var currentPlayer: Player = .x
  public var oPlayerName: String
  public var xPlayerName: String

  public init(oPlayerName: String, xPlayerName: String) {
    self.oPlayerName = oPlayerName
    self.xPlayerName = xPlayerName
  }

  public var currentPlayerName: String {
    switch self.currentPlayer {
    case .o: return self.oPlayerName
    case .x: return self.xPlayerName
    }
  }
}

extension Array where Element == [Player?] {
  public static let empty: Self = [
    [nil, nil, nil],
    [nil, nil, nil],
    [nil, nil, nil],
  ]

  public var isFilled: Bool {
    self.allSatisfy { row in row.allSatisfy { $0 != nil } }
  }

  func hasWin(_ player: Player) -> Bool {
    let winConditions = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [6, 4, 2],
    ]

    for condition in winConditions {
      let matchCount =
        condition
        .map { self[$0 % 3][$0 / 3] }
        .filter { $0 == player }
        .count

      if matchCount == 3 {
        return true
      }
    }
    return false
  }

  public var hasWinner: Bool {
    hasWin(.x) || hasWin(.o)
  }
}
