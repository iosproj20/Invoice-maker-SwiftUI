//
//  CreateInvoiceView.swift
//  PDFCrator
//
//  Created by My Mac on 25/09/24.
//

import SwiftUI
import PDFKit
import SwiftData

struct CreateInvoiceView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.presentationMode) var presentationMode
    @State private var showImagePicker = false
    @State private var selectedImage:UIImage?
    @State private var companyName: String = ""
    @State private var companyNumber: String = ""
    @State private var companyAddress: String = ""
    @State private var country: String = ""
    @State private var pincode: String = ""
    @State private var productName: String = ""
    @State private var quantity: String = ""
    @State private var price: String = ""
    @State private var isAddProductTap:Bool = false
    @State private var productArray: [Product] = []
    @State private var showPDFPreview: Bool = false
    @State private var pdfData: Data?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var selectedCountry: CountryModel?
    @State private var isPickerVisible = false
    
    
    var totalAmount: String {
        let total = productArray.reduce(0) { sum, product in
            if let price = Double(product.price.trimmingCharacters(in: ["$"])) {
                return sum + price
            }
            return sum
        }
        return "$\(total)"
    }
    var isFormComplete: Bool {
        return selectedImage != nil &&
               !companyName.isEmpty &&
               !companyNumber.isEmpty &&
               !companyAddress.isEmpty &&
               !country.isEmpty &&
               !pincode.isEmpty &&
               !productArray.isEmpty
    }
    
    var body: some View {
        ZStack{
            Color.white
                .edgesIgnoringSafeArea(.all)
            VStack{
                TopView
                ScrollView{
                    fillDetailsView
                    productList
                    addProductsView
                }
                bottomButtonView
                Spacer()
            }
            .onTapGesture {
                        UIApplication.shared.endEditing(true) // Dismiss the keyboard when tapping outside
                    }
            .fullScreenCover(isPresented: $showImagePicker) {
                        pickerView(selectedImage: $selectedImage)
                    }
            .alert(isPresented: $showAlert) {
                            Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
            .sheet(isPresented: $isPickerVisible) {
                CountryPicker(country: $selectedCountry, countrys: $country)
            }
          
            NavigationLink(
                destination: PDFPreviewView(data: pdfData ?? Data(), isfromHome: false), // Your PDF preview view
                isActive: $showPDFPreview,
                label: {
                    EmptyView()
                }
            )
            if isAddProductTap{
                ZStack{
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    VStack{
                        productdetailView
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
       
    }
    var TopView:some View{
        VStack{
            HStack{
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }){
                    VStack{
                        Image(ImageString.back)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40,height: 40)
                            .clipShape(Circle())
                    }
                }
                .padding(.leading,10)
                Spacer()
                Text(Strings.createInvoice)
                    .font(.system(size: 25))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.blue.opacity(0.6))
                    .padding(.leading,-30)
                Spacer()
            }
        }
        .frame(width: UIScreen.main.bounds.width,height: 80)
        .background(Color.white)
        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
    }
    
    var fillDetailsView:some View{
        VStack(spacing:15){
            companyLogoView
            companyNameView
            companyNumberView
            companyAddressView
            companyCountryView
            companyPinCodeView
        }
        .padding(.top,15)
    }
    
    var companyLogoView:some View{
        VStack(spacing:15){
            HStack{
                Text(Strings.companyLogo)
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.gray)
                Spacer()
            }
            .padding([.leading,.trailing],15)
            
            Button(action:{
                showImagePicker = true
            }){
                VStack{
                    VStack {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120,height: 120)
                                .clipShape(Circle())
                        } else {
                            Image(ImageString.plus)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    
                }
                .frame(width: 120,height: 120)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    var companyNameView:some View{
        VStack{
            HStack{
                Text(Strings.companyName)
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.gray)
                Spacer()
            }
            .padding([.leading,.trailing],15)
            
            VStack{
                TextField(Strings.placeHolderEnterCompanyName, text: $companyName)
                    .padding()
            }
            .frame(width:UIScreen.main.bounds.width-30,height: 40)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
    }
    
    var companyNumberView:some View{
        VStack{
            HStack{
                Text(Strings.companyNumber)
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.gray)
                Spacer()
            }
            .padding([.leading,.trailing],15)
            VStack{
                TextField(Strings.placeHolderEnterCompanyNumber, text: $companyNumber)
                    .keyboardType(.numberPad)
                       .onChange(of: companyNumber) { newValue in
                           if newValue.count > 10 {
                               companyNumber = String(newValue.prefix(10)) // restrict to 10 digits
                           }
                           companyNumber = companyNumber.filter { "0123456789".contains($0) } // allow only numbers
                       }
                    .padding()
            }
            .frame(width:UIScreen.main.bounds.width-30,height: 40)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
    }
    
    var companyAddressView:some View{
        VStack{
            HStack{
                Text(Strings.companyAddress)
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.gray)
                Spacer()
            }
            .padding([.leading,.trailing],15)
            VStack{
                TextField(Strings.placeHolderEnterCompanyAddress, text: $companyAddress)
                    .padding()
            }
            .frame(width:UIScreen.main.bounds.width-30,height: 40)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
    }
    var companyCountryView:some View{
        VStack{
            HStack{
                Text(Strings.country)
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.gray)
                Spacer()
            }
            .padding([.leading,.trailing],15)
            
            VStack{
                TextField(selectedCountry?.countryName ?? "Select Country", text: $country)
                        .padding()
                        .overlay(
                            HStack{
                                Spacer()
                                Button(action:{
                                    isPickerVisible.toggle()
                                }){
                                    VStack{
                                        Image(ImageString.downArrow)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width:15,height: 15)
                                    }
                                }
                            }
                                .padding(.trailing,10)
                        )
               
            }
            .frame(width:UIScreen.main.bounds.width-30,height: 40)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
    }
    var companyPinCodeView:some View{
        VStack{
            HStack{
                Text(Strings.pinCode)
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.gray)
                Spacer()
            }
            .padding([.leading,.trailing],15)
            
            VStack{
                TextField(Strings.placeHolderEnterPinCode, text: $pincode)
                    .keyboardType(.numberPad)
                        .onChange(of: pincode) { newValue in
                            pincode = pincode.filter { "0123456789".contains($0) } // allow only numbers
                        }
                    .padding()
            }
            .frame(width:UIScreen.main.bounds.width-30,height: 40)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
    }
    
    var addProductsView:some View{
        VStack{
            HStack{
                Button(action:{
                    productName = ""
                    quantity = ""
                    price = ""
                    isAddProductTap = true
                }){
                    HStack{
                        Image(ImageString.plus)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .clipShape(Circle())
                        Text(Strings.addProducts)
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.blue)
                        Spacer()
                    }
                }
            }
            .padding()
        }
        .frame(width: UIScreen.main.bounds.width - 30)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
        .padding(.top,15)
        .padding(.bottom,15)
    }
    
    
    var productdetailView:some View{
        VStack{
            VStack{
                VStack{
                    HStack{
                        Text(Strings.productName)
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                    VStack{
                        TextField(Strings.placeHolderEnterProductName, text: $productName)
                            .padding()
                    }
                    .frame(width:UIScreen.main.bounds.width-50,height: 40)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                VStack{
                    HStack{
                        Text(Strings.quantity)
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                    VStack{
                        TextField(Strings.placeHolderEnterQuantity, text: $quantity)
                            .padding()
                    }
                    .frame(width:UIScreen.main.bounds.width-50,height: 40)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                VStack{
                    HStack{
                        Text(Strings.price)
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                    VStack{
                        TextField(Strings.placeHolderEnterPrice, text: $price)
                            .padding()
                    }
                    .frame(width:UIScreen.main.bounds.width-50,height: 40)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                
                HStack{
                    Button(action:{
                        if productName.isEmpty || quantity.isEmpty || price.isEmpty{
                            alertMessage = "Please add all Details To Add Product"
                            showAlert = true
                        }else{
                            let total = (Double(quantity) ?? 0.0) * (Double(price) ?? 0.0)
                            productArray.append(Product(Name: productName, quantity: quantity, price: "\(total)"))
                            isAddProductTap = false
                        }
                    }){
                        VStack{
                            Text(Strings.add)
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white)
                                .padding()
                        }
                        .frame(width:120,height: 40)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray,lineWidth: 1)
                    )
                    Button(action:{
                        isAddProductTap = false
                    }){
                        VStack{
                            Text(Strings.cancel)
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(Color.blue)
                                .padding()
                        }
                        .frame(width:120,height: 40)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray,lineWidth: 1)
                    )
                }
                .padding(.top,15)
            }
            .padding(15)
            
        }
        .frame(width: UIScreen.main.bounds.width - 30)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
    }
    
    var productList:some View{
        VStack{
            ForEach(productArray){ product in
                VStack{
                    HStack{
                        VStack(spacing:5){
                            HStack{
                                Text(Strings.productName)
                                    .font(.system(size: 10))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.gray)
                            }
                            HStack{
                                Text(product.Name)
                                    .font(.system(size: 15))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            }
                        }
                        Spacer()
                        VStack(spacing:5){
                            HStack{
                                Text(Strings.quantity)
                                    .font(.system(size: 10))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.gray)
                            }
                            HStack{
                                Text(product.quantity)
                                    .font(.system(size: 15))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            }
                        }
                        Spacer()
                        VStack(spacing:5){
                            HStack{
                                Text(Strings.price)
                                    .font(.system(size: 10))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.gray)
                            }
                            HStack{
                                Text(product.price)
                                    .font(.system(size: 15))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding(15)
                    
                }
                .frame(width: UIScreen.main.bounds.width - 30)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
            }
        }
        .padding(.top,15)
    }
    
    var bottomButtonView:some View{
        VStack{
            HStack{
                Button(action:{
                    validateInputs()
                }){
                    VStack{
                        Text(Strings.create)
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.white)
                            .padding()
                    }
                    .frame(width:150,height: 40)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray,lineWidth: 1)
                )
                
                Button(action:{
                    if let pdfDatas = CommonUtility.shared.generatePDF(companyName: companyName, selectedImage: selectedImage, companyNumber: companyNumber, companyAddress: companyAddress, country: country, pincode: pincode, productArray: productArray, totalAmount: totalAmount)  {
                        if let generatedPDFData = CommonUtility.shared.generatePDF(companyName: companyName, selectedImage: selectedImage, companyNumber: companyNumber, companyAddress: companyAddress, country: country, pincode: pincode, productArray: productArray, totalAmount: totalAmount)  {
                            // Set pdfData only after PDF is successfully generated
                            pdfData = generatedPDFData
                            // After a slight delay, toggle the preview
                            DispatchQueue.main.async {
                                showPDFPreview = true
                            }
                        }
                    }
                }){
                    VStack{
                        Text(Strings.preview)
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.blue)
                            .padding()
                    }
                    .frame(width:150,height: 40)
                }
                .disabled(!isFormComplete)
                .opacity(isFormComplete ? 1.0 : 0.5)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray,lineWidth: 1)
                )
            }
            .padding(.top,10)
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width,height: 100)
        .background(Color.white)
        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
        .padding(.bottom,-50)
    }
    private func validateInputs() {
           // Check if any of the fields are empty
           if selectedImage == nil {
               alertMessage = "Please select an image."
               showAlert = true
           } else if companyName.isEmpty {
               alertMessage = "Please enter a company name."
               showAlert = true
           } else if companyNumber.isEmpty {
               alertMessage = "Please enter a company number."
               showAlert = true
           } else if companyAddress.isEmpty {
               alertMessage = "Please enter a company address."
               showAlert = true
           } else if country.isEmpty {
               alertMessage = "Please enter a country."
               showAlert = true
           } else if pincode.isEmpty {
               alertMessage = "Please enter a pincode."
               showAlert = true
           } else if productArray.isEmpty {
               alertMessage = "Please add at least one product."
               showAlert = true
           } else {
               // Call your function if all validations pass
               if let pdfData = CommonUtility.shared.generatePDF(companyName: companyName, selectedImage: selectedImage, companyNumber: companyNumber, companyAddress: companyAddress, country: country, pincode: pincode, productArray: productArray, totalAmount: totalAmount) {
                   CommonUtility.shared.savePDF(data: pdfData, context: context){ success in
                       if success {
                           // Dismiss the view after the PDF is saved
                           DispatchQueue.main.async {
                               presentationMode.wrappedValue.dismiss()
                           }
                       } else {
                           print("Failed to save the PDF or user canceled")
                       }
                   }
                   //presentationMode.wrappedValue.dismiss()
               }
           }
       }

}

