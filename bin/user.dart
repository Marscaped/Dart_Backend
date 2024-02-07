class User {
  int id;
  String email;
  String password;

  User(this.id, this.email, this.password);

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'pw': password,
      };

  bool authorizeUser() {
    return true;
  }
}
