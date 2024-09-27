
import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var items: [PDFEntry]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    TopView
                    
                    if items.isEmpty {
                        noDataView
                    } else {
                        pdfListView
                    }
                    Spacer()
                }
                .overlay(
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            NavigationLink(destination: CreateInvoiceView()) {
                                VStack {
                                    Image(ImageString.plus)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                }
                                .frame(width: 50, height: 50)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
                            }
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, 30)
                )
            }
        }
        .navigationBarBackButtonHidden()
    }

    var TopView: some View {
        VStack {
            Text(Strings.topHeading)
                .font(.system(size: 25))
                .fontWeight(.semibold)
                .foregroundColor(Color.blue.opacity(0.6))
        }
        .frame(width: UIScreen.main.bounds.width, height: 80)
        .background(Color.white)
        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
    }

    var noDataView: some View {
        VStack {
            Image(ImageString.noData)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
            Text(Strings.noRecord)
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .foregroundColor(Color.gray)
            Text(Strings.addNewInvoice)
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .foregroundColor(Color.gray)
        }
        .padding(.top, 200)
    }
    
    var pdfListView: some View {
        VStack {
                  List {
                       ForEach(Array(items.enumerated().reversed()), id: \.element.id) { index, pdf in
                           let currentPDF = pdf
                           NavigationLink(destination: PDFPreviewView(data: currentPDF.pdfData,isfromHome:true)) {
                               VStack {
                                   HStack {
                                       Text("# \(items.count - index)")
                                           .font(.system(size: 20))
                                           .fontWeight(.bold)
                                           .foregroundColor(.blue)
                                       Text(pdf.name)
                                           .font(.system(size: 15))
                                           .fontWeight(.bold)
                                           .foregroundColor(.black)
                                       Spacer()
                                       
                                       Image("leftArrow")
                                           .resizable()
                                           .frame(width: 15, height: 15)
                                       Text("Swipe To Delete")
                                           .font(.system(size: 15))
                                           .fontWeight(.medium)
                                           .foregroundColor(.gray.opacity(0.3))
                                   }
                                   .padding(15)
                               }
                               .frame(width: UIScreen.main.bounds.width - 30)
                               .background(Color.white)
                               .cornerRadius(10)
                               .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
                           }
                           .buttonStyle(PlainButtonStyle())
                           .background(Color.clear)
                       }
                       .onDelete(perform: delete)
                   }
                  .listStyle(PlainListStyle())
                          .background(Color.clear)
                          .scrollContentBackground(.hidden)
        }
        .background(Color.clear)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func delete(at offsets: IndexSet) {
          for index in offsets {
              let pdfToDelete = items[items.count - 1 - index]
              
              do {
                  context.delete(pdfToDelete)
                  try context.save() 
              } catch {
                  print("Error deleting item: \(error)")
              }
          }
      }
}






