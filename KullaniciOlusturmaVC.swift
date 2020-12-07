

import UIKit
import Firebase
import FirebaseAuth

class KullaniciOlusturmaVC: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtParola: UITextField!
    @IBOutlet weak var txtKullaniciAdi: UITextField!
    @IBOutlet weak var btnHesapAc: UIButton!
    @IBOutlet weak var btnVazgec: UIButton!
    
    public var KullaniciADI : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        txtEmail.layer.cornerRadius = 5
        txtParola.layer.cornerRadius = 5
        txtKullaniciAdi.layer.cornerRadius = 5
        btnHesapAc.layer.cornerRadius = 10
        btnVazgec.layer.cornerRadius = 10
    }
    

    @IBAction func btnHesapAcPressed(_ sender: Any) {
        guard let emailAdresi = txtEmail.text,
              let parola = txtParola.text,
              let kullaniciAdi = txtKullaniciAdi.text else {return}
        Auth.auth().createUser(withEmail: emailAdresi, password: parola){ (KullaniciBilgileri , hata) in 
            if let hata = hata { 
                debugPrint("Kullanici Olusturulurken Hata Meydana Geldi \(hata.localizedDescription)")
            }
            //Kullanici basarili bir sekilde olusturuldu
            let BilgiGuncelle = KullaniciBilgileri?.user.createProfileChangeRequest()
            BilgiGuncelle?.displayName = kullaniciAdi
            BilgiGuncelle?.commitChanges(completion: {(hata) in
                if let hata = hata{
                    debugPrint("Kullanici Bilgileri Guncellenirken Hata Meydana Geldi \(hata.localizedDescription)")
                }
            })
            
            guard let KullaniciID = KullaniciBilgileri?.user.uid else {return}
            
            
            
            
            Firestore.firestore().collection(KULLANICILAR_REF)
                
                .addDocument( data: [
                    KULLANICI_EMAIL : self.txtEmail.text ?? "",
                    KULLANICI_ADI : self.txtKullaniciAdi.text ?? "Misafir",
                KULLANICI_OLUSTURMA_TARIHI : FieldValue.serverTimestamp(),
                    PAROLA : self.txtParola.text ?? "********",
                    KULLANICI_ID : KullaniciID
                    
            ], completion: {(hata) in
                if let hata = hata {
                    debugPrint("Kullanici Eklenirken Hata Meydana Geldi: \(hata.localizedDescription)")
                }else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        )}
        KullaniciADI = self.txtKullaniciAdi.text ?? "Misafir"
        print("KULLANICIOLUSTURMASATIR65------\(KullaniciADI)")
        print("KULLANICIOLUSTURMASATIR66------\(PAROLA)")
    }
        
        
    @IBAction func btnVazgecPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
