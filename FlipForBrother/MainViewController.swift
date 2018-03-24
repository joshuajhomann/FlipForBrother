//
//  ViewController.swift
//  KeyframeAnimator
//
//  Created by Flip for Brother on 3/24/18.
//  Copyright © 2018 Flip for Brother. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var timeLineCollectionView: UICollectionView!
    @IBOutlet weak var paletteCollectionView: UICollectionView!
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var nextKeyFrameButton: UIButton!
    @IBOutlet weak var keyFrameSwitch: UISwitch!
    @IBOutlet weak var hiddenSwitch: UISwitch!
    @IBOutlet weak var translationXTextfield: UITextField!
    @IBOutlet weak var translationYTextField: UITextField!
    @IBOutlet weak var scaleXTextfield: UITextField!
    @IBOutlet weak var scaleYTextfield: UITextField!
    @IBOutlet weak var rotationTextfield: UITextField!
    enum Axis: Int {
        case xAndY, x, y
    }
    private var axis = Axis.xAndY
    private var keyFrames: [KeyFrame] = []
    private var keyFrameIndex = 0
    private var keyFrame: KeyFrame {
        return keyFrames[keyFrameIndex]
    }
    private var selectedTransformableView: TransformableView?
    private var transformableViews: [TransformableView] = []
    private var imageNames: [String] = ["penguin","penguin-blink", "penguin-flap1", "penguin-flap2", "penguin-flap3", "droplet","cloud","water", "ice", "whale", "spout", "splash", "bottle","setting-sun", "ufo", "ufo2","cone", "astro1", "astro2", "astro3", "rocket1", "rocket2", "rocket3", "rocket4", "moon", "night", "crater", "earth"]
    private var framesToGhost = 0
    private var pasteBoard: Any?
    private var pasteKeyFrame: KeyFrame?
    private var fileName: String?
    private var imagesToPrint: [UIImage] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        paletteCollectionView.dragInteractionEnabled = true
        paletteCollectionView.dragDelegate = self
        canvasView.addInteraction(UIDropInteraction(delegate: self))
        canvasView.isUserInteractionEnabled = true
        previewImageView.addInteraction(UIDropInteraction(delegate: self))
        previewImageView.isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: .main) {_ in
            self.save()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if fileName == nil {
            performSegue(withIdentifier: String(describing: CreateLoadViewController.self), sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let destination as AnimationViewController:
            recalculateKeyFrames()
            destination.proposedSize = canvasView.bounds.size
            destination.keyFrames = keyFrames
        case let destination as CreateLoadViewController:
            destination.delegate = self
            save()
        case let navigation as UINavigationController:
            if let destination = navigation.topViewController as? BRSelectDeviceTableViewController {
                destination.delegate = self
                let savedIndex = keyFrameIndex
                imagesToPrint = keyFrames.indices.map { index -> UIImage in
                    keyFrameIndex = index
                    setup()
                    return UIGraphicsImageRenderer(bounds: canvasView.bounds).image {renderer in
                        self.canvasView.drawHierarchy(in: self.canvasView.bounds, afterScreenUpdates: true)
                    }
                }
                keyFrameIndex = savedIndex
                setup()
            }
        default:
            break
        }
    }
    func setup() {
        let selectedIndex = transformableViews.index{ $0 === self.selectedTransformableView }
        recalculateKeyFrames()
        canvasView.subviews.forEach{$0.removeFromSuperview()}
        transformableViews = keyFrame.transformableImages.map { TransformableView(transformableImage: $0) }
        transformableViews.forEach {self.canvasView.addSubview($0)
            $0.center = self.canvasView.center
            $0.updateImage()
        }
        (max(keyFrameIndex - framesToGhost, 0) ..< keyFrameIndex).forEach { frameIndex in
            let alpha = (1 - CGFloat(self.keyFrameIndex - frameIndex) / CGFloat(self.framesToGhost)) * 0.4 + 0.05
            self.keyFrames[frameIndex].transformableImages.enumerated().forEach {
              let view = TransformableView(transformableImage: $0.element)
              self.canvasView.insertSubview(view, belowSubview: transformableViews[$0.offset])
              view.center = self.canvasView.center
              view.updateImage()
              view.calculateTransform()
              view.alpha = alpha
            }

        }

        if let selectedIndex = selectedIndex {
            select(index: selectedIndex)
        }
        canvasView.backgroundColor = keyFrame.isKey ? .white : .lightGray
        keyFrameSwitch.isOn = keyFrame.isKey
        canvasView.setNeedsDisplay()
    }
    func select(index: Int) {
        select(transformableViews[index])
    }
    func select(_ transformableView: TransformableView?) {
        deselectAll()
        guard let transformableView = transformableView else {
            return
        }
        selectedTransformableView = transformableView
        let transformableImage = transformableView.transformableImage
        transformableView.isSelected = true
        previewImageView.image = transformableView.transformableImage.image
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        translationXTextfield.text = formatter.string(for: transformableImage.translation.x)
        translationYTextField.text = formatter.string(for: transformableImage.translation.y)
        scaleXTextfield.text = formatter.string(for: transformableImage.scaleX)
        scaleYTextfield.text = formatter.string(for: transformableImage.scaleY)
        rotationTextfield.text = formatter.string(for: transformableImage.rotation)
        hiddenSwitch.isEnabled = true
        hiddenSwitch.isOn = transformableImage.isHidden
    }
    func recalculateKeyFrames() {
        var lastKeyIndex = 0
        for (index,keyFrame) in keyFrames.enumerated() {
            guard !keyFrame.isKey else {
                lastKeyIndex = index
                continue
            }
            let nextKeyIndex = keyFrames[(index+1)...].index{$0.isKey}!
            for i in 0..<keyFrame.transformableImages.count {
                keyFrames[index].transformableImages[i].lerp(from: keyFrames[lastKeyIndex].transformableImages[i],
                                                             to: keyFrames[nextKeyIndex].transformableImages[i],
                                                             proportion: CGFloat(index - lastKeyIndex) / CGFloat(nextKeyIndex - lastKeyIndex))
            }
        }
    }
    func addItem(named name: String, at location: CGPoint) {
        for index in keyFrames.indices {
            keyFrames[index].transformableImages.append(TransformableImage(imageName: name, scaleX: 1, scaleY: 1, rotation: 0, translation: location, isHidden: false))
        }
        setup()
        select(transformableViews.last)
    }
    func deselectAll() {
        selectedTransformableView = nil
        previewImageView.image = nil
        transformableViews.forEach { $0.isSelected = false }
        translationXTextfield.text = nil
        translationYTextField.text = nil
        scaleXTextfield.text = nil
        scaleYTextfield.text = nil
        rotationTextfield.text = nil
        hiddenSwitch.isEnabled = false
    }
    func setCurrentFrame(isKey: Bool) {
        keyFrames[keyFrameIndex].isKey = isKey
        timeLineCollectionView.reloadData()
        canvasView.backgroundColor = keyFrame.isKey ? .white : .lightGray
    }
    func save() {
        if let fileName = fileName {
            KeyFrame.save(keyframes: keyFrames, to: fileName)
        }
    }
    @objc func copyTransform(){
        pasteBoard = selectedTransformableView?.transformableImage
    }
    @objc func copyImage() {
        pasteBoard = selectedTransformableView?.transformableImage.imageName
    }
    @objc func pasteFromBoard() {
        guard let selectedTransformableView = selectedTransformableView,
              let index = transformableViews.index(of: selectedTransformableView) else {
            return
        }
        switch pasteBoard {
        case let name as String:
            keyFrames[keyFrameIndex].transformableImages[index].imageName = name
            setup()
        case let transform as TransformableImage:
            keyFrames[keyFrameIndex].transformableImages[index].lerp(from: transform, to: transform, proportion: 1)
            setup()
        default:
            break
        }
    }
    @objc func keyFrameCopy() {
        pasteKeyFrame = keyFrame
    }
    @objc func keyFramePaste() {
        guard let pasteKeyFrame = pasteKeyFrame else {
            return
        }
        keyFrames[keyFrameIndex] = pasteKeyFrame
        keyFrames[keyFrameIndex].isKey = true
        setup()
    }
    @objc func toFront() {
        guard let selectedTransformableView = selectedTransformableView,
            let index = transformableViews.index(of: selectedTransformableView) else {
                return
        }
        for frameIndex in keyFrames.indices {
            let removed = keyFrames[frameIndex].transformableImages.remove(at: index)
            keyFrames[frameIndex].transformableImages.append(removed)
        }
        setup()
        select(transformableViews.last)
    }
    @objc func toBack() {
        guard let selectedTransformableView = selectedTransformableView,
            let index = transformableViews.index(of: selectedTransformableView) else {
                return
        }
        for frameIndex in keyFrames.indices {
            let removed = keyFrames[frameIndex].transformableImages.remove(at: index)
            keyFrames[frameIndex].transformableImages.insert(removed, at: 0)
        }
        setup()
        select(transformableViews.first)
    }
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        select(transformableViews.reversed().first(where: { $0.bounds.contains(sender.location(in: $0))}))
    }
    @IBAction func pinch(_ sender: UIPinchGestureRecognizer) {
        guard let selectedTransformableView = selectedTransformableView else {
            return
        }
        switch sender.state {
        case .changed:
            guard let index = transformableViews.index(of: selectedTransformableView) else {
                return
            }
            if axis == .x || axis == .xAndY {
                keyFrames[keyFrameIndex].transformableImages[index].scaleX *= sender.scale
            }
            if axis == .y || axis == .xAndY {
                keyFrames[keyFrameIndex].transformableImages[index].scaleY *= sender.scale
            }
            selectedTransformableView.transformableImage = keyFrames[keyFrameIndex].transformableImages[index]
            sender.scale = 1
            setCurrentFrame(isKey: true)
        case .ended, .cancelled:
            setCurrentFrame(isKey: true)
            setup()
        default:
            return
        }
    }
    @IBAction func rotate(_ sender: UIRotationGestureRecognizer) {
        guard let selectedTransformableView = selectedTransformableView else {
            return
        }
        switch sender.state {
        case .changed:
            guard let index = transformableViews.index(of: selectedTransformableView) else {
                return
            }
            keyFrames[keyFrameIndex].transformableImages[index].rotation += sender.rotation
            selectedTransformableView.transformableImage = keyFrames[keyFrameIndex].transformableImages[index]
            sender.rotation = 0
            setCurrentFrame(isKey: true)
        case .ended, .cancelled:
            setCurrentFrame(isKey: true)
            setup()
        default:
            return
        }
    }
    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
        guard let selectedTransformableView = selectedTransformableView else {
            return
        }
        switch sender.state {
        case .began:
            if !selectedTransformableView.bounds.contains(sender.location(in: selectedTransformableView)) {
                sender.isEnabled = false
                sender.isEnabled = true
            }
        case .changed:
            guard let index = transformableViews.index(of: selectedTransformableView) else {
                return
            }
            let translation = sender.translation(in: self.canvasView)
            if axis == .x || axis == .xAndY {
                keyFrames[keyFrameIndex].transformableImages[index].translation.x += translation.x
            }
            if axis == .y || axis == .xAndY {
                keyFrames[keyFrameIndex].transformableImages[index].translation.y += translation.y
            }
            selectedTransformableView.transformableImage = keyFrames[keyFrameIndex].transformableImages[index]
            sender.setTranslation(.zero, in: canvasView)
            setCurrentFrame(isKey: true)
        case .ended, .cancelled:
            setup()
        default:
            return
        }
    }
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        guard let selectedTransformableView = selectedTransformableView else {
            return
        }
        switch sender.state {
        case .began:
            selectedTransformableView.becomeFirstResponder()
            let copyTransformItem = UIMenuItem(title: "Copy Transform", action: #selector(copyTransform))
            let copyImageItem = UIMenuItem(title: "Copy Image", action: #selector(copyImage))
            let bringToFront = UIMenuItem(title: "To Front", action: #selector(toFront))
            let sendToBack = UIMenuItem(title: "To Back", action: #selector(toBack))
            let pasteItem = UIMenuItem(title: pasteBoard is String ? "Paste Image" : "Paste Transform", action: #selector(pasteFromBoard))
            UIMenuController.shared.menuItems = pasteBoard == nil ? [copyImageItem, copyTransformItem, bringToFront, sendToBack] :
                                                                    [copyImageItem, copyTransformItem, pasteItem, bringToFront, sendToBack]
            UIMenuController.shared.setTargetRect(selectedTransformableView.frame, in: canvasView)
            UIMenuController.shared.setMenuVisible(true, animated: true)
        default:
            break
        }
    }
    @IBAction func printBook(_ sender: UIButton) {
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = .grayscale
        printInfo.jobName = "Flipbook"
        printController.printInfo = printInfo
        let savedIndex = keyFrameIndex
        let images = keyFrames.indices.map { index -> UIImage in
            keyFrameIndex = index
            setup()
            return UIGraphicsImageRenderer(bounds: canvasView.bounds).image {renderer in
                self.canvasView.drawHierarchy(in: self.canvasView.bounds, afterScreenUpdates: true)
            }
        }
        keyFrameIndex = savedIndex
        setup()
        printController.printingItems = images
        printController.present(animated: true, completionHandler: nil)
    }
    @IBAction func tapDelete(_ sender: Any) {
        guard let selectedTransformableView = selectedTransformableView,
              let indexToDelete = transformableViews.index(of: selectedTransformableView) else {
            return
        }
        for index in keyFrames.indices {
            keyFrames[index].transformableImages.remove(at: indexToDelete)
        }
        deselectAll()
        setup()
    }
    @IBAction func tapForwardBackwards(_ sender: UIButton) {
        let proposedIndex = keyFrameIndex + (sender == forwardButton ? 1 : -1)
        guard proposedIndex >= 0 && proposedIndex < keyFrames.count else {
            return
        }
        timeLineCollectionView.selectItem(at: [0, proposedIndex], animated: true, scrollPosition: .centeredHorizontally)
        timeLineCollectionView.delegate?.collectionView?(timeLineCollectionView, didSelectItemAt: [0, proposedIndex])
    }
    @IBAction func tapNextKeyFrame(_ sender: UIButton) {
        let proposedIndex = keyFrameIndex + (sender == nextKeyFrameButton ? 1 : -1)
        guard proposedIndex >= 0 && proposedIndex < keyFrames.count else {
            return
        }
        let searchRange = sender == nextKeyFrameButton ? stride(from: proposedIndex, through: keyFrames.count - 1, by: 1) :
                                                         stride(from: proposedIndex, through: 0, by: -1)
        guard let targetIndex = searchRange.first(where: { self.keyFrames[$0].isKey }) else {
            return
        }
        timeLineCollectionView.selectItem(at: [0, targetIndex], animated: true, scrollPosition: .centeredHorizontally)
        timeLineCollectionView.delegate?.collectionView?(timeLineCollectionView, didSelectItemAt: [0, targetIndex])
    }
    @IBAction func tapAxis(_ sender: UISegmentedControl) {
        axis = Axis(rawValue: sender.selectedSegmentIndex)!
    }
    @IBAction func tapGhost(_ sender: UISegmentedControl) {
        let values = [0,5,10,15]
        framesToGhost = values[sender.selectedSegmentIndex]
        setup()
    }
    @IBAction func toggleHidden(_ sender: Any) {
        guard let selectedTransformableView = selectedTransformableView,
              let index = transformableViews.index(of: selectedTransformableView) else {
                return
        }
        keyFrames[keyFrameIndex].transformableImages[index].isHidden = !keyFrames[keyFrameIndex].transformableImages[index].isHidden
        setup()
    }
    @IBAction func toggleKeyFrame(_ sender: Any) {
        keyFrames[keyFrameIndex].isKey = !keyFrame.isKey
        setup()
        timeLineCollectionView.reloadData()
    }
    func printImage (images: [UIImage], deviceName: String, serialNumber: String) {

        guard let ptp = BRPtouchPrinter(printerName: deviceName, interface: CONNECTION_TYPE.BLUETOOTH) else {
            print("*** Prepare Print Error ***")
            return
        }
        ptp.setupForBluetoothDevice(withSerialNumber: serialNumber)
        let printInfo = BRPtouchPrintInfo()
        printInfo.strPaperName = "62mmRB"
        printInfo.nPrintMode = PRINT_FIT
        printInfo.nAutoCutFlag = OPTION_AUTOCUT
        ptp.setPrintInfo(printInfo)

        guard ptp.isPrinterReady() else {
            print("*** Printer is not Ready ***")
            return
        }
        if ptp.startCommunication() {
            images.forEach { image in
                let result = ptp.print(image.cgImage, copy: 1)
                if result != ERROR_NONE_ {
                    print ("*** Printing Error ***")
                }
            }
            ptp.endCommunication()
        }
        else {
            print("Communication Error")
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case timeLineCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: KeyFrameCollectionViewCell.self), for: indexPath) as! KeyFrameCollectionViewCell
            cell.circleView.backgroundColor = keyFrames[indexPath.row].isKey ? .red : .lightGray
            cell.layer.borderColor = (indexPath.row == keyFrameIndex ? UIColor.blue : UIColor.clear).cgColor
            cell.layer.cornerRadius = 8
            cell.layer.borderWidth = 1
            cell.label.text = (indexPath.row + 1).description
            return cell
        case paletteCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PaletteCollectionViewCell.self), for: indexPath) as! PaletteCollectionViewCell
            cell.imageView.image = UIImage(named: imageNames[indexPath.row])
            return cell
        default:
            fatalError()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case timeLineCollectionView:
            return keyFrames.count
        case paletteCollectionView:
            return imageNames.count
        default:
            return 0
        }
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case timeLineCollectionView:
            keyFrameIndex = indexPath.row
            setup()
            collectionView.reloadData()
        default:
            return
        }
    }
}

