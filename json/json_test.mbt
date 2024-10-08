// Copyright 2024 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

test "get as null" {
  inspect!(Null |> @json.as_null, content="Some(())")
  inspect!(True |> @json.as_null, content="None")
  inspect!(False |> @json.as_null, content="None")
  inspect!(Number(1.0) |> @json.as_null, content="None")
  inspect!(String("Hello World") |> @json.as_null, content="None")
  inspect!(Array([String("Hello World")]) |> @json.as_null, content="None")
  inspect!(
    Object({ "key": String("key"), "value": Number(100.0) }) |> @json.as_null,
    content="None",
  )
}

test "get as bool" {
  inspect!(Json::Null |> @json.as_bool, content="None")
  inspect!(Json::True |> @json.as_bool, content="Some(true)")
  inspect!(Json::False |> @json.as_bool, content="Some(false)")
  inspect!(Json::Number(1.0) |> @json.as_bool, content="None")
  inspect!(Json::String("Hello World") |> @json.as_bool, content="None")
  inspect!(
    Json::Array([Json::String("Hello World")]) |> @json.as_bool,
    content="None",
  )
  inspect!({ "key": "key", "value": 100.0 } |> @json.as_bool, content="None")
}

test "get as number" {
  inspect!(Json::Null |> @json.as_number, content="None")
  inspect!(Json::False |> @json.as_number, content="None")
  inspect!(Json::True |> @json.as_number, content="None")
  inspect!(Json::Number(1.0) |> @json.as_number, content="Some(1.0)")
  inspect!(Json::String("Hello World") |> @json.as_number, content="None")
  inspect!(
    Json::Array([Json::String("Hello World")]) |> @json.as_number,
    content="None",
  )
  inspect!(
    Json::Object(
      Map::of([("key", Json::String("key")), ("value", Json::Number(100.0))]),
    )
    |> @json.as_number,
    content="None",
  )
}

test "get as string" {
  inspect!(Json::Null |> @json.as_string, content="None")
  inspect!(Json::True |> @json.as_string, content="None")
  inspect!(Json::False |> @json.as_string, content="None")
  inspect!(Json::Number(1.0) |> @json.as_string, content="None")
  inspect!(
    Json::String("Hello World") |> @json.as_string,
    content=
      #|Some("Hello World")
    ,
  )
  inspect!(
    Json::Array([Json::String("Hello World")]) |> @json.as_string,
    content="None",
  )
  inspect!(
    Json::Object(
      Map::of([("key", Json::String("key")), ("value", Json::Number(100.0))]),
    )
    |> @json.as_string,
    content="None",
  )
}

test "get as array" {
  inspect!(Json::Null |> @json.as_array, content="None")
  inspect!(Json::True |> @json.as_array, content="None")
  inspect!(Json::False |> @json.as_array, content="None")
  inspect!(Json::Number(1.0) |> @json.as_array, content="None")
  inspect!(Json::String("Hello World") |> @json.as_array, content="None")
  inspect!(
    Json::Array([Json::String("Hello World")]) |> @json.as_array,
    content=
      #|Some([String("Hello World")])
    ,
  )
  inspect!(
    Json::Array([Json::String("Hello World")]).item(0).bind(@json.as_string),
    content=
      #|Some("Hello World")
    ,
  )
  inspect!(
    Json::Array([Json::String("Hello World")]).item(1).bind(@json.as_string),
    content="None",
  )
  inspect!(
    Json::Array([Json::String("Hello World")]).item(0).bind(@json.as_number),
    content="None",
  )
  inspect!(
    Json::Object(
      Map::of([("key", Json::String("key")), ("value", Json::Number(100.0))]),
    )
    |> @json.as_array,
    content="None",
  )
}

