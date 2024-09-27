//
//  Item.swift
//  PDFCrator
//
//  Created by My Mac on 25/09/24.
//

import Foundation
import SwiftData

@Model
class PDFEntry {
    var id: UUID
    var name: String
    var pdfData: Data

    init(name: String, pdfData: Data) {
        self.id = UUID()
        self.name = name
        self.pdfData = pdfData
    }
}
