//
//  NSAttributedString++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 6/29/21.
//

import Foundation
public extension NSAttributedString {

    convenience init(data: Data, documentType: DocumentType, encoding: String.Encoding = .utf8) throws {
        try self.init(attributedString: .init(data: data, options: [.documentType: documentType, .characterEncoding: encoding.rawValue], documentAttributes: nil))
    }

    func data(_ documentType: DocumentType) -> Data {
        // Discussion
        // Raises an rangeException if any part of range lies beyond the end of the receiver’s characters.
        // Therefore passing a valid range allow us to force unwrap the result
        try! data(from: .init(location: 0, length: length),
                  documentAttributes: [.documentType: documentType])
    }

    var text: Data { data(.plain) }
    var html: Data { data(.html)  }
    var rtf:  Data { data(.rtf)   }
    var rtfd: Data { data(.rtfd)  }
    
    func extractThumbnailImage() -> UIImage? {
        var image: UIImage?
        enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: length), options: NSAttributedString.EnumerationOptions()) {  (attribute, range, stop) -> Void in
            guard let att = attribute as? NSTextAttachment,
                  let fileType = att.fileType?.lowercased(),
                  "jpeg, jpg, png, tiff".components(separatedBy: ",").contains(where: { fileType.contains($0) }) else { return }
            
            guard let data = att.fileWrapper?.regularFileContents else { return }
            image = UIImage(data: data)
        }
        return image
    }
}
