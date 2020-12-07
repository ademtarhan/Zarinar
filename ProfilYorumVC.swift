//
//  ProfilYorumVC.swift
//  zarinar
//
//  Created by Adem Tarhan on 16.11.2020.
//

import UIKit
import Firebase

class ProfilYorumVC: UIViewController{

    
    @IBOutlet weak var fieldTextYorum: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var yorumlar = [ProfilYorum]()
    
    var paylasimlar = [Paylasimlar]()
    
    var fikirRef : DocumentReference!
    var YorumlarListener : ListenerRegistration!
    var kullaniciAdi : String!
    let fireStore = Firestore.firestore()
    
    
    
    var SecilenPaylasim : Paylasimlar!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        fieldTextYorum.layer.cornerRadius = 7
        
        
        
        fikirRef = fireStore.collection(PAYLASIMLAR_REF).document(SecilenPaylasim.DokumanId)
        
        
        if let adi = Auth.auth().currentUser?.displayName{
            kullaniciAdi = adi
        }
        

    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        YorumlarListener = fireStore.collection(PAYLASIMLAR_REF)
            .document(SecilenPaylasim.DokumanId)
            .collection(PROFIL_YORUM_REF)
            .order(by: Eklenme_Tarihi, descending:  false)
            .addSnapshotListener({ (snapshot, hata ) in 
                guard let snapshot = snapshot else{
                    debugPrint("Yorumlari Alirken Hata meydana geldiii \(hata?.localizedDescription)")
                    return 
                }
                self.yorumlar.removeAll()
                self.yorumlar = ProfilYorum.YorumlariGetir(snapshot: snapshot)
                print("Yorumlar GEtirildi")
                self.tableView.reloadData()
            })
    }


    @IBAction func btnYorumYap(_ sender: Any) {
        
        guard let yorumText = fieldTextYorum.text else {return}
        
        fireStore.runTransaction { (transection, errorPointer) -> Any? in
            let secilenFikirKayit : DocumentSnapshot
            do{
                try secilenFikirKayit = transection.getDocument(self.fireStore.collection(Fikirler_REF).document(self.SecilenPaylasim.DokumanId))
            }catch let hata as NSError{
                debugPrint("Hata meydana geldi : \(hata.localizedDescription)")
                return  nil
            }
            
            guard let eskiYorumSayisi = (secilenFikirKayit.data()?[Yorum_Sayisi] as? Int) else {return nil}
            transection.updateData([Yorum_Sayisi : eskiYorumSayisi+1], forDocument: self.fikirRef)
            let YeniYorumREF = self.fireStore.collection(Fikirler_REF).document(self.SecilenPaylasim.DokumanId).collection(YORUMLAR_REF).document()
            transection.setData([
                YORUM_TEXT : yorumText,
                Eklenme_Tarihi : FieldValue.serverTimestamp(),
                KULLANICI_ADI : Kullanici_Adi,
                KULLANICI_ID : Auth.auth().currentUser?.uid ?? ""
            ], forDocument: YeniYorumREF)
            print("ProfilYorumlarVC-Satir 78 Calisiyor")
            return nil
        } completion: { (nesne, hata) in
            if let hata = hata{
                debugPrint("Hata Meydana Geldi : \(hata.localizedDescription)")
            }else{
                self.fieldTextYorum.text = ""
            }
        }
    }
}



extension ProfilYorumVC : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        yorumlar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilYorumCell", for: indexPath) as? ProfilYorumCell{
            cell.gorunumAyarla(yorum: yorumlar[indexPath.row], delegate: self)
            return cell
        }else{
            return UITableViewCell()
        }
        
    }
   
    
    
    
    
}

extension ProfilYorumVC : yorumDelegate{
    func seceneklerYorumPressed(yorum: ProfilYorum) {
        print("=============Secili Yorum \(yorum.YorumText ?? "default")")
    }

}


