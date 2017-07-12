//
//  ViewController.swift
//  Toast-Swift
//
//  Copyright (c) 2017 Charles Scalesse.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit

class ViewController: UITableViewController {

    fileprivate var showingActivity = false
    
    fileprivate struct ReuseIdentifiers {
        static let switchCellId = "toastSwitchCell"
        static let demoCellId = "toastDemoCell"
    }
    
    // MARK: - Constructors
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        self.title = "Toast-Swift"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not used")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifiers.demoCellId)
    }
    
    // MARK: - Events
    
    @objc func handleTapToDismissToggled() {
        ToastManager.shared.isTapToDismissEnabled = !ToastManager.shared.isTapToDismissEnabled
    }
    
    @objc func handleQueueToggled() {
        ToastManager.shared.isQueueEnabled = !ToastManager.shared.isQueueEnabled
    }
}

// MARK: - UITableViewDelegate & DataSource Methods

extension ViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 9
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "SETTINGS"
        } else {
            return "DEMOS"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {

            var cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.switchCellId)
            
            if indexPath.row == 0 {
                if cell == nil {
                    cell = UITableViewCell(style: .default, reuseIdentifier: ReuseIdentifiers.switchCellId)
                    let tapToDismissSwitch = UISwitch()
                    tapToDismissSwitch.onTintColor = UIColor.blue
                    tapToDismissSwitch.isOn = ToastManager.shared.isTapToDismissEnabled
                    tapToDismissSwitch.addTarget(self, action: #selector(ViewController.handleTapToDismissToggled), for: .valueChanged)
                    cell?.accessoryView = tapToDismissSwitch
                    cell?.selectionStyle = .none
                    cell?.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
                }
                cell?.textLabel?.text = "Tap to dismiss"
            } else {
                if cell == nil {
                    cell = UITableViewCell(style: .default, reuseIdentifier: ReuseIdentifiers.switchCellId)
                    let queueSwitch = UISwitch()
                    queueSwitch.onTintColor = UIColor.blue
                    queueSwitch.isOn = ToastManager.shared.isQueueEnabled
                    queueSwitch.addTarget(self, action: #selector(ViewController.handleQueueToggled), for: .valueChanged)
                    cell?.accessoryView = queueSwitch
                    cell?.selectionStyle = .none
                    cell?.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
                }
                cell?.textLabel?.text = "Queue toast"
            }
            
            return cell!
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.demoCellId, for: indexPath)
            cell.textLabel?.numberOfLines = 2
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.accessoryType = .disclosureIndicator
            
            switch indexPath.row {
            case 0: cell.textLabel?.text = "Make toast"
            case 1: cell.textLabel?.text = "Make toast on top for 3 seconds"
            case 2: cell.textLabel?.text = "Make toast with a title"
            case 3: cell.textLabel?.text = "Make toast with an image"
            case 4: cell.textLabel?.text = "Make toast with a title, image, and completion closure"
            case 5: cell.textLabel?.text = "Make toast with a custom style"
            case 6: cell.textLabel?.text = "Show a custom view as toast"
            case 7: cell.textLabel?.text = "Show an image as toast at point\n(110, 110)"
            case 8: cell.textLabel?.text = showingActivity ? "Hide toast activity" : "Show toast activity"
            default: cell.textLabel?.text = nil
            }
            
            return cell
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section > 0 else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            // Make Toast
            self.navigationController?.view.makeToast("This is a piece of toast")
        case 1:
            // Make toast with a duration and position
            self.navigationController?.view.makeToast("This is a piece of toast on top for 3 seconds", duration: 3.0, position: .top)
        case 2:
            // Make toast with a title
            self.navigationController?.view.makeToast("This is a piece of toast with a title", duration: 2.0, position: .top, title: "Toast Title", image: nil)
        case 3:
            // Make toast with an image
            self.navigationController?.view.makeToast("This is a piece of toast with an image", duration: 2.0, position: .center, title: nil, image: UIImage(named: "toast.png"))
        case 4:
            // Make toast with an image, title, and completion closure
            self.navigationController?.view.makeToast("This is a piece of toast with a title, image, and completion closure", duration: 2.0, position: .bottom, title: "Toast Title", image: UIImage(named: "toast.png")) { didTap in
                if didTap {
                    print("completion from tap")
                } else {
                    print("completion without tap")
                }
            }
        case 5:
            // Make toast with a custom style
            var style = ToastStyle()
            style.messageFont = UIFont(name: "Zapfino", size: 14.0)!
            style.messageColor = UIColor.red
            style.messageAlignment = .center
            style.backgroundColor = UIColor.yellow
            self.navigationController?.view.makeToast("This is a piece of toast with a custom style", duration: 3.0, position: .bottom, style: style)
        case 6:
            // Show a custom view as toast
            let customView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 80.0, height: 400.0))
            customView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            customView.backgroundColor = UIColor.blue
            self.navigationController?.view.showToast(customView, duration: 2.0, position: .center)
        case 7:
            // Show an image view as toast, on center at point (110,110)
            let toastView = UIImageView(image: UIImage(named: "toast.png"))
            self.navigationController?.view.showToast(toastView, duration: 2.0, point: CGPoint(x: 110.0, y: 110.0))
        case 8:
            // Make toast activity
            if !showingActivity {
                self.navigationController?.view.makeToastActivity(.center)
            } else {
                self.navigationController?.view.hideToastActivity()
            }
            
            showingActivity = !showingActivity
            
            tableView.reloadData()
        default:
            break
        }
    }
}
