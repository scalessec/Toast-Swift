//
//  ViewController.swift
//  Toast-Swift
//
//  Copyright (c) 2015 Charles Scalesse.
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

    private let switchCellId = "ToastSwitchCellId"
    private let demoCellId = "ToastDemoCellId"
    
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
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: demoCellId)
    }
    
    // MARK: - Events
    
    func handleTapToDismissToggled() {
        print("tap to dismiss toggled")
    }
    
    func handleQueueToggled() {
        print("queue toast toggled")
    }
}

// MARK: - UITableViewDelegate & Datasource Methods

extension ViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 9
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "SETTINGS"
        } else {
            return "DEMOS"
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            var cell = tableView.dequeueReusableCellWithIdentifier(switchCellId)
            
            if indexPath.row == 0 {
                if cell == nil {
                    cell = UITableViewCell(style: .Default, reuseIdentifier: switchCellId)
                    let tapToDismissSwitch = UISwitch()
                    tapToDismissSwitch.onTintColor = UIColor.blueColor()
                    tapToDismissSwitch.addTarget(self, action: "handleTapToDismissToggled", forControlEvents: .ValueChanged)
                    cell?.accessoryView = tapToDismissSwitch
                    cell?.selectionStyle = .None
                    cell?.textLabel?.font = UIFont.systemFontOfSize(16.0)
                }
                cell?.textLabel?.text = "Tap to dismiss"
            } else {
                if cell == nil {
                    cell = UITableViewCell(style: .Default, reuseIdentifier: switchCellId)
                    let queueSwitch = UISwitch()
                    queueSwitch.onTintColor = UIColor.blueColor()
                    queueSwitch.addTarget(self, action: "handleQueueToggled", forControlEvents: .ValueChanged)
                    cell?.accessoryView = queueSwitch
                    cell?.selectionStyle = .None
                    cell?.textLabel?.font = UIFont.systemFontOfSize(16.0)
                }
                cell?.textLabel?.text = "Queue toast"
            }
            
            return cell!
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(demoCellId, forIndexPath: indexPath)
            cell.textLabel?.numberOfLines = 2
            cell.textLabel?.font = UIFont.systemFontOfSize(16.0)
            cell.accessoryType = .DisclosureIndicator
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Make toast"
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Make toast on top for 3 seconds"
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "Make toast with a title"
            } else if indexPath.row == 3 {
                cell.textLabel?.text = "Make toast with an image"
            } else if indexPath.row == 4 {
                cell.textLabel?.text = "Make toast with a title, image, and completion block"
            } else if indexPath.row == 5 {
                cell.textLabel?.text = "Make toast with a custom style"
            } else if indexPath.row == 6 {
                cell.textLabel?.text = "Show a custom view as toast"
            } else if indexPath.row == 7 {
                cell.textLabel?.text = "Show an image as toast at point\n(110, 110)"
            } else if indexPath.row == 8 {
                cell.textLabel?.text = "Show toast activity"
            }
            
            return cell
            
        }
    }
}
