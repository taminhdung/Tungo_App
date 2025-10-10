class ProductShow {
  String anh;
  String ten;
  String tensukien;
  String giamgia;
  String giagiam;
  String sao;
  String sohangdaban;
  String diachi;

  ProductShow({
    required this.anh,
    required this.ten,
    required this.tensukien,
    required this.giamgia,
    required this.giagiam,
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
      giamgia: json['giamgia'],
      giagiam: json['giagiam'],
      sao: json['sao'],
      sohangdaban: json['sohangdaban'],
      diachi: json['diachi']
    );
  }
}