extension MainViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = imageNames [indexPath.row]
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}

extension MainViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self) && session.items.count == 1
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: canvasView.frame.contains(session.location(in: canvasView)) ||
                                         previewImageView.frame.contains(session.location(in: previewImageView)) ?
                                         .copy : .cancel)
    }
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSString.self) { items in
            guard let name = items.first as? String  else {
                return
            }
            if self.canvasView.frame.contains(session.location(in: self.canvasView)) {
                self.addItem(named: name, at: session.location(in: self.canvasView))
            } else if self.previewImageView.frame.contains(session.location(in: self.previewImageView)){
                if let selectedTransformableView = self.selectedTransformableView,
                   let index = self.transformableViews.index(of: selectedTransformableView) {
                    self.keyFrames[self.keyFrameIndex].transformableImages[index].imageName = name
                }
                self.selectedTransformableView?.transformableImage.imageName = name
                self.selectedTransformableView?.updateImage()
                self.previewImageView.image = self.selectedTransformableView?.image
            }
        }
    }
}

extension MainViewController: CreateLoadViewControllerDelegate {
    func create(frameCount: Int, name: String) {
        keyFrames = (0..<frameCount).map{ _ in KeyFrame() }
        fileName = name
        keyFrames[0].isKey = true
        keyFrames[keyFrames.count - 1].isKey = true
        setup()
        timeLineCollectionView.reloadData()
    }
    func load(keyFrames: [KeyFrame], name: String) {
        self.keyFrames = keyFrames
        fileName = name
        setup()
        timeLineCollectionView.reloadData()
    }
}

extension MainViewController: BRSelectDeviceTableViewControllerDelegate {
    func setSelected(deviceInfo: BRPtouchDeviceInfo) {
        dismiss(animated: false, completion: nil)
        guard let modelName = deviceInfo.strModelName else {return}
        let venderName = "Brother "
        let dev = venderName + modelName
        guard let num = deviceInfo.strSerialNumber else {return}
        printImage(images: imagesToPrint, deviceName: dev, serialNumber: num)
        imagesToPrint.removeAll()
    }
}

