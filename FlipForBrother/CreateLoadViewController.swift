//
//  CreateLoadViewController.swift
//  KeyframeAnimator
//
//  Created by Flip for Brother on 3/24/18.
//  Copyright © 2018 Flip for Brother. All rights reserved.
//

import UIKit

protocol CreateLoadViewControllerDelegate {
    func create(frameCount: Int, name: String)
    func load(keyFrames: [KeyFrame], name: String)
}
class CreateLoadViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var frameCount: Int = 24
    var delegate: CreateLoadViewControllerDelegate?
    var fileNames: [String] = []
    var selectedFile: Int?
    let frames = [2,36,48,60,96]
    override func viewDidLoad() {
        super.viewDidLoad()
        fileNames = (try? FileManager.default.contentsOfDirectory(atPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)) ?? []
    }
    @IBAction func tapSegment(_ sender: UISegmentedControl) {
        frameCount = frames[sender.selectedSegmentIndex]
    }
    @IBAction func tapCreate(_ sender: UIButton) {
        guard let name = nameTextField.text else {
            return
        }
        delegate?.create(frameCount: frameCount, name: name)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func tapLoad(_ sender: UIButton) {
        guard let selected = tableView.indexPathForSelectedRow?.row else {
            return
        }
        let name = fileNames[selected]
        let keyframes = KeyFrame.load(from: name)
        delegate?.load(keyFrames: keyframes, name: name)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func tapOutside(_ sender: Any) {
        view.endEditing(true)
    }
}
extension CreateLoadViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileNames.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = fileNames[indexPath.row].replacingOccurrences(of: ".animation", with: "")
        return cell
    }
}
