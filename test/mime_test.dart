library mime_parse;

import 'package:unittest/unittest.dart';

part '../lib/src/mime_parse.dart';

var mime1 = "blah/wibble";
var mime2 = "a/a";
var mime3 = "abc/def;xyz=efg";
var mime4 = 'abc/def;x=";";y=1';
var mime41 = r'abc/def;x=";\"";y=1';
var mime42 = 'abc/def;x=",";y=1';
var mime43 = 'a/b;x=",",c/d';
var mime44 = 'a/b;x=",",c/d;x=y';
var mime5 = "abc/def ; xyz=0.2";
var mime6 = "abc/def ; a=1 ; b=2";
var mime7 = "abc/def;a=1;b=2";
var mime8 = "a/b,c/d , e/f, g/h";
var mime9 = "*";
var mime10 = "a/b;q=0.5";
var mime11 = "a/b;q=0";
var mime12 = "a/b;q=1";
var mime13 = "a/b;q=-1";
var mime14 = "a/b;q=2";
var mime15 = "a/b;q=z";
var mime16 = 'a/b;q="x=y"';

//TODO should send 406 Not Acceptable if, er, not acceptable

// q=0.000 .. 0.999 .. 1.000


main() {
  group("parse", () {
    test("really simple", () {
      var mimes = parse(mime1);
      expect(mimes, isList);
      expect(mimes, hasLength(1));
      expect(mimes[0].type, equals("blah"));
      expect(mimes[0].subtype, equals("wibble"));
    });
    
    test("another simple one", () {
      var mimes = parse(mime2);
      expect(mimes, isList);
      expect(mimes, hasLength(1));
      expect(mimes[0].type, equals("a"));
      expect(mimes[0].subtype, equals("a"));
    });
    
    test("params", () {
      var mimes = parse(mime3);
      expect(mimes, isList);
      expect(mimes, hasLength(1));
      expect(mimes[0].type, equals("abc"));
      expect(mimes[0].subtype, equals("def"));
      expect(mimes[0].params, hasLength(1));
      expect(mimes[0].params["xyz"], equals("efg"));
    });
    
    test("quotes", () {
      var mimes = parse(mime4);
      expect(mimes, isList);
      expect(mimes, hasLength(1));
      expect(mimes[0].type, equals("abc"));
      expect(mimes[0].subtype, equals("def"));
      expect(mimes[0].params, hasLength(2));
      expect(mimes[0].params["x"], equals('";"'));
      expect(mimes[0].params["y"], equals("1"));
    });

    test("params and spaces", () {
      var mimes = parse(mime5);
      expect(mimes, isList);
      expect(mimes, hasLength(1));
      expect(mimes[0].type, equals("abc"));
      expect(mimes[0].subtype, equals("def"));
      expect(mimes[0].params, hasLength(1));
      expect(mimes[0].params["xyz"], equals("0.2"));
    });

    test("two params and spaces", () {
      var mimes = parse(mime6);
      expect(mimes, isList);
      expect(mimes, hasLength(1));
      expect(mimes[0].type, equals("abc"));
      expect(mimes[0].subtype, equals("def"));
      expect(mimes[0].params, hasLength(2));
      expect(mimes[0].params["a"], equals("1"));
      expect(mimes[0].params["b"], equals("2"));
    });

    test("two params", () {
      var mimes = parse(mime7);
      expect(mimes, isList);
      expect(mimes, hasLength(1));
      expect(mimes[0].type, equals("abc"));
      expect(mimes[0].subtype, equals("def"));
      expect(mimes[0].params, hasLength(2));
      expect(mimes[0].params["a"], equals("1"));
      expect(mimes[0].params["b"], equals("2"));
    });

    test("multi", () {
      var mimes = parse(mime8);
      expect(mimes, isList);
      expect(mimes, hasLength(4));
      expect(mimes[0].type, equals("a"));
      expect(mimes[0].subtype, equals("b"));
      expect(mimes[1].type, equals("c"));
      expect(mimes[1].subtype, equals("d"));
      expect(mimes[2].type, equals("e"));
      expect(mimes[2].subtype, equals("f"));
      expect(mimes[3].type, equals("g"));
      expect(mimes[3].subtype, equals("h"));
    });

    test("malformed", () {
      var mimes = parse(mime9);
      expect(mimes, isList);
      expect(mimes, hasLength(1));
      expect(mimes[0].type, equals("*"));
      expect(mimes[0].subtype, equals("*"));
    });

    test("malformed", () {
      var mimes = parse(mime16);
      expect(mimes, isList);
      expect(mimes, hasLength(1));
      expect(mimes[0].type, equals("a"));
      expect(mimes[0].subtype, equals("b"));
      expect(mimes[0].params["q"], equals('"x=y"'));
    });
  });
  
  group("q value is", () {
    test("0.5", () {
      var mimes = parse(mime10);
      updateQValues(mimes);
      expect(mimes, isList);
      expect(mimes, hasLength(1));
      expect(mimes[0].type, equals("a"));
      expect(mimes[0].subtype, equals("b"));
      expect(mimes[0].params, hasLength(1));
      expect(mimes[0].params["q"], equals(0.5));
    });

    test("zero", () {
      var mimes = parse(mime11);
      updateQValues(mimes);
      expect(mimes, isList);
      expect(mimes, hasLength(1));
      expect(mimes[0].type, equals("a"));
      expect(mimes[0].subtype, equals("b"));
      expect(mimes[0].params, hasLength(1));
      expect(mimes[0].params["q"], equals(0.0));
    });

    test("one", () {
      var mimes = parse(mime12);
      updateQValues(mimes);
      expect(mimes, isList);
      expect(mimes, hasLength(1));
      expect(mimes[0].type, equals("a"));
      expect(mimes[0].subtype, equals("b"));
      expect(mimes[0].params, hasLength(1));
      expect(mimes[0].params["q"], equals(1.0));
    });

    test("too big", () {
      var mimes = parse(mime13);
      updateQValues(mimes);
      expect(mimes, isList);
      expect(mimes, hasLength(1));
      expect(mimes[0].type, equals("a"));
      expect(mimes[0].subtype, equals("b"));
      expect(mimes[0].params, hasLength(1));
      expect(mimes[0].params["q"], equals(1.0));
    });

    test("too low", () {
      var mimes = parse(mime14);
      updateQValues(mimes);
      expect(mimes, isList);
      expect(mimes, hasLength(1));
      expect(mimes[0].type, equals("a"));
      expect(mimes[0].subtype, equals("b"));
      expect(mimes[0].params, hasLength(1));
      expect(mimes[0].params["q"], equals(1.0));
    });

    test("invalid", () {
      var mimes = parse(mime15);
      updateQValues(mimes);
      expect(mimes, isList);
      expect(mimes, hasLength(1));
      expect(mimes[0].type, equals("a"));
      expect(mimes[0].subtype, equals("b"));
      expect(mimes[0].params, hasLength(1));
      expect(mimes[0].params["q"], equals(1.0));
    });
  });
  
  group("find positions of", () {
    test("semicolons", () {
      var positions = _findPositions(mime4);
      expect(positions.semicolons, equals([[7, 13]]));
    });
    
    test("commas and semicolons", () {
      var positions = _findPositions(mime42);
      expect(positions.commas, equals([]));
    });
    
    test("commas and semicolons", () {
      var positions = _findPositions(mime43);
      expect(positions.commas, equals([9]));
    });
    
    test("commas and semicolons", () {
      var positions = _findPositions(mime44);
      expect(positions.commas, equals([9]));
      expect(positions.semicolons, equals([[3], [3]]));
    });

    test("commas and semicolons", () {
      var positions = _findPositions(mime41);
      expect(positions.commas, equals([]));
      expect(positions.semicolons, equals([[7, 15]]));
    });
  });
}

