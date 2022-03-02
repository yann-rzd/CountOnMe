//
//  FailureNumberFormatterMock.swift
//  CountOnMeTests
//
//  Created by Yann Rouzaud on 02/03/2022.
//  Copyright © 2022 Vincent Saluzzo. All rights reserved.
//

import Foundation


@testable import CountOnMe


class FailureNumberFormatterMock: NumberFormatterProtocol {
    var maximumFractionDigits: Int = 6
    
    var allowsFloats: Bool = true
    
    func string(from number: NSNumber) -> String? {
        return nil
    }
    
    
}
