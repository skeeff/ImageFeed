import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController{
    
    var largeImageURL: URL?
    private var imageView: UIImageView?
    private var scrollView: UIScrollView?
    private var shareButton: UIButton?
    private lazy var backButton: UIButton? = {
        let backButton = UIButton()
        backButton.accessibilityIdentifier = "backButton"
        return backButton
    }()
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupScrollViewAndImageView()
        addBackButton()
        addShareButton()
        setImage()
    }
    
    private func setupScrollViewAndImageView() {
        let scrollView = UIScrollView(frame: view.bounds)
        let imageView = UIImageView()
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        
        self.scrollView = scrollView
        self.imageView = imageView
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        guard let scrollView, let imageView else { return }
        imageView.bounds.size = image.size
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.height / imageSize.height
        let wScale = visibleRectSize.width / imageSize.width
        let scale = min(maxZoomScale, max(hScale, wScale))
        scrollView.minimumZoomScale = min(maxZoomScale, max(minZoomScale, min(hScale, wScale)))
        scrollView.maximumZoomScale = 3 * scale
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func setImage(){
        loadImage()
//        guard let imageView else { return }
//        
//        UIBlockingProgressHUD.show()
//        imageView.kf.setImage(with: largeImageURL){ [weak self] result in
//            UIBlockingProgressHUD.dismiss()
//            guard let self else{ return }
//            switch result{
//            case .success(let imageResult):
//                rescaleAndCenterImageInScrollView(image: imageResult.image)
//                
//            case .failure(_):
//                if !isBeingDismissed{
//                    self.setImage()
//                }
//            }
//        }
    }
    
    private func loadImage(){
        guard let imageView else { return }
        
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: largeImageURL){ [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else{ return }
            switch result{
            case .success(let imageResult):
                rescaleAndCenterImageInScrollView(image: imageResult.image)
                
            case .failure(_):
                if !isBeingDismissed{
                    self.showError()
                }
            }
        }
    }
    
    private func showError(){
        let alert = UIAlertController(title: "Что - то пошло не так", message: "Попробовать еще раз?", preferredStyle: .alert)
        let actionNo = UIAlertAction(title: "Нет", style: .default)
        let actionReload = UIAlertAction(title: "Повторить", style: .default){ [weak self] _ in
            guard let self else { return }
            self.loadImage()
        }
        alert.addAction(actionNo)
        alert.addAction(actionReload)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func addBackButton() {
        guard let backButtonImage = UIImage(named: "nav_back_button")?.withRenderingMode(.alwaysOriginal) else { return }
        
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(self.didTapBackButton), for: .touchUpInside)
        
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
        
        self.backButton = backButton
    }
    
    private func addShareButton() {
        guard let shareButtonImage = UIImage(named: "share_button")?.withRenderingMode(.alwaysOriginal) else { return }
        
        let shareButton = UIButton(type: .custom)
        shareButton.setImage(shareButtonImage, for: .normal)
        shareButton.addTarget(self, action: #selector(self.didTapShareButton), for: .touchUpInside)
        view.addSubview(shareButton)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            shareButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
        
        self.shareButton = shareButton
    }
    
    @objc private func didTapBackButton() {
        guard let imageView else { return }
        dismiss(animated: true)
        imageView.kf.cancelDownloadTask()
    }
    
    @objc private func didTapShareButton() {
        guard let imageView else { return }
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
    
    private func centerImageInScrollViewAfterZoom() {
        guard let scrollView else { return }
        let xInset = max((scrollView.bounds.width - scrollView.contentSize.width) / 2, 0)
        let yInset = max((scrollView.bounds.height - scrollView.contentSize.height) / 2, 0)
        scrollView.contentInset = UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: xInset)
        
    }
    
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
        
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageInScrollViewAfterZoom()
    }
    
    
}
