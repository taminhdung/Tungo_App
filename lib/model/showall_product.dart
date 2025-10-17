class Vouchershow {
  String anh;
  String ten;
  String mota;
  String dieukien;
  String hieuluc;
  String soluong;

  Vouchershow({
    required this.anh,
    required this.ten,
    required this.mota,
    required this.dieukien,
    required this.hieuluc,
    required this.soluong,
  });
  // Chuyển từ Map JSON -> Object
  Vouchershow.fromJson(Map<String, dynamic> json)
    : anh = json['anh'] ?? '',
      ten = json['ten'] ?? '',
      mota = json['mota'] ?? '',
      dieukien = json['dieukien'] ?? '',
      hieuluc = json['hieuluc'] ?? '',
      soluong = json['soluong'] ?? '';

  // Chuyển từ Object -> Map JSON
  Map<String, dynamic> toJson() => {
    'anh': anh,
    'ten': ten,
    'mota': mota,
    'dieukien': dieukien,
    'hieuluc': hieuluc,
    'soluong': soluong,
  };

  @override
  String toString() {
    return 'Vouchershow(anh: $anh, ten: $ten mota: $mota, dieukien: $dieukien, hieuluc: $hieuluc, soluong: $soluong)';
  }
}
