//
//  YorumlarVC.swift
//  zarinar
//
//  Created by Adem Tarhan on 30.10.2020.
//

import UIKit
import Firebase
import FirebaseAuth
class YorumlarVC: UIViewController {

    @IBOutlet weak var txtYorum: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblKullaniciAdi: UILabel!
    @IBOutlet weak var lblBegeniSayisi: UILabel!
    @IBOutlet weak var imgBegeni: UIImageView!
    @IBOutlet weak var lblFikirText: UILabel!
    @IBOutlet weak var lblTarih: UILabel!
    @IBOutlet weak var lblYorumSayisi: UILabel!
    
    
    
    
    var Yorumlar = [Yorum]()
    
    var secilenFikir : Fikir!
    var fikirRef : DocumentReference!
    let fireStore = Firestore.firestore()
    var kullaniciAdi : String!
    var YorumlarListener : ListenerRegistration!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        txtYorum.layer.cornerRadius = 7
        print("\(self.secilenFikir.FikirText!)")
        fikirRef = fireStore.collection(Fikirler_REF).document(secilenFikir.DokumanID)
        print("YorumlarVC satir 33")
       
        if let adi = Auth.auth().currentUser?.displayName{
            kullaniciAdi = adi
        }
       
        self.view.KlavyeAyarla()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        YorumlarListener = fireStore.collection(Fikirler_REF).document(secilenFikir.DokumanID).collection(YORUMLAR_REF)
            .order(by: Eklenme_Tarihi, descending: false)
            .addSnapshotListener({(snapshot,hata) in
            guard let snapshot = snapshot else{
                debugPrint("Yorumlari Getirirken Hata Meydana Geldi : \(hata?.localizedDescription)")
                return
            }
                print("profilVC satir 61")

               // for document in snapshot.documents{
                    //let data = document.data()
                    print("YorumlarVC satir 63")
                    self.lblKullaniciAdi.text = self.secilenFikir.KullaniciAdi
                    self.lblFikirText.text = self.secilenFikir.FikirText
                    
                    
                    let tarihiFormat = DateFormatter()
                    tarihiFormat.dateFormat = "dd MM yyyy hh:mm"
                    self.lblTarih.text = tarihiFormat.string(from: self.secilenFikir.EklemeTarihi)
                    
                    
                    
                    
                    self.lblBegeniSayisi.text = String(self.secilenFikir.BegeniSayisi)
                    self.lblYorumSayisi.text = String(self.secilenFikir.YorumSayisi)
                    
                    
                    print("""
                        \(self.secilenFikir.KullaniciAdi!)
                        \(self.secilenFikir.FikirText!)
                        \(self.secilenFikir.BegeniSayisi!)
                        """)
                    
              //  }
            
            
            
            self.Yorumlar.removeAll()
            self.Yorumlar = Yorum.YorumlariGetir(snapshot: snapshot)
                print("YorumlarVC-Satir 53 Calisiyor")
            self.tableView.reloadData()
        })
    }
    
    
    
    @IBAction func btnYorumEkle(_ sender: Any) {
        
        guard let yorumText = txtYorum.text else {return}
        
        fireStore.runTransaction { (transection, errorPointer) -> Any? in
            let secilenFikirKayit : DocumentSnapshot
            do{
                try secilenFikirKayit = transection.getDocument(self.fireStore.collection(Fikirler_REF).document(self.secilenFikir.DokumanID))
            }catch let hata as NSError{
                debugPrint("Hata meydana geldi : \(hata.localizedDescription)")
                return  nil
            }
            
            guard let eskiYorumSayisi = (secilenFikirKayit.data()?[Yorum_Sayisi] as? Int) else {return nil}
            transection.updateData([Yorum_Sayisi : eskiYorumSayisi+1], forDocument: self.fikirRef)
            let YeniYorumREF = self.fireStore.collection(Fikirler_REF).document(self.secilenFikir.DokumanID).collection(YORUMLAR_REF).document()
            transection.setData([
                YORUM_TEXT : yorumText,
                Eklenme_Tarihi : FieldValue.serverTimestamp(),
                KULLANICI_ADI : self.kullaniciAdi,
                KULLANICI_ID : Auth.auth().currentUser?.uid ?? ""
            ], forDocument: YeniYorumREF)
            print("YorumlarVC-Satir 78 Calisiyor")
            return nil
        } completion: { (nesne, hata) in
            if let hata = hata{
                debugPrint("Hata Meydana Geldi : \(hata.localizedDescription)")
            }else{
                self.txtYorum.text = ""
            }
            
            
        }


}
}

extension YorumlarVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Yorumlar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "YorumCell", for: indexPath) as? YorumCell{
            cell.GorunumAyarla(yorum: Yorumlar[indexPath.row],delegate: self)
            return cell
        }
        return UITableViewCell()
    }
}


extension YorumlarVC : YorumDelegate{
    func secenklerYorumPressed(yorum: Yorum) {
        print("------------secilen yorum \(yorum.YorumText)")
    }
}


