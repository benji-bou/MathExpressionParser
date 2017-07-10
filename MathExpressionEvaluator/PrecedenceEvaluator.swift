//
//  PrecedenceEvaluator.swift
//  BioSignalLayer
//
//  Created by Benjamin Bouachour on 04/07/2017.
//  Copyright © 2017 BioSerenity. All rights reserved.
//

import Foundation



extension String {
    public func cleanUpMathematical() throws -> String {
        var exp = self.components(separatedBy: .whitespacesAndNewlines).joined()
        try exp.isValidMathematical()
        while (true) {
            guard let currentOperator = Operators(rawValue:exp.characters[exp.startIndex]), currentOperator.isGroupOperator else {
                return exp
            }
            let next = try currentOperator.nextPairClosing(from: exp, at: exp.startIndex)
            if  exp.characters.index(after: next) == exp.endIndex {
                exp = exp.substring(with: exp.characters.index(after: exp.startIndex)..<next)
            }
            else {
                return exp
            }
        }
    }
    
    
    
    public func isValidMathematical() throws {
        if self.isEmpty {
            throw MathParserError.expressionEmpty
        }
        let exp = self.components(separatedBy: .whitespacesAndNewlines).joined()
        var openingBrackets = 0
        var openingParenthesis = 0
        var lastCharacterIsOperator : Operators? = nil
        var currentCharacterIsOperator : Operators? = nil
        
        for index in exp.characters.indices[exp.startIndex..<exp.endIndex] {
            let c = exp.characters[index]
            currentCharacterIsOperator = nil
            if let op  = Operators(rawValue: c) {
                currentCharacterIsOperator = op
            }
            if let lastCharacterIsOperator = lastCharacterIsOperator ,
                let currentCharacterIsOperator = currentCharacterIsOperator {
                switch (lastCharacterIsOperator, currentCharacterIsOperator) {
                case let (last, current) where  last.order == 1 && current.order == 1 || last.order == 2 && current.order == 1:
                    throw MathParserError.expressionError(message: "Operator \(last.rawValue) cannot be followed by \(current.rawValue) operator", expression: exp, position: index)
                case let (last, current) where  !last.isGroupOperator && current.isCloseGroupOperator:
                    throw MathParserError.expressionError(message: "Operator \(last.rawValue) cannot be followed by \(current.rawValue) operator", expression: exp, position: index)
                case let (last, current) where (last == .closingParenthesis || last == .closingBrackets) && (current == .parenthesis || current == .brackets) :
                    throw MathParserError.expressionError(message:"There must be an arithmetical operator between closing \(last.rawValue) and opening \(current.rawValue)", expression: exp, position: index)
                case let (last, current) where last == .parenthesis  &&  current == .closingParenthesis || last == .brackets && current == .closingBrackets:
                    throw MathParserError.expressionError(message:"There must be an mathematical expretion between opening \(last.rawValue) and closing \(current.rawValue)", expression: exp, position: index)
                case let (last, current) where (last == .parenthesis || last == .brackets)  &&  (current == .closingParenthesis || current == .closingBrackets):
                    throw MathParserError.expressionError(message:"An opening \(last.rawValue) group cannot be followed by a closing \(current.rawValue) group", expression: exp, position: index)
                default : break
                }
            }
            lastCharacterIsOperator = currentCharacterIsOperator
            
            switch c {
            case "(":
                openingParenthesis += 1
            case ")":
                openingParenthesis -= 1
            case "[":
                openingBrackets += 1
            case "]":
                openingBrackets -= 1
            default:break
            }
            
        }
        if let last = lastCharacterIsOperator, last.isGroupOperator == false || last == .parenthesis || last == .brackets {
            throw MathParserError.expressionError(message: "Expression may not be finished by \(last.rawValue)", expression: exp, position: exp.index(before: exp.endIndex))
        }
        if openingBrackets != 0 {
            throw MathParserError.expressionError(message: "Missing \(openingBrackets > 0 ? "closing" : "opening")  bracket", expression: exp, position: nil )
        }
        if openingParenthesis != 0 {
            throw MathParserError.expressionError(message: "Missing \(openingParenthesis > 0 ? "closing" : "opening")  parenthesis", expression: exp, position: nil )
        }
        
    }
}

public class PrecedenceEvaluator {
    
    let expression : String
    
    
    
    var operatorIndex : [(Operators, String.CharacterView.Index)] = []
    
    init(expression exp: String) throws {
        expression = try  exp.cleanUpMathematical()
    }
    
    public static func evaluate(expression: String) throws -> ExpressionLeaf {
        let eval = try PrecedenceEvaluator(expression:expression)
        return try eval.evaluate()
    }
    
    private func createNode(currentOperator:Operators, i : String.CharacterView.Index) throws -> ExpressionTree {
        var expressionLeaf = [ExpressionLeaf]()
        expressionLeaf.append(try PrecedenceEvaluator.evaluate(expression: expression.substring(with: expression.startIndex..<i)))
        expressionLeaf.append(try PrecedenceEvaluator.evaluate(expression: expression.substring(with: expression.characters.index(after: i)..<expression.endIndex)))
        return ExpressionTree(operator:currentOperator, operands: expressionLeaf, expression:expression)
    }
    
    func evaluate() throws  -> ExpressionLeaf {
        if expression.isEmpty {
            throw MathParserError.expressionEmpty
        }

        var i = expression.startIndex
        while i < expression.endIndex {
            if let currentOperator = Operators(rawValue:expression.characters[i]) {
                switch currentOperator {
                case let o where o.isGroupOperator == true :
                    i = try o.nextPairClosing(from: expression, at: i)
                case let o where o.order == 2 :
                    return try createNode(currentOperator: currentOperator, i: i)
                case let o where o.order == 1 :
                    operatorIndex.append((currentOperator, i))
                default : break
                }
            }
            i = expression.characters.index(after: i)
        }
        if let (currentOperator, i) = operatorIndex.first {
            return try createNode(currentOperator: currentOperator, i: i)
       }
        return OperandLeaf(expression:expression)
    }
}
