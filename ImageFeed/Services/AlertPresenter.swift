import UIKit

protocol AlertPresenterProtocol{
    func showAlert(result: AlertModel)
}

final class AlertPresenter: UIAlertController, AlertPresenterProtocol{
    func showAlert(result: AlertModel) {
        let alert = UIAlertAction(title: <#T##String?#>, style: <#T##UIAlertAction.Style#>, handler: <#T##((UIAlertAction) -> Void)?##((UIAlertAction) -> Void)?##(UIAlertAction) -> Void#>)
    }
}
