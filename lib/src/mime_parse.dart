part of mime_parse;

class AcceptRange {
  AcceptRange(this.type, this.subtype);
  String type;
  String subtype;
  Map<String, dynamic> params = new Map<String, dynamic>();
}

List<AcceptRange> parse(String accept) {
  var ranges = new List<AcceptRange>();
  
  var positions = _findPositions(accept);
  positions.commas.add(accept.length);
  positions.semicolons.add(new List<int>());
  
  var lastComma = 0;
  for (var i = 0; i < positions.commas.length; i++) {
    var commaPos = positions.commas[i];
    var split = accept.substring(lastComma, commaPos);
    lastComma = commaPos + 1;

    positions.semicolons[i].add(split.length);
    var lastSemicolon = positions.semicolons[i][0];
    var type = split.substring(0, lastSemicolon);
    if (type == "*") {
      type = "*/*";
    };
    var parts = type.split("/");
    var range = new AcceptRange(parts[0].trim(), parts[1].trim());
    ranges.add(range);

    lastSemicolon++;
    for (var ii = 1; ii < positions.semicolons[i].length; ii++) {
      var semicolonPos = positions.semicolons[i][ii];
      var param = split.substring(lastSemicolon, semicolonPos);
      lastSemicolon = semicolonPos + 1;
      var equalsPos = param.indexOf("=");
      var paramName = param.substring(0, equalsPos).trim();
      var paramValue = param.substring(equalsPos + 1).trim();
      range.params[paramName] = paramValue;
    };
  };
  return ranges;
}

updateQValues(List<AcceptRange> ranges) {
  ranges.forEach((range) {
    if (range.params.containsKey("q")) {
      var q = range.params["q"];
      q = double.parse(q, (error) => 1.0);
      if (q < 0 || q > 1) {
        q = 1.0;
      }
      range.params["q"] = q;
    } else {
      range.params["q"] = 1.0;      
    }
  });
}

_Positions _findPositions(String mime) {
  var positions = new _Positions();
  bool inQuotes = false;
  String lastChar;
  int lastComma = 0;
  for (var i = 0; i < mime.length; i++) {
    var c = mime[i];
    if (inQuotes) {
      if (lastChar != r'\') {
        if (c == '"') {
          inQuotes = false;
        }
      }
      lastChar = c;
    } else {
      if (c == '"') {
        inQuotes = true;
      } else if (c == ';') {
        positions.addSemicolon(i - lastComma);
      } else if (c == ',') {
        positions.addComma(i);
        lastComma = i + 1;
      }
    }
  };
  return positions;
}

class _Positions {
  List<int> commas = new List<int>();
  List<List<int>> semicolons = new List<List<int>>();
  
  _Positions() {
    semicolons.add(new List<int>());
  }
  
  void addComma(int commaPos) {
    commas.add(commaPos);
    var semicolonList = new List<int>();
    semicolons.add(semicolonList);
  }
  
  void addSemicolon(int semicolonPos) {
    semicolons[semicolons.length - 1].add(semicolonPos);
  }
}
