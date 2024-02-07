class Dataset {
  int id;
  DateTime time;
  double? temp;
  double? humid;
  double? moist;

  Dataset(this.id, this.time, [this.temp, this.humid, this.moist]);

  Map<String, dynamic> toJson() => {
        'id': id,
        'time': time,
        'temp': temp,
        'humid': humid,
        'moist': moist,
      };

  static List<Dataset> getDatasetFromDatabaseByDate(
      DateTime startDate, DateTime endDate) {
    List<Dataset> data = [
      Dataset(1, DateTime.now(), 20, 20, 20),
      Dataset(2, DateTime.now(), 20, 20, 20),
      Dataset(3, DateTime.now(), 20, 20, 20),
    ];

    return data;
  }
}
