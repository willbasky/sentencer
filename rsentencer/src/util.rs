use serde::Deserialize;
use std::fs::read_to_string;
use std::process::Command;

pub fn read_lines(filename: &str) -> Vec<String> {
  read_to_string(filename)
      .unwrap()  // panic on possible file-reading errors
      .lines()  // split the string into an iterator of string slices
      .map(String::from)  // make each slice into a string
      .collect()  // gather them together into a vector
}

#[derive(Deserialize, Debug)]
pub struct Config {
  pub directory: String,
  pub input : String,
}

pub fn run_es_ru(source: &str) -> String {
  let output = Command::new("trans")
    .arg("es:ru")
    .arg("-dump")
    .arg(source)
    .output()
    .expect("Failed to execute command runEsRu");
  String::from_utf8_lossy(&output.stdout).to_string()
}

pub fn normalaizer(dump: &str) -> String {
  let left_index = dump.find('[').unwrap();

  let right_index = dump.rfind(']').unwrap();

  dump[left_index..right_index+1].to_string()

}
