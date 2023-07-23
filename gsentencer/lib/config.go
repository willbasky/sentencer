package config

import (
	"fmt"

	"github.com/BurntSushi/toml"
)

type Config struct {
	Directory string
	Input     string
}

func FetchConfig() Config {

	var conf Config

	_, err := toml.DecodeFile("content.toml", &conf)
	if err != nil {
		fmt.Println("DecodeFile return error")
		panic(err)
	}

	return conf
}
