import Cocoa
import Foundation

protocol ClipboardItemViewDelegate: AnyObject {
    func clipboardItemView(_ view: ClipboardItemView, didClickItem item: ClipboardItem)
    func clipboardItemView(_ view: ClipboardItemView, didDoubleClickItem item: ClipboardItem)
}

class ClipboardItemView: NSCollectionViewItem {
    weak var delegate: ClipboardItemViewDelegate?
    private var clipboardItem: ClipboardItem?
    
    private var containerView: NSView!
    private var textLabel: NSTextField!
    private var textScrollView: NSScrollView!
    private var customImageView: NSImageView!
    private var timeLabel: NSTextField!
    private var statusLabel: NSTextField!
    
    override func loadView() {
        view = NSView()
        setupUI()
    }
    
    private func setupUI() {
        // Container view with rounded corners and shadow
        containerView = NSView()
        containerView.wantsLayer = true
        containerView.layer?.cornerRadius = 8
        containerView.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        containerView.layer?.borderWidth = 1
        containerView.layer?.borderColor = NSColor.separatorColor.cgColor
        
        // Add shadow
        containerView.shadow = NSShadow()
        containerView.shadow?.shadowColor = NSColor.black.withAlphaComponent(0.1)
        containerView.shadow?.shadowOffset = NSSize(width: 0, height: -1)
        containerView.shadow?.shadowBlurRadius = 3
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Time label
        timeLabel = NSTextField()
        timeLabel.isEditable = false
        timeLabel.isSelectable = false
        timeLabel.isBordered = false
        timeLabel.backgroundColor = .clear
        timeLabel.font = NSFont.systemFont(ofSize: 10, weight: .medium)
        timeLabel.textColor = NSColor.secondaryLabelColor
        timeLabel.alignment = .center
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(timeLabel)
        
        // Text label for displaying clipboard text
        textLabel = NSTextField()
        textLabel.isEditable = false
        textLabel.isSelectable = true
        textLabel.isBordered = false
        textLabel.backgroundColor = .clear
        textLabel.font = NSFont.systemFont(ofSize: 12)
        textLabel.textColor = NSColor.labelColor
        textLabel.alignment = .left
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.maximumNumberOfLines = 0  // Allow unlimited lines
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create scroll view for text
        textScrollView = NSScrollView()
        textScrollView.hasVerticalScroller = true
        textScrollView.hasHorizontalScroller = false
        textScrollView.autohidesScrollers = true
        textScrollView.borderType = .noBorder
        textScrollView.translatesAutoresizingMaskIntoConstraints = false
        textScrollView.documentView = textLabel
        
        containerView.addSubview(textScrollView)
        
        // Image view for displaying clipboard images
        customImageView = NSImageView()
        customImageView.imageScaling = .scaleProportionallyUpOrDown
        customImageView.imageAlignment = .alignCenter
        customImageView.translatesAutoresizingMaskIntoConstraints = false
        customImageView.isHidden = true
        
        // Add border for images
        customImageView.wantsLayer = true
        customImageView.layer?.borderWidth = 1
        customImageView.layer?.borderColor = NSColor.separatorColor.cgColor
        customImageView.layer?.cornerRadius = 4
        
        containerView.addSubview(customImageView)
        
        // Status label for feedback
        statusLabel = NSTextField()
        statusLabel.isEditable = false
        statusLabel.isSelectable = false
        statusLabel.isBordered = false
        statusLabel.backgroundColor = .clear
        statusLabel.font = NSFont.systemFont(ofSize: 10, weight: .bold)
        statusLabel.textColor = NSColor.systemGreen
        statusLabel.alignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.isHidden = true
        containerView.addSubview(statusLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Container fills the view
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 2),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -2),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -2),
            
            // Time label at top
            timeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            timeLabel.heightAnchor.constraint(equalToConstant: 14),
            
            // Text scroll view fills most of the space
            textScrollView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            textScrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            textScrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            textScrollView.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: -4),
            
            // Image view fills same space as text label
            customImageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            customImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            customImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            customImageView.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: -4),
            
            // Status label at bottom
            statusLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            statusLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        // Add hover effect
        setupHoverEffect()
        
        // Add click gestures
        let singleClickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleSingleClick))
        singleClickGesture.numberOfClicksRequired = 1
        containerView.addGestureRecognizer(singleClickGesture)
        
        let doubleClickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleDoubleClick))
        doubleClickGesture.numberOfClicksRequired = 2
        containerView.addGestureRecognizer(doubleClickGesture)
    }
    
    private func setupHoverEffect() {
        let trackingArea = NSTrackingArea(
            rect: view.bounds,
            options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        view.addTrackingArea(trackingArea)
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            containerView.layer?.borderColor = NSColor.controlAccentColor.cgColor
            containerView.layer?.backgroundColor = NSColor.controlBackgroundColor.blended(withFraction: 0.1, of: NSColor.controlAccentColor)?.cgColor
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            containerView.layer?.borderColor = NSColor.separatorColor.cgColor
            containerView.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        }
    }
    
    func configure(with item: ClipboardItem) {
        self.clipboardItem = item
        
        // Set time label
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        timeLabel.stringValue = formatter.localizedString(for: item.timestamp, relativeTo: Date())
        
        // Configure based on item type
        switch item.itemType {
        case .text:
            // Show text scroll view, hide image view
            textScrollView.isHidden = false
            customImageView.isHidden = true
            
            // Set text content
            textLabel.stringValue = item.content
            
            // Set the text label frame to fit content for proper scrolling
            let textSize = textLabel.sizeThatFits(NSSize(width: textScrollView.contentSize.width, height: CGFloat.greatestFiniteMagnitude))
            textLabel.frame = NSRect(origin: .zero, size: textSize)
            
        case .image:
            // Show image view, hide text scroll view
            textScrollView.isHidden = true
            customImageView.isHidden = false
            
            // Set image content
            if let imageData = item.imageData {
                if let image = NSImage(data: imageData) {
                    customImageView.image = image
                } else {
                    // Show placeholder for unsupported image formats
                    customImageView.image = NSImage(systemSymbolName: "photo", accessibilityDescription: "Image")
                }
            } else {
                customImageView.image = NSImage(systemSymbolName: "photo", accessibilityDescription: "Image")
            }
        }
    }
    
    @objc private func handleSingleClick() {
        guard let item = clipboardItem else { return }
        
        // Show visual feedback
        showCopiedFeedback()
        
        // Notify delegate
        delegate?.clipboardItemView(self, didClickItem: item)
    }
    
    @objc private func handleDoubleClick() {
        guard let item = clipboardItem else { return }
        delegate?.clipboardItemView(self, didDoubleClickItem: item)
    }
    
    private func showCopiedFeedback() {
        statusLabel.stringValue = "✓ Copied!"
        statusLabel.isHidden = false
        
        // Animate feedback
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            statusLabel.alphaValue = 1.0
        }
        
        // Hide after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                self.statusLabel.alphaValue = 0.0
            } completionHandler: {
                self.statusLabel.isHidden = true
                self.statusLabel.alphaValue = 1.0
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel.stringValue = ""
        timeLabel.stringValue = ""
        statusLabel.stringValue = ""
        statusLabel.isHidden = true
        customImageView.image = nil
        textScrollView.isHidden = false
        customImageView.isHidden = true
        clipboardItem = nil
    }
}