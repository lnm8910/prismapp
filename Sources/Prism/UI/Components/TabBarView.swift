import Cocoa

protocol TabBarDelegate: AnyObject {
    func tabBar(_ tabBar: TabBarView, didSelectTabAt index: Int)
    func tabBar(_ tabBar: TabBarView, didCloseTabAt index: Int)
}

class TabBarView: NSView {
    weak var delegate: TabBarDelegate?
    private var tabs: [TabItem] = []
    private var selectedIndex: Int = 0
    private var tabContainers: [HoverTabContainer] = []
    private var lastBoundsSize: NSSize = .zero

    private let tabHeight: CGFloat = 32
    private let tabMinWidth: CGFloat = 120
    private let tabMaxWidth: CGFloat = 200

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        wantsLayer = true
        // Dark background for tab bar area
        layer?.backgroundColor = NSColor(calibratedWhite: 0.12, alpha: 1.0).cgColor
    }

    func setTabs(_ tabs: [TabItem], selectedIndex: Int) {
        self.tabs = tabs
        self.selectedIndex = selectedIndex
        lastBoundsSize = bounds.size
        rebuildTabs()
    }

    private func rebuildTabs() {
        // Remove ALL subviews to ensure clean slate
        subviews.forEach { $0.removeFromSuperview() }
        tabContainers.removeAll()

        guard !tabs.isEmpty else { return }

        let tabWidth = min(tabMaxWidth, max(tabMinWidth, bounds.width / CGFloat(tabs.count)))

        for (index, tab) in tabs.enumerated() {
            let x = CGFloat(index) * tabWidth
            let isSelected = index == selectedIndex

            // Create hover-aware tab container
            // Selected tab extends to bottom (no gap), unselected tabs have a gap at bottom
            let yPosition: CGFloat = isSelected ? 0 : 4
            let containerHeight: CGFloat = isSelected ? tabHeight : tabHeight - 4

            let tabContainer = HoverTabContainer(
                frame: NSRect(x: x + 4, y: yPosition, width: tabWidth - 8, height: containerHeight),
                isSelected: isSelected
            )

            // Tab click handler
            tabContainer.onTabClick = { [weak self] in
                self?.delegate?.tabBar(self!, didSelectTabAt: index)
            }

            // Close button click handler
            tabContainer.onCloseClick = { [weak self] in
                self?.delegate?.tabBar(self!, didCloseTabAt: index)
            }

            // Set tab title
            tabContainer.setTitle(tab.title + (tab.document.isModified ? " •" : ""))

            addSubview(tabContainer)
            tabContainers.append(tabContainer)
        }
    }

    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        // Only rebuild if we actually have tabs AND the size actually changed
        if !tabs.isEmpty && bounds.size != lastBoundsSize {
            lastBoundsSize = bounds.size
            rebuildTabs()
        }
    }
}

// MARK: - Hover-aware Tab Container

class HoverTabContainer: NSView {
    private var isSelected: Bool
    private var isHovering = false
    private var label: NSTextField!
    private var closeButton: NSButton!
    private var clickArea: NSView!

    var onTabClick: (() -> Void)?
    var onCloseClick: (() -> Void)?

    init(frame frameRect: NSRect, isSelected: Bool) {
        self.isSelected = isSelected
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        wantsLayer = true

        // Background styling
        updateBackground()

        // Click area (invisible button covering the whole tab except close button)
        clickArea = NSView(frame: NSRect(x: 0, y: 0, width: bounds.width - 30, height: bounds.height))
        clickArea.wantsLayer = true
        let clickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(handleTabClick))
        clickArea.addGestureRecognizer(clickRecognizer)
        addSubview(clickArea)

        // Label for tab title - properly centered vertically
        label = NSTextField(frame: NSRect(x: 12, y: 6, width: bounds.width - 48, height: 16))
        label.isEditable = false
        label.isBordered = false
        label.backgroundColor = .clear
        label.font = .systemFont(ofSize: 13, weight: isSelected ? .medium : .regular)
        label.textColor = isSelected ? NSColor.labelColor : NSColor(calibratedWhite: 0.6, alpha: 1.0)
        label.alignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.drawsBackground = false
        addSubview(label)

        // Close button - only show on selected tab
        if isSelected {
            let closeButtonSize: CGFloat = 16
            closeButton = NSButton(frame: NSRect(
                x: bounds.width - closeButtonSize - 8,
                y: (bounds.height - closeButtonSize) / 2,
                width: closeButtonSize,
                height: closeButtonSize
            ))
            closeButton.title = "×"
            closeButton.bezelStyle = .inline
            closeButton.isBordered = false
            closeButton.target = self
            closeButton.action = #selector(handleCloseClick)
            closeButton.font = .systemFont(ofSize: 14, weight: .medium)
            closeButton.contentTintColor = NSColor.secondaryLabelColor

            // Add hover tracking for close button
            let closeTrackingArea = NSTrackingArea(
                rect: closeButton.bounds,
                options: [.mouseEnteredAndExited, .activeInActiveApp],
                owner: self,
                userInfo: ["isCloseButton": true]
            )
            closeButton.addTrackingArea(closeTrackingArea)

            addSubview(closeButton)
        }

        // Add hover tracking for the tab itself
        updateTrackingAreas()
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        // Remove old tracking areas
        trackingAreas.forEach { removeTrackingArea($0) }

        // Add new tracking area for the entire tab
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeInActiveApp],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
    }

    override func mouseEntered(with event: NSEvent) {
        if !isSelected {
            isHovering = true
            updateBackground()
        }

        // Change close button color on hover
        if let closeButton = closeButton {
            closeButton.contentTintColor = NSColor.labelColor
        }
    }

    override func mouseExited(with event: NSEvent) {
        if !isSelected {
            isHovering = false
            updateBackground()
        }

        // Reset close button color
        if let closeButton = closeButton {
            closeButton.contentTintColor = NSColor.secondaryLabelColor
        }
    }

    private func updateBackground() {
        if isSelected {
            // Match the editor background color for seamless integration
            layer?.backgroundColor = NSColor.textBackgroundColor.cgColor
            layer?.cornerRadius = 6
            layer?.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isHovering {
            layer?.backgroundColor = NSColor(calibratedWhite: 0.18, alpha: 1.0).cgColor
            layer?.cornerRadius = 6
            layer?.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            layer?.backgroundColor = NSColor.clear.cgColor
            layer?.cornerRadius = 0
        }
    }

    func setTitle(_ title: String) {
        label.stringValue = title
    }

    @objc private func handleTabClick() {
        onTabClick?()
    }

    @objc private func handleCloseClick() {
        onCloseClick?()
    }
}
