//
//  ProfilVC.swift
//  zarinar
//
//  Created by Adem Tarhan on 3.11.2020.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth

class ProfilVC:  UIViewController, UITableViewDelegate {

    //@IBOutlet weak var imgProfil: UIImageView!    
    //@IBOutlet weak var lblKullaniciAdi: UILabel!
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var lblHakkinda: UILabel!
    
    @IBOutlet weak var sgmntPopulerGuncel: UISegmentedControl!
    private var paylasimlar = [Paylasimlar]()
    private var paylasimCollectionRef : CollectionReference!
    private var paylasimListener : ListenerRegistration!
   
    var SecilenPaylasim : Paylasimlar!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ProfilVC satir 22")
        tableView.delegate = self
        tableView.dataSource = self
        //lblKullaniciAdi.layer.cornerRadius = 7
        //lblHakkinda.layer.cornerRadius = 7
    
        paylasimCollectionRef = Firestore.firestore().collection(PAYLASIMLAR_REF)
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ProfilVC satir 44")
        //ProfilPaylasimlari()
        PopulerPaylasimlar()
        self.tableView.reloadData()
        print("ProfilVC satir 48")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if paylasimListener != nil{
            paylasimListener.remove()
        }
    }
    
    
    func PopulerPaylasimlar(){
        
        print("ProfilVC satir 63 calisiyor")
        
        paylasimListener = Firestore.firestore().collection(PAYLASIMLAR_REF)
        .order(by: Begeni_Sayisi, descending: true).addSnapshotListener{ (snapshot , error) in
            print("ProfilVC satir 64")
            
            
            if let error = error {
                debugPrint("Kayitlari alirken hata meydana geldi \(error.localizedDescription)")
            }else{
                self.paylasimlar.removeAll()
                guard let snap = snapshot else { return }
                
                for document in snap.documents{
                    let data = document.data()
                    
                    //self.lblKullaniciAdi.text = data[Kullanici_Adi] as? String ?? "Misafir"
                    
                    print("ProfilVC satir 59")
                    let KullaniciAdi = data[Kullanici_Adi] as? String ?? "Misafir"
                    print("\(KullaniciAdi)")
                    let Kategori = data[KATEGORI] as? String ?? "Eğlence"
                    let FikirText = data[Fikir_Text] as? String ?? "Fikir Yok"
                    let DokumanId = document.documentID
                    let BegeniSayisi = data[Begeni_Sayisi] as? Int ?? 0
                    let YorumSayisi = data[Yorum_Sayisi] as? Int ?? 0
                    let timestamp = data[Eklenme_Tarihi] as? Timestamp ?? Timestamp()
                    let EklemeTarihi = timestamp.dateValue()
                    let KullaniciId = data[KULLANICI_ID] as? String ?? ""
                    let yeniPaylasim = Paylasimlar(KullaniciAdi: KullaniciAdi, Kategori: Kategori, EklenmeTarihi: EklemeTarihi, TextFikir: FikirText, DokumanId: DokumanId, KullaniciId: KullaniciId, BegeniSayisi: BegeniSayisi, YorumSayisi: YorumSayisi)
                    if( KullaniciId == Auth.auth().currentUser?.uid){
                        self.paylasimlar.append(yeniPaylasim)
                    }
                }
                self.tableView.reloadData()
                print("ProilVC satir 95----\(self.paylasimlar.count)")
            }
        }
    }
    
    func GuncelPaylasimlar(){
        print("ProfilVC satir 99 calisiyor")
        
        paylasimListener = Firestore.firestore().collection(PAYLASIMLAR_REF)
        .order(by: Eklenme_Tarihi, descending: true).addSnapshotListener{ (snapshot , error) in
            if let error = error {
                debugPrint("Kayitlari alirken hata meydana geldi \(error.localizedDescription)")
            }else{
                self.paylasimlar.removeAll()
                guard let snap = snapshot else { return }
                
                for document in snap.documents{
                    let data = document.data()
                    
                    //self.lblKullaniciAdi.text = data[Kullanici_Adi] as? String ?? "Misafir"
                    
                    print("ProfilVC satir 59")
                    let KullaniciAdi = data[Kullanici_Adi] as? String ?? "Misafir"
                    let Kategori = data[KATEGORI] as? String ?? "Eğlence"
                    let FikirText = data[Fikir_Text] as? String ?? "Fikir Yok"
                    let DokumanId = document.documentID
                    let BegeniSayisi = data[Begeni_Sayisi] as? Int ?? 0
                    let YorumSayisi = data[Yorum_Sayisi] as? Int ?? 0
                    let timestamp = data[Eklenme_Tarihi] as? Timestamp ?? Timestamp()
                    let EklemeTarihi = timestamp.dateValue()
                    let KullaniciId = data[KULLANICI_ID] as? String ?? ""
                    let yeniPaylasim = Paylasimlar(KullaniciAdi: KullaniciAdi, Kategori: Kategori, EklenmeTarihi: EklemeTarihi, TextFikir: FikirText, DokumanId: DokumanId, KullaniciId: KullaniciId, BegeniSayisi: BegeniSayisi, YorumSayisi: YorumSayisi)
                    if( KullaniciId == Auth.auth().currentUser?.uid){
                        self.paylasimlar.append(yeniPaylasim)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
 
    
    @IBAction func sgmntDegisti(_ sender: Any) {
        
        switch sgmntPopulerGuncel.selectedSegmentIndex{
        case 0:
            PopulerPaylasimlar()
        case 1:
            GuncelPaylasimlar()
        default:
            PopulerPaylasimlar()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        print("ProfilVC satir 201")
        if segue.identifier == "ProfilYorumlarSegue"{
            print("ProfilVC satir 203")
            if let hedefVC = segue.destination as? ProfilYorumVC{
                print("ProfilVC satir 205")
                if let Secilenpaylasim = sender as? Paylasimlar{
                    print("ProfilVC satir 207")
                    hedefVC.SecilenPaylasim = Secilenpaylasim
                    print("Secilen Paylasim Text : \(SecilenPaylasim.TextFikir)")
                }
            }
        }
    }
}

extension ProfilVC : UIWebViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        paylasimlar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("ProfilVC satir 43")
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PaylasimCell", for: indexPath) as? PaylasimCell{
            cell.GorunumAyari(paylasim: paylasimlar[indexPath.row])
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView : UITableView, didSelectRowAt indexPath: IndexPath){
        print("ProfiVC satir 3")
        performSegue(withIdentifier: "ProfilYorumlarSegue", sender: paylasimlar[indexPath.row])
    }
}


extension ProfilVC : FikirDelegate{
    func seceneklerFikirPressed(fikir: Fikir) {
        print("secilen fikir")
    }
    
    
}



