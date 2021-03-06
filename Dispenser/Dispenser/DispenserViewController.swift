import RxSwift
import UIKit

class DispenserViewController: UITableViewController, Storyboarded {
    static let UpdateSection = 1
    static let ControlsSection = 2
    static let RemoteConnectedSection = 3
    static let RemoteDisconnectedSection = 4
    
    var coordinator: DispenserCoordinator?
    var hasUpdate = false
    var isRemoteNodeConnected = false
    var disposeBag = DisposeBag()
    
    @IBOutlet var dispenseOnTouchCell: UITableViewCell!
    @IBOutlet var buzzOnDispenseCell: UITableViewCell!
    @IBOutlet var detailsCell: DispenserTableViewCell!
    @IBOutlet var updateCell: UITableViewCell!
    @IBOutlet var restartCell: UITableViewCell!
    @IBOutlet var unpairCell: UITableViewCell!
    @IBOutlet var connectCell: UITableViewCell!
    @IBOutlet var disconnectCell: UITableViewCell!
    @IBOutlet var dispenseOnTouchSwitch: UISwitch!
    @IBOutlet var buzzOnDispenseSwitch: UISwitch!
    @IBOutlet var dispenseCell: UITableViewCell!
    @IBOutlet var remoteNodeDisconnectCellSubtitle: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    
    @IBAction func help(_ sender: Any) {
        // TODO: show help
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell == self.detailsCell {
            self.coordinator?.showDetails()
        } else if cell == self.updateCell {
            self.coordinator?.showUpdate()
        } else if cell == self.connectCell {
            self.connect()
            cell?.isSelected = false
        } else if cell == self.disconnectCell {
            self.disconnect()
            cell?.isSelected = false
        } else if cell == self.restartCell {
            self.coordinator?.restart()
            cell?.isSelected = false
        } else if cell == self.unpairCell {
            self.coordinator?.unpair()
            cell?.isSelected = false
        } else if cell == self.dispenseCell {
            cell?.isSelected = false
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if cell == self.updateCell && !self.hasUpdate {
            return 0
        } else if indexPath.section == DispenserViewController.RemoteConnectedSection && !self.isRemoteNodeConnected {
            return 0
        } else if indexPath.section == DispenserViewController.RemoteDisconnectedSection && self.isRemoteNodeConnected {
            return 0
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == DispenserViewController.UpdateSection && !self.hasUpdate {
            return 0.1
        } else if section == DispenserViewController.RemoteConnectedSection && !self.isRemoteNodeConnected {
            return 0.1
        } else if section == DispenserViewController.RemoteDisconnectedSection && self.isRemoteNodeConnected {
            return 0.1
        } else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == DispenserViewController.UpdateSection && !self.hasUpdate {
            return 0.1
        } else if section == DispenserViewController.RemoteConnectedSection && !self.isRemoteNodeConnected {
            return 0.1
        } else if section == DispenserViewController.RemoteDisconnectedSection && self.isRemoteNodeConnected {
            return 0.1
        } else {
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.dispenseCell.isSelected = true
            self.coordinator?.toggleDispenser(on: true)
        } else if sender.state == .ended {
            self.dispenseCell.isSelected = false
            self.coordinator?.toggleDispenser(on: false)
        }
    }
    
    func connect() {
        self.coordinator?.connectRemoteNode()
    }
    
    func disconnect() {
        self.coordinator?.disconnectRemoteNode()
    }
    
    @IBAction func toggleDispenseOnTouch(_ sender: UISwitch) {
        self.coordinator?.toggleDispenseOnTouch(enable: sender.isOn)
    }
    
    @IBAction func toggleBuzzOnDispense(_ sender: UISwitch) {
        self.coordinator?.toggleBuzzOnDispense(enable: sender.isOn)
    }
    
    override func viewDidLoad() {
        if (self.coordinator?.coordinator.getDispensers().count ?? 0) > 1 {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: #imageLiteral(resourceName: "Menu"),
                style: .plain,
                target: self,
                action: #selector(DispenserViewController.switchDispenser))
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(DispenserViewController.addDispenser))
        }
        
        self.coordinator?.name
            .subscribe(
                onNext: { name in
                    self.title = name
                    self.nameLabel.text = name
            })
            .disposed(by: self.disposeBag)
        
        self.coordinator?.displayState
            .subscribe(
                onNext: { state in
                    switch state {
                    case .dispensing:
                        self.statusLabel.text = "dispensing"
                        self.statusLabel.textColor = #colorLiteral(red: 0.3280000091, green: 0.2090000063, blue: 0.7250000238, alpha: 1)
                    case .connecting:
                        self.statusLabel.text = "connecting"
                        self.statusLabel.textColor = #colorLiteral(red: 0.3280000091, green: 0.2090000063, blue: 0.7250000238, alpha: 1)
                    case .connected:
                        self.statusLabel.text = "connected"
                        self.statusLabel.textColor = #colorLiteral(red: 0.2980392157, green: 0.8509803922, blue: 0.3921568627, alpha: 1)
                    case .unreachable:
                        self.statusLabel.text = "unreachable"
                        self.statusLabel.textColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
                    }
            })
            .disposed(by: self.disposeBag)
        
        self.coordinator?.dispenseOnTouch
            .subscribe(
                onNext: { dispenseOnTouch in
                    self.dispenseOnTouchSwitch.setOn(dispenseOnTouch, animated: true)
            })
            .disposed(by: self.disposeBag)
        
        self.coordinator?.buzzOnDispense
            .subscribe(
                onNext: { buzzOnDispense in
                    self.buzzOnDispenseSwitch.setOn(buzzOnDispense, animated: true)
            })
            .disposed(by: self.disposeBag)
        
        self.coordinator?.version
            .subscribe(
                onNext: { version in
                    print("Version is \(version)")
                    
                    // This has a nicer animation, but the cell does not reappear
                    // let indexPath = IndexPath(row: 0, section: updateSection)
                    // self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
            })
            .disposed(by: self.disposeBag)
        
        self.coordinator?.remoteNodeUrl
            .subscribe(
                onNext: {
                    if let url = $0 {
                        self.isRemoteNodeConnected = true
                        self.remoteNodeDisconnectCellSubtitle.text = url
                    } else {
                        self.isRemoteNodeConnected = false
                    }
                    
                    // This has a nicer animation, but the cell does not reappear
                    // let indexPath = IndexPath(row: 0, section: updateSection)
                    // self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
            })
            .disposed(by: self.disposeBag)
        
        self.coordinator?.updateAvailable
            .subscribe(
                onNext: {
                    self.hasUpdate = $0
                    
                    // This has a nicer animation, but the cell does not reappear
                    // let indexPath = IndexPath(row: 0, section: updateSection)
                    // self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
            })
            .disposed(by: self.disposeBag)
    }
    
    @IBAction func switchDispenser() {
        self.coordinator?.switchDispenser()
    }
    
    @IBAction func addDispenser() {
        self.coordinator?.addDispenser()
    }
}
