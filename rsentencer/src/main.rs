mod util;

use util::*;
use std::{fs::{read_to_string, self}, thread::{self}};
use serde_json::Value;
// use std::collections::BTreeMap;

fn main() {
  let config_str =
    read_to_string("content.toml").unwrap();

  let conf: Config = toml::from_str(&config_str).unwrap();
  println!("{:?}",conf);

  let input_path: String = format!("{}/{}", conf.directory, conf.input);

  let source_lines: Vec<String> = read_lines(&input_path);

  let source_line_indexed = (1..=source_lines.len()).zip(source_lines);

  let mut await_translations = Vec::new();

  for (i,source) in source_line_indexed {

    await_translations.push(thread::spawn(move || -> _ {
      let mut translation: Vec<String> = Vec::new();
      translator(source, &mut translation);
      (i,translation)
    }))
  }

  let mut translations: Vec<(usize, Vec<String>)> = vec![];
  for trans in await_translations {
      let intermediate = trans.join().unwrap();
      translations.push(intermediate);
  }
  translations.sort();

  let mut result = Vec::new();

  for (_, ts) in translations  {
    for t in ts {
      result.push(t)
    }
  }

  let res = result.join("\n\n");

  fs::write("content/rust_test.txt", res).unwrap()

}

fn translator (source: String, translation: &mut Vec<String>) {
    let dump = run_es_ru(&source);
    let dump_normalized = normalaizer(&dump);
    parse_translation(dump_normalized, translation)
}

fn parse_translation(dump: String, translation: &mut Vec<String>) {
  let v: Value = serde_json::from_str(&dump).unwrap();

    if v[0].is_array() {
      let v_iter = v[0].as_array().unwrap();

      for arr in v_iter {
        let source = &arr[1];
        let target = &arr[0];
        if target.is_string() && source.is_string() {
          let s = source.as_str().unwrap().to_string();
          let t = target.as_str().unwrap().to_string();
          translation.push(format!("{}\n{}",s,t))
        }
      }
    }
}
