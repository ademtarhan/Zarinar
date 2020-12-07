
import UIKit
import FirebaseAuth
import Firebase

class GirisVC: UIViewController {

   
    @IBOutlet weak var txtKullaniciAdi: UITextField!
    @IBOutlet weak var txtParola: UITextField!
    @IBOutlet weak var btnGirisYap: UIButton!
    @IBOutlet weak var btnHesapAc: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        txtParola.layer.cornerRadius = 5
        btnHesapAc.layer.cornerRadius = 10
        btnGirisYap.layer.cornerRadius = 10
        txtKullaniciAdi.layer.cornerRadius = 5
        
       
    }
    
    @IBAction func btnGirisYapPressed(_ sender: Any) {
        btnGirisYap.backgroundColor = .black
        
        guard let KullaniciAdi = txtKullaniciAdi.text,
              let Parola = txtParola.text else{return}
        Auth.auth().signIn(withEmail: KullaniciAdi, password: Parola){(kullanici, hata) in
            if let hata = hata {
                
                debugPrint("Oturum Acilirken Hata Meydana Geldi \(hata.localizedDescription)")
            }else{  
                self.dismiss(animated: true, completion: nil )
            }
        }
    }
    
    
    
    
    
    @IBAction func btnHesapAcPressed(_ sender: Any) {
        btnHesapAc.backgroundColor = .black
    }
    
}
