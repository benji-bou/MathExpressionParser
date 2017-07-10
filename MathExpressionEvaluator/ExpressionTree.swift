//
//  ExpressionTree.swift
//  BioSignalLayer
//
//  Created by Benjamin Bouachour on 04/07/2017.
//  Copyright © 2017 BioSerenity. All rights reserved.
//

import Foundation

public protocol ExpressionLeaf {
    var expression : String {get set}
}



public struct OperandLeaf : ExpressionLeaf {
    public var expression : String
    
}

public struct ExpressionTree : ExpressionLeaf {
    
    public let `operator` : Operators
    public let operands : [ExpressionLeaf]
    public var expression : String 
}




