class User {
  int id;
  String email;
  String password;
  String permissions;

  User(this.id, this.email, this.password, this.permissions);

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'pw': password,
      };

  bool authorizeUser() {
    return true;
  }

  String changeUserPermission(bool read, bool write, bool admin) {
    String newPermissions = "";

    if (read) {
      newPermissions += "r";
    }

    if (write) {
      newPermissions += "w";
    }

    if (admin) {
      newPermissions += "a";
    }

    // TODO: UPDATE USER IN DATABASE

    return "Updated Users Permission to: $newPermissions";
  }
}
