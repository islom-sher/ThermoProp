//
//  DataExportManager.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 7/5/26.
//

import UIKit
import QuickLook

class DataExportManager: NSObject {
    static let shared = DataExportManager()
        
    private var generatedFileURL: URL?
    private weak var presentingViewController: UIViewController?
    
    // MARK: - CSV Generation
    private func generateCSV(fluidName: String, tableName: String, coreHeaders: [String], coreRows: [[String]], transportHeaders: [String], transportRows: [[String]]) -> URL? {
        var csvString = "Properties of \(fluidName) - \(tableName)\n\n"
        
        csvString += "[Thermodynamic Properties]\n"
        csvString += coreHeaders.map { $0.replacingOccurrences(of: "\n", with: " ") }.joined(separator: ",") + "\n"
        for row in coreRows { csvString += row.joined(separator: ",") + "\n" }
        
        csvString += "\n[Transport Properties]\n"
        csvString += transportHeaders.map { $0.replacingOccurrences(of: "\n", with: " ") }.joined(separator: ",") + "\n"
        for row in transportRows { csvString += row.joined(separator: ",") + "\n" }
        
        let safeFluidName = fluidName.replacingOccurrences(of: " ", with: "_")
        let safeTableName = tableName.replacingOccurrences(of: " ", with: "_")
        let fileName = "\(safeFluidName)_\(safeTableName)_\(UUID().uuidString.prefix(6)).csv"
        
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: path, atomically: true, encoding: .utf8)
            return path
        } catch {
            print("Failed to create CSV: \(error)")
            return nil
        }
    }
    
    // MARK: - PDF Generation
    private func generatePDF(fluidName: String, tableName: String, coreHeaders: [String], coreRows: [[String]], transportHeaders: [String], transportRows: [[String]]) -> URL? {
        let format = UIGraphicsPDFRendererFormat()
        let pageWidth: CGFloat = 842.0 // A4 Landscape
        let pageHeight: CGFloat = 595.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let safeFluidName = fluidName.replacingOccurrences(of: " ", with: "_")
        let safeTableName = tableName.replacingOccurrences(of: " ", with: "_")
        let fileName = "\(safeFluidName)_\(safeTableName)_\(UUID().uuidString.prefix(6)).pdf"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try renderer.writePDF(to: path) { context in
                let margin: CGFloat = 30
                var cursorY: CGFloat = margin
                
                func drawText(_ text: String, in rect: CGRect, font: UIFont, color: UIColor = .black) {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .center
                    let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color, .paragraphStyle: paragraphStyle]
                    let textSize = text.boundingRect(with: CGSize(width: rect.width - 4, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
                    let textRect = CGRect(x: rect.minX + 2, y: rect.minY + (rect.height - textSize.height) / 2.0, width: rect.width - 4, height: textSize.height)
                    text.draw(with: textRect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
                }
                
                func drawCell(rect: CGRect) {
                    context.cgContext.setStrokeColor(UIColor.darkGray.cgColor)
                    context.cgContext.setLineWidth(0.5)
                    context.cgContext.stroke(rect)
                }
                    
                func renderTableBlock(subTitle: String, headers: [String], rows: [[String]]) {
                    if cursorY + 60 > pageHeight - margin {
                        context.beginPage()
                        cursorY = margin
                    } else {
                        cursorY += 15
                    }
                    
                    let subTitleAttr: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 14)]
                    subTitle.draw(at: CGPoint(x: margin, y: cursorY), withAttributes: subTitleAttr)
                    cursorY += 25
                    
                    let columnWidth = (pageWidth - 2 * margin) / CGFloat(headers.count)
                    let headerHeight: CGFloat = 35.0
                    let rowHeight: CGFloat = 20.0
                    let boldFont = UIFont.boldSystemFont(ofSize: 10)
                    let regularFont = UIFont.systemFont(ofSize: 10)
                    
                    let drawHeaders = {
                        for (index, text) in headers.enumerated() {
                            let rect = CGRect(x: margin + CGFloat(index) * columnWidth, y: cursorY, width: columnWidth, height: headerHeight)
                            drawCell(rect: rect)
                            drawText(text, in: rect, font: boldFont)
                        }
                        cursorY += headerHeight
                    }
                                    
                    drawHeaders()
                    
                    for row in rows {
                        if cursorY > pageHeight - margin - rowHeight {
                            context.beginPage()
                            cursorY = margin
                            drawHeaders()
                        }
                        for (index, item) in row.enumerated() {
                            let rect = CGRect(x: margin + CGFloat(index) * columnWidth, y: cursorY, width: columnWidth, height: rowHeight)
                            drawCell(rect: rect)
                            drawText(item, in: rect, font: regularFont)
                        }
                        cursorY += rowHeight
                    }
                }
                
                context.beginPage()
                let titleText = "Properties of \(fluidName) - \(tableName)"
                let titleAttr: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 18)]
                titleText.draw(at: CGPoint(x: margin, y: cursorY), withAttributes: titleAttr)
                cursorY += 20
                
                renderTableBlock(subTitle: "Thermodynamic Properties", headers: coreHeaders, rows: coreRows)
                renderTableBlock(subTitle: "Transport Properties", headers: transportHeaders, rows: transportRows)
            }
            return path
        } catch {
            return nil
        }
    }
    
    // MARK: - QuickLook
    private func showQuickLook() {
        guard let vc = presentingViewController else { return }
        let qlController = QLPreviewController()
        qlController.dataSource = self
        qlController.delegate = self
        vc.present(qlController, animated: true)
    }
    
    // MARK: - Export .PDF
    func exportAsPDF(from viewController: UIViewController, fluidName: String, tableName: String, coreHeaders: [String], coreRows: [[String]], transportHeaders: [String], transportRows: [[String]]) {
        self.presentingViewController = viewController
        if let url = self.generatePDF(fluidName: fluidName, tableName: tableName, coreHeaders: coreHeaders, coreRows: coreRows, transportHeaders: transportHeaders, transportRows: transportRows) {
            self.generatedFileURL = url
            self.showQuickLook()
        }
    }
    
    // MARK: - Export .CSV
    func exportAsCSV(from viewController: UIViewController, fluidName: String, tableName: String, coreHeaders: [String], coreRows: [[String]], transportHeaders: [String], transportRows: [[String]]) {
        self.presentingViewController = viewController
        if let url = self.generateCSV(fluidName: fluidName, tableName: tableName, coreHeaders: coreHeaders, coreRows: coreRows, transportHeaders: transportHeaders, transportRows: transportRows) {
            self.generatedFileURL = url
            self.showQuickLook()
        }
    }
}

// MARK: - QLPreviewController Delegate & DataSource
extension DataExportManager: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return self.generatedFileURL != nil ? 1 : 0
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return (self.generatedFileURL as NSURL?) ?? NSURL()
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        guard let fileToDelete = self.generatedFileURL else { return }
        do {
            try FileManager.default.removeItem(at: fileToDelete)
        } catch {
            print("Failed to delete temporary file: \(error)")
        }
        self.generatedFileURL = nil
        self.presentingViewController = nil
    }
}
