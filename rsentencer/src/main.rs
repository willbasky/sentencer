mod util;

use util::*;

use std::fs::{read_to_string, self};

use serde_json::Value;


fn main() {
  let config_str =
    read_to_string("content.toml").unwrap();

  let conf: Config = toml::from_str(&config_str).unwrap();
  println!("{:?}",conf);

  let input_path = format!("{}/{}", conf.directory, conf.input);

  let source_lines = read_lines(&input_path);

  let mut translation: Vec<String> = Vec::new();

  for source in source_lines {

    let dump = runEsRu(&source);
    let dump_normalized = normalaizer(&dump);

    let v: Value = serde_json::from_str(&dump_normalized).unwrap();

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
  let res = translation.join("\n\n");

  fs::write("content/rust_test.txt", res).unwrap()


}



