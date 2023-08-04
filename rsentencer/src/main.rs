mod util;

use util::*;
use std::{fs::{self}, thread::{self}};
use serde_json::Value;

fn main() {
  let conf: Config = fetch_config();

  let input_path: String = format!("{}/{}", conf.directory, conf.input);

  let source_lines: Vec<String> = read_lines(&input_path);

  let mut translations: Vec<(usize, Vec<String>)> = map_concurrently(source_lines);

  translations.sort();

  let res = flatten(translations);

  fs::write(output_path(conf), res).unwrap();
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

fn map_concurrently (source_lines: Vec<String>) -> Vec<(usize, Vec<String>)> {
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
  translations
}

