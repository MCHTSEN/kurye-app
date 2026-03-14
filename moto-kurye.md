&#x20;**Uygulama Adı: Moto Kurye Sipariş Ve Kurye takip programı**



&#x20;**Müşteriler**          : Siparişi veren firma. Sipariş ekleme formunda tabloda firma\_kisa\_ad stunundan dolacak.

&#x20;**Müşteri Personel**    : Müşteri seçildiğinde müşteri\_personelleri tablosunda O müşteriye ait personellerden dolacak

&#x20;**Uğramalar**           : Müşteri seçildiğinde ugramalar tablosunda O müşteriye ait ugrama stunundan dolacak dolacak



&#x20;**Operasyon Personel**  : Sistemi yöneten kendi personelimizdir. Sipariş oluşturabilir, düzenleme yapabilir,kurye atayabilir. Siparişi silemez, sadece iptal edebilir. Geçmiş siparişleri görebilir, inceleyebilir, düzenleme yapabilir.



&#x20;**Kuryeler**            : Kuryeler tablosunda çalışan ve aktif/pasif kuryeler









""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

&#x20; 1- Sayfa ilk açıldığında login sayfası karşılasın. Giriş yapıldığında Müşteri,Operasyon personeli(bizim personel) veya kurye parsoneli olarak herkesi kendi sayfasına yönlendirisin.



&#x09;**1-1 Müşteri Ekranı : Müşterideki personel kendi Kullanıcı bilgileriyel girdiğinde(Mobil olacak) karşılama mesajı çıksın.Sipariş ekleme ekranına gitsin.**

&#x09;	**1-1 : Çıkıs Ugrama Ugrama Not . Bunlar dropdown olacak Bu müşteriye ait ugramalar tablosundan o müşteriye ait ugramalar dolacak**

&#x09;	**1-2 : Sipariş oluşturduktan sonra hemen altına bir satır olarak düşsün. ilk durum "Kurye bekliyor" olsun.,**

&#x09;	**1-3 : Bundan sonraki durumlara müdahale edemesin.**

&#x09;	**1-4 : İş bittiğinde ekrandan düşsün.**

&#x09;	**1-5 : Geçmiş siparişlerden sipariş detaylarını görebilsin.Tarihe göre sipariş süzme yapbilsin.Bunları farklı sayfada görsün**



&#x09;**2-1 Operasyon Ekranı : operasyon personeli kendi Kullanıcı bilgileriyel girdiğinde( WEB ve Mobil olacak) karşılama mesajı çıksın. Ana ekrana gitsin.**

&#x09;	**2-1 : Ana Ekran: Analiz ekranı olsun. 3 aylık 1 aylık ve bir haftalık ciro toplamlarını ve İçinde bulunduğumuz ayın günlük ortalamasını göstersin.Kuryelerin içinde bulunduğumuz aydaki ve o günkü yaptığı işleri toplam kaç iş yaptığını göstersin.BU GÜNKÜ ÇALIŞAN AKTİF KURYELERİ GÖSTERSİN.**



&#x09;	**2-2 : Operasyon Ekranı : En önemli ekran.Aktif kuryelere atama yapsın**

&#x09;

&#x09;	 **2-2-a : Sipariş olşturma paneli:Sipariş eklendikten sonra Kurye Bekleyenler tarafına geçsin**

&#x09;

&#x09;		**Müşteri(Dropdown): Müşteriler tablosunda dolacak**

&#x20;			**Cikis (Dropdown) : müşteri seçilince Ugramalar tablosundan Müşteriye ait ugramalar dolacak**

&#x09;		**Ugrama (Dropdown): müşteri seçilince Ugramalar tablosundan Müşteriye ait ugramalar dolacak**

&#x09;		**Ugrama1(Dropdown): müşteri seçilince Ugramalar tablosundan Müşteriye ait ugramalar dolacak. Boş geçilebilecek**

&#x09;		**Not   (Dropdown) : müşteri seçilince Ugramalar tablosundan Müşteriye ait ugramalar dolacak**

&#x09;		**Not1	(textBox) : Boş geçilebilecek**

**Sçilecek Ugrama yok ise Kayıt yapmak için sorsun ve kaydetsin.**



