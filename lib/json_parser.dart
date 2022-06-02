import 'dart:convert';

class JsonParser {
  JsonParser(this.jsonString, this.nameOfObject, this.makeRequired);
  String jsonString;
  String nameOfObject;
  bool makeRequired;

  List<String> objects = [];
  String convertToDartObject() {
    Map? jsonFormat;
    String? hashedLinkType;
    String userObject = '';
    String constructor = '';
    try {
      jsonFormat = jsonDecode(jsonString);
      hashedLinkType = jsonFormat.runtimeType.toString();
    } on FormatException {
      userObject = "invalid json format";
    }
    if (jsonFormat != null) {
      jsonFormat.forEach((key, value) {
        if (value.runtimeType == List) {
          List list = value as List;
          if (list.isNotEmpty) {
            final type = list[0].runtimeType;
            var secondType;
            for (final element in list) {
              if (element.runtimeType.toString() == hashedLinkType) {
                String internalObjName =
                    "${key[0].toString().toUpperCase()}${key.toString().substring(1)}";
                final JsonParser internalObj = JsonParser(
                    jsonEncode(element), internalObjName, makeRequired);
                secondType = internalObjName;
                var newType = internalObj.convertToDartObject();
                objects.add(newType);
                break;
              } else if (element.runtimeType != type) {
                secondType = "dynamic";
                break;
              } else {
                secondType = type;
              }
            }
            userObject += "List<$secondType>? $key; \n";
            constructor += "${makeRequired ? "required" : ""} this.$key, ";
          } else {
            userObject += "${value.runtimeType} $key; ";
            constructor += "${makeRequired ? "required" : ""} this.$key, ";
          }
        } else if (value.runtimeType.toString() == hashedLinkType) {
          String internalObjName =
              "${key[0].toString().toUpperCase()}${key.toString().substring(1)}";
          final JsonParser internalObj =
              JsonParser(jsonEncode(value), internalObjName, makeRequired);
          userObject += "$internalObjName? $key; \n";
          constructor += "${makeRequired ? "required" : ""} this.$key, ";
          var newType = internalObj.convertToDartObject();
          objects.add(newType);
        } else {
          userObject += "${value.runtimeType}? ${key.toString()}; \n";
          constructor += "${makeRequired ? "required" : ""} this.$key, ";
        }
      });
    } else {
      userObject = "invalid json format";
    }
    if (userObject == "invalid json format") {
      return "invalid json format";
    }
    return createFromJson(
        "class $nameOfObject{\n$userObject\n$nameOfObject(${makeRequired ? "{" : ''}${constructor.substring(0, constructor.length - 2)}${makeRequired ? "}" : ''});\n");
  }

  createFromJson(String obj) {
    Map? jsonFormat;
    String? hashedLinkType;
    String fromJson = "";
    try {
      jsonFormat = jsonDecode(jsonString);
      hashedLinkType = jsonFormat.runtimeType.toString();
    } on FormatException catch (e) {
      fromJson = "";
    }
    if (jsonFormat != null) {
      jsonFormat.forEach((key, value) {
        if (value.runtimeType == List) {
          List list = value as List;
          if (list.isNotEmpty) {
            final type = list[0].runtimeType;
            var secondType;
            for (final element in list) {
              if (element.runtimeType.toString() == hashedLinkType) {
                String internalObjName =
                    "${key[0].toString().toUpperCase()}${key.toString().substring(1)}";
                secondType = internalObjName;
                break;
              } else if (element.runtimeType != type) {
                secondType = "dynamic";
                break;
              } else {
                secondType = type;
              }
            }
            fromJson +=
                "if(json['$key'] != null){\n$key =<$secondType>[];\n json['$key'].forEach((v){\n$key!.add(${secondType == type ? "" : "$secondType.fromJson"}(v));\n  });\n}\n";
          } else {
            fromJson +=
                "if(json['$key'] != null){\n$key =<dynamic>[];\n json['$key'].forEach((v){\n$key!.add(v);\n  });\n}\n";
          }
        } else if (value.runtimeType.toString() == hashedLinkType) {
          String internalObjName =
              "${key[0].toString().toUpperCase()}${key.toString().substring(1)}";
          fromJson +=
              "$key = json['$key']!= null?\n$internalObjName.fromJson(json['$key'])\n:null;\n";
        } else {
          fromJson += "$key = json['$key'];\n";
        }
      });
    } else {
      fromJson = "";
    }
    return createToJson(
        "$obj\n$nameOfObject.fromJson(Map<String, dynamic> json){\n$fromJson}\n\n");
  }

  createToJson(String obj) {
    String toJsonTemplate =
        "Map<String, dynamic> toJson() {\nfinal Map<String, dynamic> data = <String, dynamic>{};\n";
    String toJson = "";
    Map? jsonFormat;
    String? hashedLinkType;
    try {
      jsonFormat = jsonDecode(jsonString);
      hashedLinkType = jsonFormat.runtimeType.toString();
    } on FormatException catch (e) {
      toJson = "";
    }

    if (jsonFormat != null) {
      jsonFormat.forEach((key, value) {
        if (value.runtimeType == List) {
          List list = value as List;
          if (list.isNotEmpty) {
            final type = list[0].runtimeType;
            var secondType;
            for (final element in list) {
              if (element.runtimeType.toString() == hashedLinkType) {
                String internalObjName =
                    "${key[0].toString().toUpperCase()}${key.toString().substring(1)}";
                secondType = internalObjName;
                break;
              } else if (element.runtimeType != type) {
                secondType = "dynamic";
                break;
              } else {
                secondType = type;
              }
            }
            if (secondType == type) {
              toJson += "data['$key'] = $key;\n";
            } else {
              toJson +=
                  "if($key != null){\ndata['$key'] = $key!.map((v) => v.toJson()).toList();\n}\n";
            }
          } else {
            toJson += "if($key != null){\ndata['$key'] = $key.toList();\n}";
          }
        } else if (value.runtimeType.toString() == hashedLinkType) {
          toJson += "if($key != null){\ndata['$key'] = $key!.toJson();\n}\n";
        } else {
          toJson += "data['$key']= $key;\n";
        }
      });
    } else {
      toJson = "";
    }
    return "$obj$toJsonTemplate$toJson return data;\n}\n}\n\n${objects.join("\n")}";
  }
}
