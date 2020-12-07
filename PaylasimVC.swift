

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
class PaylasimVC : UIViewController {
    
   
    @IBOutlet weak var sgmntKategori: UISegmentedControl!
    @IBOutlet weak var lblKategori: UILabel!
    @IBOutlet weak var txtKullaniciAdi: UITextView!
    @IBOutlet weak var txtFikir: UITextView!
    @IBOutlet weak var btnPaylas: UIButton!
    
   
    
    let Kategoriler = ["Eğlence","Spor","Magazin","Bilim","Teknoloji"]
    let placeholdertextKullaniciAdi = "Kullanici Adi"
    let placeholdertextFikir = "Fikriniz..."
    var SecilenKategori = "Eglence"
    override func viewDidLoad() {
        super.viewDidLoad()
        txtFikir.layer.cornerRadius = 5
        btnPaylas.layer.cornerRadius = 5
        
        txtFikir.text = placeholdertextFikir
        txtFikir.textColor = .lightGray
        txtFikir.delegate = self 
        
        
        
    } 
    
    
    @IBAction func sgmntDegisti(_ sender: Any){
        switch sgmntKategori.selectedSegmentIndex{
         case 0:
            SecilenKategori = Kategoriler[0]
            lblKategori.text = SecilenKategori
        case 1:
            SecilenKategori = Kategoriler[1]
            lblKategori.text = SecilenKategori
        case 2:
            SecilenKategori = Kategoriler[2]
            lblKategori.text = SecilenKategori
        case 3:
            SecilenKategori = Kategoriler[3]
            lblKategori.text = SecilenKategori
        case 4:
            SecilenKategori = Kategoriler[4]
            lblKategori.text = SecilenKategori
        default:
            SecilenKategori = Kategoriler[0]
       }
    }
    
    //..Paylaş butonun etkinleştirildiğinde yapılacak eylemler
     
    
    @IBAction func btnPaylasPressed(_ sender: Any) {   
        
        guard let /*KullaniciAdi = txtKullaniciAdi.text,
              let*/ Fikir = txtFikir.text else { return}
        print("PaylasimVC-Satir 68 Calisiyor")
        
        Firestore.firestore().collection(Fikirler_REF).addDocument(data: [
            
            Kullanici_Adi : txtKullaniciAdi.text ?? "Misafir" ,
            KATEGORI : SecilenKategori,
            Begeni_Sayisi : 0,
            Yorum_Sayisi : 0,
            Fikir_Text : txtFikir.text!,
            Eklenme_Tarihi : FieldValue.serverTimestamp(),
           
            KULLANICI_ID : Auth.auth().currentUser?.uid ?? ""
            
        ]){(hata) in
            if let hata = hata{
                print("Dokuman hatasi \(hata.localizedDescription)")
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }
        print("PaylasimVC-Satir 75 Calisiyor")
        
        
        Firestore.firestore().collection(PAYLASIMLAR_REF).addDocument(data: [
            
            Kullanici_Adi : txtKullaniciAdi.text ?? "Misafir" ,
            KATEGORI : SecilenKategori,
            Begeni_Sayisi : 0,
            Yorum_Sayisi : 0,
            Fikir_Text : txtFikir.text!,
            Eklenme_Tarihi : FieldValue.serverTimestamp(),
           
            KULLANICI_ID : Auth.auth().currentUser?.uid ?? ""
            
        ]){(hata) in
            if let hata = hata{
                print("Dokuman hatasi \(hata.localizedDescription)")
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }
        print("PaylasimVC-Satir 104 Calisiyor")
    }
}


/*
 Paylaşım sayfasındakı -kullanıcı adı ve fikir- kısımlarının yazı işlemleri yapıldı. Görünürlük durumu
 */
extension PaylasimVC : UITextViewDelegate{
   func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholdertextKullaniciAdi {
            textView.text = ""
            textView.textColor = .black
        }
        if textView.text == placeholdertextFikir{
            textView.text = ""
            textView.textColor = .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
           // txtKullaniciAdi.text = placeholdertextKullaniciAdi
            //txtKullaniciAdi.textColor = .lightGray
        }
        if textView.text.isEmpty{
            txtFikir.text = placeholdertextFikir
            txtFikir.textColor = .lightGray
        }
    }
}






