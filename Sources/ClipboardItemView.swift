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
    private var textView: NSTextView!
    private var scrollView: NSScrollView!
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
        
        // Setup text view with scroll view
        setupTextView()
        
        // Setup image view
        setupImageView()
        
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
            
            // Text view fills most of the space
            scrollView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            scrollView.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: -4),
            
            // Image view fills most of the space (same position as text view)
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
        
        // Add single-click gesture for copying
        let singleClickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleSingleClick))
        singleClickGesture.numberOfClicksRequired = 1
        containerView.addGestureRecognizer(singleClickGesture)
        
        // Add double-click gesture for copy and paste
        let doubleClickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleDoubleClick))
        doubleClickGesture.numberOfClicksRequired = 2
        containerView.addGestureRecognizer(doubleClickGesture)
    }
    
    private func setupTextView() {
        // Create scroll view
        scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create text view
        textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.isRichText = false
        textView.font = NSFont.systemFont(ofSize: 12)  // Increased from 11 for better readability
        textView.textColor = NSColor.labelColor
        textView.backgroundColor = .clear
        textView.textContainer?.lineFragmentPadding = 4
        textView.textContainer?.containerSize = NSSize(width: 220, height: CGFloat.greatestFiniteMagnitude)  // Increased from 180 to match larger items
        textView.textContainer?.widthTracksTextView = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        
        scrollView.documentView = textView
        containerView.addSubview(scrollView)
    }
    
    private func setupImageView() {
        // Create image view
        customImageView = NSImageView()
        customImageView.imageScaling = .scaleProportionallyUpOrDown
        customImageView.imageAlignment = .alignCenter
        customImageView.translatesAutoresizingMaskIntoConstraints = false
        customImageView.isHidden = true // Hidden by default, shown for image items
        
        // Add a subtle border for images
        customImageView.wantsLayer = true
        customImageView.layer?.borderWidth = 1
        customImageView.layer?.borderColor = NSColor.separatorColor.cgColor
        customImageView.layer?.cornerRadius = 4
        
        containerView.addSubview(customImageView)
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
            // Show text view, hide image view
            scrollView.isHidden = false
            customImageView.isHidden = true
            
            // Set text content
            textView.string = item.content
            
            // Scroll to top
            textView.scrollToBeginningOfDocument(nil)
            
        case .image:
            // Show image view, hide text view
            scrollView.isHidden = true
            customImageView.isHidden = false
            
            // Set image content
            if let imageData = item.imageData {
                // Try to create NSImage from data
                if let image = NSImage(data: imageData) {
                    customImageView.image = image
                } else {
                    // For PDF or other formats, try different approaches
                    if item.type == .pdf {
                        // For PDF, we can show a PDF icon or first page
                        customImageView.image = NSImage(systemSymbolName: "doc.richtext", accessibilityDescription: "PDF Document")
                    } else {
                        // Generic image placeholder
                        customImageView.image = NSImage(systemSymbolName: "photo", accessibilityDescription: "Image")
                    }
                }
            } else {
                // Fallback image or placeholder
                customImageView.image = NSImage(systemSymbolName: "photo", accessibilityDescription: "Image")
            }
        }
    }
    
    @objc private func handleSingleClick() {
        guard let item = clipboardItem else { return }
        
        // Show visual feedback
        showCopiedFeedback()
        
        // Notify delegate to handle copying
        delegate?.clipboardItemView(self, didClickItem: item)
    }
    
    private func showCopiedFeedback() {
        statusLabel.stringValue = "✓ Copied!"
        statusLabel.isHidden = false
        
        // Animate the feedback
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
    
    @objc private func handleDoubleClick() {
        guard let item = clipboardItem else { return }
        delegate?.clipboardItemView(self, didDoubleClickItem: item)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textView.string = ""
        timeLabel.stringValue = ""
        statusLabel.stringValue = ""
        statusLabel.isHidden = true
        customImageView.image = nil
        scrollView.isHidden = false
        customImageView.isHidden = true
        clipboardItem = nil
    }
}