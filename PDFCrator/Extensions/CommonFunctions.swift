//
//  CommonFunctions.swift
//  PDFCrator
//
//  Created by My Mac on 26/09/24.
//


import Foundation
import UIKit
import SwiftData
import SwiftUI
import PDFKit



extension UIApplication {
    func endEditing(_ force: Bool) {
        self.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

class CommonUtility {
    // Singleton instance
    static let shared = CommonUtility()
    
    // Private initializer to prevent instantiation
    private init() {}
    
    // MARK: - To Save PDF in SwiftData
    
    func addItem(_ item: PDFEntry, context: ModelContext) {
        var items = [PDFEntry]()
        items.insert(item, at: 0)
        do {
            try context.insert(item)
            try context.save() // Save the context after insertion
        } catch {
            print("Error saving item: \(error)")
        }
    }
    
    // MARK: - To Save PDF in Device
    
    func savePDF(data: Data, context: ModelContext, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "Save PDF", message: "Enter a name for the PDF file", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter file name (optional)"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let enteredFileName = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            var fileName = enteredFileName?.isEmpty == false ? enteredFileName! : "Bill"
            fileName = self.sanitizeFileName(fileName)
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            var fileIndex = 1
            var pdfURL: URL
            
            repeat {
                pdfURL = documentsDirectory.appendingPathComponent(fileName + (enteredFileName?.isEmpty == false ? "" : "\(fileIndex)").appending(".pdf"))
                fileIndex += 1
            } while FileManager.default.fileExists(atPath: pdfURL.path)
            
            do {
                try data.write(to: pdfURL)
                print("PDF saved successfully at \(pdfURL)")
                let pdfEntry = PDFEntry(name: pdfURL.lastPathComponent, pdfData: data)
                CommonUtility.shared.addItem(pdfEntry, context: context)
                
                let activityVC = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
                if let topController = UIApplication.shared.windows.first?.rootViewController {
                    topController.present(activityVC, animated: true, completion: nil)
                }

                // Call the completionHandler with 'true' to indicate success
                completionHandler(true)
                
            } catch {
                print("Could not save PDF: \(error.localizedDescription)")
                
                // Call the completionHandler with 'false' to indicate failure
                completionHandler(false)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Call completion handler with 'false' in case of cancel
            completionHandler(false)
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func downloadPDF(data: Data, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "Save PDF", message: "Enter a name for the PDF file", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter file name (optional)"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let enteredFileName = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            var fileName = enteredFileName?.isEmpty == false ? enteredFileName! : "Bill"
            fileName = self.sanitizeFileName(fileName)
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            var fileIndex = 1
            var pdfURL: URL
            
            repeat {
                pdfURL = documentsDirectory.appendingPathComponent(fileName + (enteredFileName?.isEmpty == false ? "" : "\(fileIndex)") + ".pdf")
                fileIndex += 1
            } while FileManager.default.fileExists(atPath: pdfURL.path)
            
            do {
                // Attempt to write the data to the file
                try data.write(to: pdfURL)
                print("PDF saved successfully at \(pdfURL)")
                
                // Present the Activity View Controller for sharing the saved PDF
                let activityVC = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
                if let topController = UIApplication.shared.windows.first?.rootViewController {
                    topController.present(activityVC, animated: true, completion: nil)
                }

                // Call the completionHandler with 'true' to indicate success
                completionHandler(true)
                
            } catch {
                print("Could not save PDF: \(error.localizedDescription)")
                // Call the completionHandler with 'false' to indicate failure
                completionHandler(false)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Call completion handler with 'false' in case of cancel
            completionHandler(false)
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    private func sanitizeFileName(_ fileName: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>:.")
        return fileName.components(separatedBy: invalidCharacters).joined(separator: "")
    }
    
    
    // MARK: - To Generate PDF
    
    func generatePDF(companyName:String,selectedImage:UIImage?,companyNumber:String,companyAddress:String,country:String,pincode:String,productArray:[Product],totalAmount:String) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "App Name",
            kCGPDFContextAuthor: companyName
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 595.2 // A4 paper size in points
        let pageHeight = 841.8 // A4 paper size in points
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)
        
        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            
            // Draw Logo
            let logoYPosition: CGFloat = 20
            if let logo = selectedImage {
                logo.draw(in: CGRect(x: 20, y: logoYPosition, width: 100, height: 100))
            }
            
            // Left-aligned data (Company name and number)
            let boldAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
            let regularAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
            
            let leftColumnX: CGFloat = 20 // Left column starting X coordinate
            let yStartingPosition: CGFloat = 130 // Same starting Y position for both left and right columns
            
            companyName.draw(in: CGRect(x: leftColumnX, y: yStartingPosition, width: 300, height: 30), withAttributes: boldAttributes)
            companyNumber.draw(in: CGRect(x: leftColumnX, y: yStartingPosition + 30, width: 300, height: 30), withAttributes: regularAttributes)
            
            // Right-aligned data (Company address, country, pin code)
            let rightAlignedAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .paragraphStyle: rightAlignedParagraphStyle()
            ]
            
            let rightPadding: CGFloat = 20
            let addressWidth: CGFloat = pageWidth - 40 // Width for right-aligned data
            
            // Align the right-side data to match the top of the logo (20 points down)
            let addressRect = CGRect(x: pageWidth - addressWidth - rightPadding, y: logoYPosition, width: addressWidth, height: 30)
            let countryRect = CGRect(x: pageWidth - addressWidth - rightPadding, y: logoYPosition + 30, width: addressWidth, height: 30)
            let pinCodeRect = CGRect(x: pageWidth - addressWidth - rightPadding, y: logoYPosition + 60, width: addressWidth, height: 30)
            
            companyAddress.draw(in: addressRect, withAttributes: rightAlignedAttributes)
            country.draw(in: countryRect, withAttributes: rightAlignedAttributes)
            pincode.draw(in: pinCodeRect, withAttributes: rightAlignedAttributes)
            
            // Double Line after Company Info (Blue Color)
            let blueLinePath = UIBezierPath()
            blueLinePath.move(to: CGPoint(x: 20, y: 230))
            blueLinePath.addLine(to: CGPoint(x: pageWidth - 20, y: 230))
            blueLinePath.move(to: CGPoint(x: 20, y: 235))
            blueLinePath.addLine(to: CGPoint(x: pageWidth - 20, y: 235))
            blueLinePath.lineWidth = 1
            UIColor.black.setStroke()
            blueLinePath.stroke()
            
            // Add some spacing between the line and the table
            let yStartForTable: CGFloat = 285 // Adjusted position for table start
            
            // Table Headers
            let headers = ["Product Name", "Quantity", "Price"]
            let headerAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
            
            // Define table column widths
            let totalTableWidth = pageWidth - 40.0 // 20 padding from both sides
            let columnWidths = [totalTableWidth * 0.5, totalTableWidth * 0.25, totalTableWidth * 0.25]
            
            // Table border settings
            let rowHeight = 30.0
            let tableStartX: CGFloat = 20.0 // 20 points padding from the left
            var yPosition = yStartForTable
            
            // Center-aligned paragraph style for table content
            let centerAlignedAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .paragraphStyle: centerAlignedParagraphStyle()
            ]
            
            // Draw Table Headers inside a box
            for (index, header) in headers.enumerated() {
                let columnX = tableStartX + CGFloat(columnWidths.prefix(index).reduce(0, +))
                let headerRect = CGRect(x: columnX, y: yPosition, width: CGFloat(columnWidths[index]), height: rowHeight)
                header.draw(in: headerRect, withAttributes: centerAlignedAttributes)
                
                // Draw header border
                let headerBorder = UIBezierPath(rect: headerRect)
                UIColor.black.setStroke()
                headerBorder.lineWidth = 1
                headerBorder.stroke()
            }
            
            yPosition += rowHeight // Move to the first row
            
            // Table Data in rows with boxes around each cell
            for product in productArray {
                let productData = [product.Name, product.quantity, product.price]
                
                for (index, data) in productData.enumerated() {
                    let columnX = tableStartX + CGFloat(columnWidths.prefix(index).reduce(0, +))
                    let cellRect = CGRect(x: columnX, y: yPosition, width: CGFloat(columnWidths[index]), height: rowHeight)
                    data.draw(in: cellRect, withAttributes: centerAlignedAttributes)
                    
                    // Draw cell border
                    let cellBorder = UIBezierPath(rect: cellRect)
                    UIColor.black.setStroke()
                    cellBorder.lineWidth = 1
                    cellBorder.stroke()
                }
                
                yPosition += rowHeight // Move to the next row
            }
            
            // Draw total row inside a box
            let totalLabel = "Total"
            totalLabel.draw(in: CGRect(x: tableStartX + columnWidths[0], y: yPosition, width: columnWidths[1], height: rowHeight), withAttributes: centerAlignedAttributes)
            totalAmount.draw(in: CGRect(x: tableStartX + columnWidths[0] + columnWidths[1], y: yPosition, width: columnWidths[2], height: rowHeight), withAttributes: centerAlignedAttributes)
            
            // Draw total row border
            let totalLabelRect = CGRect(x: tableStartX + columnWidths[0], y: yPosition, width: columnWidths[1], height: rowHeight)
            let totalAmountRect = CGRect(x: tableStartX + columnWidths[0] + columnWidths[1], y: yPosition, width: columnWidths[2], height: rowHeight)
            let totalLabelBorder = UIBezierPath(rect: totalLabelRect)
            let totalAmountBorder = UIBezierPath(rect: totalAmountRect)
            UIColor.black.setStroke()
            totalLabelBorder.lineWidth = 1
            totalAmountBorder.lineWidth = 1
            totalLabelBorder.stroke()
            totalAmountBorder.stroke()
            
            // Adjusting spacing between table and the blue line at the bottom
            let spacingBetweenTableAndLine: CGFloat = 50 // Equal to the space before the table
            let yAfterTable = yPosition + rowHeight + spacingBetweenTableAndLine
            
            // Blue Lines after Table
            let blueLinePathAfterTable = UIBezierPath()
            blueLinePathAfterTable.move(to: CGPoint(x: 20, y: yAfterTable))
            blueLinePathAfterTable.addLine(to: CGPoint(x: pageWidth - 20, y: yAfterTable))
            blueLinePathAfterTable.move(to: CGPoint(x: 20, y: yAfterTable + 5))
            blueLinePathAfterTable.addLine(to: CGPoint(x: pageWidth - 20, y: yAfterTable + 5))
            blueLinePathAfterTable.lineWidth = 1
            UIColor.black.setStroke()
            blueLinePathAfterTable.stroke()
        }
        
        return data
    }

    private func rightAlignedParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        return paragraphStyle
    }

    private func centerAlignedParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return paragraphStyle
    }

    // MARK: - For Showing PDF
    
    struct PDFKitView: UIViewRepresentable {
        let data: Data

        func makeUIView(context: Context) -> PDFView {
            let pdfView = PDFView()
            pdfView.document = PDFDocument(data: data)
            pdfView.autoScales = true  // Automatically scale to fit the view
            return pdfView
        }

        func updateUIView(_ uiView: PDFView, context: Context) {
            uiView.autoScales = true  // Ensure auto scaling is applied when updated
        }
    }
}
