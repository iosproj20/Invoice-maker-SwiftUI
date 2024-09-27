//
//  PDFPreviewView.swift
//  PDFCrator
//
//  Created by My Mac on 26/09/24.
//

import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    
    @Environment(\.presentationMode) var presentationMode
    var data:Data
    var isfromHome:Bool
    @State private var showAlert = false
    
    var body: some View {
        ZStack{
            Color.white
                .edgesIgnoringSafeArea(.all)
            VStack{
                TopView
                pdfView
                Spacer()
            }
            .navigationBarBackButtonHidden()
            .alert(isPresented: $showAlert) { // Alert configuration
                       Alert(
                           title: Text("Download Complete"),
                           message: Text("The PDF has been downloaded successfully."),
                           dismissButton: .default(Text("OK"))
                       )
                   }
        }
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
                Text(Strings.preview)
                    .font(.system(size: 25))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.blue.opacity(0.6))
                    .padding(.leading,-30)
                Spacer()
                
                
                if isfromHome{
                    VStack{
                        Button(action:{
                          
                            CommonUtility.shared.downloadPDF(data: data) { success in
                                if success{
                                    showAlert = true
                                }
                            }
                        }){
                            VStack{
                                Image(ImageString.download)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 25,height: 25)
                            }
                        }
                        .hidden()
                    }
                    .padding(.trailing,15)
                }
               
            }
        }
        .frame(width: UIScreen.main.bounds.width,height: 80)
        .background(Color.white)
        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
    }
    
    var pdfView:some View{
        VStack{
            CommonUtility.PDFKitView(data: data)
        }
        .frame(width: UIScreen.main.bounds.width - 30)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
        .padding(.top,20)
    }

}


