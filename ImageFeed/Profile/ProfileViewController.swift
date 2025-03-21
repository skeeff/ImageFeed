import UIKit

final class ProfileViewController: UIViewController {
    
    private var avatarImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "YP Black")
        
        setUpProfileImage()
        setUpLogOutButton()
        setUpLabels() 
    }
    
    private func setUpProfileImage(){
        let avatarImage = UIImage(named: "avatar")
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
        let logOutButtonImage = UIImage(named:"exit_button_icon")
        
        guard let logOutButtonImage else { return }
        
        let logOutButton = UIButton.systemButton(
            with: logOutButtonImage,
            target: self,
            action: #selector(Self.didTapButton)
        )
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        logOutButton.backgroundColor = UIColor(named: "YP Black")
        view.addSubview(logOutButton)
        
        NSLayoutConstraint.activate([
            logOutButton.widthAnchor.constraint(equalToConstant: 44),
            logOutButton.heightAnchor.constraint(equalToConstant: 44),
            
            logOutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            logOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            logOutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    private func setUpLabels(){
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nameLabel.textColor = .white
        view.addSubview(nameLabel)
        
        let nickNameLabel = UILabel()
        nickNameLabel.translatesAutoresizingMaskIntoConstraints = false
        nickNameLabel.text = "@ekaterina_nov"
        nickNameLabel.textColor = UIColor(named: "YP Gray")
        nickNameLabel.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(nickNameLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nickNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nickNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nickNameLabel.leadingAnchor)
            
            
        ])
        
        
    }
    
    @objc private func didTapButton(){
        //TODO написать обработку нажатия на кнопку
    }
    
}
