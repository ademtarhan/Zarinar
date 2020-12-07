//
//  AnaViewController.swift
//  zarinar
//
//  Created by Adem Tarhan on 15.10.2020.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth


class FikirlerVC : UIViewController{

    
    
  
    

    @IBOutlet weak var sgmntKategoriler: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblSeciliKategori: UILabel! 
    @IBOutlet weak var sgmntTrendYeni: UISegmentedControl!
    
    
    @IBOutlet weak var btnYeniler: UIButton!
    
    @IBOutlet weak var btnPopuler: UIButton!
    
    private var Fikirler = [Fikir]()  //..Fikir türünde boş bir dizi tanımlandı.
   
    
    
    
    
    private var FikirlerCollectionRef : CollectionReference! //..Koleksiyondan veri alımı için referans oluşturuldu.
    private var FikirlerListener : ListenerRegistration!
    private var SecilenKategori = Kategoriler.Eglence.rawValue //..Default olarak bir kategori secildi.
    private var SecilenFiltre : String! //..Default olarak bir filtre seçildi.
    private var ListenerHandle : AuthStateDidChangeListenerHandle?
    //var Giris_Cikis : Bool = true
    var secilenfikir : Fikir!
    let Filtreler = ["Yeni","Trend"]
    let Kategoriler1 = ["Eğlence","Spor","Magazin","Bilim","Teknoloji"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Satir 28")
        tableView.delegate = self
        tableView.dataSource = self
        
        
        sgmntKategoriler.layer.cornerRadius = 0
        btnPopuler.layer.cornerRadius = 10
        btnYeniler.layer.cornerRadius = 10
       
        
        FikirlerCollectionRef = Firestore.firestore().collection(Fikirler_REF) 
        
        
       
        
    }
    
    
    @IBAction func btnYenilerPressed(_ sender: Any) {
        
        YeniSelected()
        btnYeniler.backgroundColor = .systemGray
        btnPopuler.backgroundColor = .lightGray
        
    }
    
    
    @IBAction func btnPopulerPressed(_ sender: Any) {
        TrendSelected()
        btnPopuler.backgroundColor = .systemGray
        btnYeniler.backgroundColor = .lightGray
    }
    
    
    
    
    //Verileri Alinmasi ve anlik degisiminin yansitilmasi
    override func viewWillAppear(_ animated: Bool) {
        print("FikirlerVC-Satir 38 Calisiyor")
        
        
        
        
        self.tableView.reloadData() //..Table viewdeki veriler tekrar yüklendi
       // self.YeniSelected()
       
        
            //..Kullanıcının uygulamada girişi olup olmadığı kontrol edildi.
        ListenerHandle = Auth.auth().addStateDidChangeListener{(auth,user) in
           if user == nil{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let GirisVC = storyboard.instantiateViewController(withIdentifier: "GirisVC")
                self.present(GirisVC, animated: true, completion: nil)
            }else{
               self.YeniSelected()
            }}
        
        
        
    }
    //..Verilerin tekrarlanmaması sağlandı.
    override func viewWillDisappear(_ animated: Bool) {
        if FikirlerListener != nil {
            FikirlerListener.remove() 
        }
    }
    
    
   
    
    

    
    //..Beğeni sayısına göre veriler alınıp sıralandı.
    func TrendSelected(){
        print("Satir 49")
        FikirlerListener = FikirlerCollectionRef.whereField(KATEGORI, isEqualTo: SecilenKategori)
            .order(by: Begeni_Sayisi, descending: true) //..Beğeni sayısına göre sıralanma sağlandı.
            .addSnapshotListener{ (snapshot, error ) in 
                print("FikirlerVC satir 119")
            if let error = error {
                debugPrint("Kayitlari Alirken Hata Meydana geldi-Satir 80 \(error.localizedDescription)")
            }else{
                print("FikirlerVC satir 123")
                self.Fikirler.removeAll() //ayni verileri tekrar yazdirilmamasi saglandi
                guard let snap = snapshot else{return} 
                print("FikirlerVC satir 126")
                for documentler in snap.documents {
                    print("FikirlerVC satir 128")
                    let data = documentler.data()
                    print("Satir 64")
                    let KullaniciAdi = data[KULLANICI_ADI] as? String ?? "Misafir"
                    let FikirText = data[Fikir_Text] as? String ?? ""
                    let BegeniSayisi = data[Begeni_Sayisi] as?  Int ?? 0
                    let YorumSayisi = data[Yorum_Sayisi] as? Int ?? 0
                    let DokumanId = documentler.documentID 
                    let timestamp = data[Eklenme_Tarihi] as? Timestamp ?? Timestamp()
                    let EklemeTarihi = timestamp.dateValue()
                    let KullaniciId = data[KULLANICI_ID] as? String ?? ""
                    
                    let YeniFikir = Fikir(KullaniciAdi: KullaniciAdi, EklemeTarihi: EklemeTarihi, BegeniSayisi: BegeniSayisi, YorumSayisi: YorumSayisi, FikirText: FikirText, DokumanID: DokumanId, KullaniciID: KullaniciId)
                    self.Fikirler.append(YeniFikir)
                }
                self.tableView.reloadData()  //Her yeni verinin tableview de gorunmesi saglandi
            }
        }
    }
    
