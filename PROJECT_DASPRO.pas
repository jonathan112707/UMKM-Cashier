program U-Cashier;

uses    crt;

type  DataProduk = record
        Kode: string[10];
        Nama: string[35];
        Kategori: string[20];
        Harga: longint;
        Stok: integer;
  end;

      ItemKeranjang = record
        Nama: string[35];
        HargaSatuan: longint;
        JumlahBeli: integer;
        Subtotal: longint;
  end;

    ArrayKatalog = array[1..50] of DataProduk;
    ArrayKeranjang = array[1..30] of ItemKeranjang;

var
  Katalog: ArrayKatalog;
  Keranjang: ArrayKeranjang;
  jumlahProduk, pilihanMenu: integer;
  totalOmzet: longint;

function KapitalkanString(teks: string): string;
var
  i: integer;
begin
  for i := 1 to Length(teks) do
    teks[i] := UpCase(teks[i]);
  KapitalkanString := teks;
end;

function CariIndeksBarang(var daftar: ArrayKatalog; total: integer; kodeCari: string): integer;
var
  i, hasil: integer;
begin
  hasil := -1;
  for i := 1 to total do
    if daftar[i].Kode = kodeCari then
    begin
      hasil := i;
      break;
    end;
  CariIndeksBarang := hasil;
end;

function HitungDiskon(totalKotor: longint; member: char): longint;
var
  status: char;
begin
  status := UpCase(member);
  if (status = 'Y') and (totalKotor >= 100000) then
    HitungDiskon := Round(totalKotor * 0.10)
  else if (status = 'Y') or (totalKotor >= 100000) then
    HitungDiskon := Round(totalKotor * 0.05)
  else
    HitungDiskon := 0;
end;

procedure InputProduk(var daftar: ArrayKatalog; var total: integer; judul: string);
var
  i, jumlahTambah: integer;
  kodeBaru: string[10];
  namaBaru: string[35];
  kategoriBaru: string[20];
  hargaBaru: longint;
  stokBaru: integer;
begin
  clrscr;
  writeln(judul);
  repeat
    write('Jumlah produk yang diinput (0-', 50 - total, ') : ');
    readln(jumlahTambah);
  until (jumlahTambah >= 0) and (jumlahTambah <= 50 - total);
  for i := 1 to jumlahTambah do
  begin
    writeln;
    writeln('Produk ke-', total + 1);
    repeat
      write('  Kode Barang  : ');
      readln(kodeBaru);
      kodeBaru := KapitalkanString(kodeBaru);
      if (Length(kodeBaru) = 0) or (CariIndeksBarang(daftar, total, kodeBaru) <> -1) then
        writeln('  Kode kosong atau sudah terdaftar.');
    until (Length(kodeBaru) > 0) and (CariIndeksBarang(daftar, total, kodeBaru) = -1);
    repeat
      write('  Nama Barang  : ');
      readln(namaBaru);
      write('  Kategori     : ');
      readln(kategoriBaru);
      write('  Harga Satuan : ');
      readln(hargaBaru);
      write('  Stok Awal    : ');
      readln(stokBaru);
      if (Length(namaBaru) = 0) or (Length(kategoriBaru) = 0) or (hargaBaru <= 0) or (stokBaru < 0) then
        writeln('  Data tidak valid, silakan ulangi.');
    until (Length(namaBaru) > 0) and (Length(kategoriBaru) > 0) and (hargaBaru > 0) and (stokBaru >= 0);
    total := total + 1;
    daftar[total].Kode := kodeBaru;
    daftar[total].Nama := namaBaru;
    daftar[total].Kategori := kategoriBaru;
    daftar[total].Harga := hargaBaru;
    daftar[total].Stok := stokBaru;
  end;
end;

procedure TampilkanKatalog(var daftar: ArrayKatalog; total: integer);
var
  i: integer;
begin
  writeln('KATALOG PRODUK U-CASHIER');
  if total = 0 then
    writeln('Katalog masih kosong.')
  else
  begin
    writeln('Kode':8, 'Nama Barang':26, 'Kategori':14, 'Harga (Rp)':12, 'Stok':8);
    for i := 1 to total do
      writeln(daftar[i].Kode:8, daftar[i].Nama:26, daftar[i].Kategori:14, daftar[i].Harga:12, daftar[i].Stok:8);
  end;
  writeln;
end;

procedure CetakStruk(var beli: ArrayKeranjang; jml: integer; kotor, diskon, akhir, bayar, kembali: longint);
var
  i: integer;
