// =============================================
// HW 2 - Patroli Security
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

//variable global untuk menyimpan urutan checkpoint yang seharusnya di-scan saat ini
int urutanSelanjutnya = 1;

//----------DECOMPOSITION----------

//Function 1: Cari Pos (BR-01)
Checkpoint? findCheckpoint(String namaPos) {
  for (final pos in rutePatroli) {
    if (pos.nama == namaPos) {
      return pos;
    }
  }
  return null;
}

//Function 2: Cek Urutan (BR-02)
bool isCorrectOrder(int urutanPos) {
  return urutanPos == urutanSelanjutnya;
}

//Function 3: Hitung Keterlambatan (BR-03)
bool isLate(int jamJadwal, int menitJadwal, int jamScan, int menitScan) {
  int totalMenitJadwal = (jamJadwal * 60) + menitJadwal;
  int totalMenitScan = (jamScan * 60) + menitScan;
  
  int selisihMenit = totalMenitScan - totalMenitJadwal;
  
  //return true jika telat lebih dari 15 menit
  return selisihMenit > 15;
}

// Function 4: Ubah status menjadi pesan string
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
  // 1. Cari data checkpoint (BR-01)
  Checkpoint? pos = findCheckpoint(namaPos);
  
  if (pos == null) {
    return StatusScan.tidakDitemukan;
  }
  
  // 2. Validasi urutan (BR-02)
  if (!isCorrectOrder(pos.urutan)) {
    return StatusScan.salahUrutan;
  }
  
  // jika validasi lolos, catat bahwa pos ini sudah diselesaikan
  // dan siapkan urutan untuk pos berikutnya
  urutanSelanjutnya++; 
  
  // 3. Validasi keterlambatan (BR-03)
  if (isLate(pos.jamJadwal, pos.menitJadwal, jamScan, menitScan)) {
    return StatusScan.terlambat;
  } else {
    return StatusScan.sukses;
  }
}

// ----------TEST SCENARIO----------
void main() {
  print("MULAI PATROLI");
  
  // Skenario 1 (Sukses BR-01): Pos Depan di-scan tepat waktu jam 22:05 (Jadwal 22:00)
  // Expected: Berhasil: Scan tepat waktu.
  print("Skenario 1: " + toMessage(scanCheckpoint("Pos Depan", 22, 5)));
  
  // Skenario 2 (Gagal BR-02): Satpam langsung loncat ke Gudang (Padahal harusnya Area Parkir)
  // Expected: Gagal: Checkpoint tidak sesuai urutan.
  print("Skenario 2: " + toMessage(scanCheckpoint("Gudang", 22, 10)));
  
  // Skenario 3 (Gagal BR-01): Satpam asal masukin nama pos
  // Expected: Gagal: Checkpoint tidak terdaftar.
  print("Skenario 3: " + toMessage(scanCheckpoint("Kantin", 22, 15)));
  
  // Skenario 4 (Telat BR-03): Area Parkir baru di-scan jam 22:50 (Jadwal 22:30, telat 20 menit)
  // Expected: Berhasil: Scan tercatat, tapi terlambat.
  print("Skenario 4: " + toMessage(scanCheckpoint("Area Parkir", 22, 50)));
  
  // Skenario 5 (Sukses BR-01): Gudang di-scan jam 23:10 (Jadwal 23:00, telat 10 menit -> masih wajar)
  // Expected: Berhasil: Scan tepat waktu.
  print("Skenario 5: " + toMessage(scanCheckpoint("Gudang", 23, 10)));
}
