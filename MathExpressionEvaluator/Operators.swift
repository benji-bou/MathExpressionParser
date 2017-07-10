//
//  Operators.swift
//  BioSignalLayer
//
//  Created by Benjamin Bouachour on 04/07/2017.
//  Copyright © 2017 BioSerenity. All rights reserved.
//

import Foundation



public enum Operators : Character {
    case add = "+"
    case multi = "*"
    case div = "/"
    case sub = "-"
    case parenthesis = "("
    case closingParenthesis = ")"
    case brackets = "["
    case closingBrackets = "]"
    case exponent = "^"
    case modulo = "%"
    
    var order : Int {
        switch self {
        case .multi, .div, .modulo, .exponent:
            return 1
        case .add, .sub:
            return 2
        default :
            return 0
        }
    }
    
    var isOpenGroupOperator : Bool {
    return self == .parenthesis || self == .brackets
    }
    
    var isCloseGroupOperator : Bool {
    return self == .closingParenthesis || self == .closingBrackets
    }
    
    var isGroupOperator : Bool {
        return self == .parenthesis || self == .brackets || self == .closingParenthesis || self == .closingBrackets
    }
    
    var close : Operators? {
        switch self {
        case .brackets:
            return .closingBrackets
        case .parenthesis :
            return .closingParenthesis
        default :
            return nil
        }
    }

    public func nextPairClosing(from:String, at:String.CharacterView.Index) throws -> String.CharacterView.Index {
        if !self.isOpenGroupOperator {
            throw MathParserError.groupFailed(message: "Is not an opening group operator", operator: self)
        }
        let c = from.characters[at]
        if  c != self.rawValue {
            throw MathParserError.operatorsMismatch(self, c)
        }
        var openingCount = 0
        for index in from.characters.indices[at..<from.endIndex] {
            let c = from.characters[index]
            if let op = Operators(rawValue: c){
            if op == self {
                openingCount += 1
            } else if let close = self.close, op == close {
                openingCount -= 1
            }
            if openingCount == 0 {
                return index
            }
            }
        }
     throw  MathParserError.closingNotFound(self)
    }
    
}