&#x09;	**2-2-b : Kurye Bekleyenler Paneli : Siparişin düştüğü ikinci alan.sipariş düzenleme işlemi yapılabilsin.siparişe tıklayınca sipariş oluşturma paneline düşsün ve işlem yapılabilsin.Burada Kurye Kutsu olsun.Siparişlerin başında seçme kutusu(ChekBox)olsun.Seçili siparişlere Kurye seçilip atama işlemi yapılsın.Siparişin durumu "Devam ediyor" Paneline düşsün.**



&#x09;		**Saat 		   : Siparişin verildiği saati göstersin**

&#x09;		**Müsteri/PersonelAdi: firma\_kisa\_adi/PersonelAdi**

&#x09;		**Güzergah	   : ChekBox - Cikis-ugrama-Ugrama1(varsa) Özellikle böyle görünsün.**



&#x09;

&#x09;	**2-3 Devam edenler Paneli : ChekBox Saat - Msteri/PersonelAdi - Güzergah - Kurye   Seçilen siparişler Bitti butonu ile bitirebilsin.   İşi bitirdiğinde sistem tablodan daha önce yapılmış en yakın tarihteki siparişin ücretini biten siparişe eklesin, yoksa operasyon personeline uyarı versin. Maosu haritada kuryenin üstüne getirdiğinde kuryedeki devam eden işleri görsün.**





**Bu (üç)panel aynı sayfada: Üstte:*Sipariş olşturma paneli* altta: <i>Kurye Bekleyenler Paneli</i> bunun yanında <i>Devam edenler Paneli</i> olsun. yani bütün paneller aynı sayfada olsun.Durumlar değiştikçe Sayfa yenileme olmasın sadece panellerdeki veriler değişsin. Müşterinin mobilde verdiği sipariş anlık olarak operasyon ekranına düşsün.Sesli Uyarı versin.Aynı şekilde müşteri ekranlarıda güncellesin.**





&#x09;	**3-1 Kurye Ekranı: Kendi kullanıcı bilgileriyle giriş yapsın. Ekranda kendisini aktif pasif yapabilsin.Aktif durumda sipariş alabilsin.**



&#x09;	**3-2 Siparişi aldığını onaylasın.**

&#x09;	**3-3 Cıkıs(textBox) Ugrama(TextBox) Ugrama1(textBox) olsun. Her aldığı noktada ait olan textBox a tıklasın. Sistem Saat atsın.**

&#x09;	**3-4 Kuryeyi uygulama üstünden takip edebilelim. İşler bitince akranından düşsün.**

&#x20;









&#x20; **Otomatik kurye ataması için bir buton koyalım(Otomatik/Manuel). Otomatik kurye ataması ve mesafe hesaplama için uğramalar tablosunda lokasyon alanına kayıt yapabilelim, Buradaki format Geograpy. Bir kurye birden fazla iş alabilir. Aynı güzergah Üzerin de gelecek siparişleri o güzergahtaki kuryeye atayabilsin.**





&#x20;**Müşteri kayıt ekaranı olsun. Kayıttan sonra alt tarafta excel tablosu şeklinde görelim.Tıklandığında Kayıt paneline çıksın ve düzenleme/güncelleme yapılabilsin.Bunu bizim personelimiz yapabilsin.**



&#x20;**Müşteri personel kayıt ekranı: Mutlaka müşteri seçilsin. seçilmediği sürece kaydetmesin uyarı versin.Bunu bizim personelimizde yapabilsin.**





**Geçmiş Siparişler Ekranı: Burada Geçmiş siparişleri görelim.Excell görünümü gibi olsun. Tarihe- Müşteriye-Cikis-Ugrama diye Süzme yapabişlelim. Üst tarafta toplam ciro aktif alarak görünsün. Burada siparişe tıkladığımızda yukarıya bir panel koyalım düzenleme ve güncelleme yapabilelim.**



**Kuryenin konumunu sadece günlük kayıt yapalım. uzun kayıt yapıp şişirmeye gerek yok**



**Siparişlerde log tutabiliriz ama semn öner. Farklı önerilerin varsa onlarada bakmak isterim**





**“Kullanıcıların not tutabileceği basit bir web uygulaması yapmak istiyorum. React ve Node.js kullanılsın, kullanıcı giriş sistemi olsun.”**

