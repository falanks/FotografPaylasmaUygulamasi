//
//  UploadViewController.swift
//  FotografPaylasmaUygulamasi
//
//  Created by Muhammed Sağlam on 17.10.2022.
//

import UIKit
import Firebase

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var yorumTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //gorseli kullanıcıya sectirmek istiyoruz.
        //image'ı etkilesime actık, etkilesimi fonksiyona bagladık. fonksiyon asagıda (gorselSec).
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    
    
    
    
    @objc func gorselSec() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true)
        //foto secildi, secilince ne olacagı asagıda (didfinish func)
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }
    
    @IBAction func uploadButtonTiklandi(_ sender: Any) {
        let storage = Storage.storage()
        let storageReferance = storage.reference()
        
        let mediaFolder = storageReferance.child("media") //firebase storage'da media klasörü olusturuldu, referansımız burası olarak belirlendi.
        //fakat image'ı normal data'ya dönüstürerek yüklemek gerekiyor.
        if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
            
            let uuid = UUID().uuidString
            
            let imageReferance = mediaFolder.child("\(uuid).jpg")
            imageReferance.putData(data) { (storagemetadata, error) in
                if error != nil {
                    self.hataMesajiGoster(title: "hata", message: error!.localizedDescription)
                } else {
                    imageReferance.downloadURL { (url, error) in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            //simdi ise verileri firestore database'e yüklemek gerekiyor. //koleksiyon, doküman, vs..
                            if let imageUrl = imageUrl { //imageurl'yi optional'dan cıkardık.
                                let firestoreDatabase = Firestore.firestore()
                                let firestorePost = ["gorselurl" : imageUrl,
                                                     "yorum": self.yorumTextField.text,
                                                     "email": Auth.auth().currentUser?.email,
                                                     "tarih": FieldValue.serverTimestamp()] as [String : Any]
                                firestoreDatabase.collection("Post").addDocument(data: firestorePost) { error in
                                    if error != nil {
                                        self.hataMesajiGoster(title: "hata", message: error?.localizedDescription ?? "hata, tekrar dene.")
                                    } else {
                                        self.imageView.image = UIImage(named: "unknown")
                                        self.yorumTextField.text = ""
                                        self.tabBarController?.selectedIndex = 0
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func hataMesajiGoster(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
}