begin
  clrscr;
  writeln('STRUK PEMBAYARAN U-CASHIER');
  writeln('Nama Barang':26, 'Qty':6, 'Harga':10, 'Subtotal':12);
  for i := 1 to jml do
    writeln(beli[i].Nama:26, beli[i].JumlahBeli:6, beli[i].HargaSatuan:10, beli[i].Subtotal:12);
  writeln('Total Kotor : Rp ', kotor);
  writeln('Diskon      : Rp ', diskon);
  writeln('Total Akhir : Rp ', akhir);
  writeln('Tunai Bayar : Rp ', bayar);
  writeln('Kembalian   : Rp ', kembali);
end;

procedure ProsesTransaksi(var daftar: ArrayKatalog; total: integer; var omzet: longint);
var
  jmlItem, idx, qty: integer;
  kodeInput: string[10];
  lanjut, member: char;
  kotor, diskon, akhir, bayar, kembali: longint;
begin
  if total = 0 then
  begin
    clrscr;
    writeln('Katalog kosong. Tambahkan produk di Menu 3 terlebih dahulu.');
    exit;
  end;
  jmlItem := 0;
  kotor := 0;
  lanjut := 'Y';
  while (UpCase(lanjut) = 'Y') and (jmlItem < 30) do
  begin
    clrscr;
    TampilkanKatalog(daftar, total);
    write('Masukkan Kode Barang (0 untuk bayar) : ');
    readln(kodeInput);
    if kodeInput = '0' then
      break;
    kodeInput := KapitalkanString(kodeInput);
    idx := CariIndeksBarang(daftar, total, kodeInput);
    if idx = -1 then
      writeln('Kode barang tidak ditemukan.')
    else
    begin
      write('Jumlah beli ', daftar[idx].Nama, ' : ');
      readln(qty);
      if (qty > 0) and (qty <= daftar[idx].Stok) then
      begin
        jmlItem := jmlItem + 1;
        Keranjang[jmlItem].Nama := daftar[idx].Nama;
        Keranjang[jmlItem].HargaSatuan := daftar[idx].Harga;
        Keranjang[jmlItem].JumlahBeli := qty;
        Keranjang[jmlItem].Subtotal := qty * daftar[idx].Harga;
        daftar[idx].Stok := daftar[idx].Stok - qty;
        kotor := kotor + Keranjang[jmlItem].Subtotal;
      end
      else
        writeln('Stok tidak mencukupi atau jumlah tidak valid.');
    end;
    write('Tambah barang lagi? (Y/T) : ');
    readln(lanjut);
  end;
  if jmlItem > 0 then
  begin
    write('Apakah pelanggan member? (Y/T) : ');
    readln(member);
    diskon := HitungDiskon(kotor, member);
    akhir := kotor - diskon;
    writeln('Total Bayar : Rp ', akhir);
    repeat
      write('Uang Tunai  : Rp ');
      readln(bayar);
      if bayar < akhir then
        writeln('Uang kurang Rp ', akhir - bayar);
    until bayar >= akhir;
    kembali := bayar - akhir;
    omzet := omzet + akhir;
    CetakStruk(Keranjang, jmlItem, kotor, diskon, akhir, bayar, kembali);
  end;
end;

begin
  jumlahProduk := 0;
  totalOmzet := 0;
  InputProduk(Katalog, jumlahProduk, 'INPUT DATA PRODUK AWAL U-CASHIER');
  repeat
    clrscr;
    writeln('SISTEM KASIR UMKM U-CASHIER');
    writeln('Total Omzet Sesi Ini : Rp ', totalOmzet);
    writeln('1. Lihat Katalog dan Stok');
    writeln('2. Transaksi Kasir Baru');
    writeln('3. Tambah Produk Baru');
    writeln('4. Keluar Program');
    write('Pilih menu (1-4) : ');
    readln(pilihanMenu);
    case pilihanMenu of
      1: begin 
            clrscr;
               TampilkanKatalog(Katalog, jumlahProduk);
         end;
      2: ProsesTransaksi(Katalog, jumlahProduk, totalOmzet);
      3: InputProduk(Katalog, jumlahProduk, 'TAMBAH PRODUK BARU');
      4: writeln('Program selesai.');
    else
      writeln('Pilihan tidak valid.');
    end;
    if pilihanMenu <> 4 then
    begin
      writeln;
      write('Tekan Enter untuk kembali...');
      readln;
    end;
  until pilihanMenu = 4;
end.