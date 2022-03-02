//
//  NumberFormatterProtocol.swift
//  CountOnMe
//
//  Created by Yann Rouzaud on 02/03/2022.
//  Copyright © 2022 Vincent Saluzzo. All rights reserved.
//

import Foundation


protocol NumberFormatterProtocol: AnyObject {
    var maximumFractionDigits: Int { get set }
    var allowsFloats: Bool { get set }
    
    func string(from number: NSNumber) -> String?
}
