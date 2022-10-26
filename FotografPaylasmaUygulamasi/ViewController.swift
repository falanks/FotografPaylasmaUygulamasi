//
//  ViewController.swift
//  FotografPaylasmaUygulamasi
//
//  Created by Muhammed Sağlam on 17.10.2022.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sifreTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func girisYapTiklandi(_ sender: Any) {
        if emailTextField.text != "" && sifreTextField.text != "" {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: sifreTextField.text!) { authdataresult, error in
                if error != nil {
                    self.hataMesaji(titleInput: "Hata", messageInput: error!.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        } else {
            hataMesaji(titleInput: "hata", messageInput: "mail ve sifre giriniz")
        }
    }
    
    @IBAction func kayitOlTiklandi(_ sender: Any) {
        //mail ve sifre girilmediyse islem yapılmasın istiyoruz.
        //mail ve sifre bos degilse .... islem yap .... , else ...
        if emailTextField.text != "" && sifreTextField.text != "" {
            //mail ve sifre bos degilse kayıt olma islemi yapılsın.(firebase import edildi.)
            Auth.auth().createUser(withEmail: emailTextField.text!, password: sifreTextField.text!) { authdataresult, error in
                if error != nil {
                    self.hataMesaji(titleInput: "Hata!", messageInput: error!.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
            //ünlem koyabiliriz cünkü if kontrolle garanti altına aldık, bos gelmeyecek.
        } else {
            //kullanıcıya hata mesajı verilsin.
            hataMesaji(titleInput: "hata", messageInput: "mail ve sifre giriniz")
        }

    }
    
    //hata mesajı sablonu olusturduk, kullanıcının yaptıgı isleme göre mesaj icerigi farklı yazılacak.
    func hataMesaji(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
}