    func YeniSelected(){
        print("FikirlerVC-Satir 100")
        FikirlerListener = FikirlerCollectionRef.whereField(KATEGORI, isEqualTo: SecilenKategori)
            .order(by: Eklenme_Tarihi, descending: true)
            .addSnapshotListener{ (snapshot, error ) in 
            if let error = error {
                debugPrint("Kayitlari Alirken Hata Meydana geldi-Satir 104 \(error.localizedDescription)")
            }else{
                self.Fikirler.removeAll() //ayni verileri tekrar yazdirilmamasi saglandi
                guard let snap = snapshot else{return} 
                    for document in snap.documents {
                    let data = document.data()
                    print("Satir 93")
                    let KullaniciAdi = data[Kullanici_Adi] as? String ?? "Misafir"
                    //let EklemeTarihi = data[Eklenme_Tarihi] as? Date ?? Date()
                    let FikirText = data[Fikir_Text] as? String ?? ""
                    let BegeniSayisi = data[Begeni_Sayisi] as?  Int ?? 0
                    let YorumSayisi = data[Yorum_Sayisi] as? Int ?? 0
                    let DokumanId = document.documentID 
                    let timestamp = data[Eklenme_Tarihi] as? Timestamp ?? Timestamp()
                    let EklemeTarihi = timestamp.dateValue()
                    let KullaniciId = data[KULLANICI_ID] as? String ?? ""
                    let YeniFikir = Fikir(KullaniciAdi: KullaniciAdi, EklemeTarihi: EklemeTarihi, BegeniSayisi: BegeniSayisi, YorumSayisi: YorumSayisi, FikirText: FikirText, DokumanID: DokumanId,KullaniciID: KullaniciId)
                    
                    self.Fikirler.append(YeniFikir)
                        print("FikirlerVC satir 206----\(KullaniciAdi)")
                    //self.tableView.reloadData() 
                }
                self.tableView.reloadData()  //Her yeni verinin tableview de gorunmesi saglandi
                
                print("FikirlerVC satir 206----\(self.Fikirler.count)")
                
                
            }
        }
    }

    //..Kategori seçimi sağlandı
    @IBAction func KategoriDegisti(_ sender: Any) {
        switch sgmntKategoriler.selectedSegmentIndex{
        case 0:
            self.SecilenKategori = Kategoriler.Eglence.rawValue
            print("Kategori \(SecilenKategori as Any)")
            YeniSelected()
        case 1:
            self.SecilenKategori = Kategoriler.Spor.rawValue
            print("Kategori \(SecilenKategori as Any)")
            YeniSelected()
        case 2:
            self.SecilenKategori = Kategoriler.Magazin.rawValue
            print("Kategori \(SecilenKategori as Any)")
            YeniSelected()
        case 3:
            self.SecilenKategori = Kategoriler.Teknoloji.rawValue
            print("Kategori \(SecilenKategori as Any)")
            YeniSelected()
        case 4:
            self.SecilenKategori = Kategoriler.Bilim.rawValue
            print("Kategori \(SecilenKategori as Any)")
            YeniSelected()
        default:
            self.SecilenKategori = Kategoriler.Eglence.rawValue
            btnYenilerPressed(SecilenFiltre as Any)
            YeniSelected()
        }
    }

    
    //..Oturum kapatma fonksiyonu yazıldı
    @IBAction func btnCikisPressed(_ sender: Any){
        
                let firebaseAuth = Auth.auth()
                do{
                    try firebaseAuth.signOut()
                    print("Cikis Yapildi")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let GirisVC = storyboard.instantiateViewController(withIdentifier: "GirisVC")
                    
                    self.present(GirisVC, animated: true, completion: nil) 
                    print("Giris Ekrani Getirildi")
                }catch let CikisHatasi as NSError {
                    print("Oturum Kapatilirken Hata Meydana Geldi \(CikisHatasi.localizedDescription)")
                }
    }
    
    //..Yorum sayfasına bağlantı kuruldu.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Satir 206 Calisiyor")
        if segue.identifier == "YorumlarSegue" {
            print("Satir 208 Calisiyor")
            if let HedefVC = segue.destination as? YorumlarVC {
                print("Satir 210 Calisiyor")
                if let Secilenfikir = sender as? Fikir{
                    print("Satir 212 Calisiyor")
                    HedefVC.secilenFikir = Secilenfikir
                }
            }
        }
    }
}

extension FikirlerVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Fikirler.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FikirCell", for: indexPath) as? FikirCell{
            cell.GorunumAyarla(fikir: Fikirler[indexPath.row], delegate: self)
            return cell
        }else{
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "YorumlarSegue", sender: Fikirler[indexPath.row])
    }
    
    
}
extension FikirlerVC : FikirDelegate {
    func seceneklerFikirPressed(fikir: Fikir) {
        print("----------------secilen fikir \(fikir.FikirText ?? "default")")
    }
}



















