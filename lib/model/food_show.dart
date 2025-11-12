class foodShow {
  String id;
  String anh;
  String ten;
  String tensukien;
  String gia;
  String giamgia;
  String sao;
  String sohangdaban;
  String type;
  String diachi;
  String mota;
  String useruid;

  foodShow({
    required this.id,
    required this.anh,
    required this.ten,
    required this.tensukien,
    required this.gia,
    required this.giamgia,
    required this.sao,
    required this.sohangdaban,
    required this.type,
    required this.diachi,
    required this.mota,
    required this.useruid,
  });
  // Chuyển từ Map JSON -> Object
  foodShow.fromJson(Map<String, dynamic> json):
      id= json['id'] ?? '',
      anh = json['anh'] ?? '',
      ten = json['ten'] ?? '',
      tensukien = json['tensukien'] ?? '',
      gia = json['gia'] ?? '0',
      giamgia = json['giamgia'] ?? '0',
      sao = json['sao'] ?? '0',
      sohangdaban = json['sohangdaban'] ?? '0',
      type = json['type'] ?? '',
      diachi = json['diachi'] ?? '',
      mota=json['mota']??'',
      useruid=json['useruid'] ?? '';

  // Chuyển từ Object -> Map JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'anh': anh,
    'ten': ten,
    'tensukien': tensukien,
    'gia': gia,
    'giamgia': giamgia,
    'sao': sao,
    'sohangdaban': sohangdaban,
    'type': type,
    'diachi': diachi,
    'mota':mota,
    'useruid': useruid
  };

  @override
  String toString() {
    return 'foodShow(id: $id, ten: $ten, gia: $gia, sao: $sao, diachi: $diachi, tensukien: $tensukien, sohangdaban: $sohangdaban, type: $type, giamgia: $giamgia, anh: $anh, mota: $mota, useruid: $useruid)';
  }
}
