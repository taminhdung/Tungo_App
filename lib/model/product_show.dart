class ProductShow {
  String anh;
  String ten;
  String tensukien;
  String gia;
  String giamgia;
  String sao;
  String sohangdaban;
  String diachi;

  ProductShow({
    required this.anh,
    required this.ten,
    required this.tensukien,
    required this.gia,
    required this.giamgia,
    required this.sao,
    required this.sohangdaban,
    required this.diachi,
  });

  // Chuyển từ JSON thành object
  factory ProductShow.fromJson(Map<String, dynamic> json) {
    return ProductShow(
      ten: json['ten'],
      anh: json['anh'],
      tensukien: json['tensukien'],
      gia: json['gia'],
      giamgia: json['giamgia'],
      sao: json['sao'],
      sohangdaban: json['sohangdaban'],
      diachi: json['diachi'],
    );
  }
  @override
  String toString() {
    return 'ProductShow(ten: $ten, gia: $gia, sao: $sao, diachi: $diachi, tensukien: $tensukien, sohangdaban: $sohangdaban, giamgia: $giamgia, anh: $anh)';
  }
}
