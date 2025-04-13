import Foundation

extension DateFormatter{
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.dateFormat = .none
        return formatter
    }()
}
