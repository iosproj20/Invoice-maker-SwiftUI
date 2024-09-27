//
//  pickerView.swift
//  PDFCrator
//
//  Created by My Mac on 25/09/24.
//

import SwiftUI

struct pickerView: View {
    
    @Binding var selectedImage: UIImage?
    var body: some View {
        VStack{
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}


