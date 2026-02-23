//
//  Extensions.swift
//  RenalCalculi
//
//  Created by SAIL on 04/12/25.
//

import Foundation
import UIKit

extension String {
    var data: Data {
        return self.data(using: .utf8)!
    }
}

extension UIImage {
    func pixelBuffer() -> Data? {
        return self.pngData() // simple version
    }
}
