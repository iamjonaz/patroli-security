// =============================================
// Patroli Security
// Nama : Arjuna Meiureksa
// NIM  : 1124160226
// =============================================

//BAGIAN B 

//----------ABSTRACTION----------
enum StatusScan { sukses, terlambat, salahUrutan, tidakDitemukan }

class Checkpoint {
  final String nama; 
  final int urutan; 
  final int jamJadwal; 
  final int menitJadwal; 
  
  Checkpoint(this.nama, this.urutan, this.jamJadwal, this.menitJadwal);
}

//----------DATA----------
final List<Checkpoint> rutePatroli = [
  Checkpoint("Pos Depan", 1, 22, 0),    //jadwal 22:00
  Checkpoint("Area Parkir", 2, 22, 30), //jadwal 22:30
  Checkpoint("Gudang", 3, 23, 0),       //jadwal 23:00
];

//variable global untuk menyimpan urutan checkpoint yang seharusnya di scan saat ini
int urutanSelanjutnya = 1;

//----------DECOMPOSITION----------

//Function 1: cari pos (BR-01)
Checkpoint? findCheckpoint(String namaPos) {
  for (final pos in rutePatroli) {
    if (pos.nama == namaPos) {
      return pos;
    }
  }
  return null;
}

//Function 2: cek urutan (BR-02)
bool isCorrectOrder(int urutanPos) {
  return urutanPos == urutanSelanjutnya;
}

//Function 3: hitung Keterlambatan (BR-03)
bool isLate(int jamJadwal, int menitJadwal, int jamScan, int menitScan) {
  int totalMenitJadwal = (jamJadwal * 60) + menitJadwal;
  int totalMenitScan = (jamScan * 60) + menitScan;
  
  int selisihMenit = totalMenitScan - totalMenitJadwal;
  
  //return true jika telat lebih dari 15 menit
  return selisihMenit > 15;
}

// Function 4: ubah status menjadi pesan string
String toMessage(StatusScan status) {
  switch (status) {
    case StatusScan.sukses: 
      return "Berhasil: Scan tepat waktu.";
    case StatusScan.terlambat: 
      return "Berhasil: Scan tercatat, tapi terlambat lebih dari 15 menit.";
    case StatusScan.salahUrutan: 
      return "Gagal: Checkpoint tidak sesuai urutan (Lompat pos).";
    case StatusScan.tidakDitemukan: 
      return "Gagal: Checkpoint tidak terdaftar di sistem.";
  }
}

// ----------ALGORITHM----------
StatusScan scanCheckpoint(String namaPos, int jamScan, int menitScan) {
  // 1. cari data checkpoint (BR-01)
  Checkpoint? pos = findCheckpoint(namaPos);
  
  if (pos == null) {
    return StatusScan.tidakDitemukan;
  }
  
  // 2. validasi urutan (BR-02)
  if (!isCorrectOrder(pos.urutan)) {
    return StatusScan.salahUrutan;
  }
  
  // jika validasi lolos, catat bahwa pos ini sudah diselesaikan
  // dan siapkan urutan untuk pos berikutnya
  urutanSelanjutnya++; 
  
  // 3. validasi keterlambatan (BR-03)
  if (isLate(pos.jamJadwal, pos.menitJadwal, jamScan, menitScan)) {
    return StatusScan.terlambat;
  } else {
    return StatusScan.sukses;
  }
}

// ----------TEST SCENARIO----------
void main() {
  print("MULAI PATROLI");
  
  // skenario 1 (Sukses BR-01): pos depan di scan tepat waktu jam 22:05 (jadwal 22:00)
  // expected: berhasil: scan tepat waktu.
  print("Skenario 1: " + toMessage(scanCheckpoint("Pos Depan", 22, 5)));
  
  // skenario 2 (Gagal BR-02): satpam langsung loncat ke Gudang (padahal harusnya area parkir)
  // expected: gagal: checkpoint tidak sesuai urutan.
  print("Skenario 2: " + toMessage(scanCheckpoint("Gudang", 22, 10)));
  
  // skenario 3 (Gagal BR-01): satpam asal masukin nama pos
  // expected: gagal: checkpoint tidak terdaftar.
  print("Skenario 3: " + toMessage(scanCheckpoint("Kantin", 22, 15)));
  
  // skenario 4 (Telat BR-03): area parkir baru di scan jam 22:50 (jadwal 22:30, telat 20 menit)
  // expected: berhasil: scan tercatat, tapi terlambat.
  print("Skenario 4: " + toMessage(scanCheckpoint("Area Parkir", 22, 50)));
  
  // skenario 5 (Sukses BR-01): Gudang di-scan jam 23:10 (jadwal 23:00, telat 10 menit dihitung masih wajar)
  // expected: berhasil: scan tepat waktu.
  print("Skenario 5: " + toMessage(scanCheckpoint("Gudang", 23, 10)));
}
