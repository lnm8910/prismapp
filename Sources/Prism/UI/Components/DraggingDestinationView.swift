import Cocoa

/// Custom NSView that forwards drag and drop operations to a delegate
class DraggingDestinationView: NSView {
    weak var delegate: NSDraggingDestination?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }

    // MARK: - NSDraggingDestination

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return delegate?.draggingEntered?(sender) ?? []
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return delegate?.draggingUpdated?(sender) ?? []
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        delegate?.draggingExited?(sender)
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return delegate?.performDragOperation?(sender) ?? false
    }
}