test "get as object" {
  inspect!(
    Json::Null |> @json.as_object |> @option.map(Map::to_array),
    content="None",
  )
  inspect!(
    Json::True |> @json.as_object |> @option.map(Map::to_array),
    content="None",
  )
  inspect!(
    Json::False |> @json.as_object |> @option.map(Map::to_array),
    content="None",
  )
  inspect!(
    Json::Number(1.0) |> @json.as_object |> @option.map(Map::to_array),
    content="None",
  )
  inspect!(
    Json::String("Hello World") |> @json.as_object |> @option.map(Map::to_array),
    content="None",
  )
  inspect!(
    Json::Array([Json::String("Hello World")])
    |> @json.as_object
    |> @option.map(Map::to_array),
    content="None",
  )
  inspect!(
    Json::Object(
      Map::of([("key", Json::String("key")), ("value", Json::Number(100.0))]),
    )
    |> @json.as_object
    |> @option.map(Map::to_array),
    content=
      #|Some([("key", String("key")), ("value", Number(100.0))])
    ,
  )
  inspect!(
    Json::Object(
      Map::of([("key", Json::String("key")), ("value", Json::Number(100.0))]),
    )
    .value("key")
    .bind(@json.as_string),
    content=
      #|Some("key")
    ,
  )
  inspect!(
    Json::Object(
      Map::of([("key", Json::String("key")), ("value", Json::Number(100.0))]),
    )
    .value("value")
    .bind(@json.as_number),
    content="Some(100.0)",
  )
  inspect!(
    Json::Object(
      Map::of([("key", Json::String("key")), ("value", Json::Number(100.0))]),
    )
    .value("key")
    .bind(@json.as_number),
    content="None",
  )
  inspect!(
    Json::Object(
      Map::of([("key", Json::String("key")), ("value", Json::Number(100.0))]),
    )
    .value("asdf")
    .bind(@json.as_number),
    content="None",
  )
}

test "deep access" {
  let json = Json::Object(
    Map::of(
      [
        (
          "key",
          Json::Array(
            [
              Json::Number(1.0),
              Json::True,
              Json::Null,
              Json::Array([]),
              Json::Object(
                Map::of(
                  [
                    ("key", Json::String("value")),
                    ("value", Json::Number(100.0)),
                  ],
                ),
              ),
            ],
          ),
        ),
        ("null", Json::Null),
        ("bool", Json::False),
        ("obj", Json::Object({  })),
      ],
    ),
  )
  inspect!(json.value("null").bind(@json.as_null), content="Some(())")
  inspect!(
    json.value("key").bind(fn { array => array.item(2) }).bind(@json.as_null),
    content="Some(())",
  )
  inspect!(json.value("bool").bind(@json.as_bool), content="Some(false)")
  inspect!(
    json.value("key").bind(fn { array => array.item(1) }).bind(@json.as_bool),
    content="Some(true)",
  )
  inspect!(
    json.value("key").bind(@json.as_array),
    content=
      #|Some([Number(1.0), True, Null, Array([]), Object({"key": String("value"), "value": Number(100.0)})])
    ,
  )
  inspect!(
    json.value("key").bind(fn { array => array.item(3) }).bind(@json.as_array),
    content="Some([])",
  )
  inspect!(
    json
    .value("key")
    .bind(fn { array => array.item(4) })
    .bind(@json.as_object)
    .map(Map::to_array),
    content=
      #|Some([("key", String("value")), ("value", Number(100.0))])
    ,
  )
  inspect!(
    json.value("obj").bind(@json.as_object).map(Map::to_array),
    content="Some([])",
  )
}

test "stringify" {
  let json : Json = {
    "key": [1.0, true, Null, [], { "key": "value", "value": 100.0 }],
    "null": Null,
    "bool": false,
    "obj": {  },
  }
  inspect!(
    json.stringify(),
    content=
      #|{"key":[1.0,true,null,[],{"key":"value","value":100.0}],"null":null,"bool":false,"obj":{}}
    ,
  )

  // not mut once we have `try except else` syntax
  // we do come across issues like ParseError not unified with String
  let newjson = @json.parse!(json.stringify())
  match json {
    { "key": [_, _, _, _, { "value": Number(i) }, ..] } =>
      inspect!(i, content="100.0")
    _ => fail!("Failed to match the JSON")
  }
  @test.eq!(newjson, json)
}

test "stringify escape" {
  let json : Json = {
    "\b": "\"hello\"",
    "\n": "\n\r\t\x0C",
    "\\": "/",
    "\x1F": "\x01",
  }
  inspect!(
    json.stringify(),
    content=
      #|{"\b":"\"hello\"","\n":"\n\r\t\f","\\":"\/","\u001f":"\u0001"}
    ,
  )
  match @json.parse?(json.stringify()) {
    Err(e) => raise e
    Ok(newjson) => @test.eq!(newjson, json)
  }
}
