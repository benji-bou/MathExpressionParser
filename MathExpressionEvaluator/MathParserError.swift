//
//  MathParserError.swift
//  BioSignalLayer
//
//  Created by Benjamin Bouachour on 04/07/2017.
//  Copyright © 2017 BioSerenity. All rights reserved.
//

import Foundation


public enum MathParserError : Error {
    case expressionEmpty
    case expressionError(message:String, expression: String?, position:String.CharacterView.Index?)
    case operatorsMismatch(Operators, Character)
    case closingNotFound(Operators)
    case groupFailed(message:String, operator: Operators?)
}
