//  PostViewController.swift
//  lab-insta-parse
//
//  Created by Ritesh Kafle
//

import UIKit
import ParseSwift
import PhotosUI
import CoreLocation

class PostViewController: UIViewController,
                          PHPickerViewControllerDelegate,
                          CLLocationManagerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var previewImageView: UIImageView!

   
    private var pickedImage: UIImage?
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        shareButton.isEnabled = false

        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

   
    @IBAction func onPickedImageTapped(_ sender: UIBarButtonItem) {

        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Share Post
    @IBAction func onShareTapped(_ sender: Any) {

        view.endEditing(true)

        // Validate image
        guard let image = pickedImage,
              let imageData = image.jpegData(compressionQuality: 0.1) else {
            showAlert(description: "Please select an image")
            return
        }

        
        let imageFile = ParseFile(name: "image.jpg", data: imageData)

        
        var post = Post()
        post.caption = captionTextField.text
        post.imageFile = imageFile
        post.user = User.current

        
        if let location = currentLocation {
            post.latitude = location.coordinate.latitude
            post.longitude = location.coordinate.longitude
        }

      
        post.save { [weak self] (result: Result<Post, ParseError>) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }

    @IBAction func onViewTapped(_ sender: Any) {
        view.endEditing(true)
    }

    
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: description ?? "Please try again...",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }

   
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        currentLocation = locations.last
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print(" Location error: \(error.localizedDescription)")
    }

    
    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {

        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let image = object as? UIImage else {
                self?.showAlert()
                return
            }

            DispatchQueue.main.async {
                self?.previewImageView.image = image
                self?.pickedImage = image
                self?.shareButton.isEnabled = true
            }
        }
    }
}
