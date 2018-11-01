import UIKit

class RemoteNodeCoordinator {
    var coordinator: DispenserCoordinator
    var navigationController: RemoteNodeNavigationController
    
    init(coordinator: DispenserCoordinator) {
        self.coordinator = coordinator
        self.navigationController = RemoteNodeNavigationController.instantiate()
    }
    
    func start() {
        let vc = RemoteNodeConnectViewController.instantiate()
        vc.coordinator = self
        
        self.navigationController.setViewControllers([vc], animated: false)
    }
}
