class ProductShow {
  String anh;
  String ten;
  String tensukien;
  String gia;
  String giamgia;
  String sao;
  String sohangdaban;
  String type;
  String diachi;

  ProductShow({
    required this.anh,
    required this.ten,
    required this.tensukien,
    required this.gia,
    required this.giamgia,
    required this.sao,
    required this.sohangdaban,
    required this.type,
    required this.diachi,
  });
  // Chuyển từ Map JSON -> Object
  ProductShow.fromJson(Map<String, dynamic> json)
    : anh = json['anh'] ?? '',
      ten = json['ten'] ?? '',
      tensukien = json['tensukien'] ?? '',
      gia = json['gia'] ?? '0',
      giamgia = json['giamgia'] ?? '0',
      sao = json['sao'] ?? '0',
      sohangdaban = json['sohangdaban'] ?? '0',
      type = json['type'] ?? '',
      diachi = json['diachi'] ?? '';

  // Chuyển từ Object -> Map JSON
  Map<String, dynamic> toJson() => {
    'anh': anh,
    'ten': ten,
    'tensukien': tensukien,
    'gia': gia,
    'giamgia': giamgia,
    'sao': sao,
    'sohangdaban': sohangdaban,
    'type': type,
    'diachi': diachi,
  };

  @override
  String toString() {
    return 'ProductShow(ten: $ten, gia: $gia, sao: $sao, diachi: $diachi, tensukien: $tensukien, sohangdaban: $sohangdaban, type: $type, giamgia: $giamgia, anh: $anh)';
  }
}
