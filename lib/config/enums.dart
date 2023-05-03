part of config;

enum ListMode { normal, check, edit, search }

enum TogglePage { login, signup }

enum Members {
  memberFree(0, 'Free', 240, 'Rp0,-'),
  memberPro(1, 'Starter', 600, 'Rp50.000,-'),
  memberPremium(2, 'Pro', 1320, 'Rp99.000,-');

  final int id;
  final String member;
  final int quota;
  final String price;

  const Members(this.id, this.member, this.quota, this.price);
}
