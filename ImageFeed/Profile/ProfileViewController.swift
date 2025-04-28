import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject{
    var presenter: ProfilePresenterProtocol? { get }
    func updateProfileInformation(profile: Profile)
    func updateAvatar()
    func dismiss()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    //MARK: Singleton
    private let profileData = ProfileService.shared.profile
    private let bearerToken = OAuth2ServiceStorage.shared.token
    private let profileImageService = ProfileImageService.shared
    private let logoutService = ProfileLogoutService.shared
    //MARK: Properties
    private var profileImageServiceObserver: NSObjectProtocol?
    private(set) var presenter: ProfilePresenterProtocol?
    
    init(presenter: ProfilePresenterProtocol){
        super.init(nibName: nil, bundle: nil)
        
        self.presenter = presenter
        presenter.view = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: UI
    lazy var avatarImageView: UIImageView? = {
        let profileImage = UIImage(named: "avatar")
        let profileImageView = UIImageView(image: profileImage)
        profileImageView.backgroundColor = UIColor(named: "YP Dark" )
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        return profileImageView
    }()
    
    private lazy var nameLabel: UILabel? = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nameLabel.textColor = UIColor(named: "YP White")
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }()
    
    private lazy var loginLabel: UILabel? = {
        let loginLabel = UILabel()
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        loginLabel.textColor = UIColor(named:"YP Gray")
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        return loginLabel
    }()
    
    private lazy var bioLabel: UILabel? = {
        let bioLabel = UILabel()
        bioLabel.font = UIFont.systemFont(ofSize: 13)
        bioLabel.textColor = UIColor(named: "YP White")
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        return bioLabel
    }()
    
    private lazy var logOutButton: UIButton? = {
        guard let logOutButtonImage = UIImage(named: "exit_button_icon")?.withRenderingMode(.alwaysOriginal) else { return nil }

        let button = UIButton.systemButton(with: logOutButtonImage, target: self, action: #selector(didTapLogoutButton))
        button.backgroundColor = UIColor(named: "YP Dark")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "logoutButton"
        return button
    }()

    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "YP Black")
        
        setUpProfileImage()
        setUpLogOutButton()
        setUpProfileLabels()
        
        
        guard let profileData = ProfileService.shared.profile else { return }
        updateProfileInformation(profile: profileData)
    }
    
    private func updateProfileLabels(profile: Profile){
        setUpProfileLabels()
        
        nameLabel?.text = profile.name
        loginLabel?.text = profile.loginName
        bioLabel?.text = profile.bio
    }
    
    func updateProfileInformation(profile: Profile) {
        updateProfileLabels(profile: profile)
        updateAvatar()
        
        print("user data set up successfully")
    }
    
    func updateAvatar(){
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        avatarImageView?.kf.setImage(with: url, placeholder: UIImage(named: "avatar_pplaceholder"), options: [.processor(processor)])
    }
    
    private func setUpProfileImage(){
        let avatarImage = UIImage(named: "avatar_placeholder")
        let avatarImageView = UIImageView(image: avatarImage)
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 76)
        ])
        self.avatarImageView = avatarImageView
    }
    
    private func setUpLogOutButton(){
        
//        guard let logOutButtonImage = UIImage(named: "exit_button_icon")?.withRenderingMode(.alwaysOriginal) else { return }
//        
//        let logOutButton = UIButton(type: .custom)
//       logOutButton.setImage(logOutButtonImage, for: .normal)
//        logOutButton.addTarget(self, action: #selector(self.didTapLogoutButton), for: .touchUpInside)
        guard let logOutButton else { return }

        view.addSubview(logOutButton)
        logOutButton.backgroundColor = UIColor(named: "YP Black")
        view.addSubview(logOutButton)
        
        guard let avatarImageView else { return }
        NSLayoutConstraint.activate([
            logOutButton.widthAnchor.constraint(equalToConstant: 44),
            logOutButton.heightAnchor.constraint(equalToConstant: 44),
            
            logOutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            logOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            logOutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    private func setUpProfileLabels() {
        guard let nameLabel, let loginLabel, let bioLabel, let avatarImageView else { return }
        
        let labels = [nameLabel, loginLabel, bioLabel]
        
        labels.forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            bioLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bioLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8)
        ])
    }
    
    func dismiss() {
        self.dismiss(animated: true)
    }
    
    @objc private func didTapLogoutButton(){
        print("loguot button tapped")
        presenter?.didTapLogoutButton()
//        let alert = UIAlertController(title: "Пока!", message: "Вы точно хотите уйти?", preferredStyle: .alert)
//        let actionNo = UIAlertAction(title: "Нет", style: .cancel)
//        let actionLeave = UIAlertAction(title: "Да", style: .destructive){ [weak self] _ in
//            guard let self else { return }
//            self.logoutService.logout()
//        }
//        alert.addAction(actionNo)
//        alert.addAction(actionLeave)
//        
//        present(alert, animated: true, completion: nil)
    }
    
}

