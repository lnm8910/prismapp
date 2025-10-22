import Foundation

/// Represents a single tab in the editor
class TabItem {
    let id: UUID
    var document: PrismDocument
    var textView: PrismTextView?
    var title: String {
        if let url = document.fileURL {
            return url.lastPathComponent
        }
        return "Untitled"
    }

    init(document: PrismDocument) {
        self.id = UUID()
        self.document = document
    }
}
