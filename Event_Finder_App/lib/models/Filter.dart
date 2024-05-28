
//Filter data type used for local storage
class Filter {
  String filterType;
  String value;

  Filter({this.filterType, this.value});

  String toString() {
    return 'OBJ: ${this.filterType} ${this.value}';
  }

  Filter.fromMap(Map<String, dynamic> map) {
    this.filterType = map['filterType'];
    this.value = map['value'];
  }

  Map<String, dynamic> toMap() {
    return {'filterType': this.filterType, 'value': this.value};
  }
}
